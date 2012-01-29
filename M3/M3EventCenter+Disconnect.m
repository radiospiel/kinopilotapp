#import "M3.h"
#import "M3-Internals.h"

@implementation M3EventCenter(Disconnect)

-(void)__disconnectAutomatically:(id)object
{
  MAZeroingWeakRef *ref = [[MAZeroingWeakRef alloc] initWithTarget: object];

  // Note: it is important not to use the object within the block, as
  // this would magically retain the object one more time on some
  // platforms, but not on others.
  [ref setCleanupBlock: ^(id target) {
    [self disconnectAll: target];
    [ref autorelease];
  }];
}

@end
