#import "M3.h"

#import "RegexKitLite-4.0/RegexKitLite.h"
#import "RegexKitLite-4.0/RegexKitLite.m"

#define CASE_SENSITIVE    (RKLComments | RKLDotAll)
#define CASE_INSENSITIVE  (RKLComments | RKLDotAll | RKLCaseless)

@implementation NSString (Regexp)

// TODO: Raise exception if error is set.

#define RETURN(value, error) return value

- (NSString*) gsub: (NSString*) regexp with: (NSString*) replacement
{
  NSError* error = 0;
  
  NSString* r;
  r = [ self stringByReplacingOccurrencesOfRegex: regexp
                                      withString: replacement 
                                         options: CASE_SENSITIVE
                                           range: NSMakeRange(0, self.length)
                                           error: &error ];

  RETURN(r, error);
}

- (NSString*) igsub: (NSString*) regexp with: (NSString*) replacement
{
  NSError* error = 0;
  
  NSString* r;
  r = [ self stringByReplacingOccurrencesOfRegex: regexp
                                      withString: replacement 
                                         options: CASE_INSENSITIVE
                                           range: NSMakeRange(0, self.length)
                                           error: &error ];

  RETURN(r, error);
}

- (NSArray*) imatches:(NSString*)regexp
{
  NSError* error = 0;
  
  NSArray* r;
  r = [self componentsMatchedByRegex: regexp 
                             options: CASE_INSENSITIVE
                               range: NSMakeRange(0, self.length)
                             capture: 0 
                               error: &error];

  if([r count] == 0) r = nil;
  RETURN(r, error);
}

- (NSArray*) matches:(NSString*)regexp
{
  NSError* error = 0;
  
  NSArray* r;
  r = [self componentsMatchedByRegex: regexp 
                             options: CASE_SENSITIVE
                               range: NSMakeRange(0, self.length)
                             capture: 0 
                               error: &error];

  if([r count] == 0) r = nil;
  RETURN(r, error);
}

        
@end

// @implementation M3(Regexp)
// 
// +(NSRegularExpression*) regexp: (id)regexp_or_string;
// {
//   if([regexp_or_string isKindOfClass: [NSRegularExpression class]])
//     return regexp_or_string;
// 
//   NSError *error = NULL;
//   return [NSRegularExpression regularExpressionWithPattern: regexp_or_string
//                                                    options: 0 
//                                                      error: &error];
// }
// 
// +(NSRegularExpression*) regexp: (id)regexp_or_string withOptions: (int)options;
// {
//   if([regexp_or_string isKindOfClass: [NSRegularExpression class]])
//     return regexp_or_string;
// 
//   NSError *error = NULL;
//   return [NSRegularExpression regularExpressionWithPattern: regexp_or_string
//                                                    options: options
//                                                      error: &error];
// }
// 
// @end

ETest(Regexp)

-(void)test_regexp
{
  assert_true([@"abc" matches: @"a"]);
  // assert_true([@"abc" matches: [M3 regexp: @"a"]]);
  // assert_false([@"abc" matches: [M3 regexp: @"A"]]);
  // assert_true([@"abc" matches: [M3 regexp: @"A" withOptions: NSRegularExpressionCaseInsensitive]]);
}

-(void)test_submatches
{
  // assert_equal([@"abc abc" matches: @"abc"],    _.array("abc", "abc"));
  // assert_equal([@"ab abc" matches: @"abc"],     _.array("abc"));
  // assert_nil([@"ab abc" matches: @"xyz"]);
  // assert_equal([@"ab abc" matches: @"ab(c?)"],  _.array("ab", "abc"));
  // assert_equal([@"abc abc" matches: @"abc?"],   _.array("abc", "abc"));
}

// -(void)test_submatches
// {
//   assert_equal([@"abc abc" matches: @"abc"],    _.array("abc", "abc"));
//   assert_equal([@"ab abc" matches: @"abc"],     _.array("abc"));
//   assert_nil([@"ab abc" matches: @"xyz"]);
//   assert_equal([@"ab abc" matches: @"ab(c?)"],  _.array("ab", "abc"));
//   assert_equal([@"abc abc" matches: @"abc?"],   _.array("abc", "abc"));
// }
// 
// -(void)test_regexp_parsing
// {
//   assert_equal([@"/controller/action/parameters" matches: @"^/(\\w+)/(\\w+)(/(.*))?"], _.array("controller", "action", "parameters"));
// }
// 
@end
