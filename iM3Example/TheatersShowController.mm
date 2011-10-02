//
//  TheatersShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "TheatersShowController.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation TheatersShowController

- (NSString*)descriptionAsHTML
{
  NSMutableString* html = [NSMutableString string];
 
  NSString* name = [self.model objectForKey:@"name"];
  [html appendFormat:@"<h2><b>%@</b></h2>", name.cdata];

  NSString* address = [self.model objectForKey:@"address"];
  if(address)
    [html appendFormat: @"<p><b>Adresse:</b> %@</p>", address.cdata]; 
  
  return html;
}

-(NSString*)title
{
  return [self.model objectForKey:@"name"];
}

-(NSArray*)actions
{
  NSMutableArray* actions = _.array();

  NSString* address = [self.model objectForKey:@"address"];
  
  if(actions.count < 2 && address) {
    [actions addObject: _.array(@"Fahrinfo", _.join(@"fahrinfo-berlin://connection?to=", address.urlEscape))];
  }

  NSString* fon = [self.model objectForKey:@"telephone"];
  if(actions.count < 2 && fon) {
    [actions addObject: _.array(@"Fon", _.join(@"tel://", fon.urlEscape))];
  }

  NSString* email = [self.model objectForKey:@"email"];
  if(actions.count < 2 && email) {
    [actions addObject: _.array(@"Email", _.join(@"mailto:", email))];
  }
  NSString* web = [self.model objectForKey:@"website"];
  if(actions.count < 2 && web) {
    [actions addObject: _.array(@"Website", web)];
  }
  
  return actions;
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];

  //
  // Add a map view
  CGRect frame = imageView.frame; 
  frame.origin = CGPointMake(0,0);
  
  MKMapView* mapView = [[MKMapView alloc]initWithFrame:frame];
  [imageView addSubview:[mapView autorelease]];

  NSArray* latlong = [self.model objectForKey:@"latlong"];
  
  MKCoordinateRegion region;
  region.center = CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue]);
  region.span.latitudeDelta = 0.003;    // This is roughly 300m
  region.span.longitudeDelta = 0.003;   // This is roughly 300m

  mapView.region = region;
  mapView.layer.borderColor = [UIColor colorWithName:@"#666"].CGColor;
  mapView.layer.borderWidth = 0.6f;

  MKPointAnnotation* annotation = [[MKPointAnnotation alloc]init];
  [annotation setCoordinate:region.center];
  [mapView addAnnotation: [annotation autorelease]];
  
  //
  // Open URL on tapping the map. It is strange - but this seems to work only
  // when adding a tap handler on imageView *and* on mapView.
  NSString* url = _.join(@"/map/show/theater_id=", [self.model objectForKey:@"_uid" ]);
  
  [imageView onTapOpen: url];
  [mapView onTapOpen: url];
  
  //
  // Set body controller
  NSString* bodyURL = _.join(@"/movies/list/theater_id=", [self.model objectForKey:@"_uid" ]);
  [self setBodyController: [app viewControllerForURL:bodyURL ] withTitle: @"Filme"];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
