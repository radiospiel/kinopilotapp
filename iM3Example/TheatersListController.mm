//
//  TheatersListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "M3TableViewProfileCell.h"
#import "TheatersListController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"

/*** A cell for the TheatersListController ***************************************************/

@interface TheatersListCell: M3TableViewProfileCell
@end

@implementation TheatersListCell

-(BOOL)theaterHasSchedules
{
  NSDictionary* theater = self.key;
  NSString* movies = [theater objectForKey: @"movies"];
  return [movies isKindOfClass:[NSString class]];
}

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

-(void)setKey: (NSDictionary*)theater
{
  [super setKey:theater];
  if(!theater) return;
  
  [super setFlagged: [app isFlagged: [self theater_id]]];
  
  [self setText: [theater objectForKey: @"name"]];

  NSString* movies = [theater objectForKey: @"movies"];
  if([self theaterHasSchedules]) {  // i.e. if it is not NSNull null
    [self setDetailText: [movies stringByReplacingOccurrencesOfString:@"," 
                                                           withString:@", "]
    ];
  }
  else {
    [self setDetailText: @"Für dieses Kino liegen uns keine Vorführungen vor."];
  }
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  if(![self theaterHasSchedules])
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
    
  return [super title];
}

-(NSString*) movie_id
{
  return [self.url.to_url param: @"movie_id"];
}

-(void)reloadURL
{
  NSString* movie_id = self.movie_id;
  
  if(movie_id) {
    [self setRightButtonWithSystemItem: UIBarButtonSystemItemAction
                                   url: _.join(@"/movie/actions?movie_id=", movie_id)];
  
    self.dataSource = [M3DataSource theatersListFilteredByMovie:movie_id];
    self.tableView.tableHeaderView = [M3ProfileView profileViewForMovie:[self movie]]; 

    return;
  }
  else {
    if(![self hasSegmentedControl]) {
      [self addSegment: @"Alle" 
            withFilter: @"all" 
              andTitle: @"Alle Kinos"];
      [self addSegment: [UIImage imageNamed:@"unstar15.png"] 
            withFilter: @"fav" 
              andTitle: @"Favorites"];
    }

    NSDictionary* params = self.url.to_url.params;
    NSString* filter = [params objectForKey: @"filter"];
    if(!filter) filter = @"all";
    self.dataSource = [M3DataSource theatersListWithFilter: filter];

    [self setSearchBarEnabled: YES];
  }
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
