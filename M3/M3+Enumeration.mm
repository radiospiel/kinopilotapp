//
//  M3.m
//
//  Created by Enrico Thierbach on 12.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "M3.h"
#import "Underscore.hh"

#define implemenation_missing(name) [NSException raise:@"Implementation missing" \
                                       format:@"Not yet implemented: %s", name]

//
// check object type.
static BOOL is_array(id obj) {
  if([obj isKindOfClass: [NSArray class]]) return YES;
  if([obj isKindOfClass: [NSDictionary class]]) return NO;
  
  [NSException raise:  @"IllegalArgument"
                format: @"No M3 support for objects of class: %@", 
                          NSStringFromClass([obj class])
 ];
  
  return 0;
}

@implementation M3(Enumeration)

// 
// -- each ------------------------------------------------------------

+ (id) each: (id) list 
  withIndex: (void (^)(id value, NSUInteger index)) iterator {
  if(is_array(list)) {
    [list enumerateObjectsUsingBlock: (void (^)(id value, NSUInteger index, BOOL*))iterator];
  }
  else {
    NSUInteger __block idx = 0;
    [list enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      iterator(obj, idx++);
    }];
  }

  return list;
}

+ (id) each: (id) list 
       with: (void (^)(id value, id key))iterator {
  if(is_array(list)) {
    [list enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        id key = [NSNumber numberWithUnsignedInteger: idx];
        iterator(obj, key);
      }
   ];
  }
  else {
    [list enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        iterator(obj, key);
      }
   ];
  }
  
  return list;
}

//
// -- inject -----------------------------------------

+ (id) inject: (id) list 
         memo: (id) memo
         with: (id (^)(id memo, id value, id key))iterator {
  
  id __block r = memo;
  
  if(is_array(list)) {
    [list enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        id key = [NSNumber numberWithUnsignedInteger: idx];
        r = iterator(r, obj, key);
      }
   ];
  }
  else {
    [list enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        r = iterator(r, obj, key);
      }
   ];
  }
  
  return r;
}

+ (id) inject: (id) list
         with: (id (^)(id memo, id value, id key))iterator {
   return [self inject: list memo: nil with: iterator];
}

+ (id) inject: (id) list 
         memo: (id) memo
    withIndex: (id (^)(id memo, id value, NSUInteger key))iterator {
  
  id __block r = memo;
  
  if(is_array(list)) {
    [list enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        r = iterator(r, obj, idx);
      }
   ];
  }
  else {
    NSUInteger __block idx = 0;
    [list enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        r = iterator(r, obj, idx++);
      }
   ];
  }
  
  return r;
}

+ (id) inject: (id) list
    withIndex: (id (^)(id memo, id value, NSUInteger key))iterator {
   return [self inject: list memo: nil withIndex: iterator];
}

//
// -- map -----------------------------------------------

+ (NSMutableArray*) map: (id) list 
                   with: (id (^)(id value, id key))iterator {
  NSMutableArray* r = [NSMutableArray arrayWithCapacity: [list count]];

  [M3 each: list 
               with:^(id value, id key) { [r addObject: iterator(value, key)]; }
 ];

  return r;
}

+ (NSMutableArray*) map: (id) list 
              withIndex: (id (^)(id value, NSUInteger idx))iterator {
  NSMutableArray* r = [NSMutableArray arrayWithCapacity: [list count]];
  
  [M3 each: list 
          withIndex:^(id value, NSUInteger idx) { [r addObject: iterator(value, idx)]; }
 ];
  
  return r;
}

//
// -- detect ----------------------------------------------------------

+ (id) detect: (id) list 
         with: (BOOL (^)(id value, id key))iterator {
  
  id __block r = nil;
  
  if(is_array(list)) {
    [list enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        id key = [NSNumber numberWithUnsignedInteger: idx];
        if(iterator(obj, key)) {
          *stop = YES; r = obj;
        }
      }
   ];
  }
  else {
    [list enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if(iterator(obj, key)) {
          *stop = YES; r = obj;
        }
      }
   ];
  }

  return r;
}

+ (id) detect: (id) list 
    withIndex: (BOOL (^)(id value, NSUInteger key))iterator {
  
  id __block r = nil;
  
  if(is_array(list)) {
    [list enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        if(iterator(obj, idx)) {
          *stop = YES; r = obj;
        }
      }
   ];
  }
  else {
    NSUInteger __block idx = 0;
    
    [list enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if(iterator(obj, idx++)) {
          *stop = YES; r = obj;
        }
      }
   ];
  }

  return r;
}

//
// -- select ----------------------------------------------------------

+ (NSMutableArray*) select: (id) list 
                      with: (BOOL (^)(id value, id key))iterator {
  NSMutableArray* r = [NSMutableArray array];
  
  [self each: list 
         with: ^(id obj, id key) {
           if(iterator(obj, key)) {
             [r addObject: obj];
           }
         }
 ];
  
  return r;
}

+ (NSMutableArray*) select: (id) list 
                 withIndex: (BOOL (^)(id value, NSUInteger idx))iterator {
  NSMutableArray* r = [NSMutableArray array];

  [self each: list 
    withIndex: ^(id obj, NSUInteger key) {
      if(iterator(obj, key)) {
        [r addObject: obj];
      }
    }
 ];

  return r;
}

//
// -- reject ----------------------------------------------------------

+ (NSMutableArray*) reject: (id) list 
                      with: (BOOL (^)(id value, id key))iterator {
  NSMutableArray* r = [NSMutableArray array];
  
  [self each: list 
         with: ^(id obj, id key) {
           if(!iterator(obj, key)) {
             [r addObject: obj];
           }
         }
 ];
  
  return r;
}

+ (NSMutableArray*) reject: (id) list 
                 withIndex: (BOOL (^)(id value, NSUInteger idx))iterator {
  NSMutableArray* r = [NSMutableArray array];

  [self each: list 
    withIndex: ^(id obj, NSUInteger key) {
      if(!iterator(obj, key)) {
        [r addObject: obj];
      }
    }
 ];

  return r;
}

//
// -- all -----------------------------------------------

+ (BOOL) all: (id) list
        with: (BOOL (^)(id value, id key))iterator {
  id failing = [M3 detect: list 
                              with: ^(id value, id key) {
                                return (BOOL)(iterator(value, key) == NO);
                              }
              ];
  
  return failing == nil;
}

+ (BOOL) all: (id) list 
   withIndex: (BOOL (^)(id value, NSUInteger key))iterator {
  id failing = [M3 detect: list
                         withIndex: ^(id value, NSUInteger key) {
                           return (BOOL)(iterator(value, key) == NO);
                         } 
              ];
  
  return failing == nil;
}

//
// -- any -----------------------------------------------

+ (BOOL) any: (id) list
        with: (BOOL (^)(id value, id key))iterator {

  return [M3 detect: list
                        with: iterator ] != nil;
}

+ (BOOL) any: (id) list 
   withIndex: (BOOL (^)(id value, NSUInteger key))iterator {

  return [M3 detect: list
                   withIndex: iterator ] != nil;
}

//
// -- include ---------------------------------------------------------

+ (BOOL) include: (id) list 
           value: (id) value {
  if(is_array(list)) {
    return [list containsObject: value]; 
  }

  return [self any: list 
               with: ^(id value_in_hash, id key) {
                 return [value isEqual: value_in_hash];
               }
 ];
}

//
// -- pluck -----------------------------------------------------------

+ (id) pluck: (id) list 
        name: (NSString*) propertyName {
  NSMutableArray* r = [NSMutableArray array]; 

  [M3 each: list
          withIndex: ^(id value, NSUInteger idx) {
            id entry = [value valueForKey: propertyName];
            [r addObject: entry]; 
          }
 ];
  
  return r;
}

//
// -- min, max --------------------------------------------------------

+ (id) _minmax: (id) list 
      max_mode: (BOOL) max_mode
          with: (id (^)(id value, id key))iterator {
    
  id __block memo = nil;
  id __block memo_value = nil;
  
  [self each: list 
         with: ^(id entry, id key){
           id value = iterator(entry, key);
           if(!memo_value) {
             memo = entry; memo_value = value;
           }
           else {
             NSInteger diff = _.compare(memo_value, value);
             if(diff == 0) return;
      
             if((max_mode && diff > 0) || (!max_mode && diff < 0)) {
               memo = entry; memo_value = value;
             }
           }
         }
 ];
  
  return memo_value;
}

+ (id) _minmax: (id) list 
      max_mode: (BOOL) max_mode
     withIndex: (id (^)(id value, NSUInteger idx))iterator {

  id __block memo = nil;
  id __block memo_value = nil;
  
  [self each: list 
    withIndex: ^(id entry, NSUInteger idx){
      id value = iterator(entry, idx);
      if(!memo_value) {
        memo = entry; memo_value = value;
      }
      else {
        NSInteger diff = _.compare(memo_value, value);
        if(diff == 0) return;

        if((max_mode && diff > 0) || (!max_mode && diff < 0)) {
          memo = entry; memo_value = value;
        }
      }
    }
 ];
  
  return memo_value;
}

+ (id) max: (id) list {
  return [M3 _minmax:list 
                              max_mode: YES
                          withIndex: ^(id value, NSUInteger key) { return value; }];
}

+ (id) max: (id) list
      with: (id (^)(id value, id key))iterator {
  return [self _minmax: list max_mode: YES with: iterator];
}

+ (id) max: (id) list 
 withIndex: (id (^)(id value, NSUInteger idx))iterator {
  return [self _minmax:list max_mode: YES withIndex: iterator];
}


+ (id) min: (id) list {
  return [M3 _minmax:list 
                     max_mode: NO
                    withIndex: ^(id value, NSUInteger key) { return value; }];
}

+ (id) min: (id) list 
      with: (id (^)(id value, id key))iterator {
  return [self _minmax: list 
               max_mode: NO 
                   with: iterator];
}

+ (id) min: (id) list 
 withIndex: (id (^)(id value, NSUInteger idx))iterator {
  return [self _minmax: list 
               max_mode: NO 
              withIndex: iterator];
}

// --- sorting 
//
//sortBy_.sortBy(list, iterator, [context])
//Returns a sorted copy of list, ranked by the results of running each value through iterator.
//
//_.sortBy([1, 2, 3, 4, 5, 6], function(num){ return Math.sin(num); });
//=> [5, 4, 6, 3, 1, 2]
//

+ (id) sort: (id) list {
  if(!is_array(list))
    list = [list allValues];
  
  return [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return _.compare(obj1, obj2);
  }];
}

+ (id) sort: (id) list 
         by: (id (^)(id value))iterator {
  if(!is_array(list))
    list = [list allValues];
  
  return [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return _.compare(iterator(obj1), iterator(obj2)); 
  } 
 ];
};

//groupBy_.groupBy(list, iterator)
//Splits a collection into sets, grouped by the result of running each value through iterator.
//
//_.groupBy([1.3, 2.1, 2.4], function(num){ return Math.floor(num); });
//=> {1: [1.3], 2: [2.1, 2.4]}
//

+ (id) group: (id) list 
          by: (id (^)(id value))iterator {
  NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
  [M3 each: list
          withIndex:^(id value, NSUInteger idx) {
            id key = iterator(value);
            NSMutableArray* array = [dictionary objectForKey: key];
            if (array == nil) {
              array = [NSMutableArray arrayWithObject: value];
              [dictionary setObject: array forKey: key];
            }
            else {
              [array addObject: value];
            }
          }
 ];
  return dictionary;
}

//sortedIndex_.sortedIndex(list, value, [iterator])
//Uses a binary search to determine the index at which the value should be inserted into the list in order to maintain the list's sorted order. If an iterator is passed, it will be used to compute the sort ranking of each value.
//
//_.sortedIndex([10, 20, 30, 40, 50], 35);
//=> 3

+ (id) sortedIndex: (id) list 
         withValue: (id) value 
      andIterator: (id) iterator {
  implemenation_missing("sortedIndex");
  return nil;
}

+ (id) sortedIndex: (id) list 
         withValue: (id) value {
  implemenation_missing("sortedIndex");
  return nil;
}
@end


ETest(M3Enumeration)

/*
 * each
 */

- (void)testEachWithEmptyArray
{
  NSMutableArray* values = _.array();
  NSMutableArray* keys = _.array();
  
  _.each(_.array(), ^(id value, id key) {
    [values addObject: value];
    [keys addObject: key];
  });
  
  assert_equal(values, _.array());
  assert_equal(keys, _.array());
}

- (void)testEach
{
  NSMutableArray* values = _.array();
  NSMutableArray* keys = _.array();
  
  _.each(_.array(0, 11, 22, 33, 44), 
         ^(id value, id key) {
           [values addObject: value];
           [keys addObject: key];
         });
  
  assert_equal(values, _.array(0, 11, 22, 33, 44));
  assert_equal(keys, _.array(0, 1, 2, 3, 4));
}

- (void)testEachWithIndex
{
  NSMutableArray* values = _.array();
  NSMutableArray* keys = _.array();
  
  _.each(_.array(0, 11, 22, 33, 44),
         ^(id value, NSUInteger key) {
           [values addObject: value];
           [keys addObject: _.object(key)];
         });
  
  assert_equal(values, _.array(0, 11, 22, 33, 44));
  assert_equal(keys, _.array(0, 1, 2, 3, 4));
}


- (void)testInject
{
  id sum = _.inject(_.array(0, 11, 22, 33, 44),
                    ^id(id memo, id value, id key) {
                      int sum = memo ? [memo intValue] : 0;
                      sum += [value intValue];
                      return [NSNumber numberWithInt: sum];
                    });
  
  assert_equal(sum, 110);
  
  sum = _.inject(_.array(0, 11, 22, 33, 44), 0,
                 ^id(id memo, id value, id key) {
                   int sum = [memo intValue] + [value intValue];
                   return _.object(sum);
                 });
  
  assert_equal(sum, 110);
}


- (void)testGroupBy
{
  id grouped = _.group_by(_.array(2.1, 1.3, 2.4),
                          ^(id value){ 
                            return _.object(floor([value doubleValue])); 
                          });
  
  id expected = _.hash(
                       1, _.array(1.3), 
                       2, _.array(2.1, 2.4)
                       );
  
  assert_equal(grouped, expected);
}


- (void)testUnderscoreInject
{
  id sum = _.inject(_.array(0, 11, 22, 33, 44),
                    ^id(id memo, id value, id key) {
                      int sum = memo ? [memo intValue] : 0;
                      sum += [value intValue];
                      return _.object(sum);
                    });
  
  assert_equal(sum, 110);
  
  sum = _.inject(_.array(0, 11, 22, 33, 44),
                 _.object(0),
                 ^id(id memo, id value, id key) {
                   return _.object([memo intValue] + [value intValue]);
                 });
  
  assert_equal(sum, 110);
}

@end
