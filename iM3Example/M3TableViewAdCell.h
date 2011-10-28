#import "M3TableViewCell.h"
#import <iAd/ADBannerView.h>

/*
 * M3TableViewAdCell: This cell shows the movie's image and a short 
 * description of the movie.
 */

@interface M3TableViewAdCell: M3TableViewCell<ADBannerViewDelegate> {
  ADBannerView* bannerView_;
}

@end
