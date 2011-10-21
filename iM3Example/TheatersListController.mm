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

  self.url = [NSString stringWithFormat: @"/theaters/show/%@", self.key];
}

@end

// --- TheatersListFiltered ----------------------------------------------

@interface TheatersListFilteredByMovieCell: M3TableViewProfileCell
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

  self.url = [NSString stringWithFormat: @"/theaters/show/%@", [self.key objectForKey: @"theater_id"]];
}

@end

/*** The TheatersListController ***************************************************/

@implementation TheatersListController

-(void)loadFromUrl:(NSString*)url
{
  if(!url)
    self.dataSource = nil;
  else if([url matches: @"/theaters/list/movie_id=(.*)"])
    self.dataSource = [M3DataSource theatersListFilteredByMovie:$1]; 
  else
    self.dataSource = [M3DataSource theatersList];
}

-(NSString*)title
{
  return @"Kinos in Berlin";
}

@end
