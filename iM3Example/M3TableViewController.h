//
//  M3TableViewController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

#import "M3TableViewCell.h"
#import "M3TableViewDataSource.h"

@class M3TableViewDataSource;

/*
 * A M3TableViewController to work with M3TableViewCells. It adds an 
 * additional segmented control, which allows for filtering the 
 * table view. 
 */

@interface M3TableViewController : UITableViewController<ADBannerViewDelegate> {
  UISegmentedControl* segmentedControl_;
  NSMutableArray* segmentURLs_;
  // NSMutableDictionary* requestedAdBanners_;
}

// This array holds the keys.
@property (retain,nonatomic) M3TableViewDataSource* dataSource;

-(void)addSegment:(NSString*)label withURL: (NSString*)url;
-(void)showSegmentedControl;

@end

@interface M3TableViewController(iAdSupport)

-(void)releaseRequestedBannerViews;
-(void)requestAdBannerAtIndexPath: (NSIndexPath*)indexPath;
-(UIView*)adBannerAtIndexPath: (NSIndexPath*)indexPath;

@end
