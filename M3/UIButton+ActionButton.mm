#import "M3.h"

#if TARGET_OS_IPHONE

#define ACTIONS_BUTTON_HEIGHT 49

@implementation UIButton(M3ActionButton)

+(UIButton*)actionButtonWithURL: (NSString*)url 
                       andTitle: (NSString*)title;
{
  UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  btn.frame = CGRectMake(0, 5, 120, ACTIONS_BUTTON_HEIGHT - 5);
  [btn setActionURL: url andTitle: title];
  return btn;
}

-(NSString*)actionURL
{
  return [self instance_variable_get:@selector(action_url)];
}

-(void)setActionURL: (NSString*)url
{
  [self setActionURL: url andTitle: nil];
}

-(void)setActionURL: (NSString*)url andTitle: (NSString*)title
{
  [self instance_variable_set:@selector(action_url) withValue:url];

  // This action can be called multiple times: the target will
  // still be added only once.
  [self addTarget:self 
           action:@selector(activatedActionButton:) 
 forControlEvents:UIControlEventTouchUpInside];
  
  if(title)
    [self setTitle: title forState:UIControlStateNormal];
}

-(void)activatedActionButton: (id)sender
{
  NSString* url = [self instance_variable_get:@selector(action_url)];
  [[[UIApplication sharedApplication]delegate] open:url];
}

@end

#endif
