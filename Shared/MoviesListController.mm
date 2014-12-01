//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"

@interface MoviesListController: M3ListViewController

@property (readonly) NSString* theater_id;
@property (readonly) NSDictionary* theater;

@end

/*** Data sources for MoviesListController ************************************/

@interface MoviesListDataSource: M3TableViewDataSource
@end

@implementation MoviesListDataSource

-(id)initWithFilter:(NSString*)filter
{
  self = [super initWithCellClass: @"MoviesListCell"]; 
  
  // --- fetch movies ----------------------------------------------------------

  NSArray* movies;
  
  if([filter isEqualToString:@"new"]) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval two_weeks_ago = now - 14 * 24 * 3600;
    
    movies = [ app.sqliteDB all: @"SELECT movies.* FROM movies "
              "INNER JOIN schedules ON schedules.movie_id=movies._id "
              "INNER JOIN theaters ON schedules.theater_id=theaters._id "
              "WHERE schedules.time > ? AND cinema_start_date > ? "
              "GROUP BY movies._id "
              "ORDER BY sortkey ",
              [NSDate today],
              [NSNumber numberWithInt: two_weeks_ago] 
              ];
  }
  else if([filter isEqualToString:@"art"]) {
    movies = [ app.sqliteDB all: @"SELECT movies.* FROM movies "
              "INNER JOIN schedules ON schedules.movie_id=movies._id "
              "INNER JOIN theaters ON schedules.theater_id=theaters._id "
              "WHERE schedules.time > ? AND production_year < 1995 "
              "GROUP BY movies._id "
              "ORDER BY sortkey ",
              [NSDate today]
              ];
  }
  else {
    movies = [ app.sqliteDB all: @"SELECT movies.* FROM movies "
              "INNER JOIN schedules ON schedules.movie_id=movies._id  "
              "INNER JOIN theaters ON schedules.theater_id=theaters._id "
              "WHERE schedules.time > ? "
              "GROUP BY movies._id "
              "ORDER BY sortkey ",
              [NSDate today]
              ];
  }

  // --- group movies ----------------------------------------------------------

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
  
  {
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


/*** A cell for the MoviesListCell *******************************************/

@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

-(NSArray*)theaterNamesForMovie: (NSDictionary*)movie
{
  NSArray* theaters = [app.sqliteDB all: @"SELECT DISTINCT(theaters.name) FROM theaters "
                                          "INNER JOIN schedules ON schedules.theater_id=theaters._id "
                                          "WHERE schedules.movie_id=? AND schedules.time > ?", 
                                          [movie objectForKey: @"_id"],
                                          [NSDate today]];
  
  return [theaters mapUsingBlock:^id(NSDictionary* theater) { return [theater objectForKey:@"name"]; }];
}

-(void)setKey: (NSDictionary*)movie
{
  [super setKey:movie];
  if(!movie) return;

  [self setImageForMovie: movie];
  
  self.textLabel.text = [movie objectForKey: @"title"];
  
  NSArray* theaterNames = [self theaterNamesForMovie: movie];
  [self setDetailText: [theaterNames componentsJoinedByString: @", "]];

  self.url = _.join(@"/theaters/list?movie_id=", [movie objectForKey:@"_id"]);
}

@end

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListFilteredByTheaterCell: M3TableViewProfileCell

@end

@implementation MoviesListFilteredByTheaterCell

-(NSArray*)schedules
{
  return [self.key objectForKey:@"schedules"];
}

-(void)setKey: (NSDictionary*)movie
{
  [super setKey:movie];
  
  [self setImageForMovie: movie];
  self.textLabel.text = [movie objectForKey: @"title"];
  
  {
    NSArray* schedules = [self schedules];
    schedules = [schedules sortByKey:@"time"];

    schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
      NSString* time = [schedule objectForKey:@"time"];
      NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];

      return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
    }];

    [self setDetailText: [schedules componentsJoinedByString:@", "]];
  }
}

-(NSString*) url
{
  if(!self.tableViewController) return nil;
  MoviesListController* mlc = (MoviesListController*)self.tableViewController;

  NSDictionary* aSchedule = [self schedules].first;
  NSNumber* time = [aSchedule objectForKey:@"time"];

  return _.join(@"/schedules/list",
                @"?important=movie", 
                @"&day=", time.to_day.to_number,
                @"&theater_id=", mlc.theater_id, 
                @"&movie_id=", [self.key objectForKey: @"movie_id"]);
}
@end

/******************************************************************************/

@implementation MoviesListController

-(id)init
{
  self = [super init];

  [self addSegment: @"Alle" withFilter: @"all" andTitle: @"Alle Filme"];
  [self addSegment: @"Neu"  withFilter: @"new" andTitle: @"Neue Filme"];
  [self addSegment: @"Art"  withFilter: @"art" andTitle: @"Klassiker"];

  return self;
}

-(NSString*)title
{
  NSString* title = [self.theater objectForKey:@"name"];

  if(!title) title = [super title];
  if(!title) title = @"Filme";

  return title;
}

-(void)setFilter:(NSString*)filter
{
  if(self.theater_id) return;
  self.url = _.join(@"/movies/list?filter=", filter);
}

-(NSDictionary*)theater
{
  NSString* theater_id = self.theater_id;
  if(!theater_id) return nil;
  return [app.sqliteDB.theaters get: theater_id];
}

-(NSString*)theater_id
{
  return [self.url.to_url.params objectForKey:@"theater_id"];
}

-(void)reloadURL
{
  NSDictionary* params = self.url.to_url.params;

  M3TableViewDataSource* ds;
  
  if(self.theater_id) {
    [self setRightButtonReloadAction];
    
    ds = [[MoviesListFilteredByTheaterDataSource alloc]initWithTheaterFilter:[params objectForKey: @"theater_id"]];
    self.tableView.tableHeaderView = [M3ProfileView profileViewForTheater: self.theater]; 
  }
  else {
    NSString* filter = [params objectForKey: @"filter"];
    ds = [[MoviesListDataSource alloc]initWithFilter: filter];
    [self setSearchBarEnabled: YES];
  }
  
  self.dataSource = [ds autorelease];
}

@end
