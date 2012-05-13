//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"

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

@interface MoviesCalendarController: M3ListViewController
@end

@implementation MoviesCalendarController

-(NSString*)title
{
  return @"Kalender";
}

-(void)reloadURL
{
  self.dataSource = [M3DataSource moviesCalendar];
}

@end
