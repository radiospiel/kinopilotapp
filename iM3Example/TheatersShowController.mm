//
//  TheatersShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "TheatersShowController.h"

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
  
  self.tableView.tableHeaderView = [self headerView];
}

-(UIView*) headerView
{
  NSDictionary* theater = self.model;
  if(!theater) return nil;
  M3ProfileView* pv = [[M3ProfileView alloc]init];
  
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

-(void)setModel: (NSDictionary*)theater
{
  [super setModel: theater];
  
  id theater_id = [theater objectForKey:@"_uid"];
  self.dataSource = [M3DataSource moviesListFilteredByTheater: theater_id];
}

@end
