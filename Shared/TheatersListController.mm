//
//  TheatersListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"

@interface TheatersListController: M3ListViewController

@property (readonly) NSString* movie_id;
@property (readonly) NSDictionary* movie;

@end

/*** Datasources for TheatersListControllers *************************************************/


/**** TheatersListDataSource **********************************/

@interface TheatersListDataSource: M3TableViewDataSource

@end

@implementation TheatersListDataSource

-(id)initWithFilter: (NSString*)filter
{
  self = [super initWithCellClass: @"TheatersListCell"]; 
  
  if(app.isFlk) {
    NSString* sql =  @"SELECT theaters._id, theaters.name FROM theaters "
    "ORDER BY theaters.name ";
    
    NSArray* theaters = [app.sqliteDB all: sql];
    [self addSection: theaters];
  }
  
  if(app.isKinopilot) {
    NSString* sql;
    
    if([filter isEqualToString:@"fav"]) {
      sql =  @"SELECT theaters._id, theaters.name FROM theaters "
              "INNER JOIN flags ON flags.key_id=theaters._id "
              "LEFT JOIN schedules ON schedules.theater_id=theaters._id "
              "LEFT JOIN movies ON schedules.movie_id=movies._id "
              "GROUP BY theaters._id ";
    }
    else {
      sql =  @"SELECT theaters._id, theaters.name FROM theaters "
              "LEFT JOIN schedules ON schedules.theater_id=theaters._id "
              "LEFT JOIN movies ON schedules.movie_id=movies._id "
              "GROUP BY theaters._id ";
    }
    
    NSArray* theaters = [app.sqliteDB all: sql];
    
    if(theaters.count > 0) {
      
      NSDictionary* groupedHash = [theaters groupUsingBlock:^id(NSDictionary* theater) {
        return [M3TableViewDataSource indexKey: theater];
      }];
      
      NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
      
      for(NSArray* group in groups) {
        [self addSection: group.second 
             withOptions:_.hash(@"header", group.first, 
                                @"index", group.first)];
      }
    }
  }
  
  if([filter isEqualToString:@"fav"])
    [self addFallbackSectionIfNeeded: @"NoFavsCell" ];
  else
    [self addFallbackSectionIfNeeded ];

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
       withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd. MMM"])];
}

-(id)initWithMovieFilter: (id)movie_id
{
  self = [super initWithCellClass: @"TheatersListFilteredByMovieCell"];
  
  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  movie_id = [movie objectForKey:@"_id"];
  
  //
  // get all schedules for the theater
  NSArray* schedules;
  schedules = [ app.sqliteDB all: @"SELECT * FROM schedules WHERE movie_id=? AND time>?", 
                                  movie_id, [NSDate today] ];
  
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
  
  [self prependCellOfClass: @"MovieShortActionsCell" withKey: movie_id];
  
  return self;
}

@end


/*** A cell for the TheatersListController ***************************************************/

@interface TheatersListCell: M3TableViewProfileCell {
  BOOL hasSchedules;
}
@end

@implementation TheatersListCell

-(NSString*)theater_id
{
  NSDictionary* theater = self.key;
  return [theater objectForKey: @"_id"];
}

-(BOOL)onFlagging: (BOOL)isNowFlagged;
{
  [app setFlagged:isNowFlagged onKey: [self theater_id]];
  return isNowFlagged;
}

-(NSArray*)movieTitlesForTheater: (NSDictionary*)theater
{
  NSArray* movies = [app.sqliteDB all: @"SELECT DISTINCT(movies.title) FROM movies "
                                        "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                        "WHERE schedules.theater_id=? AND schedules.time > ?", 
                                        [theater objectForKey: @"_id"],
                                        [NSDate today]];
  
  return [movies mapUsingBlock:^id(NSDictionary* movie) { return [movie objectForKey:@"title"]; }];
}

-(void)setKey: (NSDictionary*)theater
{
  [super setKey:theater];
  if(!theater) return;
  
  if(app.isKinopilot) {
    [super setFlagged: [app isFlagged: [self theater_id]]];
  }
  
  [self setText: [theater objectForKey: @"name"]];

  NSArray* titles = [self movieTitlesForTheater: theater];
  hasSchedules = titles.count > 0;
  
  if(hasSchedules) {
    [self setDetailText: [titles componentsJoinedByString: @", "]];
  }
  else {
    [self setDetailText: @"Für dieses Kino liegen uns keine Vorführungen vor."];
  }
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  if(!hasSchedules)
    self.detailTextLabel.textColor = [UIColor grayColor];
}

-(NSString*)url 
{
  NSDictionary* theater = self.key;
  NSString* theater_id = [theater objectForKey: @"_id"];
  
  TheatersListController* tlc = (TheatersListController*)self.tableViewController;
  M3AssertKindOf(tlc, TheatersListController);

  if(tlc.movie_id)
    return _.join(@"/schedules/list?theater_id=", theater_id, @"&movie_id=", tlc.movie_id);

  // if(![self theaterHasSchedules])
  //   return nil;
  
  return _.join(@"/movies/list?theater_id=", theater_id);
}

@end

// --- TheatersListFiltered ----------------------------------------------

@interface TheatersListFilteredByMovieCell: M3TableViewProfileCell
@end

@implementation TheatersListFilteredByMovieCell

static CGFloat textHeight = 0, detailTextHeight = 0;

+(void)initialize {
  textHeight = [self.stylesheet fontForKey:@"h2"].lineHeight;
  detailTextHeight = [self.stylesheet fontForKey:@"detail"].lineHeight;
}

+ (CGFloat)fixedHeight
{ 
  return 2 + textHeight + detailTextHeight + 3; 
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  self.detailTextLabel.numberOfLines = 1;
}

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


-(NSArray*)schedules
{
  return [self.key objectForKey:@"schedules"];
}

-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  NSString* theater_id = [key objectForKey: @"theater_id"];
  
  NSDictionary* theater = [app.sqliteDB.theaters get: theater_id];
  
  [self setText: [theater objectForKey: @"name"]];
  
  NSArray* schedules = [self schedules];
  schedules = [schedules sortByKey:@"time"];
  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];
}

-(NSString*)url 
{
  NSString* theater_id = [self.key objectForKey: @"theater_id"];

  TheatersListController* tlc = (TheatersListController*)self.tableViewController;
  M3AssertKindOf(tlc, TheatersListController);
  M3AssertNotNil(tlc.movie_id);
  
  NSDictionary* aSchedule = [self schedules].first;
  NSNumber* time = [aSchedule objectForKey:@"time"];

  return _.join(@"/schedules/list?theater_id=", theater_id, 
                                 @"&movie_id=", tlc.movie_id,
                                 @"&day=", time.to_day.to_number);
  
}

@end

/*** The TheatersListController ***************************************************/

@implementation TheatersListController

-(NSDictionary*) movie
{
  return [app.sqliteDB.movies get: self.movie_id];
}

-(NSString*)title
{
  NSString* title = [self.movie objectForKey:@"title"];
  if(title) return title;
  
  return app.isFlk ? @"Freiluftkinos" : [super title];
}

-(NSString*) movie_id
{
  return [self.url.to_url param: @"movie_id"];
}

-(void)addSegmentedFilters
{
  if([self hasSegmentedControl]) return;
  
  [self addSegment: @"Alle" 
        withFilter: @"all" 
          andTitle: @"Alle Kinos"];
  [self addSegment: [UIImage imageNamed:@"unstar15.png"] 
        withFilter: @"fav" 
          andTitle: @"Favorites"];
}

-(void)reloadURL
{
  NSString* movie_id = self.movie_id;

  if(!movie_id && app.isKinopilot) {
    [self addSegmentedFilters];
    [self setSearchBarEnabled: YES];
  }

  M3TableViewDataSource* ds;
  
  if(movie_id) {
    [self setRightButtonWithSystemItem: UIBarButtonSystemItemAction
                                   url: _.join(@"/movie/actions?movie_id=", movie_id)];
  
    ds = [[TheatersListFilteredByMovieDataSource alloc] initWithMovieFilter: movie_id];
  }
  else {
    NSDictionary* params = self.url.to_url.params;
    NSString* filter = [params objectForKey: @"filter"];
    ds = [[TheatersListDataSource alloc]initWithFilter: filter];
  }

  [ds addFallbackSectionIfNeeded];
  self.dataSource = [ds autorelease];
}

-(void)setFilter:(NSString*)filter
{
  if(self.movie_id) return;
  
  if([filter isEqualToString:@"all"])
    self.url = _.join(@"/theaters/list");
  else    
    self.url = _.join(@"/theaters/list?filter=", filter);
}

@end
