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

@interface VicinityShowDataSource: M3TableViewDataSource
@end

@implementation VicinityShowDataSource

static inline float sqr(float val)
  { return val * val; }

/* Distance from current position to [lat2,lng2] */

static CGPoint currentPosition()
{
  float lat1 = 52.5198, lng1 = 13.3881;       // Berlin Friedrichstrasse
  
  // float lat1 = 52.49334, lng1 = 13.43689;      // Berlin Glogauer Strasse

  return CGPointMake(lat1, lng1);
}

static float distance(float lat1, float lng1, float lat2, float lng2) 
{
#define PI_DIVIDED_BY_180   0.0174532925199f
#define DEG_TO_RAD(deg)     deg * PI_DIVIDED_BY_180
#define RADIUS              6371

  lat1 = DEG_TO_RAD(lat1);
  lng1 = DEG_TO_RAD(lng1);

  lat2 = DEG_TO_RAD(lat2);
  lng2 = DEG_TO_RAD(lng2);

  float x = (lng2-lng1) * cosf((lat1+lat2)/2);
  float y = (lat2-lat1);
  
  return sqrt(sqr(x) + sqr(y)) * RADIUS;
  
}

static NSNumber* distanceToTheater(NSDictionary* theater)
{
  NSArray* latlong = [theater objectForKey:@"latlong"];

  NSNumber* lat = latlong.first;
  NSNumber* lng = latlong.second;
  
  M3AssertKindOf(lat, NSNumber);
  M3AssertKindOf(lng, NSNumber);

  float currentLat = currentPosition().x;
  float currentLng = currentPosition().y;
  
  
  float dist = distance(currentLat, currentLng, [lat floatValue], [lng floatValue]);
  return [NSNumber numberWithFloat: dist];
}

-(id)init
{
  self = [super init];
  
  Benchmark(@"Building vicinity data set");

  //
  // Time range: we'll show all schedules in the next 2 hours, i.e. less than
  // *then*. If we'll then have less than 6 (schedulesPerTheater) schedules 
  // (i.e. Arthouse cinema), we include schedules until we have those, if 
  // these are in the next 12 hours (i.e. before *then_max*.
  NSString* now =   [[NSDate date] stringWithRFC3339Format];
  NSString* then =  [[NSDate dateWithTimeIntervalSinceNow: 2 * 3600] stringWithRFC3339Format];
  NSString* then_max =  [[NSDate dateWithTimeIntervalSinceNow: 12 * 3600] stringWithRFC3339Format];

  //
  NSArray* theaters = [app.chairDB.theaters.values sortByBlock:^id(NSDictionary* theater) {
    return distanceToTheater(theater);
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
                          [distanceToTheater(theater) doubleValue]
                       ];
    [self addSection: schedulesCloseToNow
         withOptions: _.hash(@"header", header)];
  }

  return self;
}

-(Class)cellClassForKey:(id)key
{ return [VicinityShowCell class]; }

@end


@implementation VicinityShowController

-(id)init
{
  self = [super init];
  self.dataSource = [[VicinityShowDataSource alloc]init];
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched; 

  return self;
}

@end











