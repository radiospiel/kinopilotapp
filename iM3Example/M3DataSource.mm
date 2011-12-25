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

    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, GROUP_CONCAT(theaters.name) AS theaters FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? AND cinema_start_date > ? "
                                "GROUP BY movies._id ",
                                [NSDate today],
                                [NSNumber numberWithInt: two_weeks_ago] 
            ];
  }
  else if([filter isEqualToString:@"art"]) {
    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, GROUP_CONCAT(theaters.name) AS theaters FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? AND production_year < 1995 "
                                "GROUP BY movies._id ",
                                [NSDate today]
            ];
  }
  else {
    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, GROUP_CONCAT(theaters.name) AS theaters FROM movies "
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
  if(movies.count == 0) return nil;

  NSDictionary* groupedHash = [movies groupUsingBlock:^id(NSDictionary* movie) {
    // The movie_id is "m-<sortkey>", and the first character of the sortkey
    // "makes sense" for the index: this should be the first relevant 
    // letter from the movie title.
    NSString* movie_id = [movie objectForKey:@"_id"];
    NSString* index_key = [[movie_id substringWithRange:NSMakeRange(2, 1)] uppercaseString];
    if([index_key compare:@"A"] == NSOrderedAscending || [@"Z" compare: index_key] == NSOrderedAscending)
      return @"#";
    return index_key;
  }];
  
  NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
  
  for(NSArray* group in groups) {
    [self addSection: group.second 
         withOptions:_.hash(@"header", group.first, 
                            @"index", group.first)];
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
       withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd.MM."])];
}

-(id)initWithTheaterFilter: (id)theater_id
{
  self = [super initWithCellClass: @"MoviesListFilteredByTheaterCell"]; 

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
  
  if(schedules.count == 0) return nil;
  
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
  

  return self;
}

@end

/**** TheatersListDateSource **********************************/

@interface TheatersListDateSource: M3TableViewDataSource

@end

@implementation TheatersListDateSource

-(id)init
{
  self = [super initWithCellClass: @"TheatersListCell"]; 

  NSArray* theaters = [ 
    app.sqliteDB all: @"SELECT theaters._id, theaters.name, GROUP_CONCAT(movies.title) AS movies FROM theaters "
                       "INNER JOIN schedules ON schedules.theater_id=theaters._id "
                       "INNER JOIN movies ON schedules.movie_id=movies._id "
                       "WHERE schedules.time > ? "
                       "GROUP BY theaters._id ",
                       [NSDate today]
  ];

  
  if(theaters.count == 0) return nil;

  NSDictionary* groupedHash = [theaters groupUsingBlock:^id(NSDictionary* theater) {
    // The theater_id is "c-<sortkey>", and the first character of the sortkey
    // "makes sense" for the index: this should be the first relevant 
    // letter from the movie title.
    NSString* theater_id = [theater objectForKey:@"_id"];
    return [[theater_id substringWithRange:NSMakeRange(2, 1)] uppercaseString];
  }];
  
  NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
  
  for(NSArray* group in groups) {
    [self addSection: group.second 
         withOptions:_.hash(@"header", group.first, 
                            @"index", group.first)];
  }
  
  return self;
}

@end

/**** TheatersListFilteredByMovieDataSource **********************************/

@interface TheatersListFilteredByMovieDataSource: M3TableViewDataSource
@end

@implementation TheatersListFilteredByMovieDataSource

-(void)addSchedulesSection: (NSArray*)schedules
{
  NSArray* groupedByTheaterId = [[schedules groupUsingKey:@"theater_id"] allValues];
  groupedByTheaterId = [groupedByTheaterId sortByBlock:^id(NSArray* schedules) {
    M3AssertKindOf(schedules, NSArray);
    return [schedules.first objectForKey:@"theater_id"];
  }];
  
  NSMutableArray* cellKeys = [NSMutableArray array];
  for(NSArray* schedules in groupedByTheaterId) {
    schedules = [schedules sortByKey:@"theater_id"];
    
    id movie_id = [schedules.first objectForKey:@"theater_id"];
    [cellKeys addObject: _.hash(@"theater_id", movie_id, @"schedules", schedules)];
  }
  
  NSNumber* time = [schedules.first objectForKey:@"time"];
  time = [NSNumber numberWithInt: time.to_i - 6 * 2400];
  
  [self addSection: cellKeys 
       withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd.MM."])];
}

-(id)initWithMovieFilter: (id)movie_id
{
  self = [super initWithCellClass: @"TheatersListFilteredByMovieCell"];

  //
  // get all schedules for the theater
  NSArray* schedules = [
    app.sqliteDB all: @"SELECT * FROM schedules WHERE movie_id=? AND time>?", 
                      movie_id,
                      [NSDate today]
  ];

  //
  // build sections by date, and combine schedules 
  // for the same movie into one record.
  
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

  return self;
}

@end


/**** TheatersListFilteredByMovieDataSource **********************************/

@interface SchedulesByTheaterAndMovieDataSource: M3TableViewDataSource
@end

@implementation SchedulesByTheaterAndMovieDataSource

-(id)initWithTheater: (NSString*)theater_id 
            andMovie: (NSString*)movie_id
               onDay: (NSDate*)day
{
  self = [super initWithCellClass: @"ScheduleListCell"];
  
  M3AssertKindOf(day, NSDate);
  
  //
  // get all schedules for the theater and for the movie, and 
  // remove all schedules, that are in the past.
  NSArray* schedules = [
    app.sqliteDB all: @"SELECT * FROM schedules WHERE theater_id=? AND movie_id=? AND time > ? ORDER BY time", 
                      theater_id, 
                      movie_id,
                      day
  ];
  
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
    NSNumber* time = [schedules.first objectForKey:@"time"];
    [self addSection: schedules
         withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd.MM."])];
  }

  return self;
}

@end

@interface EmptyDataSource: M3TableViewDataSource
@end

@implementation EmptyDataSource

-(id)init 
{
  self = [super init];
  [self addSection: _.array(@"EmptyListCell", @"UpdateActionListCell") ];
  return self;
}

-(id) cellClassForKey: (id)key
{ 
  return key; 
}

@end

@implementation M3DataSource(M3Lists)

+(M3TableViewDataSource*)emptyDataSource
{
  return [[[EmptyDataSource alloc]init]autorelease];
}

+(M3TableViewDataSource*)moviesListWithFilter:(NSString *)filter
{
  M3TableViewDataSource* ds = [[[MoviesListDataSource alloc]initWithFilter:filter]autorelease];

  if(ds) return ds;
  return [self emptyDataSource];
}

+(M3TableViewDataSource*)moviesListFilteredByTheater:(id)theater_id
{
  M3TableViewDataSource* ds = [[[MoviesListFilteredByTheaterDataSource alloc]initWithTheaterFilter: theater_id]autorelease];
  
  if(ds) return ds;
  return [self emptyDataSource];
}

+(M3TableViewDataSource*)theatersListFilteredByMovie:(id)movie_id
{
  return [[[TheatersListFilteredByMovieDataSource alloc]initWithMovieFilter: movie_id]autorelease];
}

+(M3TableViewDataSource*)theatersList
{
  return [[[TheatersListDateSource alloc]init]autorelease];
}

+(M3TableViewDataSource*)schedulesByTheater: (NSString*)theater_id 
                                   andMovie: (NSString*)movie_id
                                      onDay: (NSDate*)day
{
  M3AssertKindOfAndSet(theater_id, NSString);
  M3AssertKindOfAndSet(movie_id, NSString);
  M3AssertKindOf(day, NSDate);
  
  return [[[SchedulesByTheaterAndMovieDataSource alloc]initWithTheater: theater_id 
                                                              andMovie: movie_id
                                                                 onDay: day]
          autorelease];
}

@end
