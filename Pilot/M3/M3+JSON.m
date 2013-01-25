#import "M3.h"

@implementation M3 (JSON)

/* --- parse JSON --------------------------------------------------------- */

// read a path or a URL, parse and return the JSON
+ (id) readJSON:(NSString *)path 
{
  NSData* jsonData;

  if([path hasPrefix: @"http://"]) {
    jsonData = [M3Http requestData: @"GET"
                           url: path
                   withOptions: nil];
  }
  else {
    jsonData = [M3 readDataFromPath:path];
  }

  return [self parseJSONData:jsonData];
}

+ (id) parseJSON:(NSString *)string;
{
  NSData* jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
  return [self parseJSONData:jsonData];
}

+ (id) parseJSONData:(NSData *)jsonData;
{
  NSError* error = 0;
  id returnValue = [NSJSONSerialization JSONObjectWithData:jsonData
                                                   options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                     error:&error];
  
  [M3Exception raiseOnError: error];
  
  return returnValue;
}

/* --- generate JSON ------------------------------------------------------ */

#ifndef NDEBUG
#define DEFAULT_COMPACT NO
#else
#define DEFAULT_COMPACT YES
#endif

+ (NSData*) toJSONData: (id) object compact: (BOOL) compact
{
  NSError* error = 0;
  NSData* data;
  
  data = [NSJSONSerialization dataWithJSONObject:object
                                         options:(compact ? 0 : NSJSONWritingPrettyPrinted)
                                           error:&error];
  
  [M3Exception raiseOnError: error];
  
  
  return data;
}

+ (void) writeJSONFile: (NSString*) path object: (id) object;
{
  NSData* jsonData = [self toJSONData:object compact:DEFAULT_COMPACT];
  path = [M3 expandPath: path];
  
  [M3 writeData: jsonData toPath: path];
}

+ (NSString*) toJSON: (id) object compact: (BOOL) compact
{
  NSData* data = [self toJSONData:object compact:compact];
  
  NSString* r = [[NSString alloc] initWithData:data
                                      encoding:NSUTF8StringEncoding];

  return r;
}

+ (NSString*) toJSON: (id) object;
{
  return [self toJSON: object compact: DEFAULT_COMPACT];
}

@end

#if 0

ETest(M3JSON)

- (void) test_json 
{
  id obj = [M3 parseJSON: @"[\"Apple\", \"Banana\"]"];
  assert_equal(obj, _.array("Apple", "Banana"));
  
  NSString* json = [M3 toJSON: obj compact: YES];
  assert_equal(json, "[\"Apple\",\"Banana\"]");
}

@end

#endif
