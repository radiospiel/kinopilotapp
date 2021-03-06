#if TARGET_OS_IPHONE 

#import "M3AppDelegate.h"
#import "Flurry.h"

@implementation M3AppDelegate(EventTracking)

-(void)trackEvent: (NSString*) event properties: (NSDictionary*) properties
{
#ifdef DEBUG
  NSLog(@"Ignoring trackEvent: %@", event);
#else
  [Flurry logEvent:event withParameters:properties];
#endif
}

-(void)trackEvent: (NSString*) event
{
  [self trackEvent:event properties:nil];
}

@end

#endif
