#import "M3.h"
#import "M3AppDelegate.h"

#define URBAN_AIRSHIP_KEY             @"GtsLZbbmRQ6Kq9XXy3LPbg"
#define URBAN_AIRSHIP_SECRET          @"9ir2nj6jTk-aC2NKpPXKiw"
#define URBAN_AIRSHIP_MASTER_SECRET   @"qXWB90OkTL2HQoGLT0O-lw"

@implementation M3AppDelegate(RemoteNotification)

-(void)enableRemoteNotifications 
{
  UIRemoteNotificationType notifications = (UIRemoteNotificationType)
  (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes: notifications];
}

-(void)registerRemoteNotificationDeviceToken: (NSData*)deviceToken
{
  NSString* token = deviceToken.description;
  token = [token stringByReplacingOccurrencesOfString: @"<" withString: @""];
  token = [token stringByReplacingOccurrencesOfString: @">" withString: @""];
  token = [token stringByReplacingOccurrencesOfString: @" " withString: @""];

  dlog << "*** Got notification registration for " << token;

  // The token could be stored and reused for various aspects of the
  // Urban Airship API.
}

-(void)application: (UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [self registerRemoteNotificationDeviceToken: deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
  NSString *str = [NSString stringWithFormat: @"Error: %@", err];
  NSLog(@"*** No notification registration: %@",str);    
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo { 
  dlog << "*** receive notification " << userInfo;
}

@end

