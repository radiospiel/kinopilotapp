#import "AppDelegate.h"

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
  dlog << "update"; 
  [app.chairDB performSelector:@selector(update) withObject:nil afterDelay:0.3];
}
@end
