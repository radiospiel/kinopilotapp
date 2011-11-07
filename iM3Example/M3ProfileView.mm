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

-(void) setHtmlDescription: (NSString*) html
{
  htmlView_ = [[[TTTAttributedLabel alloc]init]autorelease];
  htmlView_.text = [NSAttributedString attributedStringWithMarkup: html 
                                                    forStylesheet: self.stylesheet];

  CGSize htmlSize = [htmlView_ sizeThatFits: CGSizeMake(220, 1000)];
  htmlView_.frame = CGRectMake(85, 5, htmlSize.width, htmlSize.height);
  
  [self addSubview:htmlView_];
}

-(void) setActions: (NSArray*) actions
{
  int h = 26;
  int w = 90;
  int r = 305;
  
  int y = htmlView_.frame.origin.y + htmlView_.frame.size.height + 16;
  
  for(int idx=0; idx < 2; ++idx) { 
    if(idx >= actions.count) break;
    
    NSArray* action = [actions objectAtIndex:idx];
  
    UIButton* button = [UIButton actionButtonWithURL:action.second andTitle:action.first];
    button.frame = CGRectMake(r - w, y, w, h); r -= (w+10);
    [self addSubview:button];
  }
}

-(void) setImageURLs: (NSArray*) imageURLs
{
  imageView_ = [[UIImageView alloc]initWithFrame:CGRectMake(5,5,70,100)];
  [self addSubview:[imageView_ autorelease]];

  imageView_.contentMode = UIViewContentModeScaleAspectFill;
  imageView_.clipsToBounds = YES;
  imageView_.image = [UIImage imageNamed:@"no_poster.png"];

//  DLOG(imageURLs);
  
  if(!imageURLs.count) return;
  
  imageView_.imageURL = imageURLs.first;
  
  
  if(imageURLs.count > 1) {
    for(NSString* url in imageURLs)
      [imageView_ addImageURLToRotation: url];
  }
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
  mapView_ = [[MKMapView alloc]initWithFrame:CGRectMake(5,5,70,100)];
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

// --- predefined profiles ------------------------------------------------

+(M3ProfileView*) profileViewForTheater: (NSDictionary*) theater
{
  if(!theater) return nil;
  
  M3ProfileView* pv = [[[M3ProfileView alloc]init]autorelease];
  
  // -- set descriptions
  
  {
    NSMutableString* html = [NSMutableString string];
    
    NSString* name = [theater objectForKey:@"name"];
    [html appendFormat:@"<h2><b>%@</b></h2>", name.cdata];
    
    NSString* address = [theater objectForKey:@"address"];
    if(address)
      [html appendFormat: @"<p>%@</p>", address.cdata]; 
    
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
  
  // -- set proile URL
  
  NSString* url = _.join(@"/map/show?theater_id=", [theater objectForKey:@"_uid" ]);
  [pv setProfileURL:url];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

+(M3ProfileView*) profileViewForMovie: (NSDictionary*) movie
{
  if(!movie) return nil;
  
  NSString* movie_id = [movie objectForKey:@"_uid"];
  
  M3ProfileView* pv = [[[M3ProfileView alloc]init]autorelease];
  
  // -- set desription
  
  {
    NSString* title =           [movie objectForKey:@"title"];
    NSNumber* runtime =         [movie objectForKey:@"runtime"];
    NSArray* genres =           [movie objectForKey:@"genres"];
    NSNumber* production_year = [movie objectForKey:@"production-year"];
    
    NSMutableArray* parts = [NSMutableArray array];
    [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title]];
    
    if(genres.first || production_year || runtime) {
      NSMutableArray* p = [NSMutableArray array];
      if(genres.first) [p addObject: genres.first];
      if(production_year) [p addObject: production_year];
      if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
      
      [parts addObject: @"<p>"];
      [parts addObject: [p componentsJoinedByString:@", "]];
      [parts addObject: @"</p>"];
    }
    
    [pv setHtmlDescription: [parts componentsJoinedByString:@""]];
  }
  
  // -- set actions
  
  {
    NSMutableArray* actions = _.array();
    
    // add full info URL
    [actions addObject: _.array(@"Mehr...", _.join(@"/movies/show?movie_id=", movie_id))];
    
    // add imdb URL
    NSString* title =           [movie objectForKey:@"title"];
    
    NSString* imdbURL = _.join(@"imdb:///find?q=", title.urlEscape);
    if(![app canOpen:imdbURL])
      imdbURL = _.join(@"http://imdb.de/?q=", title.urlEscape);
    
    [actions addObject: _.array(@"IMDB", imdbURL)];
    
    [pv setActions: actions];
  }
  
  // -- add an image view
  
  {
    NSArray* images = [movie objectForKey:@"images"];
    [pv setImageURLs: [images pluck:@"thumbnail"]];
  }
  
  // --- set profile URL
  
  [pv setProfileURL: _.join(@"/movies/show?movie_id=", movie_id) ];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

@end
