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

  NSMutableArray *pages_;
}

@property (nonatomic,retain) NSMutableArray *pages;

@end
