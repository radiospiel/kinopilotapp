//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3.h"
#import "ProfileController.h"

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
//
// Open a document at \a url with \a options.
-(void) open: (NSString*)url withOptions: (NSDictionary*)options
{
  // get type of document
  // get view controller for that document with options
  // push document on top of current tab
}

-(id) addTab: (NSString*)nibName 
      ofClass: (NSString*)className
    withLabel: (NSString*)label 
     andIcon: (NSString*)iconName       
    navigationBarTitle: (NSString*)navigationBarTitle
{
  if(!className) className = nibName;
  UIViewController *vc = [ self loadInstanceOfClass: NSClassFromString(className)
                                            fromNib:nibName];
  
  UINavigationController* nc = [[UINavigationController alloc]initWithRootViewController:vc];
  
  if(navigationBarTitle)
    nc.navigationBar.topItem.title = navigationBarTitle;
  else
    nc.navigationBarHidden = YES;
  
  nc.tabBarItem.image = [[UIImage imageNamed:iconName] autorelease];
  nc.tabBarItem.title = [[label retain]autorelease];
  
  // Append nc to list of viewControllers
  
  NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
  [viewControllers addObject: nc];
  
  self.tabBarController.viewControllers = viewControllers;

  return vc;
}

-(void)loadTabs
{
  ProfileController* pc = [self addTab: @"ProfileController_iPhone_Landscape" 
                               ofClass: @"ProfileController"
                             withLabel: @"google" 
                               andIcon: @"games.png"  
                    navigationBarTitle: @"ProfileController" ];
  
  pc.data = _.hash(@"title", @"The Title", @"description", @"Yadda dadda, this is a description");
  
  [self addTab: @"WebViewController" 
       ofClass: nil
     withLabel: @"google" 
       andIcon: @"world.png" navigationBarTitle: nil ];
  
  [self addTab: @"WebViewController" 
       ofClass: nil
     withLabel: @"google" 
       andIcon: @"world.png" navigationBarTitle: nil ];
  
  [self addTab:@"FirstViewController" 
       ofClass:nil  
     withLabel:@"first" 
       andIcon:@"first.png"  navigationBarTitle: @"first title"];
  
  [self addTab: @"WebViewController" 
       ofClass: nil
     withLabel: @"google" 
       andIcon: @"world.png" navigationBarTitle: nil ];
  
  [self addTab: @"SecondViewController" 
       ofClass: nil
     withLabel: @"second" 
       andIcon: @"second.png" navigationBarTitle: @"2nd title" ];
}

-(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  for(NSString* sym in _.array("$cache","$tmp","$documents", "$root")) {
    NSLog(@"*** %@: %@", sym, [ M3 symbolicDir: sym ]);
  }
  
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

  self.tabBarController = [[[UITabBarController alloc] init] autorelease];

  [self loadTabs];
  
  self.window.rootViewController = self.tabBarController;

  [self.window makeKeyAndVisible];
  
  // [self progressView];
  
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
