#import "M3.h"

#define COREFOUNDATION_HACK_LEVEL 0
#define KVO_HACK_LEVEL 0

#import "MAZeroingWeakRef/MAZeroingWeakRef.h"
#import "MAZeroingWeakRef/MAZeroingWeakRef.m"
#import "MAZeroingWeakRef/MANotificationCenterAdditions.h"
#import "MAZeroingWeakRef/MANotificationCenterAdditions.m"

@implementation NSObject(M3Events)

-(void) on: (NSString*) event
    notify: (id) receiver
      with: (SEL)selector;
{
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:receiver
         selector:selector
             name:event
           object:self ];
}

-(void) on: (NSString*) event
      call: (EventCallback) callback
{
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

  id observer = [nc addObserverForName:event
                                object:self
                                 queue:[NSOperationQueue mainQueue]
                            usingBlock: ^(NSNotification* notification) {} ];

  // TODO: clean up observers in dealloc!
  [ observer retain ];
}

- (void) emit: (NSString*) event withParameter: (id) parameter
{
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName: event 
                    object: self
                  userInfo: parameter ];
}

- (void) emit: (NSString*) event
{
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName: event 
                    object: self
                  userInfo: nil ];
}

@end
