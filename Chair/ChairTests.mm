//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "ChairTests.h"

#import "Chair.h"
#import "Underscore.hh"
#import "ChairDynamicView.h"

// #import "LoggerClient.h"

/* Test helper macros */


#define assert_equal(a, e)      STAssertEqualObjects(_.object(a), _.object(e), nil)
#define assert_not_equal(a, e)  STAssertTrue(![ _.object(a) isEqual: _.object(e) ], _.join(a, "should not be equal to", e))
#define assert_true(a)          STAssertTrue(a, nil)

@implementation ChairTests

// +(void)initialize
// {
//   LoggerInit(); // , but instead at close time to call: `LoggerStop(LoggerGetDefaultLogger());`
//   // LogMessageCompat(@"*** starting logger");
//   LoggerFlush(LoggerGetDefaultLogger(), NO);
//   // [ NSThread sleepForTimeInterval: 0.1 ];
//   LogMessageCompat(@"*** Initialized logger");
// }

// -(void)setUp
// {
//   NSLog(@"setUp: %@", [ self name ]);
//   
//   [super setUp];
// }
// 
// -(void)tearDown
// {
//   NSLog(@"tearDown: %@", [ self name ]);
//   [super tearDown];
//   // LoggerFlush(LoggerGetDefaultLogger(), NO);
// }

- (void)test_chair_array_additions_multiple_entries
{
  NSMutableArray* array = _.array();
  [Chair insertObject:  _.object(1) intoArray: array ];
  
  [Chair insertObject:  _.object(1) intoArray: array ];
  [Chair insertObject:  _.object(1) intoArray: array ];
  [Chair insertObject:  _.object(1) intoArray: array ];

  assert_equal(array, _.array(1));
}

- (void)test_chair_array_additions
{
  NSMutableArray* array = _.array();
  [Chair insertObject:  _.object(1) intoArray: array ];
  [Chair insertObject:  _.object(2) intoArray: array ];
  [Chair insertObject:  _.object(3) intoArray: array ];
  [Chair insertObject:  _.object(4) intoArray: array ];

  assert_equal(array, _.array(1, 2, 3, 4));
}

- (void)test_chair_array_indexForObjectChairObject
{
  NSMutableArray* array = _.array(1, 3, 5);
  assert_equal(0, [ Chair indexForObject: _.object(0) inArray: array ]);
  assert_equal(0, [ Chair indexForObject: _.object(1) inArray: array ]);
  assert_equal(1, [ Chair indexForObject: _.object(2) inArray: array ]);
  assert_equal(1, [ Chair indexForObject: _.object(3) inArray: array ]);
  assert_equal(2, [ Chair indexForObject: _.object(4) inArray: array ]);
  assert_equal(2, [ Chair indexForObject: _.object(5) inArray: array ]);
  assert_equal(3, [ Chair indexForObject: _.object(6) inArray: array ]);
}

// All code under test must be linked into the Unit Test bundle
- (void)test_chair_dictionary
{
  ChairDictionary* cd = [ ChairDictionary dictionary ];
  assert_equal(cd.keys, _.array());

  [cd setObject: _.object("three") forKey:_.object(3) ];
  assert_equal(cd.keys, _.array(3));

  [cd setObject: _.object("one") forKey:_.object(1) ];
  assert_equal(cd.keys, _.array(1,3));

  [cd setObject: _.object("two") forKey:_.object(2) ];
  assert_equal(cd.keys, _.array(1,2,3));

  [cd setObject: _.object("four") forKey:_.object(4) ];
  assert_equal(cd.keys, _.array(1,2,3,4));

  [cd setObject: _.object("another four") forKey:_.object(4) ];
  assert_equal(cd.keys, _.array(1,2,3,4));

  [cd setObject: nil forKey:_.object(1) ];
  assert_equal(cd.keys, _.array(2,3,4));

  [cd setObject: nil forKey:_.object(3) ];
  assert_equal(cd.keys, _.array(2,4));

  [cd setObject: nil forKey:_.object(4) ];
  [cd setObject: nil forKey:_.object(2) ];
  assert_equal(cd.keys, _.array());
}

template <class T1, class T2>
static NSMutableArray* enum_keys_and_values(ChairDictionary* dictionary, T1 min, T2 max, BOOL excludingEnd) {
  NSMutableArray* rv = _.array();
  [ dictionary each: ^(id value, id key) { [ rv addObject: key ]; [ rv addObject: value ]; }
                min: _.object(min)
                max: _.object(max)
       excludingEnd: excludingEnd ];

  return rv;
}

template <class T1, class T2>
static NSMutableArray* enum_keys(ChairDictionary* dictionary, T1 min, T2 max, BOOL excludingEnd) {
  NSMutableArray* rv = _.array();
  [ dictionary each: ^(id value, id key) { [ rv addObject: key ]; }
                min: _.object(min)
                max: _.object(max)
       excludingEnd: excludingEnd ];

    return rv;
}

- (void)test_chair_enumeration
{
  ChairDictionary* cd = [ ChairDictionary dictionary ];
  assert_equal(cd.keys, _.array());

  [cd setObject: _.object("three") forKey:_.object(3) ];
  [cd setObject: _.object("one") forKey:_.object(1) ];
  [cd setObject: _.object("two") forKey:_.object(2) ];
  [cd setObject: _.object("four") forKey:_.object(4) ];

  // --- enumerate full dictionary, with and without the end

  assert_equal(enum_keys_and_values(cd, 0, 4, NO), 
    _.array(1, "one", 2, "two", 3, "three", 4, "four"));

  assert_equal(enum_keys_and_values(cd, 0, 4, YES), 
    _.array(1, "one", 2, "two", 3, "three"));

  // --- replace an entry
  
  [cd setObject: _.object("another two") forKey:_.object(2) ];
  assert_equal(enum_keys_and_values(cd, 0, 4, NO), 
    _.array(1, "one", 2, "another two", 3, "three", 4, "four"));

  // --- remove { 2: "two" } 
  [cd setObject: nil forKey:_.object(2) ];
  assert_equal(cd.keys, _.array(1, 3, 4));

  // enumerate [0..4] returns 
  assert_equal(enum_keys(cd, 0, 4, NO), _.array(1, 3, 4));
  assert_equal(enum_keys(cd, 0, 5, YES), _.array(1, 3, 4));
  assert_equal(enum_keys(cd, 0, 4, YES), _.array(1, 3));
  assert_equal(enum_keys(cd, 0, 3, YES), _.array(1));
}

/*

template <class T1, class T2>
static NSMutableArray* enum_keys_descending(ChairDictionary* dictionary, T1 min, T2 max, BOOL excludingEnd) {
  NSMutableArray* rv = _.array();
  [ dictionary each: ^(id value, id key) { [ rv addObject: key ]; }
                min: _.object(min)
                max: _.object(max)
        excludingEnd: excludingEnd
          descending: YES ];
  
  return rv;
}


- (void)test_chair_enumeration_descending
{
  ChairDictionary* cd = [ChairDictionary dictionaryWithObjects: _.array("one", "two", "three", "four")
                                                       andKeys: _.array(1,2,3,4) ];

  assert_equal(cd.keys, _.array(1, 2, 3, 4));

  // --- enumerate full dictionary, with and without the end
  
  assert_equal(enum_keys(cd, 0, 4, NO), _.array(1,2,3,4));
  assert_equal(enum_keys_descending(cd, 0, 4, NO), _.array(4,3,2,1));
  assert_equal(enum_keys_descending(cd, 0, 4, YES), _.array(4,3,2,1));
  assert_equal(enum_keys_descending(cd, 1, 4, YES), _.array(4,3,2));
  assert_equal(enum_keys_descending(cd, 1, 4, NO), _.array(4,3,2,1));
  assert_equal(enum_keys_descending(cd, 1.1, 4, NO), _.array(4,3,2));
}
*/


- (void)test_chair_uids
{
  id hash = _.hash("bla", "bla-value", "blu", 12);
  id uid = [Chair uid: hash ];
  
  assert([Chair uid: hash ] != nil);

  hash = _.hash("blu", 12, "bla", "bla-value");
  assert_equal(uid, [Chair uid: hash ]);

  hash = _.hash("blu", 12, "bla", "bla-value", "yum", "my");
  assert_not_equal(uid, [Chair uid: hash ]);
  
  // the _uid is read from the hash, if defined.
  hash = _.hash("blu", 12, "_uid", "some-uid");
  assert_equal("some-uid", [Chair uid: hash ]);
}

- (void)test_import_table
{
  ChairDatabase* db = [ ChairDatabase database ];

  [ db import: @"fixtures/theaters.json" ];
  ChairTable* theaters = [ db tableForName: @"theaters" ];
  assert_equal(13, [ theaters count ]);
}

-(void)test_import_load_and_save
{
  return;
  

  ChairDatabase* db = [ ChairDatabase database ];
  
  [ db import: @"fixtures/flk.json" ];
  [ db save: @"tmp/" ];
  
  // [ db load: @"tmp" ];
}

-(void)test_import
{
  return;
  

  @try {
    ChairDatabase* db = [[ChairDatabase alloc ] init ];
    
    [ db import: @"fixtures/flk.json" ];

    ChairTable* theaters = [db tableForName: @"theaters" ];
    assert_equal(13, [ theaters count ]);

    ChairTable* schedules = [db tableForName: @"schedules" ];
    assert_equal(102, [ schedules count ]);
    
    ChairTable* movies = [db tableForName: @"movies" ];
    assert_equal(83, [ movies count ]);
	} 
	@catch (id theException) {
		NSLog(@"Exception %@", theException);
	} 
}

-(void)test_alloc_and_release
{
  @autoreleasepool {
    ChairDatabase* db = [ ChairDatabase database ];
    ChairTable* schedules = [db tableForName: @"schedules" ];

    ChairView* view = [schedules viewWithMap:nil andReduce:nil];
    view = [schedules viewWithMap: nil andReduce: nil ];

    NSUInteger count = [view count];
  }
}

-(void)test_group_and_view
{
  @autoreleasepool {

    ChairDatabase* db = [ ChairDatabase database ];
    [ db import: @"fixtures/flk.json" ];
    
    // --------------------------------------------------------
    
    ChairTable* schedules = [db tableForName: @"schedules" ];
    assert_equal(102, [ schedules count ]);
    
    ChairView* schedules_ordered_by_theater_id = 
      [ schedules viewWithMap: nil
                     andGroup: ^(NSDictionary* value, id key) { return [ value objectForKey: @"theater_id" ]; }
                    andReduce: nil ];
    
    // 
    assert_equal(102, [ schedules_ordered_by_theater_id count ]);
 
    ChairView* schedules_by_theater;
    schedules_by_theater = [ schedules viewWithMap: nil 
                                          andGroup: ^(NSDictionary* value, id key) { return [ value objectForKey: @"theater_id" ]; }
                                         andReduce: ^(NSArray* values, id key) { return _.hash("count", [ values count ]); } ];

    // [ schedules_by_theater update ];
    assert_equal([ schedules_by_theater keys ], _.array(
      267534162, 374391607, 624179285, 837728461, 1223633946, 1592415747,
      1600891278, 1954940838, 2885852417, 3190279602, 3619205751
    ));

    assert(![ schedules_by_theater get: _.object(1) ]);
    assert_equal(11, [ schedules_by_theater count ]);

    assert_equal(_.hash("count", 8), [ schedules_by_theater get: _.object(267534162) ]);
  }
}

-(void)test_group_by_name
{
  ChairDatabase* db = [ ChairDatabase database ];
  
  [ db import: @"fixtures/flk.json" ];

  // --------------------------------------------------------
  
  ChairTable* schedules = [db tableForName: @"schedules" ];
  assert_equal(102, [ schedules count ]);

  ChairView* schedules_by_theater = [ schedules viewWithMap: nil
                                        andGroup: [ Chair groupBy: @"theater_id" ]
                                       andReduce: [ Chair reduceBy: @"count" ]
                         ];

  // [ schedules_by_theater update ];
  assert_equal([ schedules_by_theater keys ], _.array(
    267534162, 374391607, 624179285, 837728461, 1223633946, 1592415747,
    1600891278, 1954940838, 2885852417, 3190279602, 3619205751
  ));

  assert(![ schedules_by_theater get: _.object(1) ]);
  assert_equal(11, [ schedules_by_theater count ]);

  assert_equal(_.hash("count", 8), [ schedules_by_theater get: _.object(267534162) ]);
}

- (void)test_complex_hash
{
  id objects = _.array(  _.array("one"), _.array("one", "two"));
  id keys = _.array(  _.array(1), _.array(1, 2));

  // ChairDictionary* cd = 
  [[[ChairDictionary alloc ] initWithObjects: objects andKeys: keys ] autorelease];
}

static NSString* range(NSMutableArray* array, id minimum, id maximum) {
  NSRange range = [ Chair rangeInArray: array
                                   min: minimum
                                   max: maximum
                          excludingEnd: NO ];

  return _.join(range.location, "+", range.length);
}

-(void)test_range
{
  NSMutableArray* array = _.array(267534162, 374391607, 624179285, 837728461);
  
  assert_equal("0+4", range(array, nil, nil));
  assert_equal("0+1", range(array, nil, _.object(267534162)));
  assert_equal("0+1", range(array, nil, _.object(267534163)));
}

-(void)test_table_count
{
  ChairDatabase* db = [ ChairDatabase database ];
  [ db import: @"fixtures/theaters.json" ];
  ChairTable* theaters = [ db tableForName: @"theaters" ];

  assert_equal(13, [ theaters count ]);
  assert_equal(13, [ theaters countFrom: nil to: nil excludingEnd: NO ]);

  [ theaters each: ^(id value, id key) {
                     // NSLog(@">>>> key: %@", key); 
                   }
              min: nil
              max: _.object(267534163) 
     excludingEnd: NO ];
 
  // 
  
  [ theaters each: ^(id value, id key) {
                     // NSLog(@">>>> key: %@", key); 
                   }
              min: nil
              max: nil
     excludingEnd: NO ];
}

@end
