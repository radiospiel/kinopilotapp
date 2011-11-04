#import "M3.h"
#import "UIViewController+M3Extensions.h"

@class AppDelegate;
extern AppDelegate* app;

@implementation UIViewController(M3UrlExtensions)

-(NSString*) url {
  return [ self instance_variable_get: @selector(m3_url) ];
};

-(void) setUrl: (NSString*)url {
  if([url isEqualToString: self.url]) return;
  
  [self instance_variable_set: @selector(m3_url) withValue: url];
  [self loadFromUrl:url];
}

-(void)loadFromUrl: (NSString*)url
{
  dlog << "*** loadFromUrl: " << _.ptr(self) << ", url: " << self.url;
}

-(void)reload 
{
  [self loadFromUrl:self.url];
}

-(NSString*) title {
  return [ self instance_variable_get: @selector(m3_title) ];
};

-(void) setTitle: (NSString*)title {
  [ self instance_variable_set: @selector(m3_title) withValue: title ];
};

-(void)releaseM3Properties {
  [self instance_variable_set: @selector(m3_url) withValue: nil];
  self.title = nil;
}

-(BOOL)isFullscreen {
  return NO;
}

-(void)perform {
  [app presentControllerOnTop: self];
}

@end


@interface M3UIBarButtonItem: UIBarButtonItem {
  NSString* url_;
}

@property (nonatomic,retain) NSString* url;

@end

@implementation M3UIBarButtonItem

-(NSString*) url 
{ 
  return url_; 
}

-(void)setUrl: (NSString *)url 
{ 
  self.target = self;
  self.action = @selector(openURL); 
  
  url = [url copy]; 
  [url_ release];
  url_ = url;
}

-(void)dealloc
{
  [url_ release];
  [super dealloc];
}

-(void)openURL
{
  id app = [[UIApplication sharedApplication]delegate];
  [app performSelector:@selector(open:) withObject: url_];
}

@end


@implementation UIViewController(M3Extensions)


#pragma mark - set right action button

-(void)setRightButtonWithTitle: (NSString*)title
                        target: (id)target
                        action: (SEL)action
{
  UIBarButtonItem* item;
  item = [[UIBarButtonItem alloc]initWithTitle: title 
                                         style: UIBarButtonItemStyleBordered
                                        target: target 
                                        action: action];
  
  self.navigationItem.rightBarButtonItem = [item autorelease];
}


-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                             target: (id)target
                             action: (SEL)action
{
  UIBarButtonItem* item;
  item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: systemItem
                                                       target: target
                                                       action: action];
  
  self.navigationItem.rightBarButtonItem = [item autorelease];
}

-(void)setRightButtonWithTitle: (NSString*)title
                           url: (NSString*)url
{
  M3UIBarButtonItem* item;
  item = [[M3UIBarButtonItem alloc]initWithTitle: title 
                                           style: UIBarButtonItemStyleBordered
                                          target: nil 
                                          action: nil];
  item.url = url;
  
  self.navigationItem.rightBarButtonItem = [item autorelease];
}

-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                                url: (NSString*)url
{
  M3UIBarButtonItem* item;
  item = [[M3UIBarButtonItem alloc]initWithBarButtonSystemItem: systemItem
                                                        target: nil 
                                                        action: nil];
  item.url = url;
  
  self.navigationItem.rightBarButtonItem = [item autorelease];
}

@end



/*
 * an URL opener
 */

@interface M3URLOpener: NSObject {
  NSString* url_;
}

@property (nonatomic,copy) NSString* url;

@end

@implementation M3URLOpener

@synthesize url=url_;

-(void)dealloc
{
  self.url = nil;
  [super dealloc];
}

-(void)openURL
{
  id app = [[UIApplication sharedApplication]delegate];
  [app performSelector:@selector(open:) withObject: url_];
}

@end


/*
 * an URL opener
 */

@interface M3UITapGestureRecognizer: UITapGestureRecognizer {
  M3URLOpener* urlOpener_;
}

@property (nonatomic,retain) M3URLOpener* urlOpener;

@end

@implementation M3UITapGestureRecognizer

@synthesize urlOpener = urlOpener_;

@end

@implementation UIView(M3Utilities)

-(void)onTapOpen: (NSString*)url
{
  self.userInteractionEnabled = YES;
  
  M3URLOpener* target = [[M3URLOpener alloc]init];
  target.url = url;
  M3UITapGestureRecognizer* r = [[M3UITapGestureRecognizer alloc]initWithTarget:target 
                                                                         action:@selector(openURL)];
  r.urlOpener = [target autorelease];
  
  [self addGestureRecognizer:[r autorelease]];
}

@end
