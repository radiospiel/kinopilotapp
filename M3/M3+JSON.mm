#import "M3.h"

#import "JSONKit.h"

/*
 * TODO: Check raise implementation
 */

@implementation M3 (JSON)

+ (id) readJSONFile:(NSString *)path 
{
  NSData* data = [ M3 readDataFromPath: path ];
  NSError* error = 0;
  
  id r = [ data mutableObjectFromJSONDataWithParseOptions: 0 error: &error ];
  if(!r) [ M3Exception raiseWithError: error ];
  
  return r;
}

+ (void) writeJSONFile: (NSString*) path object: (id) object;
{
  NSData* jsonData = [object JSONData];

  [ M3 writeData: jsonData toPath: path ];
}

+ (id) parseJSON:(NSString *)data;
{
  return [ data objectFromJSONString ];
}

+ (NSString*) toJSON: (id) object compact: (BOOL) compact 
{
  NSError* error = 0;
  
  JKFlags flags = 0;
  if(!compact) flags |= JKSerializeOptionPretty;
  
  NSString* r = [ object JSONStringWithOptions: 0 error: &error ];
  if(!r) [ M3Exception raiseWithError: error ];
  
  return r;
}

+ (NSString*) toJSON: (id) object;
{
  BOOL compact = YES;
#ifndef NDEBUG
  compact = NO;
#endif

  return [ self toJSON: object compact: compact ];
}

@end
