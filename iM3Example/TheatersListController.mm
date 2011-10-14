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
  
  [self setStarred:YES];
  [self setText: [theater objectForKey: @"name"]];

  NSArray* movieIds = [app.chairDB movieIdsByTheaterId: theater_id];
  NSArray* movies = [[app.chairDB.movies valuesWithKeys: movieIds] pluck: @"title"];
  movies = [movies.uniq.sort mapUsingSelector:@selector(quote)];
  [self setDetailText: [movies componentsJoinedByString: @", "]];

  self.url = [NSString stringWithFormat: @"/theaters/show/%@", self.key];
}

@end

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
  return [TheatersListCell class]; 
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

/**** TheatersListFilteredByTheaterDataSource **************/

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
    id theater_id = [schedules.first objectForKey:@"theater_id"];
    [cellKeys addObject: _.hash(@"theater_id", theater_id, @"schedules", schedules)];
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
  // get all schedles for the movie
  
  NSArray* schedules = [app.chairDB schedulesByMovieId: movie_id];
  
  {
    for(NSDictionary* schedule in schedules) {
      NSCParameterAssert([schedule isKindOfClass:[NSDictionary class]]);
      NSCParameterAssert([[schedule objectForKey: @"time"] isKindOfClass:[NSNumber class]]);
    }
  }
  
  //
  // build sections by date, remove old schedules, and combine schedules 
  // for the same theater into one record.
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

-(Class)cellClassForKey:(id)key
{ 
  return [TheatersListFilteredByMovieCell class]; 
}

@end

/*** The TheatersListController ***************************************************/

@implementation TheatersListController

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];

  id dataSource;
  
  if([self.url matches: @"/theaters/list/movie_id=(.*)"])
    dataSource = [[TheatersListFilteredByMovieDataSource alloc]initWithMovieFilter:$1];
  else
    dataSource = [[TheatersListDateSource alloc]init];

  self.dataSource = [dataSource autorelease];
}

-(NSString*)title
{
  return @"Kinos in Berlin";
}

@end
