#import "M3TableViewCell.h"
#import "Underscore.hh"

@implementation M3TableViewCell

@synthesize tableViewController=tableViewController_, model=model_, key=key_, indexPath=indexPath_;

-(id)initWithStyle:(UITableViewCellStyle)style
{
  NSString* reuseIdentifier = NSStringFromClass([self class]);
  
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
  self.tableViewController = nil;
  self.key = nil;
  self.model = nil;
  self.indexPath = nil;
  
  [super dealloc];
}

- (CGFloat)wantsHeight
{ 
  _.raise(_.join(@"Implementation missing for ", [self class], "#wantsHeight")); 
  return nil;
}

+(CGFloat) fixedHeight;
  { return 0; }

@end
