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

@interface ChairDictionary: NSObject {
  NSMutableArray* keys_;
  NSMutableDictionary* data_;
};

@property (readonly,nonatomic) NSUInteger count;

-(id)init;
-(id)initWithObjects: (NSArray*)values andKeys: (NSArray*)keys;

/* JSON I/O */

-(id)initWithJSONFile: (NSString *)path withExtraData: (NSMutableDictionary*)extraData;
-(void) saveToJSONFile: (NSString *)path withExtraData: (NSDictionary*)extraData;

+ (id) dictionary;

- (void) setObject: (NSDictionary*) object forKey: (id) key;

- (void) each: (void(^)(NSDictionary* value, id key))yield 
          min: (id) min
          max: (id) max
 excludingEnd: (BOOL) excludingEnd;

- (void) each: (void(^)(NSDictionary* value, id key))yield;

@property (nonatomic,retain) NSArray* keys;
@property (nonatomic,retain) NSDictionary* data;

-(NSArray*)keys;

@end

@interface ChairMultiDictionary: ChairDictionary

- (void) addObject: (NSDictionary*) object forKey: (id) key;

+ (ChairMultiDictionary*) dictionary;

- (void) eachArray: (void(^)(NSArray* value, id key))yield
               min: (id) min
               max: (id) max
      excludingEnd: (BOOL) excludingEnd;

@end

//
// TODO: Add ChairMultiDictionary keys
//
