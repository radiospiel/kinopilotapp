//
//  M3LocationManager.m
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
// #import "M3AppDelegate.h"
#import "SVProgressHUD.h"

#import "CoreLocation/CoreLocation.h"

#if TARGET_OS_IPHONE

/*
 * This is the default location. 
 */
#define FRIEDRICH_STRASSE CLLocationCoordinate2DMake(52.5198, 13.3881)      // Berlin Friedrichstrasse
#define ACCURACY          200

@interface M3LocationManager()

@property (nonatomic,retain) CLLocationManager* locationManager;
@property (nonatomic,assign) CLLocationCoordinate2D coordinates;
@property (nonatomic,retain) NSString* urlToOpen;
@property (nonatomic,retain) NSDate* locationUpdateStartedAt;
@property (nonatomic,retain) NSDate* locationUpdatedAt;

@end

@implementation M3LocationManager

@synthesize locationManager, coordinates, urlToOpen, locationUpdateStartedAt, locationUpdatedAt;

#pragma mark - Lifecycle

-(id)init
{
  self = [super init];

  // If Location Services are disabled, restricted or denied.
  if ((![CLLocationManager locationServicesEnabled])
      || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
      || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
  {
    NSLog(@"locationServicesEnabled are disabled");
    // Send the user to the location settings preferences
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"prefs:root=LOCATION_SERVICES"]];
    return self;
  }

  self.coordinates = FRIEDRICH_STRASSE;
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self; // send location updates to myself
  [ self.locationManager requestWhenInUseAuthorization ];
  
  return self;
}

-(void)dealloc
{
  self.locationManager = nil;
  self.urlToOpen = nil;
  self.locationUpdateStartedAt = nil;
  self.locationUpdatedAt = nil;
  
  [super dealloc];
}

-(BOOL)isWaitingForLocationUpdate
{
  return self.locationUpdateStartedAt != nil;
}

-(void)stopUpdatingLocation
{
  self.locationUpdateStartedAt = nil;
  [self.locationManager stopUpdatingLocation];
}

-(void)startUpdatingLocation
{
  self.locationUpdateStartedAt = [NSDate now];
  self.locationUpdatedAt = nil;

  [self.locationManager startUpdatingLocation];
}

-(BOOL)gotRecentLocationUpdate
{
  if(!self.locationUpdatedAt) return NO;
  
  NSTimeInterval interval = [[NSDate now] timeIntervalSinceDate:self.locationUpdatedAt];
  return interval < 5 * 60; // 5 minutes
}

// Start a location update. Stop the update and set to timeout after 15 secs.
-(void) updateLocationAndOpenURL: (NSString*)url
{
  self.urlToOpen = url;
  
  // Don't start a new location update if we are waiting for an update 
  if([self isWaitingForLocationUpdate]) 
    return;
  
  // If we have a recent location we'll use that one.
  if([self gotRecentLocationUpdate]) {
    [M3 open: self.urlToOpen];
    return;
  }
  
  [self startUpdatingLocation];
  [SVProgressHUD showWithStatus:@"Position bestimmen" maskType: SVProgressHUDMaskTypeBlack];
  
  int64_t nanosecs = 15 * 1e09; // 15 secs.

#if TARGET_IPHONE_SIMULATOR
  nanosecs = 1 * 1e09;
#endif

  dispatch_after( dispatch_time(DISPATCH_TIME_NOW, nanosecs),
    dispatch_get_main_queue(), ^{
      if(![self isWaitingForLocationUpdate]) return;
      
      [self stopUpdatingLocation];

      NSError* timeout = [NSError errorWithDomain:@"Timeout" code:0 userInfo: nil];

      [self locationManager:self.locationManager 
           didFailWithError:timeout];
    });
}

#pragma mark - CLLocationManager delegate callbacks

// Note: this is deprecated since IOS6
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  // Not yet good enough?
  if([newLocation horizontalAccuracy] > ACCURACY)
    return;
  
  // Got update
  [self stopUpdatingLocation];

  self.locationUpdatedAt = [NSDate now];
  self.coordinates = newLocation.coordinate;
  
  [SVProgressHUD dismiss];
  
  [M3 open: self.urlToOpen];
}

-(void) locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error
{
  [SVProgressHUD dismissWithError: @"Deine Position konnte nicht bestimmt werden."];
  
  [self stopUpdatingLocation];
}

#pragma mark - M3LocationManager singleton object

static M3LocationManager* defaultManager = nil;

+(void) initialize
{
  defaultManager = [[M3LocationManager alloc]init];
}

+(void) updateLocationAndOpen:(NSString *)url
{
  [defaultManager updateLocationAndOpenURL:url];
}

+(CLLocationCoordinate2D) coordinates
{
  return defaultManager.coordinates;
}

@end

#endif
