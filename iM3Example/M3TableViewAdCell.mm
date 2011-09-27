#import "M3.h"
#import "M3TableViewController.h"
#import "M3TableViewAdCell.h"

@implementation M3TableViewAdCell

-(id) init {
  self = [super init];
  if(!self) return nil;

  self.textLabel.text = @"";
  self.textLabel.textColor = [UIColor clearColor];
  
  self.contentView.backgroundColor = [UIColor colorWithName: @"#000"];
  self.textLabel.backgroundColor = [UIColor colorWithName: @"#000"];
  
  return self;
}

-(void)setModel: (NSDictionary*)model
{
  [super setModel:model];
  // [self.tableViewController requestAdBannerAtIndexPath: self.indexPath];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  ADBannerView* adView = (ADBannerView*) [self.tableViewController adBannerAtIndexPath: self.indexPath];
  if(adView && adView.bannerLoaded) {
    adView.frame = CGRectMake(0,0,320,50);
    [self addSubview: adView];
  }
}

-(CGFloat)wantsHeight
{
  ADBannerView* adView = (ADBannerView*) [self.tableViewController adBannerAtIndexPath: self.indexPath];
  return adView.bannerLoaded ? 50 : 0;
}

@end
