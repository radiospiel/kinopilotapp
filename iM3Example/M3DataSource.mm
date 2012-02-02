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

    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, GROUP_CONCAT(DISTINCT theaters.name) AS theaters FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? AND cinema_start_date > ? "
                                "GROUP BY movies._id ",
                                [NSDate today],
                                [NSNumber numberWithInt: two_weeks_ago] 
            ];
  }
  else if([filter isEqualToString:@"art"]) {
    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, GROUP_CONCAT(DISTINCT theaters.name) AS theaters FROM movies "
                                "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                "INNER JOIN theaters ON schedules.theater_id=theaters._id "
                                "WHERE schedules.time > ? AND production_year < 1995 "
                                "GROUP BY movies._id ",
                                [NSDate today]
            ];
  }
  else {
    return [ app.sqliteDB all: @"SELECT movies._id, movies.title, movies.image, GROUP_CONCAT(DISTINCT theaters.name) AS theaters FROM movies "
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
  
  if(schedules.count > 0) {
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

/**** TheatersListDataSource **********************************/

@interface TheatersListDataSource: M3TableViewDataSource

@end

@implementation TheatersListDataSource

-(id)initWithFilter: (NSString*)filter
{
  self = [super initWithCellClass: @"TheatersListCell"]; 
  
  NSString* sql = @"SELECT theaters._id, theaters.name, GROUP_CONCAT(DISTINCT movies.title) AS movies FROM theaters "
      "LEFT JOIN schedules ON schedules.theater_id=theaters._id "
      "LEFT JOIN movies ON schedules.movie_id=movies._id "
      "GROUP BY theaters._id ";
  
  if([filter isEqualToString:@"fav"]) {
    sql = @"SELECT theaters._id, theaters.name, GROUP_CONCAT(DISTINCT movies.title) AS movies FROM theaters "
      "INNER JOIN flags ON flags.key_id=theaters._id "
      "LEFT JOIN schedules ON schedules.theater_id=theaters._id "
      "LEFT JOIN movies ON schedules.movie_id=movies._id "
      "GROUP BY theaters._id ";
  }
  
  NSArray* theaters = [app.sqliteDB all: sql];

  if(theaters.count > 0) {
    
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

  [self prependSection:_.array(@"MovieShortActionsCell") withOptions:nil];
  
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

@implementation M3DataSource(M3Lists)

//+(M3TableViewDataSource*) mixAdCellsIntoDataSource: (M3TableViewDataSource*)dataSource 
//{
//  int sections_count = dataSource.sections.count;
//  if(sections_count < 10) return dataSource;
//
//  // insert up to 3 ad cells. 
//  int adCellsToInsert = 3;
//  
//  for(int i = 0; adCellsToInsert > 0 && i < sections_count; ++i) {
//    NSArray* section = [dataSource.sections objectAtIndex:i];
//    NSArray* keys = section.first;
//
//    // ad cells go only into sections with more than 5 entries.
//    if(keys.count < 5) continue;
//
//    // ad cells appear somewhere inbetween the section.
//    int adCellIndex = 1 + (rand() % (keys.count - 2));
//
//    [dataSource insertKey: @"M3TableViewAdCell"
//                  atIndex: adCellIndex
//              intoSection: i];
//    
//    adCellsToInsert--; // one less left to go.
//    i += 2; // skip next 3 sections.
//  }
//
//  return dataSource;
//}

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

+(M3TableViewDataSource*)theatersListFilteredByMovie:(id)movie_id
{
  return [self datasourceWithName: @"theatersListFilteredByMovie" 
                        fromBlock: ^M3TableViewDataSource*() {
                          M3TableViewDataSource* ds;
                          ds = [[TheatersListFilteredByMovieDataSource alloc]initWithMovieFilter: movie_id];
                          return [ds autorelease];
                        }];
}

+(M3TableViewDataSource*)theatersListWithFilter:(NSString *)filter
{
  NSString* fallbackSection = @"EmptyListCell,EmptyListUpdateActionCell";
  if([filter isEqualToString:@"fav"])
    fallbackSection = @"NoFavsCell";
  
  return [self datasourceWithName: @"theatersListWithFilter" 
               andFallbackSection: fallbackSection
                        fromBlock: ^M3TableViewDataSource*() {
                          M3TableViewDataSource* ds;
                          ds = [[TheatersListDataSource alloc]initWithFilter: filter];
                          return [ds autorelease];
                        }];
}

+(M3TableViewDataSource*)schedulesByTheater: (NSString*)theater_id 
                                   andMovie: (NSString*)movie_id
                                      onDay: (NSDate*)day
{
  M3AssertKindOfAndSet(theater_id, NSString);
  M3AssertKindOfAndSet(movie_id, NSString);
  M3AssertKindOf(day, NSDate);
 
  return [self datasourceWithName: @"schedulesByTheater:andMovie:onDay" 
                        fromBlock: ^M3TableViewDataSource*() {
                          M3TableViewDataSource* ds;
                          ds = [[SchedulesByTheaterAndMovieDataSource alloc]initWithTheater: theater_id 
                                                                                   andMovie: movie_id
                                                                                      onDay: day];
                          return [ds autorelease];
                        }];
}

@end
