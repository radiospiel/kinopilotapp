//
//  M3LocationManager.m
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"

#if TARGET_OS_IPHONE

/*
 * This is the default location. 
 */
#define FRIEDRICH_STRASSE CLLocationCoordinate2DMake(52.5198, 13.3881)      // Berlin Friedrichstrasse


@interface M3LocationManager()

@property (nonatomic,retain) CLLocationManager* locationManager;
@property (nonatomic,assign) BOOL locationAvailable;
@property (nonatomic,assign) CLLocationCoordinate2D coordinates;
@property (nonatomic,assign) CLLocationAccuracy accuracy;
@property (nonatomic,retain) NSError* lastError;

@end

@implementation M3LocationManager

@synthesize locationManager, accuracy, coordinates, lastError, locationAvailable;

#pragma mark - Lifecycle

-(id)initWithAccuracy: (CGFloat)theAccuracy
{
  self = [super init];
  self.accuracy = theAccuracy;
  self.coordinates = FRIEDRICH_STRASSE;

  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self; // send location updates to myself
  
  self.locationAvailable = NO;
  
  return self;
}

-(id)init
{ 
  return [self initWithAccuracy:200]; 
}

+(M3LocationManager*) locationManager
{
  return [[[self alloc]init]autorelease];
}

-(void)dealloc
{
  self.locationManager = nil;
  self.lastError = nil;
  
  [super dealloc];
}

// Start a location update. Stop the update and set to timeout after 15 secs.
-(void) updateLocation
{
  self.locationAvailable = NO;
  self.lastError = nil;
  
  [self.locationManager startUpdatingLocation];
  
  int64_t nanosecs = 15 * 1e09; // 15 secs.

#if TARGET_IPHONE_SIMULATOR
  nanosecs = 1 * 1e09;
#endif

  dispatch_after( dispatch_time(DISPATCH_TIME_NOW, nanosecs),
    dispatch_get_main_queue(), ^{
      if(![self locationAvailable]) {
        NSError* timeout = [NSError errorWithDomain:@"Timeout" code:0 userInfo: nil];

        [self locationManager:self.locationManager 
             didFailWithError:timeout];
      }
      [self.locationManager stopUpdatingLocation];
    });
}

#pragma mark - CLLocationManager delegate callbacks

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  // Not yet good enough?
  if([newLocation horizontalAccuracy] > self.accuracy) 
    return;
  
  // Got update
  self.locationAvailable = YES;
  self.coordinates = newLocation.coordinate;
  [self.locationManager stopUpdatingLocation];
  
  [[self class] emit: @selector(onUpdatedLocation) withParameter: self];
}

-(void) locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error
{
  dlog << "Got location error " << error;
  self.lastError = error;
  
  [self.locationManager stopUpdatingLocation];
  [[self class] emit: @selector(onError) withParameter: error];
}

#pragma mark - M3LocationManager singleton object

static M3LocationManager* defaultManager = nil;

+(void) initialize
{
  defaultManager = [[M3LocationManager alloc]init];
}

+(void) updateLocation
{
  [defaultManager updateLocation];
}

+(CLLocationCoordinate2D) coordinates
{
  return defaultManager.coordinates;
}

+(BOOL)locationAvailable
{
  return defaultManager.locationAvailable;
}

+(NSError*)lastError
{
  return defaultManager.lastError;
}

@end

#endif
