//
//  M3Inflector.h
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3(Inflector)

+ (NSString*)pluralize: (NSString*) string;
+ (NSString*)singularize: (NSString*) string;
+ (NSString*)humanize: (NSString*) string;

@end
