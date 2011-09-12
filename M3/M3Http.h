//
//  M3Http.h
//  M3
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3Http : NSObject

// get an URL with options
+ (NSString*) get: (NSString*) url withOptions: (NSDictionary*) options;

// get an URL
+ (NSString*) get: (NSString*) url;

@end
