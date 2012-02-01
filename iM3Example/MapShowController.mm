//
//  MapShowController.m
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "MapShowController.h"

@interface MapAnnotation: MKPointAnnotation

@property (nonatomic,retain) NSString* theater_id;

@end

@implementation MapAnnotation

@synthesize theater_id;

-(id)initWithTheater: (NSDictionary*)theater
{
  self = [super init];
  self.theater_id = [theater objectForKey:@"_id"];

  NSNumber* lat = [theater objectForKey:@"lat"];
  NSNumber* lng = [theater objectForKey:@"lng"];
  self.coordinate = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);

  self.title = [theater objectForKey:@"name"];
  self.subtitle = [theater objectForKey:@"address"];

  return self;
}

-(void)dealloc
{
  self.theater_id = nil;
  [super dealloc];
}

-(void) showDetails: (id)param
{
  NSString* url = _.join(@"/movies/list?theater_id=", self.theater_id);
  [ app open: url];
}

@end

// The MapShow controller either shows a map around a cinema - in which 
// case a theater_id is set - or just a general map around the city.
//
// Note that the MapShowController is actually loaded from a .xib file.

@implementation MapShowController

-(NSString*)title 
{
  return @"Berlin";
}

#pragma mark - updating location

-(void)setLocation
{
  MKCoordinateRegion region = mapView.region;
  region.center = [M3LocationManager coordinates];
  [mapView setRegion:region];
}

-(void)setUpdateIsNotRunning
{
  [self setRightButtonWithImage:[UIImage imageNamed:@"location.png"] 
                         target:self 
                         action:@selector(startUpdate)];
}

-(void)setUpdateIsRunning
{
  [self setRightButtonWithSystemItem: UIBarButtonSystemItemStop 
                              target: self 
                              action: @selector(setUpdateIsNotRunning) // <-- fake: we do not stop the update.
   ];
}

#pragma mark - View lifecycle

-(NSString*)theater_id
{
  return [self.url.to_url param: @"theater_id"]; 
}

-(MKCoordinateRegion)regionFromTheater
{
  NSDictionary* theater = [app.sqliteDB.theaters get: self.theater_id];
  
  NSNumber* lat = [theater objectForKey:@"lat"];
  NSNumber* lng = [theater objectForKey:@"lng"];
  
  MKCoordinateRegion region;

  region.center = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
  region.span.latitudeDelta = 0.012;
  region.span.longitudeDelta = 0.012;

  return region;
}

-(MKCoordinateRegion)regionFromUserLocation
{
  MKCoordinateRegion region;
  
  MKUserLocation* location = mapView.userLocation;
  #if TARGET_IPHONE_SIMULATOR
  location = nil;
  #endif
  
  if(location) {
    region.center = location.coordinate;
    
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
  }
  else {
    region.center = CLLocationCoordinate2DMake(52.5198, 13.3881); // Berlin Friedrichstrasse

    region.span.latitudeDelta = 0.08;
    region.span.longitudeDelta = 0.08;
  }
  
  return region;
}

-(void)setMapViewRegion
{
  mapView.region = self.theater_id ? 
    [self regionFromTheater] : 
    [self regionFromUserLocation];
}

-(void)addTheaterAnnotations
{
  NSArray* theaters = [app.sqliteDB.theaters all];
  NSArray* annotations = [theaters mapUsingBlock:^id(NSDictionary* theater) {
    return [[MapAnnotation alloc]initWithTheater: theater];
  }];
  [mapView addAnnotations:annotations];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  mapView.delegate = self;

  [self setMapViewRegion];
  [self addTheaterAnnotations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - mapView delegate

- (MKAnnotationView*) mapView:(MKMapView *)mv 
            viewForAnnotation:(MapAnnotation*)annotation 
{
  if ([annotation isKindOfClass:[MKUserLocation class]])
    return nil;
  
  // Try to dequeue an existing pin view first.
  static NSString* identifier = @"CustomPinAnnotationView";
  
  MKPinAnnotationView* pinView;
  pinView = (MKPinAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:identifier];
  if(pinView) {
    pinView.annotation = annotation;
    return pinView;
  }
  
  // If an existing pin view was not available, create one.
  pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                             reuseIdentifier:identifier]
             autorelease];
  
  if([[self theater_id] isEqualToString: annotation.theater_id]) {
    pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.animatesDrop = NO;
  }
  else {
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.animatesDrop = YES;
  }
  
  pinView.canShowCallout = YES;
  
  // Add a detail disclosure button to the callout.
  UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
  
  [rightButton addTarget:annotation 
                  action:@selector(showDetails:)
        forControlEvents:UIControlEventTouchUpInside];
  
  pinView.rightCalloutAccessoryView = rightButton;
  
  return pinView;
}

-(void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
  if(!self.theater_id) {
    [self setMapViewRegion];
  }
}

@end
