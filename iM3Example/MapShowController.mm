#import "AppBase.h"
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

// The MapShow controller either shows a map around a cinema - 
// in which case a theater_id is set - or just a general map
// around the city.
//
// Note that the MapShowController is actually loaded from a .xib file.

@implementation MapShowController

-(NSString*)title 
{
  return @"Berlin";
}

-(void)dealloc
{
  mapView.delegate = nil;
  [super dealloc];
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

#pragma mark - theater regions

-(void)setRegionFromTheater
{
  NSDictionary* theater = [app.sqliteDB.theaters get: self.theater_id];
  
  NSNumber* lat = [theater objectForKey:@"lat"];
  NSNumber* lng = [theater objectForKey:@"lng"];
  
  MKCoordinateRegion region;

  region.center = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
  region.span.latitudeDelta = 0.012;
  region.span.longitudeDelta = 0.012;

  [mapView setRegion:region];
}

#pragma mark - user locations

-(CLLocationCoordinate2D)defaultLocation
{
  return CLLocationCoordinate2DMake(52.5198, 13.3881); // Berlin Friedrichstrasse
}

-(BOOL)validLocation: (MKUserLocation*)location
{
  if(!location) return NO;
  
  CLLocationCoordinate2D coordinate = location.coordinate;
  CLLocationCoordinate2D defaultLocation = [self defaultLocation];

  if(1 < fabs(coordinate.latitude - defaultLocation.latitude)) return NO;
  if(1 < fabs(coordinate.longitude - defaultLocation.longitude)) return NO;
  
  return YES;
}

-(void)setRegionFromUserLocation
{
  MKUserLocation* location = mapView.userLocation;
  
  if([self validLocation:location]) {     // show user's surrounding
    MKCoordinateRegion region;
    
    region.center = location.coordinate;
    
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;

    [mapView setRegion:region animated:YES];
  }
  else {                                // show overview
    MKCoordinateRegion region;
    
    region.center = [self defaultLocation];
    
    region.span.latitudeDelta = 0.11;
    region.span.longitudeDelta = 0.11;

    [mapView setRegion:region];
  }
}

-(void)setMapViewRegion
{
  if(self.theater_id)
    [self setRegionFromTheater];
  else
    [self setRegionFromUserLocation];
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

-(void)viewDidUnload
{
  mapView.delegate = nil;
  
  [super viewDidUnload];
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
