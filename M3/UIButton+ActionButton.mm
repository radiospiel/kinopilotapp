#import "M3.h"
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE

#define BUTTON_PADDING 24
#define BUTTON_HEIGHT  29

@implementation UIButton(M3ActionButton)

+(void)layoutButtons: (NSArray*)buttons 
           withWidth: (int)width 
          andPadding: (int)padding
           andMargin: (int)margin
{
  int availableWidth = width - 2 * margin;

  int button_width = 0;
  for(UIButton* btn in buttons) {
    button_width = MAX(button_width, btn.frame.size.width);
  }

  int button_count = [buttons count];
  int space_between_buttons = 0;
  
	if(padding == EVEN_PADDING) { // uniform padding: left and right padding is same as space between buttons 
    space_between_buttons = (availableWidth - button_width * button_count) / (button_count + 1); 
	  padding = (availableWidth - button_width * button_count - space_between_buttons * (button_count - 1)) / 2;
  }
  else if([buttons count] > 1) {
    space_between_buttons = (availableWidth - padding - button_width * button_count) / (button_count - 1); 
  }
  
  int x = margin + padding;

  dlog << "x " << x;
  dlog << "space_between_buttons " << space_between_buttons;
  dlog << "button_width " << button_width;
  dlog << "padding " << padding;
  

  for(UIButton* btn in buttons) {
    CGRect frame = btn.frame;
    frame.origin.x = x;
    frame.size.width = button_width;
    btn.frame = frame;
      
    x += button_width + space_between_buttons;
  }
}

static UIImage* stretchableImageNamed(NSString* name) {
  UIImage* image = [UIImage imageNamed: @"button_grey_normal.png"];
  return [image stretchableImageWithLeftCapWidth:3 topCapHeight:3];
}

+(UIButton*)actionButtonWithURL: (NSString*)url 
                       andTitle: (NSString*)title;
{
  UIButton* btn = [UIButton buttonWithType: UIButtonTypeCustom];

  // set background images, colors and font.

  btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
  [btn setTitleColor: [UIColor colorWithName: @"4c4b4b"] forState: UIControlStateNormal];
  [btn setTitleShadowColor: [UIColor whiteColor] forState: UIControlStateNormal];
  btn.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);

  [btn setBackgroundImage: stretchableImageNamed(@"button_grey_normal.png") forState: UIControlStateNormal];
  [btn setBackgroundImage: stretchableImageNamed(@"button_grey_pushed.png") forState: UIControlStateSelected];

  // set URL
  
  btn.actionURL = url;
  
  // set title, adjust button size

  [btn setTitle: title forState:UIControlStateNormal];
  
  CGSize sz = [ btn.titleLabel sizeThatFits:CGSizeMake(1000, BUTTON_HEIGHT) ];
  btn.frame = CGRectMake(0, 0, sz.width + 2 * BUTTON_PADDING, BUTTON_HEIGHT);

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
  [app open:url];
}

@end

#endif
