#import "AppBase.h"

@interface ActionController: NSObject
@property (retain,nonatomic) NSString* url;
@end

@implementation ActionController

@synthesize url;

-(void)perform
{
  [self.url.to_url.path matches: @"/action/(.*)"];
  [self performSelector: $1.to_sym];
}

-(void)update
{
  [app updateDatabase];
}
@end
