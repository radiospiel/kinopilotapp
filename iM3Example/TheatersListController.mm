//
//  TheatersListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3TableViewProfileCell.h"
#import "TheatersListController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"

/*** A cell for the TheatersListController ***************************************************/

@interface TheatersListCell: M3TableViewProfileCell
@end

@implementation TheatersListCell

-(void)setKey: (id)theater_id
{
  [super setKey:theater_id];
  
  NSDictionary* theater = [app.chairDB.theaters get: theater_id];
  
  [self setText: [theater objectForKey: @"name"]];

  NSArray* movieIds = [app.chairDB movieIdsByTheaterId: theater_id];
  NSArray* movies = [[app.chairDB.movies valuesWithKeys: movieIds] pluck: @"title"];
  movies = [movies.uniq.sort mapUsingSelector:@selector(quote)];
  [self setDetailText: [movies componentsJoinedByString: @", "]];
}

-(NSString*)url 
{
  NSString* theater_id = self.key;
  
  TheatersListController* tlc = (TheatersListController*)self.tableViewController;
  M3AssertKindOf(tlc, TheatersListController);

  if(!tlc.movie_id)
    return _.join(@"/movies/list?theater_id=", theater_id);

  return _.join(@"/schedules/list?theater_id=", theater_id, @"&movie_id=", tlc.movie_id);
}

@end

// --- TheatersListFiltered ----------------------------------------------

@interface TheatersListFilteredByMovieCell: TheatersListCell
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
  
  NSDictionary* theater = [key joinWith: app.chairDB.theaters on: @"theater_id"];
  
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

-(NSString*)title
{
  NSDictionary* movie = [app.chairDB.movies get: self.movie_id];
  return [movie objectForKey:@"title"];
}

-(NSString*) movie_id
{
  return [self.url.to_url param: @"movie_id"];
}

-(UIView*) headerView
{
  NSDictionary* movie = [app.chairDB.movies get: [self movie_id]];
  return [M3ProfileView profileViewForMovie:movie]; 
}

-(void)loadFromUrl:(NSString*)url
{
  NSString* movie_id = [url.to_url param: @"movie_id"];
  
  if(movie_id) {
    self.dataSource = [M3DataSource theatersListFilteredByMovie:movie_id];
    self.tableView.tableHeaderView = [self headerView];
  }
  else {
    self.dataSource = [M3DataSource theatersList];
    self.tableView.tableHeaderView = [self searchBar];
  }
}

@end
