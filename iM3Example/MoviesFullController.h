//
//  MoviesFullController.h
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M3TableViewController.h"

@interface MoviesFullController : M3TableViewController {
  BOOL receivedAds;
}

@property (assign,nonatomic) BOOL receivedAds;

@end
