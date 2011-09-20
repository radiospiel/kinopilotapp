
#if TARGET_OS_IPHONE 

@interface UIViewController(Model)

@property (retain,nonatomic) NSString* url;
@property (retain,nonatomic) NSDictionary* model;
@property (retain,nonatomic) NSString* title;

@end

#endif