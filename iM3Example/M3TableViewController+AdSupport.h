#import "M3TableViewController.h"

@interface M3TableViewController(AdSupport)

-(void)releaseRequestedBannerViews;
// -(void)requestAdBannerAtIndexPath: (NSIndexPath*)indexPath;
-(UIView*)adBannerAtIndexPath: (NSIndexPath*)indexPath;
-(BOOL)hasAdBannerAtIndexPath: (NSIndexPath*)indexPath;

@end
