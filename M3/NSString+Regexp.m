#import "M3.h"

#define RKL_BLOCKS          0
#define NS_BLOCK_ASSERTIONS 1

#import "RegexKitLite-4.0/RegexKitLite.h"
#import "RegexKitLite-4.0/RegexKitLite.m"

#define CASE_SENSITIVE    (RKLComments | RKLDotAll)
#define CASE_INSENSITIVE  (RKLComments | RKLDotAll | RKLCaseless)

@implementation NSString (Regexp)

+(void)setRecentMatches: (NSArray*)matches
{
  [[[NSThread currentThread]threadDictionary] setObject:matches forKey: @"regex_match"];
}

+(NSString*)getRecentMatchAtIndex: (NSUInteger)idx
{
  NSArray* currentMatches = [[[NSThread currentThread]threadDictionary] objectForKey: @"regex_match"];
  if(!currentMatches || currentMatches.count <= idx) return nil;
  return [currentMatches objectAtIndex:idx];
}

// TODO: Raise exception if error is set.

#define RETURN(value, error) return value

/* 
 * try to match and, if matching, return matches and submatches.
 * This sets the $0, $1, etc. pseudo-variables, too.
 */
- (NSArray*) matches:(NSString*)regexp withOptions: (int)options
{
  // we could probably use NSString#arrayOfCaptureComponentsMatchedByRegex:regexString

  NSError* error = 0;
  
  NSArray* matches = [self componentsMatchedByRegex: regexp 
                                            options: options
                                              range: NSMakeRange(0, self.length)
                                            capture: 0 
                                              error: &error];
  
  // NSLog(@"%@.matches: %@", self, regexp);
  
  if([matches count] == 1) {
    
    // one match: enumerate submatches
    
    long captureCount = [regexp captureCount];
    if(captureCount) {
      matches = [NSMutableArray arrayWithObject: [matches objectAtIndex: 0]];
      
      for(long i=1L; i<=captureCount; ++i) {
        NSString *submatch = [self stringByMatching:regexp capture:i];
        if(!submatch) break;
        
        [((NSMutableArray*)matches) addObject: submatch];
      }
    }
  }

  // NSLog(@"matches: %@", matches.inspect);

  [NSString setRecentMatches: matches];

  if([matches count] == 0)
    return nil;
  
  RETURN(matches, error);
}

/* 
 * replace
 */

- (NSString*) gsub: (NSString*) regexp with: (NSString*) replacement andOptions: (int)options
{
  // Try to match. This sets $0, $1, etc.
  if(![self matches: regexp withOptions: options])
    return self;
  
  NSError* error = 0;
  
  NSString* r;
  r = [ self stringByReplacingOccurrencesOfRegex: regexp
                                      withString: replacement 
                                         options: options
                                           range: NSMakeRange(0, self.length)
                                           error: &error ];

  RETURN(r, error);
}

/* 
 * replace: public API
 */


- (NSString*) gsub: (NSString*) regexp with: (NSString*) replacement
{
  return [self gsub: regexp with: replacement andOptions: CASE_SENSITIVE];
}

- (NSString*) igsub: (NSString*) regexp with: (NSString*) replacement
{
  return [self gsub: regexp with: replacement andOptions: CASE_INSENSITIVE];
}

/* 
 * match: public API
 */

- (NSArray*) imatches:(NSString*)regexp
{
  return [self matches:regexp withOptions: CASE_INSENSITIVE];
}

- (NSArray*) matches:(NSString*)regexp
{
  return [self matches:regexp withOptions: CASE_SENSITIVE];
}

@end

ETest(Regexp)

-(void)test_regexp
{
  assert_true([@"abc" matches: @"a"]);
  assert_false([@"abc" matches: @"A"]);
  assert_true([@"abc" imatches: @"A"]);
}

-(void)test_submatches
{
  assert_equal_objects([@"abc abc" matches: @"abc"],    ([NSArray arrayWithObjects: @"abc", @"abc", nil])); 
  assert_equal_objects([@"ab abc" matches: @"abc"],     ([NSArray arrayWithObjects: @"abc", nil])); 
  assert_nil([@"ab abc" matches: @"xyz"]);

  assert_equal_objects([@"ab abc" matches: @"ab(c?)"],  ([NSArray arrayWithObjects: @"ab", @"abc", nil]));
  assert_equal_objects([@"abc abc" matches: @"ab(c?)"], ([NSArray arrayWithObjects: @"abc", @"abc", nil]));
}


-(void)test_regexp_parse_submatches
{
  NSString* s = @"/controller/action/parameters";
  assert_equal_objects(
    [s matches: @"^/(\\w+)/(\\w+)(/(.*))?"],
    ([NSArray arrayWithObjects: @"/controller/action/parameters", @"controller", @"action", @"/parameters", @"parameters", nil])
  );

  assert_equal_objects($0, @"/controller/action/parameters");
  assert_equal_objects($1, @"controller");
  assert_equal_objects($2, @"action");
  assert_equal_objects($4, @"parameters");
}

-(void)test_regexp_parse_color
{
  assert_true([@"#abc" imatches: @"^#([0-9a-z])([0-9a-z])([0-9a-z])$"]);

  assert_equal_objects($1, @"a");
  assert_equal_objects($2, @"b");
  assert_equal_objects($3, @"c");
  // 
  // assert_false([@"#abc" imatches: @"#([0-9a-z][0-9a-z])([0-9a-z][0-9a-z])([0-9a-z][0-9a-z])"]);
  // 
  // assert_equal_objects($1, @"a");
  // assert_equal_objects($2, @"b");
  // assert_equal_objects($3, @"c");
}
 
@end
