//
//  MovieController.h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

@interface M3ProfileController : UIViewController {
  IBOutlet UIImageView* imageView;
  IBOutlet UILabel* headline;
  IBOutlet UILabel* description;
  IBOutlet UIButton* action0;
  IBOutlet UIButton* action1;

  IBOutlet UIView* bodyView;
  IBOutlet UILabel* subHeader;
  
  UIViewController* bodyController_;
}

@property (nonatomic,retain,readonly) UIView* bodyView;
@property (nonatomic,retain,readonly) UIImageView* imageView;
@property (nonatomic,retain,readonly) UILabel* description;

-(void)setBodyController: (UIViewController*)controller withTitle: (NSString*)title;

@end
