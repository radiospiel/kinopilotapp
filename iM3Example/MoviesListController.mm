//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "MoviesListController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"
#import "M3TableViewProfileCell.h"

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
  [self setText: [movie objectForKey: @"title"]];
  
  NSArray* theaterNames = [self theaterNamesForMovie: movie];
  [self setDetailText: [theaterNames componentsJoinedByString: @", "]];

  self.url = _.join(@"/theaters/list?movie_id=", [movie objectForKey:@"_id"]);
}

@end

/*** A cell for the MoviesListCell *******************************************/

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListFilteredByTheaterCell: M3TableViewProfileCell

@end

@implementation MoviesListFilteredByTheaterCell

//
// Example key
//
// 
//  {
//  "movie_id": "m-keinsexistauchkeinelosung",
//  "schedules": [
//                {
//                  "_id": "-jPSTvdgn5rg",
//                  "movie_id": "m-keinsexistauchkeinelosung",
//                  "theater_id": "c-alhambra",
//                  "time": 1323103500,
//                  "title": "Kein Sex ist auch keine Lösung",
//                  "version": null
//                },
//                {
//                  "_id": "-mr6wZc8nxLc",
//                  "movie_id": "m-keinsexistauchkeinelosung",
//                  "theater_id": "c-alhambra",
//                  "time": 1323112500,
//                  "title": "Kein Sex ist auch keine Lösung",
//                  "version": null
//                }
//                ],
//  "title": "Kein Sex ist auch keine Lösung"
//}


-(NSArray*)schedules
{
  return [self.key objectForKey:@"schedules"];
}

-(void)setKey: (NSDictionary*)movie
{
  [super setKey:movie];
  
  [self setImageForMovie: movie];
  [self setText: [movie objectForKey: @"title"]];
  
#if APP_FLK

  NSString* time = [movie objectForKey:@"time"];
  NSString* timeAsString = [time.to_date stringWithFormat:@"dd.MM. HH:mm"];

  [self setDetailText: timeAsString];

#else
  
  NSArray* schedules = [self schedules];
  schedules = [schedules sortByKey:@"time"];

  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];
#endif
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

#if APP_KINOPILOT
  [self addSegment: @"Alle" withFilter: @"all" andTitle: @"Alle Filme"];
  [self addSegment: @"Neu"  withFilter: @"new" andTitle: @"Neue Filme"];
  [self addSegment: @"Art"  withFilter: @"art" andTitle: @"Klassiker"];
#endif
  
  return self;
}

-(NSString*)title
{
  NSString* title = [self.theater objectForKey:@"name"];
  if(title) return title;
  
  return [super title];
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

  if(self.theater_id) {
    [self setRightButtonReloadAction];
    
    self.dataSource = [M3DataSource moviesListFilteredByTheater:[params objectForKey: @"theater_id"]]; 
    self.tableView.tableHeaderView = [M3ProfileView profileViewForTheater: self.theater]; 
  }
  else {
    NSString* filter = [params objectForKey: @"filter"];
    if(!filter) filter = @"all";
    self.dataSource = [M3DataSource moviesListWithFilter: filter];

    [self setSearchBarEnabled: YES];
  }
}

@end
