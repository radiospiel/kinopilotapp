//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"
#import "Underscore.hh"

@implementation Chair 
/*
 * Chair additions to NSMutableDictionary
 */

+(NSString*)uid: (NSDictionary*) record;
{
  id uid = [record objectForKey: @"_uid"];
  if(uid) return uid;
  
  NSArray* keys = [record.allKeys sortedArrayUsingSelector:@selector(localizedCompare:)];
  NSArray* parts = [M3 map: keys
                  withIndex: ^(id key, NSUInteger idx) {
                              id value = [record objectForKey: key];  
                              return _.join( key, ":", [value description]);
                            }
                   ];
  
  return [M3 md5: _.join(parts, "/")];
}

/*
 * Chair additions to NSMutableArray
 */

static NSComparisonResult underscore_compare(id a, id b, void* p) {
  return _.compare(a, b);
}

+(NSUInteger)indexForObject: (id)anObject 
                    inArray: (NSMutableArray*) sortedArray;
{
  NSUInteger index = 0;
  NSUInteger topIndex = sortedArray.count;
  IMP objectAtIndexImp = [sortedArray methodForSelector:@selector(objectAtIndex:)];
  while (index < topIndex) {
    NSUInteger midIndex = (index + topIndex) / 2;
    id testObject = objectAtIndexImp(sortedArray, @selector(objectAtIndex:), midIndex);

    NSComparisonResult diff = _.compare(anObject, testObject);
    if (diff == 0) return midIndex;
    
    if (diff > 0) {
      index = midIndex + 1;
    }
    else {
      topIndex = midIndex;
    }
  }
  return index;
}

+(void)insertObject: (id)anObject 
          intoArray: (NSMutableArray*) sortedArray;
{
  NSUInteger index = [self indexForObject: anObject inArray: sortedArray];

  if(index == sortedArray.count) {
    // append at end
    [sortedArray insertObject:anObject atIndex:index];
  }
  else {
    NSComparisonResult diff = _.compare(anObject, [sortedArray objectAtIndex:index]);
    if (diff != 0) 
      [sortedArray insertObject:anObject atIndex:index];
  }
}

+(void)removeObject: (id)anObject 
          fromArray: (NSMutableArray*) sortedArray;
{
  NSUInteger index = [self indexForObject:anObject inArray: sortedArray];
  
  NSComparisonResult diff = _.compare(anObject, [sortedArray objectAtIndex:index]);
  if (diff == 0) 
    [sortedArray removeObjectAtIndex:index];
}

+(NSRange) rangeInArray: (NSMutableArray*) array
                    min: (id)min 
                    max: (id)max 
           excludingEnd: (BOOL) excludingEnd;
{
  NSUInteger count = array.count;
  NSUInteger start = !min ? 0 : [self indexForObject: min inArray: array];
  if(start >= count) return NSMakeRange(0, 0);
  
  NSUInteger end = !max ? count : [self indexForObject: max inArray: array];

  // Make end point to the item *after* max
  if(end < count && !excludingEnd) {
    id end_obj = [array objectAtIndex: end];
    if(_.compare(max, end_obj) == 0)
        end++;
  }
  
  if(start > end) return NSMakeRange(0, 0);
  return NSMakeRange(start, end - start );
}

+(void) sortArray: (NSMutableArray*) array {
  [array sortUsingFunction: RS::UnderscoreAdapter::compare context: 0];
} 


@end

@implementation Chair(Dynamic)

+ (SimpleMapCallback) groupBy: (NSString*) name;
{
  id block = ^(NSDictionary* value, id key) { return [value objectForKey: name]; };
  return AUTORELEASE([block copy]);
}

+ (SimpleReduceCallback) reduceBy: (NSString*) name;
{
  if([name isEqualToString: @"count"]) {
    id block = ^(NSArray* values, id key) { return _.hash("count", values.count); };
    return [block copy];
  }
  
  _.raise("Unsuppored reduce method", name);
  __builtin_unreachable();
}


@end

ETest(Chair)

- (void)test_chair_array_additions_multiple_entries
{
  NSMutableArray* array = _.array();
  [Chair insertObject:  _.object(1) intoArray: array];
  
  [Chair insertObject:  _.object(1) intoArray: array];
  [Chair insertObject:  _.object(1) intoArray: array];
  [Chair insertObject:  _.object(1) intoArray: array];

  assert_equal(array, _.array(1));
}

- (void)test_chair_array_additions
{
  NSMutableArray* array = _.array();
  [Chair insertObject:  _.object(1) intoArray: array];
  [Chair insertObject:  _.object(2) intoArray: array];
  [Chair insertObject:  _.object(3) intoArray: array];
  [Chair insertObject:  _.object(4) intoArray: array];

  assert_equal(array, _.array(1, 2, 3, 4));
}

- (void)test_chair_array_indexForObjectChairObject
{
  NSMutableArray* array = _.array(1, 3, 5);
  assert_equal(0, [Chair indexForObject: _.object(0) inArray: array]);
  assert_equal(0, [Chair indexForObject: _.object(1) inArray: array]);
  assert_equal(1, [Chair indexForObject: _.object(2) inArray: array]);
  assert_equal(1, [Chair indexForObject: _.object(3) inArray: array]);
  assert_equal(2, [Chair indexForObject: _.object(4) inArray: array]);
  assert_equal(2, [Chair indexForObject: _.object(5) inArray: array]);
  assert_equal(3, [Chair indexForObject: _.object(6) inArray: array]);
}

- (void)test_chair_uids
{
  id hash = _.hash("bla", "bla-value", "blu", 12);
  id uid = [Chair uid: hash];
  
  assert([Chair uid: hash] != nil);

  hash = _.hash("blu", 12, "bla", "bla-value");
  assert_equal(uid, [Chair uid: hash]);

  hash = _.hash("blu", 12, "bla", "bla-value", "yum", "my");
  assert_not_equal(uid, [Chair uid: hash]);
  
  // the _uid is read from the hash, if defined.
  hash = _.hash("blu", 12, "_uid", "some-uid");
  assert_equal("some-uid", [Chair uid: hash]);
}



static NSString* range(NSMutableArray* array, id minimum, id maximum) {
  NSRange range = [Chair rangeInArray: array
                                   min: minimum
                                   max: maximum
                          excludingEnd: NO];

  return _.join(range.location, "+", range.length);
}

-(void)test_rangeInArray
{
  NSMutableArray* array = _.array(267534162, 374391607, 624179285, 837728461);
  
  assert_equal("0+4", range(array, nil, nil));
  assert_equal("0+1", range(array, nil, _.object(267534162)));
  assert_equal("0+1", range(array, nil, _.object(267534163)));
}

@end
