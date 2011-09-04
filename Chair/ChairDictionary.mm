//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"

/*
 * ChairDictionary: a sorted dictionary
 */

@implementation ChairDictionary

- (id) init;
{
  self = [ super init ];
  if(!self) return nil;
  
  data_ = [ NSMutableDictionary dictionary ];
  keys_ = [ NSMutableArray array ];
  
  return self;
} 

+ (id) dictionary {
  return AUTORELEASE([[ ChairDictionary alloc ] init ]);
}

-(id)initWithObjects: (NSArray*)values andKeys: (NSArray*)keys {
  self = [ super init ];
  if(!self) return nil;

  data_ = [ NSMutableDictionary dictionaryWithCapacity: values.count ];
  
  NSUInteger idx = 0;
  
  for(id key in keys) {
    [data_ setObject: [values objectAtIndex: idx++ ] forKey: key ];
  }

  keys_ = [NSMutableArray arrayWithArray: keys ];
  [ Chair sortArray: keys_ ];
  
  return self;
}

+ (id) dictionaryWithObjects: (NSArray*)objects andKeys: (NSArray*)keys {
  return AUTORELEASE([[ ChairDictionary alloc ] initWithObjects: objects andKeys: keys ]);
}

-(id)initWithKeyValueArray: (NSArray*)kvArray {
  self = [ super init ];
  if(!self) return nil;

  data_ = [ NSMutableDictionary dictionaryWithCapacity: kvArray.count ];
  keys_ = [ NSMutableArray arrayWithCapacity: kvArray.count ];
  
  for(NSArray* kv in kvArray) {
    id key = [ kv objectAtIndex: 0 ];
    id value = [kv objectAtIndex: 1 ];
    [keys_ addObject: key ];
    [data_ setObject: value forKey: key ];
  }
  
  return self;
}

+ (id) dictionaryWithKeyValueArray: (NSArray*) kvArray {
  return AUTORELEASE([[ ChairDictionary alloc ] initWithKeyValueArray: kvArray ]);
}

- (NSArray*) keys {
  return keys_;
};

- (NSDictionary*) data {
  return data_;
}

// replace/insert/remove object at a given key
- (void) setObject_: (id) object forKey: (id) key {

  if(object == nil) {
    [Chair removeObject: key fromArray: keys_ ];
    [data_ removeObjectForKey: key ];
  }
  else {
    [Chair insertObject: key intoArray: keys_ ];
    [data_ setObject: object forKey: key ];
  }
}

- (void) setObject: (NSDictionary*) object forKey: (id) key {
  [ self setObject_: object forKey: key ];
}

- (id) objectForKey_: (id) key {
  return [data_ objectForKey: key ];
}

- (NSDictionary*) objectForKey: (id) key {
  return [self objectForKey_: key ];
}

//
// yields each [ value, key ] pair all entries in the range minKey ..
// maxKey. If the maxKey entry exists, if will be yielded

-(void) each_: (void(^)(id value, id key))yield 
          min: (id) min
          max: (id) max
 excludingEnd: (BOOL) excludingEnd
{

  NSRange range = [ Chair rangeInArray: keys_
                                   min: min
                                   max: max
                          excludingEnd: excludingEnd ];

  [ keys_ enumerateObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: range ]
                            options: /* descending ? NSEnumerationReverse : */ 0
                         usingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                                      id value = [ data_ objectForKey: key ];
                                      yield(value, key);
                                    } 
  ];
}

-(void) each: (void(^)(NSDictionary* value, id key))yield 
         min: (id) min
         max: (id) max
 excludingEnd: (BOOL) excludingEnd
{
  [ self  each_: yield
            min: min
            max: max
   excludingEnd: excludingEnd
  ];
}

- (void) each: (void(^)(NSDictionary* value, id key))yield 
{
  [ self each: yield
          min: nil
          max: nil
 excludingEnd: NO ];
}

- (void) encodeWithCoder: (NSCoder *)coder { 
  [coder encodeObject: keys_ forKey: @"keys" ];
  [coder encodeObject: data_ forKey: @"data" ];
} 

- (id) initWithCoder: (NSCoder *)coder { 
  if (self = [super init]) { 
    keys_ = [coder decodeObjectForKey:@"keys"]; 
    data_ = [coder decodeObjectForKey:@"data"]; 
  } 
  return self; 
}

@end

@implementation ChairMultiDictionary

+ (ChairMultiDictionary*) dictionary {
  return AUTORELEASE([[ ChairMultiDictionary alloc ] init ]);
}

- (void) addObject: (NSDictionary*) object forKey: (id) key
{
  NSMutableArray* objects = [ self objectForKey_: key ];
  if(objects) {
    [objects addObject:key];
  }
  else {
    objects = [ NSMutableArray arrayWithObject: object ];
    [ self setObject_: objects forKey:key];
  }
}

- (void) each: (void(^)(NSDictionary* value, id key))yield 
          min: (id) min
          max: (id) max
 excludingEnd: (BOOL) excludingEnd
{
  [ self eachArray: ^(NSArray* values, id key) {
                      for(NSDictionary* object in values)
                        yield(object, key);
                    }
               min: min
               max: max
      excludingEnd: excludingEnd ];
}

- (void) eachArray: (void(^)(NSArray* value, id key))yield
               min: (id) min
               max: (id) max
      excludingEnd: (BOOL) excludingEnd
{
  [ super each_: yield
            min: min
            max: max
   excludingEnd: excludingEnd
  ];
};


@end

