#import "AppDelegate.h"
#import "Chair.h"

@implementation UIViewController(Model)

-(NSDictionary*) model 
{
  if(!self.url) return nil;
 
  return [self memoized:@selector(model) usingBlock:^(){
    return [app.chairDB modelWithURL: self.url];
  }];
}

-(NSString*) url {
  return [ self instance_variable_get: @selector(url) ];
};

-(void) setUrl: (NSString*)url {
  [ self instance_variable_set: @selector(url) withValue: url ];
};

-(NSString*) title {
  // Use any pre-set title
  NSString* title = [ self instance_variable_get: @selector(title) ];
  if(title) return title;
  
  // Do we have a model? Use a @"title" property in that case.
  title = [self.model objectForKey:@"title"];
  
  if(title) return title;
  
  // Use the class name as a title -- mostly for development purposes.
  return NSStringFromClass([self class]);
};

-(void) setTitle: (NSString*)title {
  [ self instance_variable_set: @selector(title) withValue: title ];
};

-(BOOL) shouldOpenModally
{
  return NO;
}

-(void) dismissModalViewController
{
  [self dismissModalViewControllerAnimated:YES];
}

@end
