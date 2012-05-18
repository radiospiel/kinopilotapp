#import "M3.h"

@implementation NSURL(Params)

-(NSDictionary*)params
{
  //NSString *urlString = [url absoluteString];
  
  //NSURL* uri = [NSURL URLWithString:self.url_string];
  //if(!uri.query) return nil;
  
  NSMutableDictionary * params = [NSMutableDictionary dictionary];

  for (NSString* pair in [self.query componentsSeparatedByString:@"&"]) {
    NSArray* bits = [pair componentsSeparatedByString:@"="];
    NSString* key = [bits.first stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    id value = [bits.second stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if(!value) value = [NSNull null];
    
    [params setObject:value forKey:key];
  }

  return params;
};

@end
