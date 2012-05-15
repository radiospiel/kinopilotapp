//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#if TARGET_OS_IPHONE 

#import "M3AppDelegate.h"
// #import "UIViewController+M3Extensions.h"

#import "FlurryAnalytics.h"

// for network status
#include <netdb.h>
#include <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "iRate.h"

M3AppDelegate* app;

@interface M3AppDelegate()
@end

@implementation M3AppDelegate

@synthesize window, tabBarController, withheldViewControllers;

-(id)init
{
  self = [super init];
  [self initializeIRate];
  return self;
}

-(void)initializeIRate
{
  NSDictionary* config = [self.config objectForKey: @"irate"];
  if(!config) return;

  // -- configure iRate
  iRate* r = [iRate sharedInstance];
  
  r.appStoreID =      [[config objectForKey: @"app_store_id"] to_i];
  r.applicationName = [config objectForKey: @"application_name"];
  r.messageTitle =    [config objectForKey: @"message_title"];
  r.daysUntilPrompt = 3;
  r.remindPeriod = 5;
  r.message = @"Gefällt Dir unsere App? "
               "Dann bewerte sie doch im Appstore. "
               "Danke für Deine Unterstützung!";
  r.cancelButtonLabel = @"Nein, danke!";
  r.rateButtonLabel = @"Vielleicht später.";
  r.remindButtonLabel  = @"Ja, gern!";

  dlog << "*** Configured iRate for app_store_id " << r.appStoreID;
}

- (void)dealloc
{
  self.window = nil;
  self.tabBarController = nil;
  
  [super dealloc];
}

-(NSString*) identifier
{
  return [[NSBundle mainBundle] bundleIdentifier];
}

-(BOOL) isFlk
{
  return [self.identifier isEqualToString: @"io.socially.kinopilot-flk"];
}

-(BOOL) isKinopilot
{
  return [self.identifier isEqualToString: @"com.radiospiel.kinopilot"];
}

-(BOOL) isLivegigs
{
  return NO;
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

-(NSString*) configPathFor: (NSString*)file
{
  NSBundle* mainBundle = [NSBundle mainBundle];
  return [NSString stringWithFormat: @"%@/config.bundle/%@", [mainBundle bundlePath], file];
}

-(NSDictionary*) config
{
  return [self memoized:@selector(config) usingBlock:^ {
    return [M3 readJSON: [self configPathFor: @"app.json"]];
  }];
}

-(UIImage*)imageNamed: (NSString*)imageName
{
  imageName = [NSString stringWithFormat: @"config.bundle/%@", imageName];
  return [UIImage imageNamed: imageName];
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

-(NSArray*)popToRootViewController
{
  return [app.topMostController popToRootViewControllerAnimated:NO];
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
  SCNetworkReachabilityRef reach = 
  SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
  
  // Part 3 - Get the flags
  SCNetworkReachabilityFlags flags;
  SCNetworkReachabilityGetFlags(reach, &flags);
  
  // Part 4 - Create output
  NSString* reachability = @"WIFI";
  
  if(!(flags & kSCNetworkFlagsReachable)) {
    reachability = nil;
  }
  else if (flags & kSCNetworkReachabilityFlagsIsWWAN) { 
    // reachability = @"CELL";
    // This is CELL reachability. We disable all wifi functionality though.
    reachability = nil;   
  }

  CFRelease(reach);

  return reachability;
}

static void uncaughtExceptionHandler(NSException *exception) {
  NSLog(@"CRASH: %@", exception);
  NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
  // Internal error reporting
}

-(BOOL) application:(UIApplication *)application 
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
  
#if DEBUG
  NSLog(@"Starting application [%@] in DEBUG mode in %@", self.identifier, [ M3 symbolicDir: @"$root" ]);
#else
  NSLog(@"Starting application in %@", [ M3 symbolicDir: @"$root" ]);
#endif

  app = self;
  
  // --- prepare database
  [app.sqliteDB migrate];
  
  // --- enable Urban Airship remote notifications
  [self enableRemoteNotifications];

  // --- enable Flurry
  [FlurryAnalytics startSession: [app.config objectForKey: @"flurry_api_key"]];

  // --- init database
  [self sqliteDB];
  [self updateDatabaseIfNeeded];

  // --- shoot!
  self.window = nil;
  
  UIWindow* wnd = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
  self.window = [wnd autorelease];  
    
  [self loadTabs];
  [self.window makeKeyAndVisible];
    
  [self trackEvent: @"start"];          // track a start event
  
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

#define KILL_IN_BACKGROUND_AFTER_SECS 300

-(void)withholdViewControllers
{
  self.withheldViewControllers = [self popToRootViewController];
}

-(void)putBackWithheldViewControllers
{
  for(UIViewController* vc in self.withheldViewControllers) {
    [app.topMostController pushViewController:vc animated:NO];
  }
  
  self.withheldViewControllers = nil;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [self withholdViewControllers];
}

#define TIME_IN_BACKGROUND_BEFORE_RESTART 10 * 60

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; 
   here you can undo many of the changes made on entering the background.
   */
  NSNumber* resigned_at = [self.sqliteDB.settings objectForKey: @"resigned_at"];
  int timeInBackground = [NSDate now].to_number.to_i - resigned_at.to_i;

  // After a certain time the application reopens at the Dashboard view again,
  // i.e. does not put back the withheldViewControllers
  if(timeInBackground > TIME_IN_BACKGROUND_BEFORE_RESTART) {
    [self trackEvent: @"start"];
    self.withheldViewControllers = nil;
  }
  else {
    [self putBackWithheldViewControllers];
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
