#import "AppDelegate.h"
#import "M3Router.h"

@implementation M3Router

-(NSString*)nibNameForURL: (NSString*)url
{
	if ([url matches: @"^/map/show(/(\\w+))?"])
    return @"MapShowController";

  return nil;
}

-(NSString*)controllerClassNameForURL: (NSString*) url
{
  // /category/action[/params] URLs create a CategoryActionController
  // object. If action is not "list", the objects will be loaded from a
  // NIB with a matching name.
  if ([url matches: @"^/(\\w+)/list(/(\\w+))?"]) 
    return _.join($1.camelizeWord, "ListController");

  if ([url matches: @"^/dashboard"])
    return @"DashboardController";
  
  if ([url matches: @"^/vicinity/show"])
    return @"VicinityShowController";

  if ([url matches: @"^/movies/images(/(\\w+))?"])
    return @"MoviesImagesController";

  if ([url matches: @"^/map/show(/(\\w+))?"])
    return @"MapShowController";
  
  if ([url matches: @"^/(\\w+)/show(/(\\w+))?"])
    return _.join($1.camelizeWord, "ShowController");

  if ([url matches: @"^/(\\w+)/full(/(\\w+))?"])
    return _.join($1.camelizeWord, "FullController");
  
  if ([url matches: @"^/(\\w+)"])
    return _.join($1.camelizeWord, "Controller");

  return nil;
}
  
-(UIViewController*)controllerForURL: (NSString*)url
{
  NSString* nibName = [self nibNameForURL: url];
  NSString *className = nibName ? nibName : [self controllerClassNameForURL: url];
  
  if(!className)
    _.raise("Cannot find controller class name for URL ", url);
  
  Class klass = NSClassFromString(className);
  if(!klass)
    _.raise("Cannot find controller class name for URL ", url);

  UIViewController* vc = !nibName ? [[klass alloc]init] : 
    [[klass alloc]initWithNibName:nibName bundle:nil];
  
  vc.url = url;

  // TODO:
  //
  // get landscape view controller for URL and Data
  // merge landscape view controller with portrait view controller 

  return [vc autorelease];
}

@end
