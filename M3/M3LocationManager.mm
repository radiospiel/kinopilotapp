//
//  M3LocationManager.m
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "SVProgressHUD.h"

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
@property (nonatomic,assign) BOOL locationAvailable;

@end

@implementation M3LocationManager

@synthesize locationManager, coordinates, urlToOpen, locationAvailable;

#pragma mark - Lifecycle

-(id)init
{
  self = [super init];

  self.coordinates = FRIEDRICH_STRASSE;
  self.locationManager = [[[CLLocationManager alloc] init] autorelease];
  self.locationManager.delegate = self; // send location updates to myself
  
  return self;
}

-(void)dealloc
{
  self.locationManager = nil;
  self.urlToOpen = nil;
  
  [super dealloc];
}

// Start a location update. Stop the update and set to timeout after 15 secs.
-(void) updateLocationAndOpenURL: (NSString*)url
{
  self.urlToOpen = url;
  self.locationAvailable = NO;

  [self.locationManager startUpdatingLocation];
  [SVProgressHUD showWithStatus:@"Position bestimmen" maskType: SVProgressHUDMaskTypeBlack];
  
  int64_t nanosecs = 15 * 1e09; // 15 secs.

#if TARGET_IPHONE_SIMULATOR
  nanosecs = 1 * 1e09;
#endif

  dispatch_after( dispatch_time(DISPATCH_TIME_NOW, nanosecs),
    dispatch_get_main_queue(), ^{
      if(!self.locationAvailable) {
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
  if([newLocation horizontalAccuracy] > ACCURACY) 
    return;
  
  // Got update
  self.locationAvailable = YES;
  self.coordinates = newLocation.coordinate;
  [self.locationManager stopUpdatingLocation];
  [SVProgressHUD dismiss];
  
  [app open: self.urlToOpen];
}

-(void) locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error
{
  [SVProgressHUD dismissWithError: @"Deine Position konnte nicht bestimmt werden."];
  
  [self.locationManager stopUpdatingLocation];
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
