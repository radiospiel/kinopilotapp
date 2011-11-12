#import "M3.h"
#import "M3AppDelegate.h"

#import "UIViewController+M3Extensions.h"

@implementation M3AppDelegate(ApplicationURL)

-(void)trackOpenURL: (NSString*)url
{
  if([url matches: @"^([-a-z]+):"]) {
    [self trackEvent: _.join(@"open:", $1)];
  }
  else {
    [url matches: @"^((/[a-zA-Z0-9_]+)+)"];
    [self trackEvent: _.join(@"open:", $1)];
  }
}

#pragma mark --- external URLs -----------------------------------

/*
 * can this URL be opened? This method returns NO, if the url is an 
 * internal URL, or if the URL is an external URL and the respective
 * application is installed.
 */
-(BOOL)canOpen: (NSString*)url
{
  // Is this an internal URL? By definition internal URLs *can*
  // be handled by the application; if they cannot be handled
  // there would be an error in the application.
  if(![url matches: @"^([-a-z]+):"]) return YES;

  return [[UIApplication sharedApplication] canOpenURL:url.to_url];
}

/*
 * Opening an application action?
 */
-(BOOL)openExternalURL: (NSString*)url 
{
  if(![url matches: @"^([-a-z]+):"]) return NO;
  
  if(![self canOpen: url]) {
    dlog << "Cannot open URL " << url;
    return NO;
  }
  
  // Adjust mailto URLs
  if([url matches: @"^mailto:(.*)"]) {
    url = [NSString stringWithFormat: @"mailto:?to=%@&subject=%@&body=%@",
           [$1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
           @"Subject", @"Body" ];
  }

  [self trackOpenURL: url];
  [[UIApplication sharedApplication] openURL: url.to_url];
  return YES;
}

#pragma mark --- internal URLs -----------------------------------

/*
 * Pass in an URL, and get a controller object which is able to
 * deal with this URL, and which has been initialized and set up,
 * but not yet activated.
 */

-(Class)controllerClassForURL: (NSString*) url
{
  // /category/action[/params] URLs create a CategoryActionController object. 
  NSArray* parts = [url.to_url.path componentsSeparatedByString: @"/"];
  parts = [parts mapUsingSelector:@selector(camelizeWord)];
  
  @try {
    NSString *className = _.join([parts get:1], [parts get:2], "Controller");
    return className.to_class;
  }
  @catch(id exception) {
    dlog << exception;
  }
  
  @try {
    NSString *className = _.join([parts get:1], "Controller");
    return className.to_class;
  }
  @catch(id exception) {
    dlog << exception;
  }
  
  return nil;
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

// Open internal URLs inside application.
-(BOOL)openInternalURL: (NSString*)url 
{
  UIViewController* vc = [self controllerForURL: url];
  if(!vc) return NO;
  
  [self trackOpenURL: url];
  [vc perform];
  return YES;
}

/*
 * "opens" the URL.
 * 
 * There are different kind of URL:
 *
 * - "app:<action>" executes an action name via AppDelegate#executeAction:
 * - "<protocol>:<protocol-parameters>" executes an external URL.
 */
-(void)open: (NSString*)url
{
  if(!url) return;
  
  dlog << "*** open: " << url;
  
  // URLs with a scheme part are opened as external URLs.
  BOOL isExternalURL = [url matches: @"^([-a-z]+):"] != nil;
  if(isExternalURL) 
    [self openExternalURL: url];
  else
    [self openInternalURL: url];
}

@end
