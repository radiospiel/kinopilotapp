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

@interface M3LocationManager: NSObject<CLLocationManagerDelegate>

/** starts updating the location once. */
+(void) updateLocation;

/** returns the currently read coordinates */
+(CLLocationCoordinate2D) coordinates;

/** returns the last error, if any. */
+(NSError*) lastError;

/** returns true if a position is available */
+(BOOL)locationAvailable;

@end

#endif
