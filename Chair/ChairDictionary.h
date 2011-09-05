//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A sorted dictionary: allows to enumerate over a range of
 * entries 
 */

@interface ChairDictionary: NSObject<NSCoding> {
  NSMutableArray* keys_;
  NSMutableDictionary* data_;
};

-(id)init;
-(id)initWithObjects: (NSArray*)values andKeys: (NSArray*)keys;

+ (id) dictionary;

- (void) setObject: (NSDictionary*) object forKey: (id) key;

- (void) each: (void(^)(NSDictionary* value, id key))yield 
          min: (id) min
          max: (id) max
 excludingEnd: (BOOL) excludingEnd;

- (void) each: (void(^)(NSDictionary* value, id key))yield;

@property (nonatomic,retain,readonly) NSArray* keys;
@property (nonatomic,retain,readonly) NSDictionary* data;

@end

@interface ChairMultiDictionary: ChairDictionary

- (void) addObject: (NSDictionary*) object forKey: (id) key;

+ (ChairMultiDictionary*) dictionary;

- (void) eachArray: (void(^)(NSArray* value, id key))yield
               min: (id) min
               max: (id) max
      excludingEnd: (BOOL) excludingEnd;

@end
