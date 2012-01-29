//
//  MoviesFullController.h
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M3TableViewController.h"

@interface MoviesShowController : M3TableViewController {
  NSDictionary* movie_;
}

@property (nonatomic,retain) NSDictionary* movie;

@end
