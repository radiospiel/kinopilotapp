#import "M3.h"
#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE

#define BUTTON_PADDING 24
#define BUTTON_HEIGHT  29

@implementation UIButton(M3ActionButton)

+(int)widthForButtons: (NSArray*)buttons 
{
  int button_width = 0;
  for(UIButton* btn in buttons) {
    button_width = MAX(button_width, btn.frame.size.width);
  }
  return button_width;
  // return button_width > 90 ? 90 : button_width;
}

+(void)layoutButtons: (NSArray*)buttons 
           withWidth: (int)button_width
            andSpace: (int)space
           andOffset: (int)x_offset
{
  if(!button_width)
    button_width = [self widthForButtons: buttons];
  
  for(UIButton* btn in buttons) {
    CGRect frame = btn.frame;
    frame.origin.x = x_offset;
    frame.size.width = button_width;
    btn.frame = frame;

    x_offset += button_width + space;
  }
}

+(void)layoutButtons: (NSArray*)buttons 
           withWidth: (int)width 
          andPadding: (int)padding
           andMargin: (int)margin
{
  int button_count = [buttons count];
  int availableWidth = width - 2 * margin;

  int button_width = [self widthForButtons: buttons];
  int space = 0;
  
	if(padding == EVEN_PADDING) { // uniform padding: left and right padding is same as space between buttons 
    space = (availableWidth - button_width * button_count) / (button_count + 1); 
	  padding = (availableWidth - button_width * button_count - space * (button_count - 1)) / 2;
  }
  else if([buttons count] > 1) {
    space = (availableWidth - padding - button_width * button_count) / (button_count - 1); 
  }
  
  [ self layoutButtons: buttons 
             withWidth: button_width
              andSpace: space
             andOffset: margin + padding ];
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
  id app = [[UIApplication sharedApplication]delegate];
  [app performSelector:@selector(open:) withObject: url];
}

@end

#endif
