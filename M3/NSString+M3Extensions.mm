//
//  NSString+M3Extensions.mm
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//
#import "M3.h"


#define _GTMDevAssert(x,y)  ((void)0)
#define _GTMDevLog(x)       ((void)0)

#import "google-toolbox/GTMNSString+HTML.h"
#import "google-toolbox/GTMNSString+HTML.m"

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

-(NSString*)dquote
{
  return [NSString stringWithFormat: @"\u201C%@\u201D", self];
}

-(NSString*)squote
{
  return [NSString stringWithFormat: @"\u2018%@\u2019", self];
}

-(NSString*)quote
{
  return [self dquote];
}

-(NSString*)cdata
{
  return [NSString stringWithFormat: @"<![CDATA[%@]]>", self];
}

-(NSDate*)to_date
  { return [NSDate dateWithRFC3339String: self]; }

-(NSString*)htmlEscape
{
  return [self gtm_stringByEscapingForHTML];
}

-(NSString*)htmlUnescape
{
  return [self gtm_stringByUnescapingFromHTML];
}

-(NSString*)urlEscape
{
  return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSString*)urlUnescape
{
  return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSURL*)to_url
{
  return [NSURL URLWithString:self];
}

-(SEL)to_sym
{
  return NSSelectorFromString(self);
}

-(NSString*)to_class
{
  Class klass = NSClassFromString(self);
  if(!klass)
    _.raise("No such class: ", self);

  return klass;
}

@end

@implementation NSURL(M3Extensions)
-(NSURL*)to_url
{ 
  return self; 
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
