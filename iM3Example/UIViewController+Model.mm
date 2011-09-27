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

@end

@implementation UIView(M3Utilities)

-(void)openURLOnTap:(UITapGestureRecognizer*)recognizer
{
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
    
    dlog << "Installed " << r << " on " << _.ptr(self);
  }
  
  [self instance_variable_set: @selector(urlToOpenOnTap) withValue: url];
}

@end
