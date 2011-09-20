#if TARGET_OS_IPHONE 

#import "M3.h"

@implementation UIViewController(Model)

-(NSDictionary*) model {
  return [ self instance_variable_get: @selector(model) ];
};

-(void) setModel: (NSDictionary*)model {
  [ self instance_variable_set: @selector(model) withValue: model ];
};

-(NSString*) url {
  return [ self instance_variable_get: @selector(url) ];
};

-(void) setUrl: (NSString*)url {
  [ self instance_variable_set: @selector(url) withValue: url ];
};

-(NSString*) title {
  NSString* title = [ self instance_variable_get: @selector(title) ];
  if(title) return title;
  
  NSDictionary* model = self.model;
  if([model isKindOfClass:[NSDictionary class]]) {
    title = [model objectForKey:@"title"];
    if(title) return title;
    
    title = [model objectForKey:@"label"];
    if(title) return title;
  }

  return NSStringFromClass([self class]);
};

-(void) setTitle: (NSString*)title {
  [ self instance_variable_set: @selector(title) withValue: title ];
};

@end

#endif
