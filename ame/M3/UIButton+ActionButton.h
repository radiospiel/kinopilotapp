@interface UIButton(M3ActionButton)

@property (nonatomic,retain) NSString* actionURL;

+(UIButton*)actionButtonWithURL: (NSString*)url
                       andTitle: (NSString*)title;

#define EVEN_PADDING 	(-1)

+(void)layoutButtons: (NSArray*)buttons 
           withWidth: (int)width 
          andPadding: (int)padding
           andMargin: (int)margin;

+(void)layoutButtons: (NSArray*)buttons 
           withWidth: (int)width
            andSpace: (int)space
           andOffset: (int)x_offset;

@end
