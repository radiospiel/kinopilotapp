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

  if (!className && [url matches: @"^/vicinity/show"]) {
    className = @"VicinityShowController";
  }

  if (!className && [url matches: @"^/movies/images(/(\\w+))?"])
    className = @"MoviesImagesController";

  if (!className && [url matches: @"^/map/show(/(\\w+))?"])
    nibName = className = @"MapShowController";
  
  if (!className && [url matches: @"^/(\\w+)/show(/(\\w+))?"]) {
    className = _.join($1.camelizeWord, "ShowController");
    nibName = @"M3ProfileController";
  }

  if (!className && [url matches: @"^/(\\w+)/full(/(\\w+))?"]) {
    className = _.join($1.camelizeWord, "FullController");
  }
  
  if (!className && [url matches: @"^/(\\w+)/(\\w+)(/(\\w+))?"]) {
    nibName = className = _.join($1.camelizeWord, $2.camelizeWord, "Controller");
  }

  if (!className && [url matches: @"^/(\\w+)"]) {
    className = _.join($1.camelizeWord, "Controller");
  }

  if(!className)
    _.raise("Cannot find controller class name for URL ", url);
  
  UIViewController* vc = nil;
  Class klass = NSClassFromString(className);

//  DLOG(className);
//  DLOG(nibName);
  
  if(nibName) {
    vc = [[klass alloc]initWithNibName:nibName bundle:nil];
  }
  else {
    vc = [[klass alloc]init];
  }
  
  vc.url = url;

  // TODO:
  //
  // get landscape view controller for URL and Data
  // merge landscape view controller with portrait view controller 

  return [vc autorelease];
}

-(BOOL)canOpen: (NSString*)url
{
  return [[UIApplication sharedApplication] canOpenURL:url.to_url];
}

-(void)executeAction: (NSString*)action
{
  dlog << "exec action " << action;
  if([action isEqualToString:@"update"]) {
    [app.chairDB performSelector:@selector(update) withObject:nil afterDelay:0.3];
  }
}

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
  UIViewController* vc = [self viewControllerForURL: url];
  if(!vc) return;

  
  UINavigationController* nc = (UINavigationController*) self.tabBarController.selectedViewController;
  if(!nc)
    nc = (UINavigationController*) [self.tabBarController.viewControllers objectAtIndex:0];

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
  UIView *contentView = [tbc.view.subviews.first isKindOfClass:[UITabBar class]] ?
    tbc.view.subviews.second :
    tbc.view.subviews.first;
  
  if([vc respondsToSelector:@selector(isFullscreen)] && [vc isFullscreen]) {
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


-(void)addTab: (NSString*)url withOptions: (NSDictionary*)options
{
  // get portrait view controller for URL and Data
  UIViewController* vc = [self viewControllerForURL: url];
  if(!vc) return;

  //
  // Build navigation controller
  UINavigationController* nc = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
  nc.delegate = self;
  
  // set navigation controller title

  if([options objectForKey: @"title"])
    nc.navigationBar.topItem.title = [options objectForKey: @"title"];
  else if(vc.title)
    nc.navigationBar.topItem.title = vc.title;
  else
    nc.navigationBarHidden = YES;
  
  // set navigation controller's tab properties

  nc.tabBarItem.image = [UIImage imageNamed:[options objectForKey: @"icon"]];
  nc.tabBarItem.title = [options objectForKey: @"label"];
  
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
    [self addTab: url withOptions: tab];
  }
}

-(BOOL) application:(UIApplication *)application 
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  app = self;
  
  rlog(1) << "Starting application in " << [ M3 symbolicDir: @"$root" ];

  // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

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
