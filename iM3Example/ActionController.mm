#import "M3AppDelegate.h"

@interface ActionController: NSObject
@property (retain,nonatomic) NSString* url;
@end

@implementation ActionController

@synthesize url = _url;

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
