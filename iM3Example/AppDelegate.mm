//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3Router.h"

AppDelegate* app;

@implementation NSString (IM3ExampleExtensions)

-(NSString*) withVersionString: (NSString*)versionString;
{
  if(!versionString) return self;
  
  versionString = versionString.uppercaseString;
  versionString = [versionString stringByReplacingOccurrencesOfString:@"OMU" withString:@"OmU"];
  
  return [self stringByAppendingFormat:@" (%@)", versionString];
}

@end

@implementation AppDelegate

@synthesize window = _window, tabBarController = _tabBarController, progressView = progressView_;

- (void)dealloc
{
  self.window = nil;
  self.tabBarController = nil;
  self.progressView = nil;
  
  [super dealloc];
}

-(BOOL)isIPhone
{
  return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

-(void)executeAction: (NSString*)action
{
  dlog << "exec action " << action;
  if([action isEqualToString:@"update"]) {
    [app.chairDB performSelector:@selector(update) withObject:nil afterDelay:0.3];
  }
}

-(BOOL)canOpen: (NSString*)url
{
  return [[UIApplication sharedApplication] canOpenURL:url.to_url];
}

/*
 * "opens" the URL.
 * 
 * There are different kind of URL:
 *
 * - "app:<action>" executes an action name via AppDelegate#executeAction:
 * - "<protocol>:<protocol-parameters>" executes an external URL.
 */
-(void)open: (NSString*)url
{
  if(!url) return;

  rlog(1) << "open " << url;
  
  // Opening an application action?
  if([url matches: @"^app:(.*)"]) {
    [self executeAction: $1];
    return;
  }
  
  // Adjust mailto URLs
  if([url matches: @"^mailto:(.*)"]) {
    url = [NSString stringWithFormat: @"mailto:?to=%@&subject=%@&body=%@",
            [$1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            @"Subject", @"Body" ];
  }
  
  // Open real URLs in external application
  if([url matches: @"^([-a-z]+):"]) {
    if(![self canOpen: url]) {
      dlog << "Cannot open URL " << url;
      return;
    }

    // test canOpenURL
    [[UIApplication sharedApplication] openURL: url.to_url];

    return;
  }

  // Open internal URLs inside application.
  UIViewController* vc = [[self router] controllerForURL: url];
  if(!vc) return;
  
  UINavigationController* nc;
  if(!self.tabBarController) {
    nc = (UINavigationController*)self.window.rootViewController;
  }
  else {
    nc = (UINavigationController*) self.tabBarController.selectedViewController;
    if(!nc)
      nc = (UINavigationController*) [self.tabBarController.viewControllers objectAtIndex:0];
  }
    
  if(NO) { // [vc shouldOpenModally]) {
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // vc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [nc presentModalViewController:vc animated:YES];
  }
  else {
    [nc pushViewController:vc animated:YES];
  }
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
  UIViewController* vc = [self.router controllerForURL: url];
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
  tabs = [tabs selectUsingBlock:^BOOL(NSDictionary* tab) {
    return [tab objectForKey: @"url"] != nil;
  }];

  NSMutableArray* viewControllers = [tabs mapUsingBlock:^id(NSDictionary* tab) {
    return [self navigationControllerForTab:tab];
  }];
  
  viewControllers = [viewControllers selectUsingBlock:^BOOL(id tab) {
    return tab != nil;
  }];

  if(viewControllers.count > 1) {
    UITabBarController* tabBarController = [[[UITabBarController alloc] init] autorelease];
    tabBarController.view.frame = [[UIScreen mainScreen] bounds];
    // tabBarController.wantsFullScreenLayout = YES;
    tabBarController.viewControllers = viewControllers;
    
    self.tabBarController = tabBarController;
    self.window.rootViewController = self.tabBarController;
  }
  else {
    self.window.rootViewController = viewControllers.first;
  }
}

-(BOOL) application:(UIApplication *)application 
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  app = self;
  
  [M3 enableImageHost:M3SenchaSupportFull scaleForRetinaDisplay:NO];
  
  rlog(1) << "Starting application in " << [ M3 symbolicDir: @"$root" ];

  // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
  /*
   * Initialise root window
   */
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  
  /*
   * Initialise database
   */
  [self initChairDB];

  /*
   * Load initial set of tabs
   */
  
  [self loadTabs];
  

  [self.window makeKeyAndVisible];

  return YES;
}

- (UINavigationController*)currentTab
{
  return [ self.tabBarController.viewControllers objectAtIndex:0];
  //  return (UINavigationController*)[self.tabBarController selectedViewController];
}


- (UIProgressView*)progressView
{
  if(progressView_) return progressView_;

  UINavigationItem* item = [[[self currentTab]navigationBar]topItem];
  dlog << @"topItem: " << [self currentTab];

  progressView_ = [[UIProgressView alloc]initWithProgressViewStyle: UIProgressViewStyleDefault];

  item.titleView = progressView_;
  [  progressView_ setProgress:0.5f];

  item.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle: @"right"
                                                            style:UIBarButtonItemStylePlain 
                                                           target:self 
                                                           action:@selector(right)];

  return progressView_;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the 
   application was inactive. If the application was previously in the 
   background, optionally refresh the user interface.
  */
  [app emit:@selector(resumed)];
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
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}


@end

@implementation AppDelegate(M3Router)

-(M3Router*) router
{
  return [[[M3Router alloc]init]autorelease];
}

@end
