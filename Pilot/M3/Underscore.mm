//
//  Underscore.m
//
//  Created by Enrico Thierbach on 12.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "M3.h"
#import "Underscore.hh"

RS::UnderscoreAdapter _;

namespace RS {
  
  void UnderscoreAdapter::print(const char* s) {
    NSLog(@"%s", s);
  }

  void UnderscoreAdapter::print(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat: format
                                                  arguments: args];
    va_end(args);

    NSLog(@"%@", formattedString);
    [formattedString release];
  }

  void UnderscoreAdapter::puts(const char* s) {
    NSLog(@"%s\n", s);
  }

  void UnderscoreAdapter::puts(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat: format
                                                  arguments: args];
    va_end(args);

    NSLog(@"%@\n", formattedString);
    [formattedString release];
  }

  NSString* RaiseFactory::run() const {
    NSString* msg = [arguments_ componentsJoinedByString: @""];
    rlog(1) << msg;
    @throw [RuntimeError errorWithMessage:msg];
  }

}; // namespace RS ----------------------------------------------------

#if 0

ETest(UnderscoreAdapter)

- (void)test_underscore_helpers
{
  NSNumber* one = [NSNumber numberWithInt: 1];
  id o1 = _.object(1);
  _.join("actual is", o1, "but should be", one);
  
  assert_equal_objects(_.object(1), one);
  
  NSArray* array, *expected;
  
  array = _.array(0, 11, 22, 33, 44);
  expected = [NSArray arrayWithObjects: _.object(0), _.object(11), 
              _.object(22), _.object(33), 
              _.object(44), nil];
  
  assert_equal_objects(array, expected);
  
  assert_equal_objects(_.array(), [NSArray array]);
}

- (void)test_join
{
  assert_equal(@"abc", _.string("abc"));
  id joined = _.join("abc", 1);
  assert_equal(@"abc1", joined);
}

@end

#endif
