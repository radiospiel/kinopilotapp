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

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

-(NSString*)detailText {
  NSString* movieId = [self.model objectForKey: @"_uid"];
  NSArray* theaterIds = [app.chairDB theaterIdsByMovieId: movieId];
  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys: theaterIds] pluck: @"name"];
  theaters = [[theaters uniq] sortedArrayUsingSelector:@selector(compare:)];
  return [theaters componentsJoinedByString: @", "];
}

@end

/*** A cell for the MoviesListCell ***************************************************/

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListWithTheaterCell: M3TableViewProfileCell
@end

@implementation MoviesListWithTheaterCell

-(void)setModel:(NSDictionary*) theModel
{
  NSMutableDictionary* model = [theModel joinWith: app.chairDB.movies on:@"movie_id"];
  [app.chairDB adjustMovies:model];
  [super setModel:model];
}

-(NSString*)detailText {
  id time = [self.model objectForKey: @"time" ];
  
  NSString* time1;
  if([time isKindOfClass:[NSString class]])
    time1 = time;
  else
    time1 = [time stringWithFormat:@"HH:mm"];

  NSString* version = [self.model objectForKey: @"version"];
  if(version)
    version = _.join(@" (", version, @")");
  
  return _.join(time1, version);
}

@end

@implementation MoviesListController

-(NSString*)theaterFilter
{
  [self.url matches: @"/movies/list/theater_id=(.*)"];
  return $1;
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  if(![self theaterFilter]) 
    return [MoviesListCell class];

  return [MoviesListWithTheaterCell class];
}

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];
  
  NSString* theaterId = [self theaterFilter];
  
  if(!theaterId) {
    self.keys = app.chairDB.movies.keys;
    return;
  }

  self.keys = [app.chairDB movieIdsByTheaterId:theaterId];

  // Get all schedules for selected movie and theater. Note: 
  // this is an example of a schedules record:
  //
  // { 
  //    movie_id: "1376447749086599222", 
  //    theater_id: "1528225484148625008", 
  //    time: <NSTime: "2011-09-20T19:15:00+02:00">, 
  //    version: "omu"
  // }

  NSArray* schedules = [app.chairDB schedulesByTheaterId:  theaterId];
  
  //  {
  //    for(NSDictionary* schedule in schedules) {
  //      NSCParameterAssert([schedule isKindOfClass:[NSDictionary class]]);
  //      NSCParameterAssert([[schedule objectForKey: @"time"] isKindOfClass:[NSDate class]]);
  //    }
  //  }

  // build sections by date, and combine schedules for the same movie into one record.

  // group schedules by *date* into sectionsHash
  NSMutableDictionary* sectionsHash = [schedules groupUsingBlock:^id(NSDictionary* schedule) {
    DLOG(schedule);
    NSDate* time = [schedule objectForKey:@"time"];
    return [time stringWithFormat:@"dd.MM."];
  }];
  
  // build sections off sectionsHash; group schedules in section by name
  NSMutableArray* sections = [NSMutableArray array];
  [sectionsHash enumerateKeysAndObjectsUsingBlock:^(NSString* day, NSMutableArray* schedulesForDay, BOOL *stop) {
    NSMutableDictionary* schedulesGroupedByMovieId = [schedulesForDay groupUsingBlock:^id(NSDictionary* schedule) {
      return [schedule objectForKey:@"movie_id"];
    }];
    
    NSMutableArray* schedules = [NSMutableArray array];
    [schedulesGroupedByMovieId enumerateKeysAndObjectsUsingBlock:^(NSString* movieId, NSArray* schedulesForMovieId, BOOL *stop) {
      
      schedulesForMovieId = [schedulesForMovieId sortByKey:@"time"];
      
      NSArray* times = [schedulesForMovieId mapUsingBlock:^id(NSDictionary* schedule) {
        NSDate* time = [schedule objectForKey:@"time"];
        return [time stringWithFormat:@"HH:mm"];
      }];

      NSMutableDictionary* schedule = [NSMutableDictionary dictionaryWithDictionary: schedulesForMovieId.first];
      NSDate* day = [schedule objectForKey:@"time"];
      
      [schedule setObject: day forKey:@"day"];
      [schedule setObject: [times componentsJoinedByString:@", "] forKey:@"time"];
    
      [schedules addObject:schedule];
    }];
    
    [sections addObject:_.array(day, day, [schedules sortByKey:@"movie_id"])];
  }];

  
  // group and sort schedules in each section by movie title 

  // sort sections by time of first schedule
  self.sections = [sections sortedArrayUsingComparator:^NSComparisonResult(NSArray* section1, NSArray* section2) {
    NSDictionary* schedule1 = [[section1 objectAtIndex:2]objectAtIndex:0];
    NSDictionary* schedule2 = [[section2 objectAtIndex:2]objectAtIndex:0];

    
    NSDate* time1 = [schedule1 objectForKey:@"day"];
    NSDate* time2 = [schedule2 objectForKey:@"day"];
    
    return [time1 compare:time2];
  }];
  
  // DLOG(self.sections);
}

-(NSDictionary*)modelWithKey:(id)key
{ 
  if(!key) return nil;
  if([key isKindOfClass: [NSNull class]]) return nil;

  if([key isKindOfClass:[NSDictionary class]]) return key;
  
  return [app.chairDB objectForKey: key andType: @"movies"]; 
}

// get url for indexPath
-(NSString*)urlWithKey: (id)key
{ 
  if(!key) return nil;
  if([key isKindOfClass: [NSNull class]]) return nil;
  
  if([key isKindOfClass: [NSDictionary class]]) {
    key = [key objectForKey:@"movie_id"];
  }
    
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

