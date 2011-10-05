@interface UIButton(M3ActionButton)

@property (nonatomic,retain) NSString* actionURL;

-(NSString*)actionURL;
-(void)setActionURL: (NSString*)url;

-(void)setActionURL: (NSString*)url andTitle: (NSString*)title;

+(UIButton*)actionButtonWithURL: (NSString*)url
                       andTitle: (NSString*)title;

@end
