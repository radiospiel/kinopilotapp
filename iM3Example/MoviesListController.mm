//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesListController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"

@interface M3TableViewProfileCell(MovieImage)
@end

@implementation M3TableViewProfileCell(MovieImage)

-(void)setImageForMovie: (NSString*)movie_id
{
  self.image = [UIImage imageNamed:@"no_poster.png"];

//  UIImage* image = [app.chairDB thumbnailForMovie:movie_id];
//  self.image = image ? image : [UIImage imageNamed:@"no_poster.png"];
}

@end

/*** A cell for the MoviesListCell *******************************************/

@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

-(void)setKey: (id)movie_id
{
  [super setKey:movie_id];

  [self setImageForMovie: movie_id];

  if(!movie_id) return;
  
  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  [self setText: [movie objectForKey: @"title"]];

  NSString* sql = 
  @"SELECT DISTINCT(name) FROM theaters, schedules ON theaters._id = schedules.theater_id WHERE schedules.movie_id=? LIMIT 6";
  
  NSArray* theaters = [[app.sqliteDB allArrays: sql, movie_id ] mapUsingSelector:@selector(first)];
  [self setDetailText: [theaters componentsJoinedByString: @", "]];

  self.url = _.join(@"/theaters/list?movie_id=", movie_id);
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
// {
//   movie_id: "howiendedthissummer|movies", 
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
  
  NSString* movie_id = [key objectForKey: @"movie_id"];
  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  
  [self setImageForMovie: movie_id];

  [self setText: [movie objectForKey: @"title"]];
  
  NSArray* schedules = [self schedules];
  schedules = [schedules sortByKey:@"time"];

  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];
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

//  [self addSegment: @"all" withFilter: @"all" andTitle: @"Alle Filme "];
//  [self addSegment: @"new" withFilter: @"new" andTitle: @"Neu im Kino"];
//  [self addSegment: @"art" withFilter: @"art" andTitle: @"Klassiker  "];

  // // [self addSegment: @"fav" withFilter: @"fav" andTitle: @"Vorgemerkt"];

  // [self activateSegment: 0];

  return self;
}

-(NSString*)title
{
  return [self.theater objectForKey:@"name"];
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

-(UIView*) headerView
{
  return [M3ProfileView profileViewForTheater: self.theater]; 
}

-(void)loadFromUrl:(NSString *)url
{
  NSDictionary* params = url.to_url.params;

  if(self.theater_id) {
    self.navigationItem.rightBarButtonItem = nil;
    
    self.dataSource = [M3DataSource moviesListFilteredByTheater:[params objectForKey: @"theater_id"]]; 
    self.tableView.tableHeaderView = [self headerView];
  }
  else {
    NSString* filter = [params objectForKey: @"filter"];
    self.dataSource = [M3DataSource moviesListWithFilter: (filter ? filter : @"all")];
    self.tableView.tableHeaderView = [self searchBar];
  }
}

@end
