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

- (NSUInteger) matches:(id)regexp_or_string
{
  NSRegularExpression* regexp = [ M3 regexp: regexp_or_string];
  
  return [regexp numberOfMatchesInString: self
                                  options: 0
                                    range: NSMakeRange(0, self.length)];
                                                     
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
  assert_equal(1, [@"abc" matches: @"a"]);
  assert_equal(1, [@"abc" matches: [M3 regexp: @"a"]]);
  assert_equal(0, [@"abc" matches: [M3 regexp: @"A"]]);
  assert_equal(1, [@"abc" matches: [M3 regexp: @"A" withOptions: NSRegularExpressionCaseInsensitive]]);
}

@end
