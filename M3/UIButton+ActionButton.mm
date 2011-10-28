#import "M3.h"
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE

@implementation UIButton(M3ActionButton)

+(UIButton*)actionButtonWithURL: (NSString*)url 
                       andTitle: (NSString*)title;
{
  UIFont* font = [UIFont boldSystemFontOfSize:15];
  
  UIColor* color = [UIColor colorWithName: @"555"];
  UIColor* bgColor = [UIColor colorWithName: @"ddd"];
  UIColor* bgColorSelected = [UIColor colorWithName: @"777"];
  

  UIButton* btn = [UIButton buttonWithType: UIButtonTypeCustom];
  btn.frame = CGRectMake(0, 0, 135, 24);

  btn.actionURL = url;
  [btn setTitle: title forState:UIControlStateNormal];

  btn.titleLabel.font = font;
  
  [btn setBackgroundImage: bgColor.to_image forState: UIControlStateNormal];
  [btn setBackgroundImage: bgColorSelected.to_image forState: UIControlStateSelected];
  
  btn.clipsToBounds = YES;

  [btn setTitleColor: color forState:UIControlStateNormal];
  
  //    button.layer.cornerRadius = 2; // this value vary as per your desire
  //    button.layer.borderColor = (CGColorRef) [UIColor blackColor];
  //    button.layer.borderWidth = 2;
  //    button.opaque = NO;
  //    button.backgroundColor = [UIColor clearColor];

  CALayer* layer = btn.layer;
  layer.cornerRadius = 6.0f;
  layer.borderWidth = 1.3f;
  layer.borderColor = [color CGColor];
  layer.masksToBounds = YES;

  return btn;
}

-(NSString*)actionURL
{
  return [self instance_variable_get:@selector(action_url)];
}

-(void)setActionURL: (NSString*)url
{
  if(!self.actionURL) {
    [self addTarget:self action:@selector(activatedActionButton:) 
               forControlEvents:UIControlEventTouchUpInside];
  }
  
  [self instance_variable_set:@selector(action_url) withValue:url];
}

-(void)activatedActionButton: (id)sender
{
  NSString* url = [self instance_variable_get:@selector(action_url)];
  [[[UIApplication sharedApplication]delegate] open:url];
}

@end

#endif
