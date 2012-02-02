//
//  MovieController.h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "TTTAttributedLabel.h"
#import "M3TableViewController.h"

@class MKMapView;

@interface M3ProfileView: UIView {
  MKMapView* mapView_;
  TTTAttributedLabel* htmlView_;
  UIImageView* imageView_;
}

-(void) setHtmlDescription: (NSString*)html;
-(void) setActions: (NSArray*) actions;
-(void) setCoordinate: (CLLocationCoordinate2D) coordinate;

-(void) setProfileURL: (NSString*)url;
-(CGFloat) wantsHeight;

+(M3ProfileView*) profileViewForTheater: (NSDictionary*) theater;

@end
