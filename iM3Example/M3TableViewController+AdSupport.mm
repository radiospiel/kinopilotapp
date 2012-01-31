#import "M3AppDelegate.h"
#import "M3TableViewController.h"
#import "M3TableViewController+AdSupport.h"
#import "M3ListViewController.h"

// --- iAds ------------------------------------------------------------------

static NSString *kADBannerContentSizePortrait = nil;
static NSString *kADBannerContentSizeLandscape = nil;

@implementation M3TableViewController(AdSupport)

+(void)initialize
{
  if (&ADBannerContentSizeIdentifierPortrait != nil)
    kADBannerContentSizePortrait = ADBannerContentSizeIdentifierPortrait;
  else
    kADBannerContentSizePortrait = ADBannerContentSizeIdentifier320x50;
  
  if (&ADBannerContentSizeIdentifierLandscape != nil)
    kADBannerContentSizeLandscape = ADBannerContentSizeIdentifierLandscape;
  else
    kADBannerContentSizeLandscape = ADBannerContentSizeIdentifier480x32;
}

-(void)releaseRequestedBannerViews
{
  [requestedAdBanners_ enumerateKeysAndObjectsUsingBlock:^(id key, ADBannerView* bannerView, BOOL *stop) {
    bannerView.delegate = nil;
    [bannerView release];
  }];
}

// This method returns a NSMutableDictionary mapping index paths to ADBannerView
-(NSMutableDictionary*)requestedBannerViews
{
  if(!requestedAdBanners_)
    requestedAdBanners_ = [[NSMutableDictionary alloc]init];

  return requestedAdBanners_;
}

/*
 * request an ad banner on indexPath.
 */
-(void)requestAdBannerAtIndexPath_: (NSIndexPath*)indexPath
{
  ADBannerView* adView = [[[ADBannerView alloc]initWithFrame:CGRectZero] autorelease];
  [adView setRequiredContentSizeIdentifiers:[NSSet setWithObject: kADBannerContentSizePortrait ]];
  [adView setCurrentContentSizeIdentifier: kADBannerContentSizePortrait];            
  // [adView setFrame:CGRectOffset([bannerView_ frame], 0, 50)];
  [adView setDelegate:self];

  NSMutableDictionary* requestedBannerViews = [self requestedBannerViews];
  [requestedBannerViews setObject: adView forKey: indexPath];
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
  NSIndexPath* indexPath = [[self requestedBannerViews]allKeysForObject:banner].first;
  if(!indexPath) return;

  [app trackEvent: @"/ad/loaded"];
  
  // TODO:
  //
  // If this is a list view controller which is currently filtering 
  // we do not update the table view. This is because the indexPath
  // here refers to the index path in the original datasource, not
  // in the filtered one!
  if([self isKindOfClass: [M3ListViewController class]]) {
    if([((M3ListViewController*)self) filterText].length > 0) return;
  }
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject: indexPath]
                        withRowAnimation:UITableViewRowAnimationNone];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  NSIndexPath* indexPath = [[self requestedBannerViews]allKeysForObject:banner].first;
  if(!indexPath) return;
  
  dlog << @"*** Did not receive a banner on " << indexPath 
       << "; reason: " << indexPath;
}

-(UIView*) adBannerAtIndexPath: (NSIndexPath*)indexPath
{
  UIView* view = [[self requestedBannerViews]objectForKey: indexPath];
  if(view) return view;
  
  [self requestAdBannerAtIndexPath_:indexPath];
  return nil;
}

-(BOOL)hasAdBannerAtIndexPath: (NSIndexPath*)indexPath
{
  ADBannerView* adView = [[self requestedBannerViews]objectForKey: indexPath];
  return adView.bannerLoaded;
}

@end
