#if TARGET_OS_IPHONE 

#import "M3.h"
#import "UIViewController+M3Extensions.h"

@implementation UIViewController(M3UrlExtensions)

-(NSString*) url {
  return [ self instance_variable_get: @selector(m3_url) ];
};

-(void) setUrl: (NSString*)url {
  if(!url && !self.url) return;
  if([url isEqualToString: self.url]) return;
  
  [self instance_variable_set: @selector(m3_url) withValue: url];
  if(url) [self reloadURL];
  
  self.navigationItem.title = self.title;
}

-(void)reloadURL
{
  // dlog << "*** reloadURL: " << _.ptr(self) << ", url: " << self.url;
}

-(void)reload 
{
  if(!self.url) return;
  [self reloadURL];
}

-(void)releaseM3Properties {
  [self instance_variable_set: @selector(m3_url) withValue: nil];
  self.title = nil;
}

-(BOOL)isFullscreen {
  return NO;
}

-(void)perform {
  id app = [[UIApplication sharedApplication]delegate];
  [app performSelector:@selector(presentControllerOnTop:) withObject:self];
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

@class M3AppDelegate;
extern M3AppDelegate* app;

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

-(void)setRightButtonWithImage: (UIImage*)image
                        target: (id)target
                        action: (SEL)action;
{
  UIBarButtonItem* item;
  item = [[UIBarButtonItem alloc]initWithImage: image 
                                         style: UIBarButtonItemStyleBordered
                                        target: target 
                                        action: action];
  
  self.navigationItem.rightBarButtonItem = [item autorelease];
}

-(void)setRightButtonWithImage: (UIImage*)image
                           url: (NSString*)url;
{
  M3UIBarButtonItem* item;
  item = [[M3UIBarButtonItem alloc]initWithImage: image
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

-(void)setRightButtonWithFlatImage: (UIImage*)image
                        target: (id)target
                        action: (SEL)action;
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setBackgroundImage: image forState:UIControlStateNormal];
  
  button.frame = CGRectMake(0.0, 0.0, 32, 32);
  
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
  self.navigationItem.rightBarButtonItem = [item autorelease];
}

-(void)setRightButtonReloadAction
{
  [self setRightButtonWithFlatImage: [UIImage imageNamed:@"icon_72px.png"] 
                         target: app 
                         action: @selector(popToRootViewController)];
}

@end

#endif
