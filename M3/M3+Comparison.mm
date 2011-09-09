//
//  M3.m
//
//  Created by Enrico Thierbach on 12.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "M3.h"
#import "Underscore.hh"

// Categories for comparision
enum {
  Category_Nil,
  
  Category_Numbers,
  Category_Date,
  Category_Strings,

  Category_Array,
  Category_Objects
};

static int comparison_category(id obj) {
  if(!obj) 
    return Category_Nil;
  if([obj isKindOfClass: [NSNull class]]) 
    return Category_Nil;
  if([obj isKindOfClass: [NSNumber class]]) 
    return Category_Numbers;
  if([obj isKindOfClass: [NSDate class]]) 
    return Category_Date;
  if([obj isKindOfClass: [NSString class]]) 
    return Category_Strings;
  if([obj isKindOfClass: [NSArray class]]) 
    return Category_Array;
  if([obj isKindOfClass: [NSObject class]]) 
    return Category_Objects;
  
  _.raise("No comparison support for", NSStringFromClass([obj class]), "objects");
  __builtin_unreachable();
}

/*
 * This could probably be optimized to sign((int)value - (int)other)
 */

template <class Integer>
inline int compare_int(Integer value, Integer other) {
  if(value < other) return NSOrderedAscending;
  if(other < value) return NSOrderedDescending;
  return NSOrderedSame;
}

NSComparisonResult RS::UnderscoreAdapter::compare_(id value, id other) {
  int value_category = comparison_category(value);
  int other_category = comparison_category(other);

  if(value_category != other_category)
    return compare_int(value_category, other_category);
  
  switch(value_category) {
    case Category_Numbers:
      return [value compare: other];
    case Category_Strings:
      return [value compare: other];  // or should we use localizedCompare?

    case Category_Array:
    {
      NSUInteger value_count = [value count];
      NSUInteger other_count = [other count];

      for(NSUInteger idx = 0; idx < (value_count < other_count ? value_count : other_count); ++idx) {
        NSComparisonResult r = compare([value objectAtIndex: idx], [other objectAtIndex: idx]);
        if(r) return r;
      }
      
      return compare_int(value_count, other_count);
    }
    case Category_Objects:
    {
      // CouchDB's object comparison requests stable key order. This we don't
      // get from a NSDictionary. Too bad. Therefore we implement a different
      // search order algorithm: we compare all entries that exist in one or
      // the other dictionary, in sorted order.

      NSUInteger capacity = [value count] + [other count];
      NSMutableArray* keys = [NSMutableArray arrayWithCapacity: capacity] ;

      [keys addObjectsFromArray: [value allKeys]];
      [keys addObjectsFromArray: [other allKeys]];
      [keys sortUsingSelector: @selector(compare:)];

      for(NSString* key in keys) {
        NSComparisonResult r = compare([value valueForKey: key], [other valueForKey: key]);
        if(r) return r;
      }
      
      return NSOrderedSame;
    }
      
    default:
      // Should never happen.
      _.raise("Unsupported comparison category", value_category);
      __builtin_unreachable();
  };
}

@implementation M3(Comparison)

+ (NSComparisonResult) compare: (id) value 
                          with: (id) other {
  return _.compare(value, other);
}

@end

ETest(M3Comparison)

- (void)testComparison
{
  assert_equal(-1, _.compare(1, 2));
  assert_equal(0,  _.compare(1, 1));
  assert_equal(1,  _.compare(1, 0));
  
  assert_equal(-1, _.compare(1, "2"));
  assert_equal(-1, _.compare(1, "1"));
  assert_equal(-1, _.compare(1, "0"));
  
  assert_equal(-1, _.compare(1, @"2"));
  assert_equal(-1, _.compare(1, @"1"));
  assert_equal(-1, _.compare(1, @"0"));
  
  assert_equal(-1, _.compare("1", "2"));
  assert_equal(0,  _.compare("1", "1"));
  assert_equal(1,  _.compare("1", "0"));
}

@end
