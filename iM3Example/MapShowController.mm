//
//  MapShowController.m
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MapShowController.h"
#import "M3.h"
#import "AppDelegate.h"

@interface MapAnnotation: MKPointAnnotation {
  NSString* theater_id_;
}

@property (nonatomic,retain) NSString* theater_id;

@end

@implementation MapAnnotation

@synthesize theater_id = theater_id_;

-(id)initWithTheater: (NSDictionary*)theater
{
  self = [super init];
  self.theater_id = [theater objectForKey:@"_uid"];

  NSArray* latlong = [theater objectForKey:@"latlong"];
  self.coordinate = CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue]);

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

@implementation MapShowController

@synthesize theatersToAdd = theatersToAdd_, theater_id = theater_id_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)loadFromUrl:(NSString *)url
{
  self.theater_id = [url.to_url param: @"theater_id"]; 
}

-(NSString*)title {
  return @"Berlin";
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
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
  [self setRightButtonWithTitle: @"cur" target: self action: @selector(startUpdate)];
}

-(void)setUpdateIsRunning
{
  [self setRightButtonWithSystemItem: UIBarButtonSystemItemStop 
                              target: self 
                              action: @selector(setUpdateIsNotRunning) // <-- fake: we do not stop the update.
   ];
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


-(void)initLocationUpdates
{
  [M3LocationManager on: @selector(onUpdatedLocation) 
                 notify: self 
                   with: @selector(onUpdatedLocation:) ];
  
  [M3LocationManager on: @selector(onError) 
                 notify: self 
                   with: @selector(onUpdateLocationFailed)];
  
  [self setLocation];
  [self setUpdateIsNotRunning];
}


#pragma mark - mapView delegate

- (MKAnnotationView*) mapView:(MKMapView *)mv 
            viewForAnnotation:(MapAnnotation*)annotation 
{
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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  mapView.delegate = self;

  NSString* theater_id = [self theater_id];
  
  MKCoordinateRegion region;
  if(theater_id) {
    NSDictionary* theater = [app.chairDB.theaters get: theater_id];
    NSArray* latlong = [theater objectForKey:@"latlong"];
    
    region.center = CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue]);
    region.span.latitudeDelta = 0.012;
    region.span.longitudeDelta = 0.012;
  }
  else {
    region.center = [M3LocationManager coordinates];
    region.span.latitudeDelta = 0.08;
    region.span.longitudeDelta = 0.08;
  }
  
  [mapView setRegion:region];
  
  NSArray* theaters = app.chairDB.theaters.values;
  NSArray* annotations = [theaters mapUsingBlock:^id(NSDictionary* theater) {
    return [[MapAnnotation alloc]initWithTheater: theater];
  }];
  
  if(!theater_id)
    [self initLocationUpdates];
  
  [mapView addAnnotations:annotations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
