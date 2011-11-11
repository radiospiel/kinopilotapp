#if TARGET_OS_IPHONE 

#import <UIKit/UIKit.h>

@class M3AppDelegate;
extern M3AppDelegate* app;

@class MixpanelAPI;

/*
 * The AppDelegate class and the global app object.
 */
@interface M3AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
  MixpanelAPI* mixpanel_;
  NSData* deviceToken_;
}

@property (retain, nonatomic) UIProgressView* progressView;
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UITabBarController *tabBarController;

/*
 * returns the configuration. It is read from "app.json".
 */
@property (retain, nonatomic, readonly) NSDictionary *config;

/*
 * returns TRUE if the current device is an iPhone (as opposed to an iPad).
 */
-(BOOL) isIPhone;

/*
 * can this URL be opened?
 */
-(BOOL)canOpen: (NSString*)url;

/*
 * open this URL.
 */
-(void)open: (NSString*)url;

-(UINavigationController*)topMostController;
-(void)presentControllerOnTop: (UIViewController*)viewController;

/*
 * Pass in an URL, and get a controller object which is able to
 * deal with this URL, and which has been initialized and set up,
 * but not yet activated.
 */
-(UIViewController*) controllerForURL: (NSString*)url;

@end

#endif
