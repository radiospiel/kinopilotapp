#import "M3.h"

#define READ_OPTIONS            (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments)
#define WRITE_OPTIONS           NSJSONWritingPrettyPrinted
#define COMPACT_WRITE_OPTIONS   0

@implementation M3(JSON)

+(id) parseJSONData: (NSData*) data;
{
  if(!data) return nil;
  
  NSError* error = 0;
  id rv = [NSJSONSerialization JSONObjectWithData: data options:READ_OPTIONS error:&error];
  [M3Exception raiseOnError: error];
  
  return rv;
}

+ (id) parseJSON:(NSString *)data;
{
  return [self parseJSONData: [data dataUsingEncoding:NSUTF8StringEncoding] ];
}

+(id) readJSON:(NSString *)path 
{
  NSData* data;
  
  if([path hasPrefix: @"http://"]) {
    data = [M3Http requestData: @"GET" 
                           url: path
                   withOptions: nil];
  }
  else {
    data = [M3 readDataFromPath:path];
  }
  
  return [self parseJSONData:data];
}

+(void) writeJSONFile: (NSString*) path object: (id) object;
{
  NSData* data;
  data = [NSJSONSerialization dataWithJSONObject: object
                                         options: WRITE_OPTIONS
                                           error: 0];
                                                 
  path = [M3 expandPath: path];
  [M3 writeData: data toPath: path];
}

+ (NSString*) toJSON: (id) object compact: (BOOL) compact 
{
  NSJSONWritingOptions options = compact ? COMPACT_WRITE_OPTIONS : WRITE_OPTIONS;
  
  NSData* data = [NSJSONSerialization dataWithJSONObject: object
                                                 options: options
                                                   error: 0];

  NSString* str = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
  
  return [str autorelease];
}

+ (NSString*) toJSON: (id) object;
{
#ifndef NDEBUG
  return [self toJSON: object compact: NO];
#else
  return [self toJSON: object compact: YES];
#endif
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
