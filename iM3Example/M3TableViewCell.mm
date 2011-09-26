#import "M3TableViewCell.h"

@implementation M3TableViewCell

@synthesize tableViewController, model, key;

-(id)initWithStyle:(UITableViewCellStyle)style
{
  // NSString* reuseIdentifier = NSStringFromClass([self class]);
  NSString* reuseIdentifier = nil; 
  
  self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: reuseIdentifier];

  self.textLabel.font = [UIFont systemFontOfSize:13];
  self.textLabel.numberOfLines = 0;

  return self;
}

-(id)init
{
  return [self initWithStyle:UITableViewCellStyleDefault];
}

-(void)dealloc
{
  self.model = nil;
  self.tableViewController = nil;
  
  [super dealloc];
}

- (CGFloat)wantsHeightForWidth: (CGFloat)width
{ 
  return 40.0f; 
}

@end
