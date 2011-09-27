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


/*** A cell for the MoviesListCell ***************************************************/

@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

// +(CGFloat) fixedHeight;
// {
//   return 120.0f;
// }
// 
-(NSString*)detailText {
  NSNumber* movieId = [self.model objectForKey: @"_uid"];

  if([self.tableViewController.url matches: @"/movies/list/theater_id=(.*)"]) {
    NSNumber* theaterId = $1.to_number;

    // Example schedule record:
    //
    // { movie_id: 1376447749086599222, 
    //   theater_id: 1528225484148625008, 
    //   time: "2011-09-20T19:15:00+02:00", 
    //   version: "omu"
    // }

    NSArray* schedules = [app.chairDB schedulesByMovieId: movieId andTheaterId: theaterId];

    NSMutableArray* parts = [NSMutableArray array];
    for(NSDictionary* schedule in schedules) {
      NSString* time = [schedule objectForKey:@"time"];
      if([time matches: @"(\\d+)-(\\d+)-(\\d+)T(\\d+):(\\d+)"])
        time = [NSString stringWithFormat: @"%@:%@", $4, $5];

      if([schedule objectForKey:@"version"])
        time = _.join(time, " (", [schedule objectForKey:@"version"], ")"); 

      [parts addObject: time];
    }

    NSArray* sortedParts = [[parts uniq] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedParts componentsJoinedByString: @", "];
  }

  NSArray* theaterIds = [app.chairDB theaterIdsByMovieId: movieId];
  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys: theaterIds] pluck: @"name"];
  theaters = [[theaters uniq] sortedArrayUsingSelector:@selector(compare:)];
  return [theaters componentsJoinedByString: @", "];
}

@end

@implementation MoviesListController

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];
  
  if([url matches: @"/movies/list/theater_id=(.*)"])
    self.keys = [app.chairDB movieIdsByTheaterId: $1.to_number];
  else
    self.keys = app.chairDB.movies.keys;

  if(self.keys.count > 12) {
    self.keys = [self.keys subarrayWithRange: NSMakeRange(0, 12)];
  }
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [MoviesListCell class];
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

