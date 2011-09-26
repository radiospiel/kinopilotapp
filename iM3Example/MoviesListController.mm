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

@implementation MoviesListController

-(NSArray*)keys
{
  return app.chairDB.movies.keys;
}

-(NSDictionary*)modelWithKey:(id)key
{ 
  NSLog(@"modelWithKey: %@", key);
  
  return [app.chairDB objectForKey: key andType: @"movies"]; 
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [M3TableViewProfileCell class];
}

// get url for indexPath
-(NSString*)urlWithKey: (id)key
{ 
  return _.join(@"/movies/show/", key); 
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view from its nib.
  [self addSegment: @"all" withURL: @"/movies/list/all"];
  [self addSegment: @"new" withURL: @"/movies/list/new"];
  [self addSegment: @"hot" withURL: @"/movies/list/hot"];
  [self addSegment: @"fav" withURL: @"/movies/list/fav"];
  [self addSegment: @"art" withURL: @"/movies/list/fav"];
  
  [self showSegmentedControl];
}

@end
