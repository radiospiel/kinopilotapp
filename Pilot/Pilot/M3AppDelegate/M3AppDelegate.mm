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

#import "Flurry.h"

// for network status
#include <netdb.h>
#include <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>

M3AppDelegate* app;

@interface M3NavigationController: UINavigationController
@end

@implementation M3NavigationController

- (BOOL)shouldAutorotate {
  return YES;
}

// This method is called on iOS < 6 only. It returns the expected value
// from the iOS6 compatible implementation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  UIViewController* vc = self.topViewController;
  if([vc respondsToSelector:@selector(supportedInterfaceOrientations)]) {
    switch(toInterfaceOrientation) {
      case UIInterfaceOrientationLandscapeLeft:
        return vc.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft;
      case UIInterfaceOrientationLandscapeRight:
        return vc.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight;
      case UIInterfaceOrientationPortrait:
        return vc.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait;
      case UIInterfaceOrientationPortraitUpsideDown:
        return vc.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown;
      default:
        break;
    }
  
    return NO;
  }

  if(vc)
    return [vc shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
  
  return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (NSUInteger)supportedInterfaceOrientations {
  UIViewController* vc = self.topViewController;
  if(vc)
    return vc.supportedInterfaceOrientations;
  
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

-(void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  // When a controller is popped which supports a rotation that the new
  // topViewController does not support, the will/didAppear callbacks
  // will NOT BE CALLED. We still have to update the navigationBar visibility
  // though.
  //
  // This is a workaround for a) probably a bug in iOS and b) for the way
  // we have some view controllers that are full screen and therefore
  // handle closing by theselves.
  UIViewController* vc = self.topViewController;
  self.navigationBarHidden = vc.title ? NO : YES;
}

@end

@interface M3AppDelegate()
@end

@implementation M3AppDelegate

@synthesize window, withheldViewControllers;

-(id)init
{
  self = [super init];
  return self;
}

- (void)dealloc
{
  self.window = nil;
  
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
  UINavigationController* nc = (UINavigationController*)self.window.rootViewController;
  M3AssertKindOf(nc, UINavigationController);
  return nc;
}

-(void)presentControllerOnTop: (UIViewController*)viewController
{
  UINavigationController* nc = [self topMostController];
  [nc pushViewController:viewController animated:YES];
}

//
// Update nav bar when top controller changes.
//
// It somehow seems important to update the nav bar both before
// and after the new vc appears, for reasons unknown.
//
-(void)navigationController:(UINavigationController *) nc
     willShowViewController:(UIViewController *)vc
                   animated:(BOOL)animated
{
  [nc setNavigationBarHidden: vc.title == nil animated:animated];
}

-(void)navigationController:(UINavigationController *) nc
      didShowViewController:(UIViewController *)vc
                   animated:(BOOL)animated
{
  [nc setNavigationBarHidden: vc.title == nil animated:animated];
}

-(UINavigationController*)navigationControllerForURL: (NSString*)url
{
  M3AssertKindOf(url, NSString);
  
  // get portrait view controller for URL and Data
  UIViewController* vc = [self controllerForURL: url];
  if(!vc) return nil;
  
  //
  // Build navigation controller
  UINavigationController* nc = [[[M3NavigationController alloc]initWithRootViewController:vc]autorelease];
  nc.delegate = self;
  [nc.navigationBar setBarStyle:UIBarStyleBlackOpaque];
  nc.navigationBarHidden = YES;

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
  
  // --- enable Flurry
  [Flurry startSession: [app.config objectForKey: @"flurry_api_key"]];

  // --- init database
  [self sqliteDB];
  [self updateDatabaseIfNeeded];

  // --- shoot!
  self.window = nil;
  
  UIWindow* wnd = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
  self.window = [wnd autorelease];  
  
  // The tabs key contains an array of dictionaries describing the requested
  // tabs for the UI. We only show the first entry (which must contain
  // a valid URL)
  NSString* startUrl = [[self config] objectForKey: @"start_url"];
  self.window.rootViewController = [self navigationControllerForURL:startUrl];
                                          
  [self.window makeKeyAndVisible];
    
  [self trackEvent: @"start"];          // track a start event
  
  return YES;
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

@end

#endif
