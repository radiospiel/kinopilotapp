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

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize progressView = progressView_;

- (void)dealloc
{
  self.window = nil;
  self.tabBarController = nil;
  self.progressView = nil;
  [self setChairDB: nil];
  
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

-(id)dataForURL: (NSString*)url
{
  if([url matches: @"^movies://"]) {
    ChairTable* movies = [ self.chairDB tableForName:@"movies" ];

    // 
    NSDictionary* movie = [movies first];
    movie = [NSMutableDictionary dictionaryWithDictionary:movie];
    
    [movie setValue:[movie valueForKey:@"url"] forKey:@"action0"];

    NSArray* images = [movie valueForKey:@"images"];
    if(images) {
      NSArray* first_image = [images objectAtIndex:0];
      if(first_image) {
        [movie setValue:[first_image valueForKey:@"thumbnail"] forKey:@"image"];
      }
    }

    // DLOG(movie);
    return movie; 
  }

  return nil;
}

-(NSString*)titleForURL: (NSString*)url andData: (id)data
{
  if([data isKindOfClass:[NSDictionary class]]) {
    NSString* title = [data objectForKey:@"title"];
    if(!title) title = [data objectForKey:@"label"];
    if(title) return title;
  }
  
  return nil;
}

-(UIViewController*)viewControllerForURL: (NSString*)url andData: (id)data
{
  if([url matches: @"^movies://"]) {
    Class klass = NSClassFromString(@"ProfileController");
    
    //
    UIViewController *pc = [ self loadInstanceOfClass: klass
                                              fromNib:@"ProfileController"];
    
    pc.model = data;
    return pc;
  }

  return nil;
}

-(id)addTabForURL:(NSString*)url withLabel: (NSString*)label andIcon: (NSString*)icon
{
  // get data for URL
  NSDictionary* data = [self dataForURL: url];
  
  // get portrait view controller for URL and Data
  UIViewController* controller = [self viewControllerForURL: url andData: data];
  
  // TODO:
  //
  // get landscape view controller for URL and Data
  // merge landscape view controller with portrait view controller 
  
  // get title for URL and Data.
  NSString* title = [self titleForURL: url andData: data];

  //
  // Build navigation controller
  UINavigationController* nc = [[UINavigationController alloc]initWithRootViewController:controller];

  // set navigation controller's tab properties
  nc.tabBarItem.image = [[UIImage imageNamed:icon] autorelease];
  nc.tabBarItem.title = label;
  
  // set navigation controller title
  if(title)
    nc.navigationBar.topItem.title = title;
  else
     nc.navigationBarHidden = YES;
  
  // Append nc to list of viewControllers
  NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
  [viewControllers addObject: nc];
  
  self.tabBarController.viewControllers = viewControllers;
  
  return controller;
}

-(void)loadTabs
{
  [self addTabForURL: @"movies://1" withLabel: @"Movies" andIcon: @"games.png"];

    
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
  rlog(1) << "Starting application in " << [ M3 symbolicDir: @"$root" ];

  // [self initCouchbase];
  [self initChairDB];
  
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
  
  // for(NSString* sym in _.array("$cache","$tmp","$documents", "$root", "$app")) {
  //   dlog << @"*** " << sym << ": " << [ M3 symbolicDir: sym ];
  // }
  
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

  UITabBarController* tabBarController = [[[UITabBarController alloc] init] autorelease];
  tabBarController.view.frame = [[UIScreen mainScreen] bounds];

  self.tabBarController = [tabBarController autorelease];
  // [[[UITabBarController alloc] init] autorelease];
  // self.tabBarController.wantsFullScreenLayout = YES;
  
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
