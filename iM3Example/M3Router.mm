#import "AppDelegate.h"
#import "M3Router.h"

@implementation M3Router

-(Class)controllerClassForURL: (NSString*) url
{
  // /category/action[/params] URLs create a CategoryActionController object. 
  NSArray* parts = [url.to_url.path componentsSeparatedByString: @"/"];
  parts = [parts mapUsingSelector:@selector(camelizeWord)];
  
  NSString *className = _.join([parts get:1], [parts get:2], "Controller");
  return className.to_class;
}
  
-(UIViewController*)controllerForURL: (NSString*)url
{
  Class klass = [self controllerClassForURL: url];
  UIViewController* vc = [[klass alloc]init];
  
  vc.url = url;

  // TODO:
  //
  // get landscape view controller for URL and Data
  // merge landscape view controller with portrait view controller 

  return [vc autorelease];
}

@end
