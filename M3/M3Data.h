//
//  M3Data.h
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3Data : NSObject

//! Analyze an object, and return a data description.
+(NSString*) analyze: (id) object;

//! Returns the supertype of a type.
+(NSString*) supertype: (NSString*) type;

@end
