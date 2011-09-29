//
//  TheatersListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3TableViewProfileCell.h"
#import "TheatersListController.h"

/*** A cell for the TheatersListController ***************************************************/

@interface TheatersListCell: M3TableViewProfileCell

-(BOOL)features: (SEL)feature;

@end

@implementation TheatersListCell

-(BOOL)features: (SEL)feature;
{
  if(feature == @selector(image))
    return NO;
  
  return [super features: feature];
}

-(NSString*)detailText {
  NSString* theaterId = [self.model objectForKey: @"_uid"];
  
  if([self.tableViewController.url matches: @"/theaters/list/movie_id=(.*)"]) {
    NSString* movieId = $1;
    
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
      id time = [schedule objectForKey:@"time"];
      if(!time) continue;
      
      if([time isKindOfClass:[NSString class]])
        [parts addObject: time];
      else
        [parts addObject: [time stringWithFormat: @"HH:mm"]];
    }
    
    NSArray* sortedParts = [[parts uniq] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedParts componentsJoinedByString: @", "];
  }

  NSArray* movieIds = [app.chairDB movieIdsByTheaterId: theaterId];

  NSArray* movies = [[app.chairDB.movies valuesWithKeys: movieIds] pluck: @"title"];
  movies = [[movies uniq] sortedArrayUsingSelector:@selector(compare:)];
  movies = [movies mapUsingSelector:@selector(quote)];
  return [movies componentsJoinedByString: @", "];
}

@end

/*** The TheatersListController ***************************************************/

@implementation TheatersListController

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];
  
  if([self.url matches: @"/theaters/list/movie_id=(.*)"])
    self.keys = [app.chairDB theaterIdsByMovieId: $1];
  else
    self.keys = app.chairDB.theaters.keys;
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [TheatersListCell class];
}

-(NSDictionary*)modelWithKey:(id)key
{ 
  return [app.chairDB objectForKey: key andType: @"theaters"]; 
}

-(NSString*)sectionForKey: (id)key
{
  if(![self.url matches: @"/theaters/list/movie_id=(.*)"])
    return [super sectionForKey: key];

  // NSDictionary* movie = [app.chairDB.movies get: $1];
  return @"Aktuelles Programm";
}

// get url for indexPath
-(NSString*)urlWithKey: (id)key
{
  return _.join(@"/theaters/show/", key);
}

@end
