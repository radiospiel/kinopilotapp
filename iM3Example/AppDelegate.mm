//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"

#import "M3.h"
#import "Chair.h"

AppDelegate* app;

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize progressView = progressView_;

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

-(UIViewController*)viewControllerForURL: (NSString*)url
{
  NSString* className = nil;
  NSString* nibName = nil;
  
  // /category/action[/params] URLs create a CategoryActionController
  // object. If action is not "list", the objects will be loaded from a
  // NIB with a matching name.
  if (!className && [url matches: @"^/(\\w+)/list(/(\\w+))?"]) {
    className = _.join($1.camelizeWord, "ListController");
  }

  if (!className && [url matches: @"^/(\\w+)/show(/(\\w+))?"]) {
    className = _.join($1.camelizeWord, "ShowController");
    nibName = @"M3ProfileController";
  }

  if (!className && [url matches: @"^/(\\w+)/(\\w+)(/(\\w+))?"]) {
    nibName = className = _.join($1.camelizeWord, $2.camelizeWord, "Controller");
  }

  if (!className && [url matches: @"^/(\\w+)"]) {
    className = _.join($1.camelizeWord, "Controller");
  }

  if(!className && ([url matches: @"^([a-z]+)://"]))
    nibName = className = @"WebViewController";

  if(!className)
    _.raise("Cannot find controller class name for URL ", url);
  
  UIViewController* vc = nil;
  if(nibName) {
    // rlog(2) << "Load " << className << " from NIB";
    vc = [self loadInstanceOfClass: NSClassFromString(className)
                           fromNib: nibName];
  }
  else {
    // rlog(2) << "Load " << className << " without NIB";
    vc = [[NSClassFromString(className) alloc]init];
  }

  vc.url = url;

  // TODO:
  //
  // get landscape view controller for URL and Data
  // merge landscape view controller with portrait view controller 

  return vc;
}

-(void)open: (NSString*)url
{
  if(!url) return;
  
  UIViewController* vc = [self viewControllerForURL: url];
  if(!vc) return;
  
  UINavigationController* currentTab = (UINavigationController*) self.tabBarController.selectedViewController;
  if(!currentTab)
    currentTab = (UINavigationController*) [self.tabBarController.viewControllers objectAtIndex:0];
  
  [currentTab pushViewController:vc animated:YES];
}

-(void)addTab: (NSString*)url withLabel: (NSString*)label andIcon: (NSString*)icon
{
  // get portrait view controller for URL and Data
  UIViewController* vc = [self viewControllerForURL: url];
  if(!vc) return;
  
  //
  // Build navigation controller
  UINavigationController* nc = [[UINavigationController alloc]initWithRootViewController:vc];

  // set navigation controller title
  if(vc.title)
    nc.navigationBar.topItem.title = vc.title;
  else
    nc.navigationBarHidden = YES;
  
  // set navigation controller's tab properties
  nc.tabBarItem.image = [UIImage imageNamed:icon];
  nc.tabBarItem.title = label;
  
  // Append nc to list of viewControllers
  NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
  
  [viewControllers addObject: nc];
  
  self.tabBarController.viewControllers = viewControllers;
}

-(NSDictionary*) config
{
  return [M3 readJSON: @"$app/app.json" ];
}

-(void)loadTabs
{
  NSArray* tabs = [[self config] objectForKey: @"tabs"];
  
  for(NSDictionary* tab in tabs) {
    if([tab objectForKey:@"disabled"]) continue;
    NSString* url = [tab objectForKey: @"url"];
    NSString* label = [tab objectForKey: @"label"];
    NSString* icon = [tab objectForKey: @"icon"];
    

    [self addTab: url withLabel: label andIcon: icon];
  }
}

-(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  app = self;
  
  rlog(1) << "Starting application in " << [ M3 symbolicDir: @"$root" ];

  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

  /*
   * Initialise database
   */
  [self initChairDB];

  /*
   * Initialise root window and (still empty) tabBarController
   */
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

  UITabBarController* tabBarController = [[[UITabBarController alloc] init] autorelease];
  tabBarController.view.frame = [[UIScreen mainScreen] bounds];
  // tabBarController.wantsFullScreenLayout = YES;

  self.tabBarController = tabBarController;
  self.window.rootViewController = self.tabBarController;
  [self.window makeKeyAndVisible];

  /*
   * Load initial set of tabs
   */
   
  [self loadTabs];
  // [self open: @"/movies/list/all"];
  
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
  //  // progressView_ = [[UIProgressView alloc]initWithProgressViewStyle: UIProgressViewStyleBar];
  //  
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
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
