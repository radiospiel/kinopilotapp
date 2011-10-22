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

/*** VicinityShowController cells *******************************************/

// VicinityTableCell defines some layout for the various Vicinity cells
//

@interface VicinityTableCell: M3TableViewCell
@end

@implementation VicinityTableCell

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

@end

// A VicinityScheduleCell defines some layout for the various Vicinity cells

@interface VicinityScheduleCell: VicinityTableCell
@end

@implementation VicinityScheduleCell

-(void)setKey: (NSDictionary*)schedule
{
  schedule = [schedule joinWith: app.chairDB.movies on:@"movie_id"];

  [super setKey:schedule];

  NSNumber* time = [schedule objectForKey: @"time"];
  
  self.textLabel.text = [time.to_date stringWithFormat: @"HH:mm"];

  NSString* detailText = [schedule objectForKey:@"title"];

  self.detailTextLabel.text = [detailText withVersionString: [schedule objectForKey:@"version"]];
  self.detailTextLabel.numberOfLines = 1;
  self.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;

  self.url = _.join(@"/movies/show?movie_id=", [schedule objectForKey: @"movie_id"]);
}

@end

// A VicinityTheaterCell holds a "link" to /movies/list?theater_id=<theaters>

@interface VicinityTheaterCell: VicinityTableCell
@end

@implementation VicinityTheaterCell

-(id)init
{ 
  self = [super init];
  
  self.detailTextLabel.font = [UIFont italicSystemFontOfSize:13];
  self.detailTextLabel.text = @"mehr...";
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  return self;
}

-(void)setKey: (NSDictionary*)theater
{
  [super setKey: theater];

  self.url = _.join(@"/movies/list?theater_id=", [theater objectForKey: @"_uid"]);
}

@end

/*** The datasource for MoviesList *******************************************/

@interface VicinityShowDataSource: M3TableViewDataSource {
  CLLocationCoordinate2D currentPosition_;
}

-(double) distanceToTheater:(NSDictionary*) theater;

@end

@implementation VicinityShowDataSource

-(id)init
{
  self = [super init];
  if(!self) return nil;

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

  return self;
}

-(Class)cellClassForKey:(NSDictionary*)key
{ 
  NSString* typeName = [key objectForKey: @"_type"];
  M3AssertKindOf(typeName, NSString);
  
  if([typeName isEqualToString: @"theaters"])
    return [VicinityTheaterCell class];
  
  return [VicinityScheduleCell class]; 
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

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched; 

  [M3LocationManager on: @selector(onUpdatedLocation) 
                 notify: self 
                   with: @selector(onUpdatedLocation:) ];
  
  [M3LocationManager on: @selector(onError) 
                 notify: self 
                   with: @selector(onUpdateLocationFailed)];
  
  [self setUpdateIsNotRunning];
  
  return self;
}

-(void)reload
{
  self.dataSource = [[[VicinityShowDataSource alloc]init]autorelease];
}

-(void)startUpdate
{
  [[M3LocationManager class] updateLocation]; 
  [self setUpdateIsRunning];
}

- (void)onUpdatedLocation: (M3LocationManager*)locationManager
{
  [self setUpdateIsRunning];
  [self reload];
}

- (void)onUpdateLocationFailed: (NSError*)error
{
  [self setUpdateIsNotRunning];
  dlog << "Got location error " << error;
}

@end