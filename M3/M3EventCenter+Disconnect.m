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

  [ref setCleanupBlock: ^(id target) {
    [self disconnectAll: object];
    [ref autorelease];
  }];

  // NSLog(@"retainCount is %d", (int)[object retainCount]);

  // Creating the MAZeroingWeakRef increments the object's retain count. 
  // As a quick fix we release the object here again.
  [object release];
}

@end
