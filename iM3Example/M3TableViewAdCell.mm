#import "M3.h"
#import "M3TableViewController+AdSupport.h"
#import "M3TableViewAdCell.h"

@implementation M3TableViewAdCell

-(id) init {
  self = [super init];

  self.textLabel.text = @"";
  self.textLabel.textColor = [UIColor clearColor];
  
  self.contentView.backgroundColor = [UIColor colorWithName: @"#000"];
  self.textLabel.backgroundColor = [UIColor colorWithName: @"#000"];
  
  return self;
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  ADBannerView* adView = (ADBannerView*) [self.tableViewController adBannerAtIndexPath: self.indexPath];
  if(adView.bannerLoaded) {
    adView.frame = CGRectMake(0,0,320,50);
    [self addSubview: adView];
  }
}

-(CGFloat)wantsHeight
{
  return [self.tableViewController hasAdBannerAtIndexPath: self.indexPath] ? 50 : 0;
}

@end
