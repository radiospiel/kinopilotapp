//
//  MovieController.h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3ViewController.h"

@interface ProfileController : M3ViewController {
  IBOutlet UIView* imageView;
  IBOutlet UILabel* headline;
  IBOutlet UILabel* description;
  IBOutlet UIButton* action0;
  IBOutlet UIButton* action1;

  IBOutlet UIView* body;
  
  BOOL isHorizontal_;
  NSDictionary* data_;
}

@property (retain,nonatomic) NSDictionary* data;
@property (assign,nonatomic) BOOL isHorizontal;

@end
