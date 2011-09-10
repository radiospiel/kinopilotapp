#import "M3.h"

#define COREFOUNDATION_HACK_LEVEL 0
#define KVO_HACK_LEVEL 0

#import "MAZeroingWeakRef/MAZeroingWeakRef.h"
#import "MAZeroingWeakRef/MAZeroingWeakRef.m"

@implementation M3EventCenter(Disconnect)

-(void)__disconnectAutomatically:(id)object
{
  // NSLog(@"retainCount is %d", (int)[object retainCount]);

  MAZeroingWeakRef *ref = [[MAZeroingWeakRef alloc] initWithTarget: object];

  // Note: it is important not to use the object within the block, as
  // this would magically retain the object one more time on some
  // platforms, but not on others.
  [ref setCleanupBlock: ^(id target) {
    // NSLog(@"Cleaning up connection");
    
    [self disconnectAll: target];
    [ref autorelease];
  }];
}

@end
