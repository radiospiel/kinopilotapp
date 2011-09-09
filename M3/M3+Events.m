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

  [nc addWeakObserver:receiver
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
                                 queue: nil           // run synchronously. [NSOperationQueue mainQueue]
                            usingBlock: callback ];

  // TODO: clean up in dealloc!
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


@interface M3EventsTests: M3ETest {
}

@end

@interface TestClass2: NSObject {
  int count_;
}

@property (nonatomic,assign) int count;

@end

@implementation TestClass2

@synthesize count = count_;

- (void) receiveM3TestNotification:(NSNotification *) notification
{
  self.count = self.count + 1;
}
@end

@implementation M3EventsTests

- (void)testEvents
{
  TestClass2* bar = [[ TestClass2 alloc]init];
  
  int __block count = 0;
  [ bar on: @"test.event" call: ^(NSNotification* notification) { count++; }];

  [bar emit: @"test.event"];
  assert_equal_pod(count, 1);
  
  TestClass2* foo = [[ TestClass2 alloc]init];
  [ bar on: @"test.event" notify: foo with: @selector(receiveM3TestNotification:) ];

  // This event is received by the block and by bar, but not by foo!
  [bar emit: @"test.event"];

  assert_equal_pod(count, 2);
  assert_equal_pod(foo.count, 1);
  assert_equal_pod(bar.count, 0);
  
  [ foo release ];

  // now that foo is no longer with us count would still increase.
  [bar emit: @"test.event"];

  assert_equal_pod(count, 3);
  assert_equal_pod(bar.count, 0);
}


@end

