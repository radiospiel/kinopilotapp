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

-(BOOL)containsString: (NSString*)aString
{
  return [self indexOfString: aString] != NSNotFound;
}

-(NSUInteger)indexOfString: (NSString*)aString
{
  if(!aString) return NSNotFound;
  
  NSRange range = [self rangeOfString:aString];
  return range.location;
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

-(SEL)to_sym
{
  return NSSelectorFromString(self);
}

-(Class)to_class
{
  Class klass = NSClassFromString(self);
  if(!klass)
    _.raise("No such class: ", self);

  return klass;
}

@end

ETest(NSStringM3Extensions)

-(void)test_camelize
{
  assert_equal(@"Abc", [@"abc" camelizeWord]);
  assert_equal(@"Abc", [@"Abc" camelizeWord]);
  assert_equal(@"A",   [@"A" camelizeWord]);
  assert_equal(@"A",   [@"a" camelizeWord]);
  assert_equal(@"",    [@"" camelizeWord]);
}
@end
