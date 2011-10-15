//
//  M3ProfileView.mm
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3ProfileView.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation M3ProfileView

-(id)initWithTheater:(NSDictionary*)theater
{
  self = [super initWithFrame: CGRectMake(0, 0, 320, 40)];
  
  return self;
}

-(void) setHtmlDescription: (NSString*) html
{
  htmlView_ = [[[TTTAttributedLabel alloc]init]autorelease];
  htmlView_.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
  
  CGSize htmlSize = [htmlView_ sizeThatFits: CGSizeMake(220, 1000)];
  htmlView_.frame = CGRectMake(85, 5, htmlSize.width, htmlSize.height);
  
  [self addSubview:htmlView_];
}

-(void) setActions: (NSArray*) actions
{
  int w = 85;
  int r = 305;
  
  int y = htmlView_.frame.origin.y + htmlView_.frame.size.height + 16;
  
  for(NSArray* action in [actions subarrayWithRange:NSMakeRange(0,2)]) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(r - w, y, w, 24); r -= (w+10);
    // button.backgroundColor = [UIColor colorWithWhite:0 alpha:0]; // this has a alpha of 0. 
    [button setActionURL: action.second andTitle:action.first];
    
    [self addSubview:button];
  }
}

-(void) setImageURLs: (NSArray*) imageURLs
{
  
}

-(void) setProfileURL: (NSString*)url
{
  //
  // Open URL on tapping the map. It is strange - but this seems to work only
  // when adding a tap handler on imageView *and* on mapView.
  
  [imageView_ onTapOpen: url];
  [mapView_ onTapOpen: url];
}

-(void) setCoordinate: (CLLocationCoordinate2D) coordinate
{
  mapView_ = [[MKMapView alloc]initWithFrame:CGRectMake(05,5,70,100)];
  [self addSubview:[mapView_ autorelease]];
  
  MKCoordinateRegion region;
  region.center = coordinate;
  region.span.latitudeDelta = 0.003;    // This is roughly 300m
  region.span.longitudeDelta = 0.003;   // This is roughly 300m
  
  mapView_.region = region;
  mapView_.layer.borderColor = [UIColor colorWithName:@"#666"].CGColor;
  mapView_.layer.borderWidth = 0.6f;
  
  MKPointAnnotation* annotation = [[MKPointAnnotation alloc]init];
  [annotation setCoordinate:region.center];
  [mapView_ addAnnotation: [annotation autorelease]];
}

-(CGFloat)wantsHeight
{
  int rHeight = htmlView_.frame.origin.y + htmlView_.frame.size.height + 16;
  rHeight += 24;
  rHeight += 16;
  
  int lHeight = 114;
  
  return lHeight > rHeight ? lHeight : rHeight;
}

@end
