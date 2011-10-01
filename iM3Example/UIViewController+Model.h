#if TARGET_OS_IPHONE 

@interface UIViewController(Model)

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

@property (retain,nonatomic) NSString* url;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic,readonly) NSDictionary* model;

-(void)releaseM3Properties;

@end

@interface UIView(M3Utilities)

-(void)onTapOpen: (NSString*)url;

@end

#endif
