//
//  MoviesShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"
#import "AppDelegate.h"

@implementation MoviesShowController

-(id)init
{
  self = [super init];
  
  if(self)
    [app.chairDB on: @selector(updated) notify:self with:@selector(reload)];
  
  return self;
}

-(void)setUrl: (NSString *)url
{
  [super setUrl: url];
  
  if(!url) return;
  
  [url matches:@"/movies/show/(.*)"];
  self.model = [app.chairDB.movies get: $1];
  
  self.tableView.tableHeaderView = [self headerView];
}

-(void)setModel: (NSDictionary*)movie
{
  [super setModel: movie];
  
  id movie_id = [movie objectForKey:@"_uid"];
  self.dataSource = [M3DataSource theatersListFilteredByMovie: movie_id];
}

-(UIView*) headerView
{
  NSDictionary* movie = self.model;
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
    [actions addObject: _.array(@"Mehr...", 
                                [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/full"]
                                )];
    
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
  
  [pv setProfileURL: _.join(@"/movies/full/", [movie objectForKey:@"_uid"]) ];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}
@end
