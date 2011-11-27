//
//  MovieList.m
//  M3
//
//  Created by Enrico Thierbach on 14.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3DataSource.h"

@implementation M3DataSource
@end

/*** The datasource for MoviesList *******************************************/

@interface MoviesListDataSource: M3TableViewDataSource
@end

@implementation MoviesListDataSource

-(id)initWithFilter:(NSString*)filter
{
  self = [super initWithCellClass: @"MoviesListCell"]; 
  
  NSArray* movies = [ app.sqliteDB allArrays: @"SELECT _id FROM movies ORDER BY _id" ];
  NSArray* movie_ids = [movies mapUsingSelector:@selector(first)];
  
  NSDictionary* groupedHash = [movie_ids groupUsingBlock:^id(NSString* movie_id) {
    return [[movie_id substringWithRange:NSMakeRange(2, 1)]uppercaseString];
  }];
  
  NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
  
  for(NSArray* group in groups) {
    [self addSection: group.second 
         withOptions:_.hash(@"header", group.first, 
                            @"index", group.first)];
  }
  
  return self;

//  NSArray* keys = nil;
//  
//  if([filter isEqualToString:@"new"]) {
//    double limit = [[NSDate date]timeIntervalSince1970] - 14 * 24 * 3600;
//  }
//  else if([filter isEqualToString:@"art"]) {
//    double limit = [[NSDate date]timeIntervalSince1970] - 10 * 365 * 24 * 3600; // ~10 years
//  }
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
    
    id movie_id = [schedules.first objectForKey:@"movie_id"];
    [cellKeys addObject: _.hash(@"movie_id", movie_id, @"schedules", schedules)];
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
  // build sections by date, and combine schedules for the same movie into one record.
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

  //
  // get all live schedules for the theater
  NSArray* schedules = [
      app.sqliteDB all: @"SELECT * FROM schedules WHERE theater_id=? AND time>?", 
                        theater_id, 
                        [NSNumber numberWithInt: now]
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

  NSArray* theaters = [ app.sqliteDB allArrays: @"SELECT _id FROM theaters ORDER BY _id" ];
  NSArray* theater_ids = [theaters mapUsingSelector:@selector(first)];

  NSDictionary* groupedHash = [theater_ids groupUsingBlock:^id(NSString* theater_id) {
    return [[theater_id substringWithRange:NSMakeRange(2, 1)]uppercaseString];
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
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  
  NSArray* schedules = [
    app.sqliteDB all: @"SELECT * FROM schedules WHERE movie_id=? AND time>?", 
                      movie_id,
                      [NSNumber numberWithInt: now]
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
  
  NSUInteger start_of_day = day.to_number.to_i;
  // NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

  //
  // get all schedules for the theater and for the movie, and 
  // remove all schedules, that are in the past.
  NSArray* schedules = [
    app.sqliteDB all: @"SELECT * FROM schedules WHERE theater_id=? AND movie_id=? AND time BETWEEN ? AND ? ORDER BY time", 
                      theater_id, 
                      movie_id,
                      [NSNumber numberWithInt: start_of_day],
                      [NSNumber numberWithInt: start_of_day + 24 * 3600]
  ];
  
  NSString* header;
  if(schedules.count > 1) 
    header = [NSString stringWithFormat: @"%d Aufführungen", schedules.count];
  else
    header = @"Eine Aufführung";
  
  [self addSection: schedules
       withOptions: _.hash(@"header", header)];

  return self;
}

@end


@implementation M3DataSource(M3Lists)

+(M3TableViewDataSource*)moviesListWithFilter:(NSString *)filter
{
  return [[[MoviesListDataSource alloc]initWithFilter:filter]autorelease];
}

+(M3TableViewDataSource*)moviesListFilteredByTheater:(id)theater_id
{
  return [[[MoviesListFilteredByTheaterDataSource alloc]initWithTheaterFilter: theater_id]autorelease];
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
