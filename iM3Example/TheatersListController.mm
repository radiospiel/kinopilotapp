//
//  TheatersListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3.h"
#import "M3TableViewProfileCell.h"
#import "TheatersListController.h"

/*** A cell for the TheatersListController ***************************************************/

@interface TheatersListCell: M3TableViewProfileCell
@end

@implementation TheatersListCell

-(void)setKey: (id)theater_id
{
  [super setKey:theater_id];
  
  NSDictionary* theater = [app.chairDB.theaters get: theater_id];
  theater = [app.chairDB adjustTheaters: theater];
  
  // [self setStarred:YES];
  [self setText: [theater objectForKey: @"name"]];

  NSArray* movieIds = [app.chairDB movieIdsByTheaterId: theater_id];
  NSArray* movies = [[app.chairDB.movies valuesWithKeys: movieIds] pluck: @"title"];
  movies = [movies.uniq.sort mapUsingSelector:@selector(quote)];
  [self setDetailText: [movies componentsJoinedByString: @", "]];
}

-(NSString*)url 
{
  NSString* theater_id = self.key;
  
  TheatersListController* tlc = (TheatersListController*)self.tableViewController;
  M3AssertKindOf(tlc, TheatersListController);

  if(!tlc.movie_id)
    return _.join(@"/movies/list?theater_id=", theater_id);

  return _.join(@"/schedules/list?theater_id=", theater_id, @"&movie_id=", tlc.movie_id);
}

@end

// --- TheatersListFiltered ----------------------------------------------

@interface TheatersListFilteredByMovieCell: TheatersListCell
@end

@implementation TheatersListFilteredByMovieCell

-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  //
  // Example key
  //
  // 
  // {
  //   theater_id: "...", 
  //   schedules: [
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 16:15:00 +0000>, version: "omu"}, 
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 14:00:00 +0000>, version: "omu"}, 
  //     ...
  //   ]
  // }
  
  NSDictionary* theater = [key joinWith: app.chairDB.theaters on: @"theater_id"];
  theater = [app.chairDB adjustMovies: theater];
  
  [self setText: [theater objectForKey: @"name"]];
  
  NSArray* schedules = [theater objectForKey:@"schedules"];
  schedules = [schedules sortByKey:@"time"];
  
  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];
}

-(NSString*)url 
{
  NSString* theater_id = [self.key objectForKey: @"theater_id"];

  TheatersListController* tlc = (TheatersListController*)self.tableViewController;
  M3AssertKindOf(tlc, TheatersListController);

  if(!tlc.movie_id)
    return _.join(@"/movies/list?theater_id=", theater_id);

  return _.join(@"/schedules/list?theater_id=", theater_id, @"&movie_id=", tlc.movie_id);
}

@end

/*** The TheatersListController ***************************************************/

@implementation TheatersListController

-(NSString*)title
{
  NSDictionary* movie = [app.chairDB.movies get: self.movie_id];
  return [movie objectForKey:@"title"];
}

-(NSString*) movie_id
{
  return [self.url.to_url param: @"movie_id"];
}

-(UIView*) headerView
{
  NSString* movie_id = [self movie_id];
  if(!movie_id) return nil;

  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  if(!movie) return nil;

  M3ProfileView* pv = [[[M3ProfileView alloc]init]autorelease];
  
  // -- set desription

  {
    NSString* title =           [movie objectForKey:@"title"];
    NSNumber* runtime =         [movie objectForKey:@"runtime"];
    NSArray* genres =           [movie objectForKey:@"genres"];
    NSNumber* production_year = [movie objectForKey:@"production-year"];

    NSMutableArray* parts = [NSMutableArray array];
    [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title]];
    
    if(genres.first || production_year || runtime) {
      NSMutableArray* p = [NSMutableArray array];
      if(genres.first) [p addObject: genres.first];
      if(production_year) [p addObject: production_year];
      if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
      
      [parts addObject: @"<p>"];
      [parts addObject: [p componentsJoinedByString:@", "]];
      [parts addObject: @"</p>"];
    }
    
    [pv setHtmlDescription: [parts componentsJoinedByString:@""]];
  }
  
  // -- set actions
  
  {
    NSMutableArray* actions = _.array();
    
    // add full info URL
    [actions addObject: _.array(@"Mehr...", _.join(@"/movies/show?movie_id=", movie_id))];
    
    // add imdb URL
    NSString* title =           [movie objectForKey:@"title"];

    NSString* imdbURL = _.join(@"imdb:///find?q=", title.urlEscape);
    if(![app canOpen:imdbURL])
      imdbURL = _.join(@"http://imdb.de/?q=", title.urlEscape);
    
    [actions addObject: _.array(@"IMDB", imdbURL)];
    
    [pv setActions: actions];
  }
  
  // -- add an image view
  
  {
    NSArray* images = [movie objectForKey:@"images"];
    [pv setImageURLs: [images pluck:@"thumbnail"]];
  }

  // --- set profile URL
  
  [pv setProfileURL: _.join(@"/movies/show?movie_id=", movie_id) ];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

-(void)loadFromUrl:(NSString*)url
{
  if(!url) {
    self.dataSource = nil;
    return;
  }

  NSString* movie_id = [url.to_url param: @"movie_id"];
    
  self.dataSource = !movie_id ? [M3DataSource theatersList] :
    [M3DataSource theatersListFilteredByMovie:movie_id];
  
  self.tableView.tableHeaderView = [self headerView];
}

@end
