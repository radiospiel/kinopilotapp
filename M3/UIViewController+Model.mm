#if TARGET_OS_IPHONE 

#import "M3.h"

@implementation UIViewController(Model)

-(NSDictionary*) model {
  return [ self instance_variable_get: @selector(model) ];
};

-(void) setModel: (NSDictionary*)model {
  return [ self instance_variable_set: @selector(model) withValue: model ];
};

@end

#endif
