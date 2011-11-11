#import "M3.h"
#import "MixpanelAPI.h"

static MixpanelAPI* mixpanelApi = nil;

#define MIXPANEL_TOKEN @"93ab63eb89a79f22a5b777881c916e7a"

static MixpanelAPI* getMixpanelApi()
{
  if(!mixpanelApi) {
    mixpanelApi = [MixpanelAPI sharedAPIWithToken:MIXPANEL_TOKEN]; 
  }
  
  return mixpanelApi;
}

@implementation M3AppDelegate(EventTracking)

-(void)trackEvent: (NSString*) event
{
  [self trackEvent:event properties:nil];
}

-(void)trackEvent: (NSString*) event properties: (NSDictionary*) properties
{
  [mixpanelApi track:event properties:properties];
}

@end
