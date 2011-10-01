#if TARGET_OS_IPHONE 

@interface UIImageView(M3Extensions)

@property (nonatomic,retain) NSString* imageURL;

-(void)addImageToRotation: (UIImage*)image;

-(void)addImageURLToRotation: (NSString*)url;

@end

#endif
