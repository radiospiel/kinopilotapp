#if TARGET_OS_IPHONE 

@interface UIColor(M3Extensions)
+ (UIColor *)colorWithName:(NSString*)name;


// returns a 1x1 pixel image of that color.
@property (retain,nonatomic,readonly) UIImage* to_image;
-(UIImage*) to_image;

@end

#endif
