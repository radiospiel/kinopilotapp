#import "AppDelegate.h"

@interface UpdateAction: NSObject

@end

@implementation UpdateAction

-(void)perform 
{
  [app.chairDB performSelector:@selector(update) withObject:nil afterDelay:0.3];
}

@end
