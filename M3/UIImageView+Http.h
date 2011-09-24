#if TARGET_OS_IPHONE 

@interface UIImageView(Http)

@property (nonatomic,retain) NSString* imageURL;

-(void)addAnimatedImageWithURL: (NSString*)url;

@end

#endif
