#if TARGET_OS_IPHONE 

@interface UIViewController(Model)

@property (retain,nonatomic) NSString* url;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic,readonly) NSDictionary* model;

-(BOOL) shouldOpenModally;

@end

#endif
