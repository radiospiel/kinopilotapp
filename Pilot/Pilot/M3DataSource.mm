//
//  MovieList.m
//  M3
//
//  Created by Enrico Thierbach on 14.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"

#import "M3DataSource.h"
#import "M3TableViewDataSource.h"

@implementation M3DataSource
@end

/*** The datasource for MoviesList *******************************************/

@interface MoviesListDataSource: M3TableViewDataSource
@end

@implementation MoviesListDataSource

-(NSArray*)movieRecordsByFilter: (NSString*)filter
{
  if([filter isEqualToString:@"new"]) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval two_weeks_ago = now - 14 * 24 * 3600;

    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, movies.sortkey FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? AND cinema_start_date > ? "
                                "GROUP BY movies._id ",
                                [NSDate today],
                                [NSNumber numberWithInt: two_weeks_ago] 
            ];
  }
  else if([filter isEqualToString:@"art"]) {
    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, movies.sortkey FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? AND production_year < 1995 "
                                "GROUP BY movies._id ",
                                [NSDate today]
            ];
  }
  else {
    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, movies.sortkey FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id  "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? "
                                "GROUP BY movies._id ",
                                [NSDate today]
            ];
  }
}

-(id)initWithFilter:(NSString*)filter
{
  self = [super initWithCellClass: @"MoviesListCell"]; 

  NSArray* movies = [self movieRecordsByFilter: filter];
  if(movies.count > 0) {
    NSDictionary* groupedHash = [movies groupUsingBlock:^id(NSDictionary* movie) {
      // The movie_id is "m-<sortkey>", and the first character of the sortkey
      // "makes sense" for the index: this should be the first relevant 
      // letter from the movie title.
      return [M3TableViewDataSource indexKey: movie];
    }];
    
    NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
    
    for(NSArray* group in groups) {
      [self addSection: group.second 
           withOptions:_.hash(@"header", group.first, 
                              @"index", group.first)];
    }
  }
  
  return self;
}

@end

/**** MoviesListFilteredByTheaterDataSource **********************************/

@interface MoviesListFilteredByTheaterDataSource: M3TableViewDataSource
@end

@implementation MoviesListFilteredByTheaterDataSource

-(void)addSchedulesSection: (NSArray*)schedules
{
  NSArray* groupedByMovieId = [[schedules groupUsingKey:@"movie_id"] allValues];
  groupedByMovieId = [groupedByMovieId sortByBlock:^id(NSArray* schedules) {
    M3AssertKindOf(schedules, NSArray);
    return [schedules.first objectForKey:@"movie_id"];
  }];
  
  NSMutableArray* cellKeys = [NSMutableArray array];
  for(NSArray* schedules in groupedByMovieId) {
    schedules = [schedules sortByKey:@"movie_id"];
    
    NSDictionary* schedule = schedules.first;
    [cellKeys addObject: _.hash(@"movie_id", [schedule objectForKey:@"movie_id"], 
                                @"title", [schedule objectForKey:@"title"], 
                                @"image", [schedule objectForKey:@"image"], 
                                @"schedules", schedules)
    ];
  }
  
  NSNumber* time = [schedules.first objectForKey:@"time"];
  time = [NSNumber numberWithInt: time.to_i - 6 * 2400];
  
  [self addSection: cellKeys 
       withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd. MMM"])];
}

-(id)initWithTheaterFilter: (id)theater_id
{
  self = [super initWithCellClass: @"MoviesListFilteredByTheaterCell"]; 

  NSDictionary* theaters = [app.sqliteDB.theaters get: theater_id];
  theater_id = [theaters objectForKey:@"_id"];

  //
  // get all live schedules for the theater
  NSArray* schedules = [
      app.sqliteDB all: @"SELECT schedules.*, movies.title, movies.image "
                        "FROM schedules "
                        "INNER JOIN movies ON movies._id=schedules.movie_id "
                        "WHERE theater_id=? AND time>?", 
                        theater_id, 
                        [NSDate today]
  ];

  if(schedules.count == 0) return self;

  if(app.isFlk) {
    schedules = [schedules sortByBlock:^id(NSDictionary* dict) {
      return [dict objectForKey:@"time"];
    }];
    [self addSection: schedules];
  }
  else {
    // group schedules by *day* into sectionsHash
    NSMutableDictionary* sectionsHash = [schedules groupUsingBlock:^id(NSDictionary* schedule) {
      NSNumber* time = [schedule objectForKey:@"time"];
    
      time = [NSNumber numberWithInt: time.to_i - 6 * 2400];
      return [time.to_date stringWithFormat:@"dd.MM."];
    }];
  
    NSArray* sectionsArray = [sectionsHash allValues];
    sectionsArray = [sectionsArray sortedArrayUsingComparator:^NSComparisonResult(NSArray* schedules1, NSArray* schedules2) {
      NSNumber* time1 = [schedules1.first objectForKey:@"time"];
      NSNumber* time2 = [schedules2.first objectForKey:@"time"];
    
      return [time1 compare:time2];
    }];
  
    for(NSArray* schedules in sectionsArray) {
      M3AssertKindOf(schedules, NSArray);
      [self addSchedulesSection: schedules];
    }
  }

  return self;
}

@end

@implementation M3DataSource(M3Lists)

+(M3TableViewDataSource*) datasourceWithName: (NSString*)name 
                          andFallbackSection: (NSString*)fallbackSection
                                   fromBlock: (M3TableViewDataSource* (^)())block
{
  Benchmark(_.join("*** Building datasource ", name));
  
  M3TableViewDataSource* dataSource = block();
  if(dataSource.sections.count == 0)
    return [M3TableViewDataSource dataSourceWithSection: [fallbackSection componentsSeparatedByString:@","]];

  return dataSource; 
  // [self mixAdCellsIntoDataSource: dataSource];
}

+(M3TableViewDataSource*) datasourceWithName: (NSString*)name 
                                   fromBlock: (M3TableViewDataSource* (^)())block
{
  return [self datasourceWithName: name 
               andFallbackSection: @"EmptyListCell,EmptyListUpdateActionCell"
                        fromBlock: block];
}

+(M3TableViewDataSource*)moviesListWithFilter:(NSString *)filter
{
  return [self datasourceWithName: @"moviesListWithFilter" 
                        fromBlock: ^M3TableViewDataSource*() {
                          M3TableViewDataSource* ds;
                          ds = [[MoviesListDataSource alloc]initWithFilter:filter];
                          return [ds autorelease];
                        }];
}

+(M3TableViewDataSource*)moviesListFilteredByTheater:(id)theater_id
{
  return [self datasourceWithName: @"moviesListFilteredByTheater" 
                        fromBlock: ^M3TableViewDataSource*() {
                          M3TableViewDataSource* ds;
                          ds = [[MoviesListFilteredByTheaterDataSource alloc]initWithTheaterFilter: theater_id];
                          return [ds autorelease];
                        }];
}

@end
