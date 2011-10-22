//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesListController.h"

/*** A cell for the MoviesListCell *******************************************/

@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

-(void)setKey: (id)movie_id
{
  [super setKey:movie_id];
  
  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  movie = [app.chairDB adjustMovies: movie];
  
  // [self setStarred:YES];
  [self setImageURL: [movie objectForKey: @"image"]];
  [self setText: [movie objectForKey: @"title"]];

  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys: theater_ids] pluck: @"name"];
  [self setDetailText: [theaters.uniq.sort componentsJoinedByString: @", "]];

  self.url = [NSString stringWithFormat: @"/theaters/list?movie_id=%@", movie_id];
}

@end

/*** A cell for the MoviesListCell *******************************************/

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListFilteredByTheaterCell: M3TableViewProfileCell

@end

@implementation MoviesListFilteredByTheaterCell


-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  //
  // Example key
  //
  // 
  // {
  //   movie_id: "howiendedthissummer|movies", 
  //   schedules: [
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 16:15:00 +0000>, version: "omu"}, 
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 14:00:00 +0000>, version: "omu"}, 
  //     ...
  //   ]
  // }
  
  NSDictionary* movie = [key joinWith: app.chairDB.movies on: @"movie_id"];
  movie = [app.chairDB adjustMovies: movie];
  
  [self setImageURL: [movie objectForKey: @"image"]];
  [self setText: [movie objectForKey: @"title"]];
  
  NSArray* schedules = [movie objectForKey:@"schedules"];
  schedules = [schedules sortByKey:@"time"];
  
  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];

  // -- set URL for this cell.

  M3AssertKindOf(self.tableViewController, MoviesListController);
  
  if(!self.tableViewController) return;
  
  MoviesListController* mlc = (MoviesListController*)self.tableViewController;
  
  self.url = [NSString stringWithFormat: @"/schedules/list?theater_id=%@&movie_id=%@", 
                mlc.theater_id,
                [self.key objectForKey: @"movie_id"]
              ];
}

@end

/******************************************************************************/

@implementation MoviesListController

-(id)init
{
  self = [super init];

  // [self addSegment: @"new" withFilter: @"new" andTitle: @"Neu im Kino"];
  // [self addSegment: @"all" withFilter: @"all" andTitle: @"Alle Filme"];
  // [self addSegment: @"art" withFilter: @"art" andTitle: @"Klassiker"];
  // // [self addSegment: @"fav" withFilter: @"fav" andTitle: @"Vorgemerkt"];

  // [self activateSegment: 0];
  return self;
}

-(NSString*)title
{
  NSDictionary* theater = [app.chairDB.theaters get: self.theater_id];
  return [theater objectForKey:@"name"];
}

-(void)setFilter:(NSString*)filter
{
  if(self.theater_id) return;
  self.url = _.join(@"/movies/list?filter=", filter);
}

-(NSDictionary*)theater
{
  return [app.chairDB.theaters get: self.theater_id];
}

-(NSString*)theater_id
{
  if(!self.url) return nil;
  
  [self.url matches: @"/movies/list\\?theater_id=(.*)"];
  return $1;
}

-(UIView*) headerView
{
  NSDictionary* theater = self.theater;
  if(!theater) return nil;
  M3ProfileView* pv = [[[M3ProfileView alloc]init]autorelease];
  
  // -- set descriptions
  
  {
    NSMutableString* html = [NSMutableString string];
    
    NSString* name = [theater objectForKey:@"name"];
    [html appendFormat:@"<h2><b>%@</b></h2>", name.cdata];
    
    NSString* address = [theater objectForKey:@"address"];
    if(address)
      [html appendFormat: @"<p><b>Adresse:</b> %@</p>", address.cdata]; 
    
    [pv setHtmlDescription:html];
  }
  
  // -- set actions
  
  {
    NSMutableArray* actions = _.array();
    
    NSString* address = [theater objectForKey:@"address"];
    
    if(address)
      [actions addObject: _.array(@"Fahrinfo", _.join(@"fahrinfo-berlin://connection?to=", address.urlEscape))];
    
    NSString* fon = [theater objectForKey:@"telephone"];
    if(fon)
      [actions addObject: _.array(@"Fon", _.join(@"tel://", fon.urlEscape))];
    
    NSString* web = [theater objectForKey:@"website"];
    if(web)
      [actions addObject: _.array(@"Website", web)];
    
    [pv setActions: actions];
  }
  
  // -- add a map view
  
  {
    NSArray* latlong = [theater objectForKey:@"latlong"];
    [pv setCoordinate: CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue])];
  }  
  
  NSString* url = _.join(@"/map/show/theater_id=", [theater objectForKey:@"_uid" ]);
  
  [pv setProfileURL:url];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

-(void)loadFromUrl:(NSString *)url
{
  if(!url)
    self.dataSource = nil;
  else if([self.url matches: @"/movies/list\\?theater_id=(.*)"])
    self.dataSource = [M3DataSource moviesListFilteredByTheater:$1]; 
  else if([self.url matches: @"/movies/list\\?filter=(.*)"])
    self.dataSource = [M3DataSource moviesListWithFilter: $1];
  else
    self.dataSource = [M3DataSource moviesListWithFilter: @"new"];
  
  self.tableView.tableHeaderView = [self headerView];
}

@end
