//
//  M3Tests.m
//  M3Tests
//
//  Created by Enrico Thierbach on 04.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
#import "M3+JSON.h"
#import "Underscore.hh"
#import "M3Tests.h"

/* Test helper macros */

#define assert_equals(a, e) STAssertEqualObjects(_.object(a), _.object(e), nil)
#define assert_true(a)      STAssertTrue(a, nil)

@implementation M3Tests

- (void)setUp
{
  [super setUp];
  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  [super tearDown];
}

- (void)test_join
{
  assert_equals(@"abc", _.string("abc"));
  id joined = _.join("abc", 1);
  assert_equals(@"abc1", joined);
}

- (void)test_underscore_helpers
{
  NSNumber* one = [NSNumber numberWithInt: 1];
  id o1 = _.object(1);
  _.join("actual is", o1, "but should be", one);
  
  assert_equals(_.object(1), one);
  
  NSArray* array, *expected;
  
  array = _.array(0, 11, 22, 33, 44);
  expected = [NSArray arrayWithObjects: _.object(0), _.object(11), 
              _.object(22), _.object(33), 
              _.object(44), nil];
  
  assert_equals(array, expected);
  
  assert_equals(_.array(), [NSArray array]);
}

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
  
  assert_equals(values, _.array());
  assert_equals(keys, _.array());
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
  
  assert_equals(values, _.array(0, 11, 22, 33, 44));
  assert_equals(keys, _.array(0, 1, 2, 3, 4));
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
  
  assert_equals(values, _.array(0, 11, 22, 33, 44));
  assert_equals(keys, _.array(0, 1, 2, 3, 4));
}


- (void)testInject
{
  id sum = _.inject(_.array(0, 11, 22, 33, 44),
                    ^id(id memo, id value, id key) {
                      int sum = memo ? [memo intValue] : 0;
                      sum += [value intValue];
                      return [NSNumber numberWithInt: sum];
                    });
  
  assert_equals(sum, 110);
  
  sum = _.inject(_.array(0, 11, 22, 33, 44), 0,
                 ^id(id memo, id value, id key) {
                   int sum = [memo intValue] + [value intValue];
                   return _.object(sum);
                 });
  
  assert_equals(sum, 110);
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
  
  assert_equals(grouped, expected);
}


- (void)testUnderscoreInject
{
  id sum = _.inject(_.array(0, 11, 22, 33, 44),
                    ^id(id memo, id value, id key) {
                      int sum = memo ? [memo intValue] : 0;
                      sum += [value intValue];
                      return _.object(sum);
                    });
  
  assert_equals(sum, 110);
  
  sum = _.inject(_.array(0, 11, 22, 33, 44),
                 _.object(0),
                 ^id(id memo, id value, id key) {
                   return _.object([memo intValue] + [value intValue]);
                 });
  
  assert_equals(sum, 110);
}


#define cmp(a,b) (int) _.compare(a,b)

- (void)testComparison
{
  assert_equals(-1, _.compare(1, 2));
  assert_equals(0,  _.compare(1, 1));
  assert_equals(1,  _.compare(1, 0));
  
  assert_equals(-1, _.compare(1, "2"));
  assert_equals(-1, _.compare(1, "1"));
  assert_equals(-1, _.compare(1, "0"));
  
  assert_equals(-1, _.compare(1, @"2"));
  assert_equals(-1, _.compare(1, @"1"));
  assert_equals(-1, _.compare(1, @"0"));
  
  assert_equals(-1, _.compare("1", "2"));
  assert_equals(0,  _.compare("1", "1"));
  assert_equals(1,  _.compare("1", "0"));
}

- (void) test_json 
{
  id obj = [M3 parseJSON: @"[\"Apple\", \"Banana\"]"];
  assert_equals(obj, _.array("Apple", "Banana"));
  
  NSString* json = [M3 toJSON: obj compact: YES];
  assert_equals(json, "[\"Apple\",\"Banana\"]");
}

- (void) test_etest 
{
  [ M3ETest runAll ];
}

@end
