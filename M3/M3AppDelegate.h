#if TARGET_OS_IPHONE 

#import <UIKit/UIKit.h>

@class M3AppDelegate;
extern M3AppDelegate* app;

/*
 * The AppDelegate class and the global app object.
 */
@interface M3AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
}

@property (retain, nonatomic) UIProgressView* progressView;
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UITabBarController *tabBarController;

/*
 * returns the aplication configuration. It is read from the 
 * "app.json" resource file.
 */
@property (retain, nonatomic, readonly) NSDictionary *config;

-(UINavigationController*)topMostController;
-(void)presentControllerOnTop: (UIViewController*)viewController;

@end

@interface M3AppDelegate(ApplicationURL)

/*
 * can this URL be opened? This method returns NO, if the url is an 
 * internal URL, or if the URL is an external URL and the respective
 * application is installed.
 */
-(BOOL)canOpen: (NSString*)url;

/*
 * open the passed-in URL.
 */
-(void)open: (NSString*)url;

/*
 * creates and returns a UIViewController for the passed-in internal URL.
 */
-(UIViewController*)controllerForURL: (NSString*)url;

@end

@interface M3AppDelegate(RemoteNotification)

/*
 * Call this method to enable remote notifications.
 */
-(void)enableRemoteNotifications;

@end

#endif
