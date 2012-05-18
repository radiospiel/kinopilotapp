#if TARGET_OS_IPHONE 

#import "M3AppDelegate.h"

@implementation M3AppDelegate(ApplicationURL)

-(void)trackOpenURL: (NSString*)url
{
  if([url matches: @"^([-a-z]+):"]) {
    [self trackEvent: _.join(@"open:", $1)];
  }
  else {
    [url matches: @"^((/[a-zA-Z0-9_]+)+)"];
    [self trackEvent: $1];
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

-(BOOL)kinopilotInstalled
{
  return [self canOpen: [NSString stringWithFormat:@"%@://test", KINOPILOT_FB_SCHEME]];
}

-(void)cannotOpen: (NSString*)url 
{
  if([url containsString: @"fahrinfo-berlin"]) {
    [app alertMessage: @"Um die Fahrinfo für diese Adresse zu sehen, installiere die Anwendung "
                        "\"Fahrinfo-Berlin\" im iTunes Store."];
  }

  dlog << "Cannot open URL " << url;
}

/*
 * Opening an application action?
 */
-(BOOL)openExternalURL: (NSString*)url 
{
  if(![url matches: @"^([-a-z]+):"]) return NO;
  
  if(![self canOpen: url]) {
    [self cannotOpen: url];
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
  if([url matches: @"^([-a-z]+):"]) {
    return @"WebViewController".to_class;
  }
  
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

static BOOL isExternalURL(NSString* url) 
{
  if(![url matches: @"^([-a-z]+):"]) 
    return NO;
  
  if([url matches: @"^http.*amazon"]) 
    return NO;

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
-(void)open: (NSString*)url withDelay: (BOOL)delay
{
  if(!url) return;
  
  dlog << "*** open: " << url;

  if(isExternalURL(url)) {
    [self openExternalURL: url];
    return;
  }

  if(!delay) {
    [self openInternalURL: url];
    return;
  }
  
  // internal URLs will usually be opened only after a short delay.
  // This is to make sure the OS can start any animation needed.
  int64_t nanosecs = 0.05 * 1e09;
  dispatch_after( dispatch_time(DISPATCH_TIME_NOW, nanosecs),
                   dispatch_get_main_queue(), ^{
                     [self openInternalURL: url];
                   });
}

-(void)open: (NSString*)url
{
  [self open:url withDelay:YES]; 
}

-(void)openFromModalView: (NSString*)url
{
  [self open:url withDelay:NO]; 
}

@end

#endif
