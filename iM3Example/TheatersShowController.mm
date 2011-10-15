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

@class TTTAttributedLabel, MKMapView;

@interface ProfileView: UIView {
  MKMapView* mapView_;
  TTTAttributedLabel* htmlView_;
  UIImageView* imageView_;
}

-(void) setHtmlDescription: (NSString*)html;
-(void) setActions: (NSArray*) actions;
-(void) setImageURLs: (NSArray*) imageURLs;
-(void) setCoordinate: (CLLocationCoordinate2D) coordinate;

+(ProfileView*) profileViewForTheater: (NSDictionary*)theater;

@end

@implementation TheatersShowController

-(id)init
{
  self = [super init];

  if(self)
    [app.chairDB on: @selector(updated) notify:self with:@selector(reload)];

  return self;
}

-(void)setUrl: (NSString *)url
{
  [super setUrl: url];

  if(!url) return;
  
  [url matches:@"/theaters/show/(.*)"];
  self.model = [app.chairDB.theaters get: $1];
  
  UIView* profileView = [ProfileView profileViewForTheater:self.model];
  self.tableView.tableHeaderView = profileView;
}

-(void)setModel: (NSDictionary*)theater
{
  [super setModel: theater];
  
  id theater_id = [theater objectForKey:@"_uid"];
  self.dataSource = [M3DataSource moviesListFilteredByTheater: theater_id];
}

@end

#import <QuartzCore/QuartzCore.h>

@implementation ProfileView

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

-(int)wantsHeight
{
  int rHeight = htmlView_.frame.origin.y + htmlView_.frame.size.height + 16;
  rHeight += 24;
  rHeight += 16;

  int lHeight = 114;
  
  return lHeight > rHeight ? lHeight : rHeight;
}


+(ProfileView*) profileViewForTheater: (NSDictionary*)theater
{
  if(!theater) return nil;
  ProfileView* pv = [[ProfileView alloc]init];

  // -- set descriptions
  
  {
    NSMutableString* html = [NSMutableString string];
    
    NSString* name = [theater objectForKey:@"name"];
    [html appendFormat:@"<h2><b>%@</b></h2>", name.cdata];
    
    NSString* address = [theater objectForKey:@"address"];
    if(address)
      [html appendFormat: @"<p><b>Adresse:</b> %@</p>", address.cdata]; 
    
    [pv setHtmlDescription:html];
  }

  // -- set actions
  
  {
    NSMutableArray* actions = _.array();
    
    NSString* address = [theater objectForKey:@"address"];
    
    if(address)
      [actions addObject: _.array(@"Fahrinfo", _.join(@"fahrinfo-berlin://connection?to=", address.urlEscape))];
    
    NSString* fon = [theater objectForKey:@"telephone"];
    if(fon)
      [actions addObject: _.array(@"Fon", _.join(@"tel://", fon.urlEscape))];
    
    NSString* web = [theater objectForKey:@"website"];
    if(web)
      [actions addObject: _.array(@"Website", web)];
    
    [pv setActions: actions];
  }

  // -- add a map view

  {
    NSArray* latlong = [theater objectForKey:@"latlong"];
    [pv setCoordinate: CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue])];
  }  

  NSString* url = _.join(@"/map/show/theater_id=", [theater objectForKey:@"_uid" ]);

  [pv setProfileURL:url];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

@end
