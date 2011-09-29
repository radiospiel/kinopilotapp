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

/*** A cell for the MoviesListCell *******************************************/

@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

-(void)setKey: (id)movie_id
{
  [super setKey:movie_id];
  
  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  movie = [app.chairDB adjustMovies: movie];
  
  [self setStarred:YES];
  [self setImageURL: [movie objectForKey: @"image"]];
  [self setText: [movie objectForKey: @"title"]];

  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys: theater_ids] pluck: @"name"];
  [self setDetailText: [theaters.uniq.sort componentsJoinedByString: @", "]];
}

-(NSString*)urlToOpen
{
  return [NSString stringWithFormat: @"/movies/full/%@", self.key];
}

@end

/*** The datasource for MoviesList *******************************************/

@interface MoviesListDataSource: M3TableViewDataSource
@end

@implementation MoviesListDataSource

-(id)init
{
  self = [super init];
  
  NSDictionary* groupedHash = [app.chairDB.movies.keys groupUsingBlock:^id(NSString* movie_id) {
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
  { return [MoviesListCell class]; }

@end


/*** A cell for the MoviesListCell ***************************************************/

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListFilteredByTheaterCell: M3TableViewProfileCell

@end

@implementation MoviesListFilteredByTheaterCell


-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  //
  // Example key
  //
  // 
  // {
  //   movie_id: "howiendedthissummer|movies", 
  //   schedules: [
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 16:15:00 +0000>, version: "omu"}, 
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 14:00:00 +0000>, version: "omu"}, 
  //     ...
  //   ]
  // }
  
  NSDictionary* movie = [key joinWith: app.chairDB.movies on: @"movie_id"];
  movie = [app.chairDB adjustMovies: movie];
  
  [self setImageURL: [movie objectForKey: @"image"]];
  [self setText: [movie objectForKey: @"title"]];
  
  NSArray* schedules = [movie objectForKey:@"schedules"];
  schedules = [schedules sortByKey:@"time"];
  
  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSDate* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time stringWithFormat:@"HH:mm"];
    
    NSString* version = [schedule objectForKey:@"version"];
    if(!version) return timeAsString;

    return [NSString stringWithFormat:@"%@ (%@)", timeAsString, version];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];
}

-(NSString*)urlToOpen
{
  return [NSString stringWithFormat: @"/movies/full/%@", [self.key objectForKey: @"movie_id"]];
}


@end

/**** MoviesListFilteredByTheaterDataSource **************/

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
  
  NSDate* time = [schedules.first objectForKey:@"time"];

  [self addSection: cellKeys 
       withOptions: _.hash(@"header", [time stringWithFormat:@"dd.MM."])];
}

-(id)initWithTheaterFilter: (id)theater_id
{
  self = [super init];
  
  //
  // get all schedles for the theater
  
  NSArray* schedules = [app.chairDB schedulesByTheaterId: theater_id];
  
  {
    for(NSDictionary* schedule in schedules) {
      NSCParameterAssert([schedule isKindOfClass:[NSDictionary class]]);
      NSCParameterAssert([[schedule objectForKey: @"time"] isKindOfClass:[NSDate class]]);
    }
  }
  
  //
  // build sections by date, and combine schedules for the same movie into one record.
  
  // group schedules by *day* into sectionsHash
  NSMutableDictionary* sectionsHash = [schedules groupUsingBlock:^id(NSDictionary* schedule) {
    NSDate* time = [schedule objectForKey:@"time"];
    return [time stringWithFormat:@"dd.MM."];
  }];
  
  NSArray* sectionsArray = [sectionsHash allValues];
  sectionsArray = [sectionsArray sortedArrayUsingComparator:^NSComparisonResult(NSArray* schedules1, NSArray* schedules2) {
    NSDate* time1 = [schedules1.first objectForKey:@"time"];
    NSDate* time2 = [schedules2.first objectForKey:@"time"];
    
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
  return [MoviesListFilteredByTheaterCell class]; 
}

@end


/******************************************************************************/

@implementation MoviesListController

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];

  if([self.url matches: @"/movies/list/theater_id=(.*)"])
    self.dataSource = [[MoviesListFilteredByTheaterDataSource alloc]initWithTheaterFilter:$1];
  else
    self.dataSource = [[MoviesListDataSource alloc]init];
}

@end

