//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#if TARGET_OS_IPHONE 

#import "M3AppDelegate.h"
#import "UIViewController+M3Extensions.h"

#import "MixpanelAPI.h"
#define MIXPANEL_TOKEN @"93ab63eb89a79f22a5b777881c916e7a"

#import "FlurryAnalytics.h"
#define FLURRY_API_KEY @"KJ96KEEHE5Y58NZURG2H"

// for network status
#include <netdb.h>
#include <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "iRate.h"

M3AppDelegate* app;

@interface M3AppDelegate()
@end

@implementation M3AppDelegate

@synthesize window, tabBarController, facebook;

+ (void)initialize
{
  // -- configure iRate
  iRate* r = [iRate sharedInstance];
  r.appStoreID = APP_STORE_ID;
  r.applicationName = @"Kinopilot";
  r.daysUntilPrompt = 3;
  r.remindPeriod = 5;
  r.messageTitle = @"Kinopilot bewerten...";
  r.message = @"Gefällt Dir unser Kinopilot? "
               "Dann bewerte die App doch im Appstore. "
               "Danke für Deine Unterstützung!";
  r.cancelButtonLabel = @"Nein, danke!";
  r.rateButtonLabel = @"Vielleicht später.";
  r.remindButtonLabel  = @"Ja, gern!";
}

- (void)dealloc
{
  self.window = nil;
  self.tabBarController = nil;
  
  [super dealloc];
}

-(UINavigationController*)topMostController
{
  // Get top-most controller.
  UINavigationController* nc;
  if(!self.tabBarController) {
    nc = (UINavigationController*)self.window.rootViewController;
  }
  else {
    nc = (UINavigationController*) self.tabBarController.selectedViewController;
    if(!nc)
      nc = (UINavigationController*) [self.tabBarController.viewControllers objectAtIndex:0];
  }
  
  M3AssertKindOf(nc, UINavigationController);
  return nc;
}

-(void)presentControllerOnTop: (UIViewController*)viewController
{
  UINavigationController* nc = [self topMostController];
  [nc.navigationBar setBarStyle:UIBarStyleBlackOpaque];
  [nc pushViewController:viewController animated:YES];
}


-(void)navigationController:(UINavigationController *) nc 
     willShowViewController:(UIViewController *) vc 
                   animated:(BOOL)anmated
{
  UITabBarController* tbc = self.tabBarController;

  // find the tab bars content view.
  NSArray* subviews = tbc.view.subviews;
  UIView *contentView = [subviews.first isKindOfClass:[UITabBar class]] ?
    subviews.second : subviews.first;
  
  if([vc isFullscreen]) {
    [nc setNavigationBarHidden: YES animated: YES];
    
    CGRect frame = [[UIScreen mainScreen]bounds];
    contentView.frame = frame;
    
    tbc.tabBar.hidden = YES;
  }
  else {
    [nc setNavigationBarHidden: NO animated: YES];
    tbc.tabBar.hidden = NO;
    
    CGRect frame = [[UIScreen mainScreen]bounds];
    frame.size.height -= tbc.tabBar.frame.size.height;
    contentView.frame = frame;
    
    tbc.tabBar.hidden = NO;
  }
}

-(void)navigationController:(UINavigationController *) nc 
      didShowViewController:(UIViewController *) vc 
                   animated:(BOOL)anmated
{
}

-(UINavigationController*)navigationControllerForTab: (NSDictionary*)tab
{
  NSString* url = [tab objectForKey: @"url"];
  
  // get portrait view controller for URL and Data
  UIViewController* vc = [self controllerForURL: url];
  if(!vc) return nil;
  
  //
  // Build navigation controller
  UINavigationController* nc = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
  nc.delegate = self;

  // set navigation controller title
  
  if([tab objectForKey: @"title"])
    nc.navigationBar.topItem.title = [tab objectForKey: @"title"];
  else if(vc.title)
    nc.navigationBar.topItem.title = vc.title;
  else
    nc.navigationBarHidden = YES;
  
  // set navigation controller's tab properties
  
  nc.tabBarItem.image = [UIImage imageNamed:[tab objectForKey: @"icon"]];
  nc.tabBarItem.title = [tab objectForKey: @"label"];

  return nc;
}

-(NSDictionary*) config
{
  return [M3 readJSON: @"$app/app.json" ];
}

-(void)loadTabs
{
  NSArray* tabs = [[self config] objectForKey: @"tabs"];


  NSString* __block initialURL;
  
  NSMutableArray* navigationControllers = [tabs mapUsingBlock:^id(NSDictionary* tab) {
    NSString* url = [tab objectForKey: @"url"];
    if(!url) return nil;

    dlog << "loading tab: " << url;

    UINavigationController* nc = [self navigationControllerForTab:tab];
    if(!nc) return nil;
    
    initialURL = url;
    return nc;
  }];
  
  navigationControllers = [navigationControllers selectUsingBlock:^BOOL(UINavigationController* nc) {
    return nc != nil;
  }];

  if(navigationControllers.count > 1) {
    UITabBarController* tbc = [[[UITabBarController alloc] init] autorelease];
    tbc.view.frame = [[UIScreen mainScreen] bounds];
    // tabBarController.wantsFullScreenLayout = YES;
    tbc.viewControllers = navigationControllers;
    
    self.window.rootViewController = self.tabBarController = tbc;
  }
  else {
    dlog << "opened tab: " << initialURL;
    self.window.rootViewController = navigationControllers.first;
  }
}

#pragma facebook support

// For 4.2+ support
- (BOOL)application: (UIApplication *)application 
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication 
         annotation: (id)annotation 
{
  return [self.facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
  [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
  [defaults synchronize];
}

#pragma twitter support

//-(void)initTwitter
//{
//  Class TWTweetComposeViewControllerClass = NSClassFromString(@"TWTweetComposeViewController");
//  if([TWTweetComposeViewControllerClass respondsToSelector:@selector(canSendTweet)]) {
//    UIViewController *twitterViewController = [[TWTweetComposeViewControllerClass alloc] init];
//    
//    [twitterViewController performSelector:@selector(setInitialText:) 
//                                withObject:@"tweet"];
//    [twitterViewController release];
//  }
//}

#pragma mark restart

-(void)createRootWindow
{
  UIWindow* wnd = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
  self.window = [wnd autorelease];  
}

-(void)restartApplication
{
  [self createRootWindow];
  
  [self loadTabs];
  [self.window makeKeyAndVisible];
  
  [self trackEvent: @"start"];          // track a start event
}

// Returns nil, @"WIFI", or @"CELL"
-(NSString*)currentReachability
{
  // Part 1 - Create Internet socket addr of zero
  struct sockaddr_in zeroAddr;
  bzero(&zeroAddr, sizeof(zeroAddr));
  zeroAddr.sin_len = sizeof(zeroAddr);
  zeroAddr.sin_family = AF_INET;
  
  // Part 2- Create target in format need by SCNetwork
  SCNetworkReachabilityRef target = 
  SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
  
  // Part 3 - Get the flags
  SCNetworkReachabilityFlags flags;
  SCNetworkReachabilityGetFlags(target, &flags);
  
  // Part 4 - Create output
  if(!(flags & kSCNetworkFlagsReachable)) 
    return nil;
  else if (flags & kSCNetworkReachabilityFlagsIsWWAN)
    return @"CELL";
  else
    return @"WIFI";
}

-(BOOL) application:(UIApplication *)application 
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
  NSLog(@"Starting application in DEBUG mode in %@", [ M3 symbolicDir: @"$root" ]);
#else
  NSLog(@"Starting application in %@", [ M3 symbolicDir: @"$root" ]);
#endif

  app = self;
  
  // --- prepare database
  [app.sqliteDB migrate];
  
  // --- log into facebook
  self.facebook = [[[Facebook alloc] initWithAppId:@"323168154384101" andDelegate:self] autorelease];

  // --- enable Urban Airship remote notifications
  [self enableRemoteNotifications];

  // --- enable sencha.io image source
  [M3 enableImageHost:M3SenchaSupportFull scaleForRetinaDisplay:YES];
  
  // --- enable Flurry
  [FlurryAnalytics startSession: FLURRY_API_KEY];

  // --- init database
  [self sqliteDB];
  [self updateDatabaseIfNeeded];

  // --- shoot!
  self.window = nil;
  [self restartApplication];  // restart app
  
  return YES;
}

- (UINavigationController*)currentTab
{
  return [ self.tabBarController.viewControllers objectAtIndex:0];
  //  return (UINavigationController*)[self.tabBarController selectedViewController];
}

#pragma mark livecycle callbacks

- (void)applicationWillResignActive:(UIApplication *)application
{
  [self.sqliteDB.settings setObject: [NSDate now].to_number forKey:@"resigned_at"];

  /*
   Sent when the application is about to move from active to inactive state. 
   This can occur for certain types of temporary interruptions (such as an 
   incoming phone call or SMS message) or when the user quits the application 
   and it begins the transition to the background state.
   
   Use this method to pause ongoing tasks, disable timers, and throttle down 
   OpenGL ES frame rates. Games should use this method to pause the game.
  */
  [app emit:@selector(paused)];
  
}


/*
 Use this method to release shared resources, save user data, invalidate 
 timers, and store enough application state information to restore your
 application to its current state in case it is terminated later. 
 
 If your application supports background execution, this method is 
 called instead of applicationWillTerminate: when the user quits.
 */

static BOOL goingToQuit = NO;

#define KILL_IN_BACKGROUND_AFTER_SECS 300

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // set up a "timer" to quit the app after 5 minutes.
  
  goingToQuit = YES;
  
  UIApplication* app = [UIApplication sharedApplication];
  UIBackgroundTaskIdentifier __block bgTask;
  bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    // Clean up any unfinished task business by marking where you.
    // stopped or ending the task outright.
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  }];
  
  if(UIBackgroundTaskInvalid != bgTask) {
    // Start the long-running task to kill app after some secs and return immediately.
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, KILL_IN_BACKGROUND_AFTER_SECS * 1e09), 
      dispatch_get_main_queue(), ^{
        if(goingToQuit) exit(0);
        [app endBackgroundTask: bgTask];
      });
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // cancel ongoing background suicide.
  goingToQuit = NO;
  
  /*
   Called as part of the transition from the background to the inactive state; 
   here you can undo many of the changes made on entering the background.
   */

  NSNumber* resigned_at = [self.sqliteDB.settings objectForKey: @"resigned_at"];
  int diff = [NSDate now].to_number.to_i - resigned_at.to_i;

  if(diff > 5 * 60) {                         // 300 seconds.
    [self restartApplication];
  }
  else {
    [app emit:@selector(resumed)];
  }

  [self updateDatabaseIfNeeded];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the 
   application was inactive. If the application was previously in the 
   background, optionally refresh the user interface.
  */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate. Save data 
   if appropriate. See also applicationDidEnterBackground:.
  */
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers 
                                                                                         changed:(BOOL)changed
{
}
@end

#endif
