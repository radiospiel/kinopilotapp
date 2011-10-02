#define NS_BLOCK_ASSERTIONS

/*
 * Defining NS_BLOCK_ASSERTIONS should disable NSCParameterAssert.
 * This, however, seems not to work or not to work completely. 
 */

#undef  NSCParameterAssert
#define NSCParameterAssert(x) (void)0

#import "JSONKit/JSONKit.h"
#import "JSONKit/JSONKit.m"

#import "M3.h"

/*
 * TODO: Check raise implementation
 */

static NSMutableString* gsub(NSString* string, NSString* regexp, NSString* replacement)
{
  NSMutableString* copy = [NSMutableString stringWithString: string];
  
  NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern: regexp
                                                                    options:NSRegularExpressionCaseInsensitive 
                                                                      error:nil];

  NSArray* matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
  [regex release];
                                                                                                
  for (NSTextCheckingResult* match in matches) // Loop through the URL list
  {
    [copy replaceCharactersInRange:match.range withString:replacement];
  }

  return copy;
}




@implementation M3 (JSON)

+ (id) readJSON:(NSString *)path 
{
  NSError* error = 0;
  id returnValue;

  if([path startsWith: @"http://"]) {
    NSData* data = [M3Http requestData: @"GET" 
                                   url: path
                           withOptions: nil];
    
    returnValue = [data mutableObjectFromJSONDataWithParseOptions: 0 error: &error];
  }
  else {
    NSString* data = [M3 read:path];
    returnValue = [data mutableObjectFromJSONStringWithParseOptions:0 error: &error];
  }

  if(!returnValue) _.raise(error);

  return returnValue;
}

+ (void) writeJSONFile: (NSString*) path object: (id) object;
{
  NSData* jsonData = [object JSONData];

  path = [M3 expandPath: path];
  [M3 writeData: jsonData toPath: path];
}

+ (id) parseJSON:(NSString *)data;
{
  Benchmark(@"Parsing JSON");
  return [data objectFromJSONString];
}

+ (NSString*) toJSON: (id) object compact: (BOOL) compact 
{
  NSError* error = 0;
  
  JKFlags flags = 0;
  if(!compact) flags |= JKSerializeOptionPretty;
  
  NSString* r = [object JSONStringWithOptions: flags error: &error];
  if(!r) [M3Exception raiseWithError: error];
  
  return r;
}

+ (NSString*) toJSON: (id) object;
{
  BOOL compact = YES;
#ifndef NDEBUG
  compact = NO;
#endif

  return [self toJSON: object compact: compact];
}

@end

ETest(M3JSON)

- (void) test_json 
{
  id obj = [M3 parseJSON: @"[\"Apple\", \"Banana\"]"];
  assert_equal(obj, _.array("Apple", "Banana"));
  
  NSString* json = [M3 toJSON: obj compact: YES];
  assert_equal(json, "[\"Apple\",\"Banana\"]");
}

@end