#if TARGET_OS_IPHONE 

#import "M3.h"
#import "M3AppDelegate.h"

#define URBAN_AIRSHIP_KEY             @"GtsLZbbmRQ6Kq9XXy3LPbg"
#define URBAN_AIRSHIP_SECRET          @"9ir2nj6jTk-aC2NKpPXKiw"
#define URBAN_AIRSHIP_MASTER_SECRET   @"qXWB90OkTL2HQoGLT0O-lw"

#define NOTIFICATIONS                 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)

// #define NOTIFICATIONS                 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)

@implementation M3AppDelegate(RemoteNotification)

-(void)enableRemoteNotifications 
{
  if(![app.config objectForKey: @"remoteNotifications"]) return;

  dlog << "Enable remoteNotifications";
  
  UIRemoteNotificationType notifications = (UIRemoteNotificationType)NOTIFICATIONS;
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes: notifications];
}

-(void)registerRemoteNotificationDeviceToken: (NSData*)deviceToken
{
  NSString* token = deviceToken.description;
  token = [token stringByReplacingOccurrencesOfString: @"<" withString: @""];
  token = [token stringByReplacingOccurrencesOfString: @">" withString: @""];
  token = [token stringByReplacingOccurrencesOfString: @" " withString: @""];

  dlog << "*** Got notification registration for " << token;

  // The token should be stored and reused for various aspects of the Urban Airship API.
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
  NSDictionary* aps = [userInfo objectForKey:@"aps"];
  NSString* url = [aps objectForKey:@"url"];
  if([url isKindOfClass:[NSString class]]) {
    [self open:url];
  }
}

@end

#endif
