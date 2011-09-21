//
//  NSString+M3Extensions.mm
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//
#import "M3.h"

@implementation NSString(M3Extensions)

-(BOOL)startsWith: (NSString*) other
{
  if(!other) return NO;
  if([self length] < [other length]) return NO;

  NSString* me = [self substringToIndex: other.length];
  return [me isEqualToString: other];
}

-(NSString*)camelizeWord;
{
  if(self.length == 0)
    return @"";
  
  NSString* firstLetter = [self substringToIndex:1];
  NSString* remainder = [self substringFromIndex:1];
  return _.join([firstLetter uppercaseString], remainder);
}

-(NSNumber*)to_number
{
  NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
  return [formatter numberFromString: self];
}

@end

ETest(NSStringM3Extensions)

-(void)test_starts_with
{
  assert_true([@"abc def" startsWith: @"abc"]);
  assert_false([@"abc def" startsWith: @"def"]);
  assert_false([@"ab" startsWith: @"def"]);
  assert_false([@"ab" startsWith: @"abc"]);
  assert_false([@"" startsWith: @"abc"]);

  // Note: each string starts with an empty string.
  assert_true([@"ab" startsWith: @""]);
  assert_true([@"" startsWith: @""]);
}

-(void)test_camelize
{
  assert_equal(@"Abc", [@"abc" camelizeWord]);
  assert_equal(@"Abc", [@"Abc" camelizeWord]);
  assert_equal(@"A",   [@"A" camelizeWord]);
  assert_equal(@"A",   [@"a" camelizeWord]);
  assert_equal(@"",    [@"" camelizeWord]);
}
@end
