#if TARGET_OS_IPHONE 

/*
 * Custom properties on UIViewControllers.
 */
@interface UIViewController(M3UrlExtensions)

@property (retain,nonatomic) NSString* url;
@property (retain,nonatomic) NSString* title;
//@property (retain,nonatomic) NSDictionary* model;

-(void)releaseM3Properties;

-(BOOL)isFullscreen;

/*
 * The reload method just sets the url to its current value, again.
 *
 * This usually results into reloading the controller's content.
 */
-(void)reload;

/*
 * This method is called whenever the URL changed.
 */
-(void)loadFromUrl: (NSString*)url;

@end


@interface UIViewController(M3Extensions)

/*
 * Setting the right button action.
 */

-(void)setRightButtonWithTitle: (NSString*)title_or_image
                        target: (id)target
                        action: (SEL)action;

/*
 * Setting the right button action.
 */
-(void)setRightButtonWithTitle: (NSString*)title_or_image
                           url: (NSString*)url;

/*
 * Setting the right button action.
 */
-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                             target: (id)target
                             action: (SEL)action;

/*
 * Setting the right button action.
 */
-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                                url: (NSString*)url;


@end

@interface UIView(M3Extensions)

-(void)onTapOpen: (NSString*)url;

@end

#endif
