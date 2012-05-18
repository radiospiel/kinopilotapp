//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"


/*** The datasource for MoviesCalendar *******************************************/

@interface MoviesCalendarDataSource: M3TableViewDataSource
@end

@implementation MoviesCalendarDataSource

-(id)init
{
  self = [super initWithCellClass: @"MoviesCalendarCell"];
  
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSTimeInterval one_week_later = now + 14 * 24 * 3600;
  
  NSArray* recs;
  recs = [ app.sqliteDB all: @"SELECT schedules.*, movies.title, movies.image, movies.sortkey, theaters.name AS theater_name FROM schedules "
          "INNER JOIN movies ON schedules.movie_id=movies._id "
          "INNER JOIN theaters ON schedules.theater_id=theaters._id "
          "WHERE schedules.time > ? AND schedules.time < ? ",
          [NSDate today],
          [NSNumber numberWithInt: one_week_later] 
          ];
  
  if(recs.count == 0) return self;
  
  NSDictionary* groupedHash = [recs groupUsingBlock:^id(NSDictionary* movie) {
    NSDate* date = [[movie objectForKey: @"time"] to_date];
    return [date to_day];
  }];
  
  NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
  
  for(NSArray* group in groups) {
    NSArray* movies = [group.second sortByBlock:^id(NSDictionary* movie) {
      return [movie objectForKey: @"time"];
    }];
    
    NSDate* day = group.first;
    [self addSection: movies 
         withOptions:_.hash(@"header", [day stringWithFormat:@"d. MMM"])];
  }
  
  return self;
}

@end

/*** A cell for the MoviesCalendarCell *******************************************/

@interface MoviesCalendarCell: M3TableViewProfileCell
@end

@implementation MoviesCalendarCell

-(void)setKey: (NSDictionary*)movie
{
  [super setKey:movie];
  if(!movie) return;

  [self setImageForMovie: movie];

  NSNumber* startTimeAsNumber = [movie objectForKey: @"time"];
  NSDate* startTime = startTimeAsNumber.to_date;
  NSString* title = [movie objectForKey: @"title"];
  
  [self setText:        [NSString stringWithFormat: @"%@ %@", [startTime stringWithFormat:@"HH:mm"], title] ];
  [self setDetailText:  [movie objectForKey: @"theater_name"]];
  
  self.url = _.join(@"/theaters/list?movie_id=", [movie objectForKey:@"movie_id"]);
}

@end

/*** The /movies/calendar controller ******************************************/

@interface MoviesCalendarController: M3ListViewController
@end

@implementation MoviesCalendarController

-(NSString*)title
{
  return @"Kalender";
}

-(void)reloadURL
{
  M3TableViewDataSource* ds = [[MoviesCalendarDataSource alloc]init];
  [ds addFallbackSectionIfNeeded];
  self.dataSource = [ds autorelease];
}

@end
