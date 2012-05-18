#import "M3.h"

@implementation NSURL(M3URLExtensions)

-(NSURL*)to_url
{
  return self;
}

-(NSDictionary*)params
{
  if(!self.query) return nil;
  
  NSMutableDictionary * params = [NSMutableDictionary dictionary];

  for (NSString* pair in [self.query componentsSeparatedByString:@"&"]) {
    NSArray* bits = [pair componentsSeparatedByString:@"="];
    NSString* key = [bits.first stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    id value = [bits.second stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if(!value) value = [NSNull null];
    
    [params setObject:value forKey:key];
  }

  return params;
}

-(NSString*)param: (NSString*)key
{
  return [self.params objectForKey:key];
}


@end


@implementation NSString(M3URLExtensions)

-(NSURL*)to_url
{
  NSString* url = self;

  // This is a workaround for use in the kinopilot project
  url = [url stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];

  return [NSURL URLWithString:url];
}

@end
