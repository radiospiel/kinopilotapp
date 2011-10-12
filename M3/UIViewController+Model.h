#if TARGET_OS_IPHONE 

/*
 * Custom properties on UIViewControllers.
 */
@interface UIViewController(M3Properties)

@property (retain,nonatomic) NSString* url;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic) NSDictionary* model;

-(void)releaseM3Properties;

-(BOOL)isFullscreen;

@end

/*
 * Setting the right button action.
 */
@interface UIViewController(M3Extensions)

-(void)setRightButtonWithTitle: (NSString*)title_or_image
                        target: (id)target
                        action: (SEL)action;

-(void)setRightButtonWithTitle: (NSString*)title_or_image
                           url: (NSString*)url;

-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                             target: (id)target
                             action: (SEL)action;

-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                                url: (NSString*)url;


@end

@interface UIView(M3Extensions)

-(void)onTapOpen: (NSString*)url;

@end

#endif
