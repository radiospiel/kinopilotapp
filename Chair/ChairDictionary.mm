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

@synthesize data=data_, keys=keys_;
   
- (id) init;
{
  self = [super init];
  self.data = [[NSMutableDictionary alloc] init];
  self.keys = [[NSMutableArray alloc] init];

  return self;
} 

- (void)dealloc
{
  self.data = nil;
  self.keys = nil;
  
  [super dealloc];
}

-(id) initWithCoder: (NSCoder *)coder 
{
  self = [super init];
  self.data = [coder decodeObjectForKey: @"data"];
  self.keys = [coder decodeObjectForKey: @"keys"];
  return self;
  
#if 0 
  // -- get keys
  
  NSArray* keys = [coder decodeObjectForKey:@"keys"];
  
  // -- get column names
  
  NSArray* column_names = [coder decodeObjectForKey: @"column_names"];
  int column_count = column_names.count;

  // -- get rows

  NSArray* rows = [coder decodeObjectForKey: @"rows"];

  NSArray* objects = [rows mapUsingBlock:^id(NSArray* row) {
    DLOG(row);
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:column_count];
    int idx = -1;
    for(id value in row) {
      idx++;
      
      if([value isKindOfClass:[NSNull class]]) continue;
      [dict setObject: value forKey:[column_names objectAtIndex:idx]];
    }

    DLOG(dict);
    return dict;
  }];

//  dlog << "objects.count " << objects;
//  dlog << "keys " << keys;
  
  return [self initWithObjects:objects andKeys:keys];
#endif
}

-(void) encodeWithCoder: (NSCoder *)coder { 
  [coder encodeObject: self.data forKey: @"data"];
  [coder encodeObject: self.keys forKey: @"keys"];
  
  return;
#if 0 
  // save keys
  
  [coder encodeObject: keys_ forKey: @"keys"];

  // save column names
  
  NSMutableArray* column_names_ = [NSMutableArray arrayWithCapacity: data_.allValues.count * 6];
  for(NSDictionary* value in data_.allValues) {
    [column_names_ addObjectsFromArray: value.allKeys];
  }
  
  NSArray* columns = column_names_.uniq.sort;

  [coder encodeObject: columns forKey: @"columns"];

  // save rows

  NSMutableArray* rows = [self.data.allValues mapUsingBlock:^id(NSDictionary* row) {
    return [columns mapUsingBlock:^id(NSString* column) {
      id value = [row objectForKey:column];
      return value ? value : [NSNull null];
    }];
  }];

  [coder encodeObject: rows forKey: @"rows"];

  // save data
  // [coder encodeObject: data_ forKey: @"data_"];
#endif
} 

-(NSUInteger)count 
{
  return keys_.count;
}

-(id)initWithObjects: (NSArray*)values andKeys: (NSArray*)keys {
  self = [super init];
  if(!self) return nil;

  data_ = [[NSMutableDictionary alloc] initWithCapacity: values.count];

  NSUInteger idx = 0;
  
  for(id key in keys) {
    [data_ setObject: [values objectAtIndex: idx++] forKey: key];
  }

  keys_ = [[NSMutableArray alloc] initWithArray: keys];

  [Chair sortArray: keys_];
  
  return self;
}

+ (id) dictionary {
  return AUTORELEASE([[ChairDictionary alloc] init]);
}

- (NSArray*) keys {
  return keys_;
};

// replace/insert/remove object at a given key
- (void) setObject_: (id) object forKey: (id) key {

  if(object == nil) {
    [Chair removeObject: key fromArray: keys_];
    [data_ removeObjectForKey: key];
  }
  else {
    [Chair insertObject: key intoArray: keys_];
    [data_ setObject: object forKey: key];
  }
}

- (void) setObject: (NSDictionary*) object forKey: (id) key {
  [self setObject_: object forKey: key];
}

- (id) objectForKey_: (id) key {
  return [data_ objectForKey: key];
}

- (NSDictionary*) objectForKey: (id) key {
  return [self objectForKey_: key];
}

//
// yields each [value, key ] pair all entries in the range minKey ..
// maxKey. If the maxKey entry exists, if will be yielded

-(void) each_: (void(^)(id value, id key))yield 
          min: (id) min
          max: (id) max
 excludingEnd: (BOOL) excludingEnd
{

  NSRange range = [Chair rangeInArray: keys_
                                   min: min
                                   max: max
                          excludingEnd: excludingEnd];

  [keys_ enumerateObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: range]
                            options: /* descending ? NSEnumerationReverse : */ 0
                         usingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                                      id value = [data_ objectForKey: key];
                                      yield(value, key);
                                    } 
  ];
}

-(void) each: (void(^)(NSDictionary* value, id key))yield 
         min: (id) min
         max: (id) max
 excludingEnd: (BOOL) excludingEnd
{
  [self  each_: yield
            min: min
            max: max
   excludingEnd: excludingEnd
];
}

- (void) each: (void(^)(NSDictionary* value, id key))yield 
{
  [self each: yield
          min: nil
          max: nil
 excludingEnd: NO];
}

@end

@implementation ChairMultiDictionary

+ (ChairMultiDictionary*) dictionary {
  return AUTORELEASE([[ChairMultiDictionary alloc] init]);
}

- (void) addObject: (NSDictionary*) object forKey: (id) key
{
  NSMutableArray* objects = [self objectForKey_: key];
  if(!objects) {
    objects = [[[NSMutableArray alloc]init]autorelease];
    [self setObject_: objects forKey:key];
  }

  [objects addObject:object];
}

-(NSUInteger)count
{
  int count = 0;
  
  for(id key in keys_) {
    NSArray* values = [data_ objectForKey: key];
    count += values.count;
  }
  
  return count;
}

- (void) each: (void(^)(NSDictionary* value, id key))yield 
          min: (id) min
          max: (id) max
 excludingEnd: (BOOL) excludingEnd
{
  [self eachArray: ^(NSArray* values, id key) {
                      for(NSDictionary* object in values)
                        yield(object, key);
                    }
               min: min
               max: max
      excludingEnd: excludingEnd];
}

- (void) eachArray: (void(^)(NSArray* value, id key))yield
               min: (id) min
               max: (id) max
      excludingEnd: (BOOL) excludingEnd
{
  [super each_: yield
            min: min
            max: max
   excludingEnd: excludingEnd
];
};


@end

template <class T1, class T2>
static NSMutableArray* enum_keys_and_values(ChairDictionary* dictionary, T1 min, T2 max, BOOL excludingEnd) {
  NSMutableArray* rv = _.array();
  [dictionary each: ^(id value, id key) { [rv addObject: key]; [rv addObject: value]; }
                min: _.object(min)
                max: _.object(max)
       excludingEnd: excludingEnd];

  return rv;
}

template <class T1, class T2>
static NSMutableArray* enum_keys(ChairDictionary* dictionary, T1 min, T2 max, BOOL excludingEnd) {
  NSMutableArray* rv = _.array();
  [dictionary each: ^(id value, id key) { [rv addObject: key]; }
                min: _.object(min)
                max: _.object(max)
       excludingEnd: excludingEnd];

    return rv;
}

ETest(ChairDictionary)

// All code under test must be linked into the Unit Test bundle
- (void)test_chair_dictionary
{
  ChairDictionary* cd = [ChairDictionary dictionary];
  assert_equal(cd.keys, _.array());

  [cd setObject: _.object("three") forKey:_.object(3)];
  assert_equal(cd.keys, _.array(3));

  [cd setObject: _.object("one") forKey:_.object(1)];
  assert_equal(cd.keys, _.array(1,3));

  [cd setObject: _.object("two") forKey:_.object(2)];
  assert_equal(cd.keys, _.array(1,2,3));

  [cd setObject: _.object("four") forKey:_.object(4)];
  assert_equal(cd.keys, _.array(1,2,3,4));

  [cd setObject: _.object("another four") forKey:_.object(4)];
  assert_equal(cd.keys, _.array(1,2,3,4));

  [cd setObject: nil forKey:_.object(1)];
  assert_equal(cd.keys, _.array(2,3,4));

  [cd setObject: nil forKey:_.object(3)];
  assert_equal(cd.keys, _.array(2,4));

  [cd setObject: nil forKey:_.object(4)];
  [cd setObject: nil forKey:_.object(2)];
  assert_equal(cd.keys, _.array());
}

- (void)test_chair_enumeration
{
  ChairDictionary* cd = [ChairDictionary dictionary];
  assert_equal(cd.keys, _.array());

  [cd setObject: _.object("three") forKey:_.object(3)];
  [cd setObject: _.object("one") forKey:_.object(1)];
  [cd setObject: _.object("two") forKey:_.object(2)];
  [cd setObject: _.object("four") forKey:_.object(4)];

  // --- enumerate full dictionary, with and without the end

  assert_equal(enum_keys_and_values(cd, 0, 4, NO), 
    _.array(1, "one", 2, "two", 3, "three", 4, "four"));

  assert_equal(enum_keys_and_values(cd, 0, 4, YES), 
    _.array(1, "one", 2, "two", 3, "three"));

  // --- replace an entry
  
  [cd setObject: _.object("another two") forKey:_.object(2)];
  assert_equal(enum_keys_and_values(cd, 0, 4, NO), 
    _.array(1, "one", 2, "another two", 3, "three", 4, "four"));

  // --- remove { 2: "two" } 
  [cd setObject: nil forKey:_.object(2)];
  assert_equal(cd.keys, _.array(1, 3, 4));

  // enumerate [0..4] returns 
  assert_equal(enum_keys(cd, 0, 4, NO), _.array(1, 3, 4));
  assert_equal(enum_keys(cd, 0, 5, YES), _.array(1, 3, 4));
  assert_equal(enum_keys(cd, 0, 4, YES), _.array(1, 3));
  assert_equal(enum_keys(cd, 0, 3, YES), _.array(1));
}

@end
