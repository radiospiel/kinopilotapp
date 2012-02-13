#import "M3AppDelegate.h"
#import "M3TableViewController.h"
#import "M3ListViewController.h"

// --- iAds ------------------------------------------------------------------

@implementation M3TableViewController(AdSupport)

/*
 * request an ad banner
 */

-(void)requestAdBannerOnTop
{
  ADBannerView* bannerView = [[[ADBannerView alloc]initWithFrame:CGRectMake(0,0,0,0)] autorelease];
  bannerView.delegate = self;
  bannerView.requiredContentSizeIdentifiers = [NSSet setWithObject: ADBannerContentSizeIdentifierPortrait];
  bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;            
  
  self.topBannerView = bannerView;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
  [app trackEvent: @"/ad/clicked"];
  
  return YES;
}

/*
 * a banner was properly loaded -> reload the AdCell at the cell's indexPath. 
 */
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
  [app trackEvent: @"/ad/loaded"];
  
  [UIView animateWithDuration:0.25
                   animations:^ { self.tableView.contentOffset = CGPointMake(0, -50); }
                   completion:^(BOOL finished){ self.tableView.tableHeaderView = banner; }
   ];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  self.tableView.contentOffset = CGPointMake(0, -50);
  self.tableView.tableHeaderView = nil;
}

@end
