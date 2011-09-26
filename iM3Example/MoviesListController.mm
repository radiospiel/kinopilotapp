//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesListController.h"
#import "M3TableViewProfileCell.h"
#import "M3TableViewAdCell.h"

@implementation MoviesListController

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];
  
  if([url matches: @"/movies/list/theater_id=(.*)"])
    self.keys = [app.chairDB movieIdsByTheaterId: $1.to_number];
  else
    self.keys = app.chairDB.movies.keys;
}

-(NSDictionary*)modelWithKey:(id)key
{ 
  if(!key) return nil;
  if([key isKindOfClass: [NSNull class]]) return nil;

  return [app.chairDB objectForKey: key andType: @"movies"]; 
}

// get url for indexPath
-(NSString*)urlWithKey: (id)key
{ 
  if(!key) return nil;
  if([key isKindOfClass: [NSNull class]]) return nil;
  
  return _.join(@"/movies/show/", key); 
}

- (void)viewDidLoad
{
  [super viewDidLoad];

//  // Do any additional setup after loading the view from its nib.
//  [self addSegment: @"all" withURL: @"/movies/list/all"];
//  [self addSegment: @"new" withURL: @"/movies/list/new"];
//  [self addSegment: @"hot" withURL: @"/movies/list/hot"];
//  [self addSegment: @"fav" withURL: @"/movies/list/fav"];
//  [self addSegment: @"art" withURL: @"/movies/list/fav"];
//  
//  [self showSegmentedControl];
}

@end
