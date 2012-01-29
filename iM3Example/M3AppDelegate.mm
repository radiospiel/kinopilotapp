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

M3AppDelegate* app;

@interface M3AppDelegate()
@end

@implementation M3AppDelegate

@synthesize window, tabBarController, facebook;

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

-(BOOL) application:(UIApplication *)application 
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  rlog(1) << "Starting application in " << [ M3 symbolicDir: @"$root" ];

  app = self;
  
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
  
  self.window.hidden = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate 
   timers, and store enough application state information to restore your
   application to its current state in case it is terminated later. 
   
   If your application supports background execution, this method is 
   called instead of applicationWillTerminate: when the user quits.
  */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
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
  self.window.hidden = NO;

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
