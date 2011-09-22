//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesListController : UITableViewController {
  UISegmentedControl* segmentedControl_;
  NSMutableArray* segmentURLs_;
  IBOutlet UITableViewController* tableViewController_;
}

@end
