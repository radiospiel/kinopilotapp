@interface UIButton(M3ActionButton)

@property (nonatomic,retain) NSString* actionURL;

+(UIButton*)actionButtonWithURL: (NSString*)url
                       andTitle: (NSString*)title;

@end
