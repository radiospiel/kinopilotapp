#import "AppDelegate.h"
#import "Chair.h"

// #import "TTTAttributedLabel.h"
// 
// @interface TTTAttributedLabel(M3Fixed)
// @end
// 
// @implementation TTTAttributedLabel(M3Fixed)
// 
// - (BOOL)isUserInteractionEnabled {
//   return [super isUserInteractionEnabled];
//   // return !_userInteractionDisabled && [self.links count] > 0;
// }
// 
// - (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
//   [super setUserInteractionEnabled: userInteractionEnabled];
//   _userInteractionDisabled = !userInteractionEnabled;
// }
// 
// @end

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
  [ self instance_variable_set: @selector(model) withValue: nil ];
};

-(NSString*) title {
  // Use any pre-set title
  NSString* title = [ self instance_variable_get: @selector(title) ];
  if(title) return title;
  
  // Do we have a model? Use a @"title" property in that case.
  if(self.model && [self.model isKindOfClass: [NSDictionary class]])
    title = [self.model objectForKey:@"title"];
  
  if(title) return title;
  
  // Use the class name as a title -- mostly for development purposes.
  return NSStringFromClass([self class]);
};

-(void) setTitle: (NSString*)title {
  [ self instance_variable_set: @selector(title) withValue: title ];
};


#pragma mark - set right action button

-(void)setRightButtonURL: (NSString*)url
{
  [ self instance_variable_set: @selector(right_button_url) withValue: url ];
}

-(void)openRightButtonURL
{
  [app open: [self instance_variable_get: @selector(right_button_url)]];
}

-(void)setRightButtonWithTitle: (NSString*)title_or_image
                        target: (id)target
                        action: (SEL)action
{
  UIBarButtonItem* item = [UIBarButtonItem alloc];
  
  item = [item initWithTitle: title_or_image
                       style: UIBarButtonItemStyleBordered
                      target: target
                      action: action];
  
  self.navigationItem.rightBarButtonItem = [item autorelease];
}

-(void)setRightButtonWithTitle: (NSString*)title_or_image
                           url: (NSString*)url
{
  [self setRightButtonURL: url];
  [self setRightButtonWithTitle: title_or_image 
                         target: self
                         action: @selector(openRightButtonURL)];
}

-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                             target: (id)target
                             action: (SEL)action
{
  UIBarButtonItem* item = [UIBarButtonItem alloc];
  
  item = [item initWithBarButtonSystemItem: systemItem
                                    target: target
                                    action: action];

  self.navigationItem.rightBarButtonItem = [item autorelease];
}

-(void)setRightButtonWithSystemItem: (UIBarButtonSystemItem)systemItem
                                url: (NSString*)url
{
  [self setRightButtonURL: url];
  [self setRightButtonWithSystemItem: systemItem 
                              target: self
                              action: @selector(openRightButtonURL)];
}

-(void)releaseM3Properties
{
  self.url = self.title = nil;
}

@end

@implementation UIView(M3Utilities)

-(void)openURLOnTap:(UITapGestureRecognizer*)recognizer
{
  dlog << "openURLOnTap:";
  
  NSString* url = [self instance_variable_get: @selector(urlToOpenOnTap)];
  [app open: url];
}

-(void)onTapOpen: (NSString*)url
{
  self.userInteractionEnabled = YES;
  
  if(![self instance_variable_get: @selector(urlToOpenOnTap)]) {
    UITapGestureRecognizer* r;
    r = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openURLOnTap:)]autorelease];
    [self addGestureRecognizer:r];
  }
  
  [self instance_variable_set: @selector(urlToOpenOnTap) withValue: url];
}

@end
