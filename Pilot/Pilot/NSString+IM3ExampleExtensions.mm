#import "M3AppDelegate.h"

@implementation NSString (IM3ExampleExtensions)

-(NSString*) withVersionString: (NSString*)versionString;
{
  if(!versionString) return self;
  if([versionString isKindOfClass:[NSNull class]]) return self;
  return [self stringByAppendingFormat:@" (%@)", versionString];
}

@end
