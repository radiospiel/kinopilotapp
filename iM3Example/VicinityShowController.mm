//
//  VicinityShowController.m
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

/*** A cell for the VicinityShowController *******************************************/

@interface VicinityShowCell: M3TableViewCell
@end

@implementation VicinityShowCell

-(id)init
{ 
  self = [super initWithStyle: UITableViewCellStyleValue1]; 
  self.textLabel.font = [UIFont boldSystemFontOfSize:14];
  self.detailTextLabel.font = [UIFont systemFontOfSize:13];
  
  return self;
}

+(CGFloat)fixedHeight
{
  return 25;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect frame = self.textLabel.frame;
  frame.origin.x = 7;
  self.textLabel.frame = frame;
}

-(void)setKey: (NSDictionary*)schedule
{
  schedule = [schedule joinWith: app.chairDB.movies on:@"movie_id"];

  [super setKey:schedule];

  NSString* time = [schedule objectForKey: @"time"];
  
  
  self.textLabel.text = [time.to_date stringWithFormat: @"HH:mm"];
  self.detailTextLabel.text = [schedule objectForKey:@"title"];
  self.detailTextLabel.numberOfLines = 1;
}

-(NSString*)urlToOpen
{
  NSDictionary* schedule = self.key;
  
  // return [NSString stringWithFormat: @"/theaters/show/%@", [schedule objectForKey: @"theater_id"]];
  return [NSString stringWithFormat: @"/movies/full/%@", [schedule objectForKey: @"movie_id"]];
}

@end

/*** The datasource for MoviesList *******************************************/

@interface VicinityShowDataSource: M3TableViewDataSource {
  CLLocationCoordinate2D currentPosition_;
}

-(double) distanceToTheater:(NSDictionary*) theater;

@end

@implementation VicinityShowDataSource

-(id)initWithPosition: (CLLocationCoordinate2D) currentPosition
{
  self = [super init];
  if(!self) return nil;
  
  currentPosition_ = currentPosition;
  
  Benchmark(@"Building vicinity data set");

  //
  // Time range: we'll show all schedules in the next 2 hours, i.e. less than
  // *then*. If we'll then have less than 6 (schedulesPerTheater) schedules 
  // (i.e. Arthouse cinema), we include schedules until we have those, if 
  // these are in the next 12 hours (i.e. before *then_max*.
  NSString* now =       [[NSDate date] stringWithRFC3339Format];
  NSString* then =      [[NSDate dateWithTimeIntervalSinceNow: 2 * 3600] stringWithRFC3339Format];
  NSString* then_max =  [[NSDate dateWithTimeIntervalSinceNow: 12 * 3600] stringWithRFC3339Format];

  //
  NSArray* theaters = [app.chairDB.theaters.values sortByBlock:^id(NSDictionary* theater) {
    return [NSNumber numberWithDouble: [self distanceToTheater: theater]];
  }];
  
  for(NSDictionary* theater in theaters) {
    if(self.sections.count >= NUMBER_OF_THEATERS) break;
    
    NSString* theater_id = [theater objectForKey:@"_uid"];
    
    NSArray* schedules = [[app.chairDB.schedules_by_theater_id get: theater_id] objectForKey: @"group"];
    schedules = [schedules selectUsingBlock:^BOOL(NSDictionary* schedule) {
      NSString* time = [schedule objectForKey: @"time"];

      if([time compare: then_max] == NSOrderedDescending) return NO;  // In the distant future?
      if([time compare: now] == NSOrderedAscending) return NO;        // In the past?
      
      return YES;
    }];
    
    schedules = [schedules sortByKey: @"time"];
    
    NSMutableArray* schedulesCloseToNow = [NSMutableArray array];
    for(NSDictionary* schedule in schedules) {
      NSString* time = [schedule objectForKey: @"time"];

      // This schedule is between then and then_max? Add only if we
      // don't have SCHEDULES_PER_THEATER schedules collected yet.
      if([time compare: then] == NSOrderedDescending) {
        if(schedulesCloseToNow.count >= SCHEDULES_PER_THEATER)
          break;
      }
      [schedulesCloseToNow addObject:schedule];
    }
    
    // Add this section. 
    if(schedulesCloseToNow.count == 0) continue;

    NSString* header = [NSString stringWithFormat:@"%@ (%.1f km)", 
                          [theater objectForKey:@"name"], 
                          [self distanceToTheater: theater]
                       ];
    [self addSection: schedulesCloseToNow
         withOptions: _.hash(@"header", header)];
  }

  return self;
}

-(Class)cellClassForKey:(id)key
{ 
  return [VicinityShowCell class]; 
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

@implementation VicinityShowController

-(void)setLocation
{
  self.dataSource = [[VicinityShowDataSource alloc]initWithPosition: [M3LocationManager coordinates]];
}

-(void)setUpdateIsNotRunning
{
  [self setRightButtonWithTitle: @"cur" target: self action: @selector(startUpdate)];
}

-(void)setUpdateIsRunning
{
  [self setRightButtonWithSystemItem: UIBarButtonSystemItemStop 
                              target: self 
                              action: @selector(setUpdateIsNotRunning) // <-- fake: we do not stop the update.
  ];
}

-(id)init
{
  self = [super init];
  if(!self) return nil;
  
  [M3LocationManager on: @selector(onUpdatedLocation) 
                 notify: self 
                   with: @selector(onUpdatedLocation:) ];
  
  [M3LocationManager on: @selector(onError) 
                 notify: self 
                   with: @selector(onUpdateLocationFailed)];
  
  [self setLocation];
   
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched; 

  [self setUpdateIsNotRunning];
  
  return self;
}

-(void)startUpdate
{
  [[M3LocationManager class] updateLocation]; 
  [self setUpdateIsRunning];
}

- (void)onUpdatedLocation: (M3LocationManager*)locationManager
{
  [self setUpdateIsRunning];
  [self setLocation];
}

- (void)onUpdateLocationFailed: (NSError*)error
{
  [self setUpdateIsNotRunning];
  dlog << "Got location error " << error;
}

@end