//
//  MapShowController.h
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapShowController: UIViewController<MKMapViewDelegate> {
  IBOutlet MKMapView *mapView;
  NSMutableArray *theatersToAdd_;
}

@property (retain,nonatomic) NSMutableArray *theatersToAdd;

@end
