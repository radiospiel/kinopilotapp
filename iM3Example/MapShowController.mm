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

@interface MapAnnotation: NSObject<MKAnnotation> {
  NSDictionary* theater_;
}

@property (nonatomic,retain) NSDictionary* theater;

@end

@implementation MapAnnotation

@synthesize theater = theater_;

-(id)initWithTheater: (NSDictionary*)theater
{
  self = [super init];
  self.theater = theater;
  
  return self;
}

-(CLLocationCoordinate2D)coordinate
{
  NSArray* latlong = [self.theater objectForKey:@"latlong"];
  
  NSNumber* lat = latlong.first;
  NSNumber* lng = latlong.second;
  
  return CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
}

-(NSString*)title
{
  return [self.theater objectForKey:@"name"];
}

-(NSString*)subtitle
{
  return [self.theater objectForKey:@"address"];
}

-(void)dealloc
{
  self.theater = nil;
  [super dealloc];
}


-(void) showDetails: (id)param
{
  NSString* url = _.join(@"/theaters/show/", [self.theater objectForKey:@"_uid"]);
  dlog << "showDetails: url " << url;
  [ app open: url];
}



@end

@implementation MapShowController

@synthesize theatersToAdd = theatersToAdd_;

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
            viewForAnnotation:(id<MKAnnotation>)annotation 
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
  
  pinView.pinColor = MKPinAnnotationColorRed;
  pinView.animatesDrop = YES;
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
  
  MKCoordinateRegion region;
  region.center = [M3LocationManager coordinates];
  region.span.latitudeDelta = 0.08;
  region.span.longitudeDelta = 0.08;
  
  [mapView setRegion:region];
  
  NSArray* theaters = app.chairDB.theaters.values;
  NSArray* annotations = [theaters mapUsingBlock:^id(NSDictionary* theater) {
    return [[MapAnnotation alloc]initWithTheater: theater];
  }];
  
  [self initLocationUpdates];
  
  [mapView addAnnotations:annotations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
