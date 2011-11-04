//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#if TARGET_OS_IPHONE 

#import "M3.h"
#import "UIViewController+M3Extensions.h"

M3AppDelegate* app;

@implementation M3AppDelegate

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

-(BOOL)canOpen: (NSString*)url
{
  return [[UIApplication sharedApplication] canOpenURL:url.to_url];
}

// Opening an application action?
-(BOOL)openExternalURL: (NSString*)url 
{
  if(![url matches: @"^([-a-z]+):"]) return NO;

  if(![self canOpen: url]) {
    dlog << "Cannot open URL " << url;
    return NO;
  }

  // Adjust mailto URLs
  if([url matches: @"^mailto:(.*)"]) {
    url = [NSString stringWithFormat: @"mailto:?to=%@&subject=%@&body=%@",
            [$1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            @"Subject", @"Body" ];
  }

  [[UIApplication sharedApplication] openURL: url.to_url];
  return YES;
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
  [nc pushViewController:viewController animated:YES];
}

#pragma mark --- resolve urls to controller objects -----------------------------------

/*
 * Pass in an URL, and get a controller object which is able to
 * deal with this URL, and which has been initialized and set up,
 * but not yet activated.
 */

-(Class)controllerClassForURL: (NSString*) url
{
  // /category/action[/params] URLs create a CategoryActionController object. 
  NSArray* parts = [url.to_url.path componentsSeparatedByString: @"/"];
  parts = [parts mapUsingSelector:@selector(camelizeWord)];
  
  @try {
    NSString *className = _.join([parts get:1], [parts get:2], "Controller");
    return className.to_class;
  }
  @catch(id exception) {
    dlog << exception;
  }

  @try {
    NSString *className = _.join([parts get:1], "Controller");
    return className.to_class;
  }
  @catch(id exception) {
    dlog << exception;
  }
  
  return nil;
}
  
-(UIViewController*)controllerForURL: (NSString*)url
{
  Class klass = [self controllerClassForURL: url];
  UIViewController* vc = [[klass alloc]init];
  
  vc.url = url;
  
  // TODO:
  //
  // get landscape view controller for URL and Data
  // merge landscape view controller with portrait view controller 
  
  return [vc autorelease];
}

// Open internal URLs inside application.
-(BOOL)openInternalURL: (NSString*)url 
{
  UIViewController* vc = [self controllerForURL: url];
  if(!vc) return NO;

  [vc perform];
  return YES;
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

  // URLs with a scheme part are opened as external URLs.
  BOOL isExternalURL = [url matches: @"^([-a-z]+):"] != nil;
  BOOL success = isExternalURL ?
    [self openExternalURL: url] :
    [self openInternalURL: url];
    
  if(!success)
    dlog << "Cannot open " << url;
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
  // [self initChairDB];

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

#endif
