#import "DashboardController.h"

//
//  DashboardController.m
//  M3
//
//  Created by Enrico Thierbach on 30.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "VicinityShowController.h"
#import "M3TableViewProfileCell.h"
#import "AppDelegate.h"
#import "M3.h"

#define NUMBER_OF_THEATERS    12
#define SCHEDULES_PER_THEATER 6

/*** VicinityShowController cells *******************************************/

@interface DashboardInfoCell: M3TableViewCell {
  BOOL rightAligned_;
}

@end

@implementation DashboardInfoCell

-(id)initWithLabel: (NSString*)label
     andBackground: (NSString*)imageName
{ 
  self = [super init];
  if(self) {
    rightAligned_ = NO;
  }

  return self;
}

+(CGFloat)fixedHeight
{
  return 90;
}

-(void)setLabel: (NSString*)label
{
  self.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:24];
  self.textLabel.textColor = [UIColor colorWithName:@"ffffff"];
  self.textLabel.backgroundColor = [UIColor clearColor];
  self.textLabel.text = label;
}

-(void)setBackground: (NSString*)imageName
{
  UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
  [[self contentView] setBackgroundColor: background];
}

-(void)setKey: (NSString*)key
{
  [super setKey: key];
  
  if([key isEqualToString: @"city"]) {
    [self setLabel: @"Berlin"];
    self.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:36];
    [self setBackground: @"berlin.png"];
    self.url = @"/info";
  }
  else if([key isEqualToString: @"theaters"]) {
    rightAligned_ = YES;

    [self setLabel: [NSString stringWithFormat:@"%d Kinos", app.chairDB.theaters.count]];
     [self setBackground: @"cinemas.png"];
    self.url = @"/theaters/list";
  }
  else if([key isEqualToString: @"movies"]) {
    rightAligned_ = YES;
    
    [self setLabel: [NSString stringWithFormat:@"%d Filme", app.chairDB.movies.count]];
    [self setBackground: @"movies.png"];
    self.url = @"/movies/list";
  }
  else if([key isEqualToString: @"vicinity"]) {
    // rightAligned_ = YES;
    
    [self setLabel: [NSString stringWithFormat:@"%d Aufführungen nearby", app.chairDB.movies.count]];
    // [self setLabel2: [NSString stringWithFormat:@"in der Nähe", app.chairDB.movies.count]];
    [self setBackground: @"traffic.png"];
    self.url = @"/vicinity/show";
  }
  else if([key isEqualToString: @"news"]) {
    // rightAligned_ = YES;
    
    [self setLabel: @"News"];
    // [self setLabel2: [NSString stringWithFormat:@"in der Nähe", app.chairDB.movies.count]];
    [self setBackground: @"movies.png"];
    self.url = @"http://www.moviepilot.de";
  }
  else if([key isEqualToString: @"moviepilot"]) {
    // rightAligned_ = YES;
    
    [self setLabel: @"Danke moviepilot!"];
    // [self setLabel2: [NSString stringWithFormat:@"in der Nähe", app.chairDB.movies.count]];
    [self setBackground: @"berlin.png"];
    self.url = @"http://www.moviepilot.de";
  }
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  if(rightAligned_) {
    CGRect frame = self.textLabel.frame;
    CGSize sz = [self.textLabel sizeThatFits: frame.size];

    self.textLabel.frame = CGRectMake(320 - frame.origin.x - sz.width, frame.origin.y,
                                      sz.width, frame.size.height);
  }
}

@end

/*** The datasource for MoviesList *******************************************/

@interface DashboardDataSource: M3TableViewDataSource {
  CLLocationCoordinate2D currentPosition_;
}

-(double) distanceToTheater:(NSDictionary*) theater;

@end

@implementation DashboardDataSource

-(id)init
{
  self = [super init];
  if(!self) return nil;

  [self addSection: _.array(@"city", @"theaters", @"movies", @"vicinity", @"news", @"moviepilot") 
       withOptions: nil];

#if 0
  currentPosition_ = [M3LocationManager coordinates];
  
  Benchmark(@"Building vicinity data set");

  //
  // Time range: we'll show all schedules in the next 2 hours, i.e. less than
  // *then*. If we'll then have less than 6 (schedulesPerTheater) schedules 
  // (i.e. Arthouse cinema), we include schedules until we have those, if 
  // these are in the next 12 hours (i.e. before *then_max*.
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSTimeInterval then = now + 2 * 3600;
  NSTimeInterval then_max = now + 12 * 3600;

  //
  NSArray* theaters = [app.chairDB.theaters.values sortByBlock:^id(NSDictionary* theater) {
    return [NSNumber numberWithDouble: [self distanceToTheater: theater]];
  }];
  
  for(NSDictionary* theater in theaters) {
    if(self.sections.count >= NUMBER_OF_THEATERS) break;
    
    NSString* theater_id = [theater objectForKey:@"_uid"];
    
    NSArray* schedules = [[app.chairDB.schedules_by_theater_id get: theater_id] objectForKey: @"group"];
    M3AssertKindOf(schedules, NSArray);

    if(!schedules) continue;
    
    schedules = [schedules selectUsingBlock:^BOOL(NSDictionary* schedule) {
      NSNumber* timeAsNumber = [schedule objectForKey: @"time"];
      double time = [timeAsNumber doubleValue];
      
      return time > now && time < then_max;
    }];
    
    schedules = [schedules sortByKey: @"time"];
    
    NSMutableArray* schedulesCloseToNow = [NSMutableArray array];
    for(NSDictionary* schedule in schedules) {
      NSNumber* timeAsNumber = [schedule objectForKey: @"time"];
      double time = [timeAsNumber doubleValue];

      // This schedule is between then and then_max? Add only if we
      // don't have SCHEDULES_PER_THEATER schedules collected yet.
      if(time > then) {
        if(schedulesCloseToNow.count >= SCHEDULES_PER_THEATER)
          break;
      }
      [schedulesCloseToNow addObject:schedule];
    }
    
    // Add this section. 
    if(schedulesCloseToNow.count == 0) continue;

    [schedulesCloseToNow addObject: theater];
    
    NSString* header = [NSString stringWithFormat:@"%@ (%.1f km)", 
                          [theater objectForKey:@"name"], 
                          [self distanceToTheater: theater]
                       ];
    [self addSection: schedulesCloseToNow
         withOptions: _.hash(@"header", header)];
  }
#endif

  return self;
}

-(id)cellClassForKey:(id)key
{ 
  return [DashboardInfoCell class];
}

/* Distance from current position to [lat2,lng2] */

static double distance(double lat1, double lng1, double lat2, double lng2) 
{
#define PI_DIVIDED_BY_180   0.0174532925199
#define DEG_TO_RAD(deg)     deg * PI_DIVIDED_BY_180
#define RADIUS              6371
  
  lat1 = DEG_TO_RAD(lat1);
  lng1 = DEG_TO_RAD(lng1);
  
  lat2 = DEG_TO_RAD(lat2);
  lng2 = DEG_TO_RAD(lng2);
  
  double x = (lng2-lng1) * cos((lat1+lat2)/2);
  double y = (lat2-lat1);
  
  return sqrt(x*x + y*y) * RADIUS;
}

-(double) distanceToTheater:(NSDictionary*) theater
{
  NSArray* latlong = [theater objectForKey:@"latlong"];
  
  NSNumber* lat = latlong.first;
  NSNumber* lng = latlong.second;
  
  M3AssertKindOf(lat, NSNumber);
  M3AssertKindOf(lng, NSNumber);
  
  return distance(currentPosition_.latitude, currentPosition_.longitude, 
                         [lat floatValue], [lng floatValue]);
}

@end

@implementation DashboardController

-(id)init
{
  self = [super init];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched; 
  return self;
}

-(void)reload
{
  self.dataSource = [[[DashboardDataSource alloc]init]autorelease];
}

-(BOOL)isFullscreen
{
  return YES;
}
@end
