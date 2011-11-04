#import "AppDelegate.h"

#import "M3TableViewCell.h"

@implementation M3TableViewCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont boldSystemFontOfSize:15] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:13] forKey:@"details"];
}

@synthesize tableViewController=tableViewController_, 
            indexPath=indexPath_,
            key=key_,
            url=url_;

-(id)initWithStyle:(UITableViewCellStyle)style
{
  self = [super initWithStyle:style reuseIdentifier: NSStringFromClass([self class])];
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

-(void)selectedCell 
{
  if(self.url) [app open: self.url];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  M3AssertNotNil(self.tableViewController);
  
  self.textLabel.font = [self.stylesheet fontForKey:@"h2"];
  self.textLabel.numberOfLines = 0;
  
  self.detailTextLabel.font = [self.stylesheet fontForKey:@"details"];
  self.detailTextLabel.numberOfLines = 0;
}

@end
