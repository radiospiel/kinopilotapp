#import "NSURL+M3Extensions.h"

@interface NSURL(M3URLExtensions)

@property (readonly,nonatomic,retain) NSDictionary* params;
-(NSDictionary*)params;

-(NSString*)param: (NSString*)key;

@property (readonly,nonatomic,retain) NSURL* to_url;
-(NSURL*)to_url;

@end

@interface NSString(M3URLExtensions)

@property (readonly,nonatomic,retain) NSURL* to_url;
-(NSURL*)to_url;

@end
