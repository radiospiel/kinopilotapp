#if TARGET_OS_IPHONE 

@interface UIViewController(Model)

@property (retain,nonatomic) NSString* url;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic,readonly) NSDictionary* model;

@end

@interface UIView(M3Utilities)
-(void)onTapOpen: (NSString*)url;
@end

#endif
