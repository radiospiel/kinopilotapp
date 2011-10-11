//
//  MovieImagesController.h
//  M3
//
//  Created by Enrico Thierbach on 02.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesImagesController : UIViewController<UIScrollViewDelegate> 
{   
  UIScrollView  *scrollView;
  UIPageControl *pageControl;
  UIButton      *closeButton;
  
  NSMutableArray *pageViews_;
  NSArray *imageUrls_;
  
  // To be used when scrolls originate from the UIPageControl
  BOOL pageControlUsed;
}

@property (nonatomic, retain) NSArray *imageUrls;
@property (nonatomic, retain) NSMutableArray *pageViews;

//- (IBAction)changePage:(id)sender;


@end
