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


@implementation M3LocationManager

@synthesize locationManager = locationManager_, accuracy = accuracy_, coordinates = coordinates_;

#pragma mark - Lifecycle

-(id)initWithAccuracy: (CGFloat)accuracy
{
  self = [super init];
  self.accuracy = accuracy;
  self.coordinates = FRIEDRICH_STRASSE;
  
  return self;
}

-(id)init
  { return [self initWithAccuracy:200]; }

+(M3LocationManager*) locationManager
{
  return [[[self alloc]init]autorelease];
}

-(void)dealloc
{
  self.locationManager = nil;
  [super dealloc];
}

-(void) updateLocation
{
  dlog << "*** updateLocation";
  
  if(!self.locationManager) {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; // send loc updates to myself
  }

  [self.locationManager startUpdatingLocation];
}

#pragma mark - M3LocationManager singleton object

+(M3LocationManager*) defaultManager
{
  static M3LocationManager* defaultManager_ = [[M3LocationManager alloc]init];

  return defaultManager_;
}

+(void) updateLocation
{
  [[self defaultManager]updateLocation];
}

+(CLLocationCoordinate2D) coordinates
{
  return [[self defaultManager]coordinates];
}

#pragma mark - CLLocationManager delegate callbacks

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  CLLocationAccuracy accuracy = [newLocation horizontalAccuracy];
  if(accuracy > self.accuracy) return;
  
  dlog << "Got location " << newLocation;

  self.coordinates = newLocation.coordinate;
  [self.locationManager stopUpdatingLocation];

  [[self class] emit: @selector(onUpdatedLocation) withParameter: self];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  dlog << "Got location error " << error;

  [self.locationManager stopUpdatingLocation];
  [[self class] emit: @selector(onError) withParameter: self];
}

@end

#endif
