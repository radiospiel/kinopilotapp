#import "M3.h"
#include <objc/runtime.h>

@implementation NSObject(Ivars)

-(id)instance_variable_get: (SEL)name
{
  return objc_getAssociatedObject(self, name);
}

-(void)instance_variable_set: (SEL)name withValue: (id)value;
{
  objc_setAssociatedObject(self, name, value, OBJC_ASSOCIATION_RETAIN);
}

-(id)memoized: (SEL)name usingBlock:(id (^)())block
{
  id current_value = [self instance_variable_get: name];
  if(current_value) return current_value;
  
  // @synchronized(self) {
    current_value = [self instance_variable_get: name];
    if(!current_value) {
      current_value = block();
      [self instance_variable_set: name withValue: current_value ];
    }
  // }

  return current_value;
}

@end

ETest(NSObjectIvars)

-(void)testFails
{
  NSString* str = @"Host";
  assert_nil([ str instance_variable_get: @selector(test) ]);

  NSDictionary* test = _.hash("key", "value");
  assert_equal(1, [test retainCount]);

  [ str instance_variable_set: @selector(test) withValue: test];
  assert_equal(2, [test retainCount]);
  
  assert_equal([ str instance_variable_get: @selector(test) ], test);

  [ str instance_variable_set: @selector(test) withValue: nil];
  assert_nil([ str instance_variable_get: @selector(test) ]);
}
@end

