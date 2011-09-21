#import "M3.h"

@implementation NSString (Regexp)

- (NSString*) gsub: (id) regexp_or_string with: (NSString*) replacement
{
  NSRegularExpression* regexp = [ M3 regexp: regexp_or_string];

  return [regexp stringByReplacingMatchesInString:self
                                          options:0
                                            range:NSMakeRange(0, self.length)
                                     withTemplate:replacement];
}

- (NSArray*) matches:(id)regexp_or_string
{
  NSRegularExpression* regexp = [ M3 regexp:regexp_or_string];

  NSArray* regexp_matches = [ regexp matchesInString:self
                                             options:0 
                                               range:NSMakeRange(0, self.length) ];
  
  if(regexp_matches.count == 0) return nil;
  
  NSMutableArray* matches = [NSMutableArray array];
  for(NSTextCheckingResult* regexp_match in regexp_matches) {
    NSString* match = [self substringWithRange:[regexp_match range]];
    [matches addObject: match];
  }
  
  return matches;
}

        
@end

@implementation M3(Regexp)

+(NSRegularExpression*) regexp: (id)regexp_or_string;
{
  if([regexp_or_string isKindOfClass: [NSRegularExpression class]])
    return regexp_or_string;

  NSError *error = NULL;
  return [NSRegularExpression regularExpressionWithPattern: regexp_or_string
                                                   options: 0 
                                                     error: &error];
}

+(NSRegularExpression*) regexp: (id)regexp_or_string withOptions: (int)options;
{
  if([regexp_or_string isKindOfClass: [NSRegularExpression class]])
    return regexp_or_string;

  NSError *error = NULL;
  return [NSRegularExpression regularExpressionWithPattern: regexp_or_string
                                                   options: options
                                                     error: &error];
}

@end

ETest(Regexp)

-(void)test_regexp
{
  assert_true([@"abc" matches: @"a"]);
  assert_true([@"abc" matches: [M3 regexp: @"a"]]);
  assert_false([@"abc" matches: [M3 regexp: @"A"]]);
  assert_true([@"abc" matches: [M3 regexp: @"A" withOptions: NSRegularExpressionCaseInsensitive]]);
}

-(void)test_regexp2
{
  assert_equal([@"abc abc" matches: @"abc"],    _.array("abc", "abc"));
  assert_equal([@"ab abc" matches: @"abc"],     _.array("abc"));
  assert_nil([@"ab abc" matches: @"xyz"]);
  assert_equal([@"ab abc" matches: @"ab(c?)"],  _.array("ab", "abc"));
  assert_equal([@"abc abc" matches: @"abc?"],   _.array("abc", "abc"));
}

@end
