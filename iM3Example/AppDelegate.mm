//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3.h"

#import "FirstViewController.h"

#import "SecondViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize progressView = progressView_;

- (void)dealloc
{
  [progressView_ release];
  [_window release];
  [_tabBarController release];
    [super dealloc];
}

-(BOOL)isIPhone
{
  return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

-(UIViewController*)loadControllerWithNibName: (NSString*)nibName andKlass:(Class)klass
{
  return [[ klass alloc]initWithNibName:nibName bundle:nil];
}

-(UIViewController*)loadController: (NSString*) name
{
  Class klass = NSClassFromString(name);
  UIViewController* r;
  if ([self isIPhone])
    r = [ self loadControllerWithNibName: _.join(name, @"_iPhone") andKlass: klass ];
  else
    r = [ self loadControllerWithNibName: _.join(name, @"_iPad") andKlass: klass ];
  
  if(!r)
    r = [ self loadControllerWithNibName: name andKlass: klass ];

  if(!r)
    @throw _.join("Cannot load ", name, " controller");
  
  return [r autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  // Override point for customization after application launch.

  UIViewController *vc1 = [ self loadController: @"FirstViewXController"];
  UIViewController *vc2 = [ self loadController: @"SecondViewController"];

  vc1 = [[UINavigationController alloc]initWithRootViewController:vc1];
  vc2 = [[UINavigationController alloc]initWithRootViewController:vc2];

  [vc1 autorelease];
  [vc2 autorelease];

  self.tabBarController = [[[UITabBarController alloc] init] autorelease];
  self.tabBarController.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];
  self.window.rootViewController = self.tabBarController;

  [self.window makeKeyAndVisible];
  
  [self progressView];
  
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
  NSLog(@"topItem: %@", [self currentTab]);

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
