#if 0

#if TARGET_OS_IPHONE 

#import "M3.h"
#ifdef __cplusplus
#import "Underscore.hh"
#endif

#import "UIViewController+M3Extensions.h"

@class M3AppDelegate;
extern M3AppDelegate* app;

/*
 * The AppDelegate class and the global app object.
 */
@interface M3AppDelegate : UIResponder <UIApplicationDelegate, 
                                        UITabBarControllerDelegate, 
                                        UINavigationControllerDelegate>

@end

#endif

#endif