@class UIViewController;

@interface M3Router: NSObject

/*
 * Pass in an URL, and get a controller object which is able to
 * deal with this URL, and which has been initialized and set up,
 * but not yet activated.
 */
-(UIViewController*) controllerForURL: (NSString*)url;

@end
