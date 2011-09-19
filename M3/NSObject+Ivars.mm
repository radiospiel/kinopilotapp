#import "M3.h"
#include <objc/runtime.h>

@implementation NSObject(Ivars)

-(id)ivar: (SEL)name
{
  return objc_getAssociatedObject(self, name);
}

-(void)ivar_set: (SEL)name withValue: (id)value;
{
  objc_setAssociatedObject(self, name, value, OBJC_ASSOCIATION_RETAIN);
}

-(id)memoized: (SEL)name usingBlock:(id (^)())block
{
  id current_value = [self ivar: name];
  if(current_value) return current_value;
  
  @synchronized(self) {
    current_value = [self ivar: name];
    if(!current_value) 
      current_value = block();
  }

  return current_value;
}

@end

ETest(NSObjectIvars)

-(void)testFails
{
  NSString* str = @"TestString";
  assert_nil([ str ivar: @selector(test) ]);
  assert_true(false);
}
@end

