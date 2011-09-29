#import "M3TableViewCell.h"
#import "Underscore.hh"

@implementation M3TableViewCell

@synthesize tableViewController=tableViewController_, 
            indexPath=indexPath_,
            key=key_;

-(id)initWithStyle:(UITableViewCellStyle)style
{
  self = [super initWithStyle:style reuseIdentifier: NSStringFromClass([self class])];
  self.textLabel.font = [UIFont systemFontOfSize:13];
  self.textLabel.numberOfLines = 0;

  self.detailTextLabel.font = [UIFont systemFontOfSize:13];
  self.detailTextLabel.numberOfLines = 0;

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

-(NSString*)urlToOpen
  { return nil; }

@end
