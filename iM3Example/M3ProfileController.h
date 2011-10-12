//
//  MovieController.h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "TTTAttributedLabel.h"

@interface M3ProfileController : UIViewController {
  IBOutlet UIImageView* imageView_;
  IBOutlet TTTAttributedLabel* descriptionView_;
  IBOutlet UIButton* actionButton0_;
  IBOutlet UIButton* actionButton1_;

  IBOutlet UIView* bodyView_;
  
  UIViewController* bodyController_;

  NSArray* actions_;
  NSString* htmlDescription_;
}

// @property (nonatomic,retain,readonly) UIView* bodyView;
@property (nonatomic,retain,readonly) UIImageView* imageView;
// @property (nonatomic,retain,readonly) TTTAttributedLabel* descriptionView;

@property (nonatomic,retain) NSArray* actions;
@property (nonatomic,retain) NSString* htmlDescription;

-(void)setBodyController: (UIViewController*)controller withTitle: (NSString*)title;

@end
