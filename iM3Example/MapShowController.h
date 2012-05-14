//
//  MapShowController.h
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"
#import <MapKit/MapKit.h>

@interface MapShowController: UIViewController<MKMapViewDelegate> {
  MKMapView *mapView;
}

@property (readonly,nonatomic) NSString* theater_id;

@end
