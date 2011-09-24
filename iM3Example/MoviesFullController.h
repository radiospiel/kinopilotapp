//
//  MoviesFullController.h
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesFullController : UIViewController {
  IBOutlet UILabel* titleLabel;
  IBOutlet UIImageView* imageView;
  IBOutlet UIWebView* detailWebView;
  IBOutlet UIWebView* bodyWebView;
}

@end
