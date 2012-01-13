#import "M3AppDelegate.h"
#import "M3TableViewCell.h"
#import "TTTAttributedLabel.h"

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
{ 
  return 0; 
}

-(void)didSelectCell 
{
  NSString* url = self.url;
  if(url) [app open: url];
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

/*
 * M3TableViewUrlCell: This cell links a label to an URL.
 */

@implementation M3TableViewUrlCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont boldSystemFontOfSize:14] forKey:@"h2"];
}

+(CGFloat)fixedHeight
{
  return 44;
}

-(id)init
{
  self = [super init];
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  return self;
}

@end

/*
 * M3TableViewHtmlCell: This cell shows a HTML description
 */

@implementation M3TableViewHtmlCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"p"];
}

-(id) init {
  self = [super init];
  if(!self) return nil;
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  htmlView = [[[TTTAttributedLabel alloc]init]autorelease];
  [self addSubview:htmlView];
  
  return self;
}

-(void)setHtml: (NSString*)html
{
  self.textLabel.text = @" ";
  htmlView.numberOfLines = 0;
  htmlView.text = [NSAttributedString attributedStringWithMarkup: html 
                                                   forStylesheet: self.stylesheet];
}

-(CGSize)htmlViewSize
{ 
  return [htmlView sizeThatFits: CGSizeMake(300, 1000)]; 
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(10, 5, sz.width, sz.height);
}

- (CGFloat)wantsHeight
{ 
  return [self htmlViewSize].height + 15; 
}

@end
