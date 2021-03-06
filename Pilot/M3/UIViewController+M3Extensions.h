#if TARGET_OS_IPHONE 

/*
 * Custom properties on UIViewControllers.
 */
@interface UIViewController(M3UrlExtensions)

@property (retain,nonatomic) NSString* url;

-(void)releaseM3Properties;

-(BOOL)isFullscreen;

/*
 * "Do" this controller. This usually presents the controller one way or another.
 * The default implementation pushs this controller on top of the current 
 * navigation controller.
 */
-(void)perform;

/*
 * The reload method just sets the url to its current value, again. 
 */
-(void)reload;

/*
 * This method is called whenever the URL changed.
 */
-(void)reloadURL;

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

-(void)setRightButtonWithImage: (UIImage*)image
                        target: (id)target
                        action: (SEL)action;

-(void)setRightButtonWithImage: (UIImage*)image
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


/*
 * Setting the right button action.
 */
-(void)setRightButtonWithFlatImage: (UIImage*)image
                            target: (id)target
                            action: (SEL)action;


-(void)setRightButtonReloadAction;


@end

#endif
