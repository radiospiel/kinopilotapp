//
//  M3LocationManager.h
//  M3
//
//  Created by Enrico Thierbach on 01.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <CoreLocation/CoreLocation.h>

/**
 * 
 * The M3LocationManager wraps a single CLLocationManager object into a 
 * singleton-like object. To get a reading from the location manager
 * just call [M3LocationManager updateLocation]. 
 * 
 * Signals:
 * 
 * The M3LocationManager class emits a @selector(onUpdatedLocation)
 * signal with a reference to the M3LocationManager object. 
 *
 * On error the class emits a @selector(onError) signal with a reference
 * to the M3LocationManager object.
 */

@interface M3LocationManager: NSObject<CLLocationManagerDelegate> {
  CLLocationManager* locationManager_;
  CGFloat accuracy_;
  CLLocationCoordinate2D coordinates_;
}

+(M3LocationManager*) defaultManager;
+(void) updateLocation;
+(CLLocationCoordinate2D) coordinates;

@property (assign,nonatomic) CGFloat accuracy;
@property (nonatomic,retain) CLLocationManager* locationManager;
@property (assign,nonatomic) CLLocationCoordinate2D coordinates;

@end

#endif
