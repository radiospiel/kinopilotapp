#import "M3.h"

#define COREFOUNDATION_HACK_LEVEL 0
#define KVO_HACK_LEVEL 0

#import "MAZeroingWeakRef/MAZeroingWeakRef.h"
#import "MAZeroingWeakRef/MAZeroingWeakRef.m"

@implementation M3EventCenter

+(void)connect: (id)sender    event: (SEL)event 
            to: (id)observer  selector: (SEL)selector;
{
  // A weak reference to sender and observer.
  MAZeroingWeakRef *senderRef = [[MAZeroingWeakRef alloc] initWithTarget: self];
  MAZeroingWeakRef *observerRef = [[MAZeroingWeakRef alloc] initWithTarget: observer];
  
}

@end
