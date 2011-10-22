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
  self = [super init];
  
  NSArray* keys = nil;
  
  if([filter isEqualToString:@"new"]) {
    
    double limit = [[NSDate date]timeIntervalSince1970] - 14 * 24 * 3600;
    
    NSMutableArray* movie_ids = [NSMutableArray array];
    [app.chairDB.movies each:^(NSDictionary *movie, id movie_id) {
      NSNumber* cinema_start_date = [movie objectForKey:@"cinema-start-date"];
      M3AssertKindOf(cinema_start_date, NSNumber);
      
      if([cinema_start_date doubleValue] < limit)
        return;
      
      [movie_ids addObject: movie_id];
    }];
    
    keys = movie_ids; 
  }
  //  else if([filter isEqualToString:@"fav"]) {
  //  }
  else if([filter isEqualToString:@"art"]) {
    
    double limit = [[NSDate date]timeIntervalSince1970] - 10 * 365 * 24 * 3600; // ~10 years
    
    int year_limit = 1999;
    
    NSMutableArray* movie_ids = [NSMutableArray array];
    [app.chairDB.movies each:^(NSDictionary *movie, id movie_id) {
      NSNumber* cinema_start_date = [movie objectForKey:@"cinema-start-date"];
      M3AssertKindOf(cinema_start_date, NSNumber);
      
      if(cinema_start_date && [cinema_start_date doubleValue] < limit) {
        [movie_ids addObject: movie_id];
        return;
      }
      
      NSNumber* production_year = [movie objectForKey:@"production-year"];
      M3AssertKindOf(production_year, NSNumber);
      
      if(production_year && [production_year intValue] < year_limit) {
        [movie_ids addObject: movie_id];
        return;
      }
    }];
    keys = movie_ids; 
  }
  
  if(!keys)
    keys = [app.chairDB.movies keys];
  
  NSDictionary* groupedHash = [keys groupUsingBlock:^id(NSString* movie_id) {
    return [[movie_id substringToIndex:1]uppercaseString];
  }];
  
  NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
  
  for(NSArray* group in groups) {
    [self addSection: group.second 
         withOptions:_.hash(@"header", group.first, 
                            @"index", group.first)];
  }
  return self;
}

-(Class)cellClassForKey:(id)key
{ 
  return @"MoviesListCell"; 
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
  time = [NSNumber numberWithInt: [time intValue] - 6 * 2400];
  
  [self addSection: cellKeys 
       withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd.MM."])];
}

-(id)initWithTheaterFilter: (id)theater_id
{
  self = [super init];

  //
  // get all schedules for the theater
  NSArray* schedules = [app.chairDB schedulesByTheaterId: theater_id];
  
  {
    for(NSDictionary* schedule in schedules) {
      NSCParameterAssert([schedule isKindOfClass:[NSDictionary class]]);
      NSCParameterAssert([[schedule objectForKey: @"time"] isKindOfClass:[NSNumber class]]);
    }
  }
  
  //
  // build sections by date, remove old schedules, and combine schedules 
  // for the same movie into one record.
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  
  // group schedules by *day* into sectionsHash
  NSMutableDictionary* sectionsHash = [schedules groupUsingBlock:^id(NSDictionary* schedule) {
    NSNumber* time = [schedule objectForKey:@"time"];
    if([time intValue] < now) return @"old";
    
    time = [NSNumber numberWithInt: [time intValue] - 6 * 2400];
    return [time.to_date stringWithFormat:@"dd.MM."];
  }];
  
  [sectionsHash removeObjectForKey:@"old"];
  
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

-(id)cellClassForKey:(id)key
{ 
  return @"MoviesListFilteredByTheaterCell";
}

@end

/**** TheatersListDateSource **********************************/

@interface TheatersListDateSource: M3TableViewDataSource

@end

@implementation TheatersListDateSource

-(id)init
{
  self = [super init];
  
  NSDictionary* groupedHash = [app.chairDB.theaters.keys groupUsingBlock:^id(NSString* theater_id) {
    return [[theater_id substringToIndex:1]uppercaseString];
  }];
  
  NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
  
  for(NSArray* group in groups) {
    [self addSection: group.second 
         withOptions:_.hash(@"header", group.first, 
                            @"index", group.first)];
  }
  
  return self;
}

-(Class)cellClassForKey:(id)key
{ 
  return @"TheatersListCell";
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
  time = [NSNumber numberWithInt: [time intValue] - 6 * 2400];
  
  [self addSection: cellKeys 
       withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd.MM."])];
}

-(id)initWithMovieFilter: (id)movie_id
{
  self = [super init];
  
  //
  // get all schedules for the theater
  NSArray* schedules = [app.chairDB schedulesByMovieId: movie_id];
  
  {
    for(NSDictionary* schedule in schedules) {
      NSCParameterAssert([schedule isKindOfClass:[NSDictionary class]]);
      NSCParameterAssert([[schedule objectForKey: @"time"] isKindOfClass:[NSNumber class]]);
    }
  }
  
  //
  // build sections by date, remove old schedules, and combine schedules 
  // for the same movie into one record.
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  
  // group schedules by *day* into sectionsHash
  NSMutableDictionary* sectionsHash = [schedules groupUsingBlock:^id(NSDictionary* schedule) {
    NSNumber* time = [schedule objectForKey:@"time"];
    if([time intValue] < now) return @"old";
    
    time = [NSNumber numberWithInt: [time intValue] - 6 * 2400];
    return [time.to_date stringWithFormat:@"dd.MM."];
  }];
  
  [sectionsHash removeObjectForKey:@"old"];
  
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

-(id)cellClassForKey:(id)key
{ 
  return @"TheatersListFilteredByMovieCell";
}

@end


/**** TheatersListFilteredByMovieDataSource **********************************/

@interface SchedulesByTheaterAndMovieDataSource: M3TableViewDataSource
@end

@implementation SchedulesByTheaterAndMovieDataSource

-(id)initWithTheater: (NSString*)theater_id 
            andMovie: (NSString*)movie_id
{
  self = [super init];

  M3AssertKindOfAndSet(theater_id, NSString);
  M3AssertKindOfAndSet(movie_id, NSString);

  //
  // get all schedules for the theater and for the movie, and 
  // remove all schedules, that are in the past.
  NSArray* schedules = [app.chairDB schedulesByTheaterId: theater_id];
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

  schedules = [schedules selectUsingBlock:^BOOL(NSDictionary* schedule) {
    NSString* schedule_movie_id = [schedule objectForKey:@"movie_id"];
    if(![movie_id isEqualToString:schedule_movie_id]) return NO;
    
    NSNumber* time = [schedule objectForKey:@"time"];
    if([time intValue] < now) return NO;
    
    return YES;
  }];

  //
  // sort schedules
  schedules = [schedules sortByBlock:^id(NSDictionary* schedule) {
    return [schedule objectForKey:@"time"];
  }];
  
  
  
  NSString* header;
  if(schedules.count > 1) 
    header = [NSString stringWithFormat: @"%d Aufführungen", schedules.count];
  else
    header = @"Eine Aufführung";
  
  [self addSection: schedules
       withOptions: _.hash(@"header", header)];
  
  return self;
}

-(id)cellClassForKey:(id)key
{ 
  return @"ScheduleListCell";
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
{
  return [[[SchedulesByTheaterAndMovieDataSource alloc]initWithTheater:theater_id andMovie:movie_id]autorelease];
}

@end
