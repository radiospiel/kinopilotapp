//
//  AppDelegate.h
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M3.h"
#import "UIViewController+Model.h"
#import "Chair.h"
#import "ChairDatabase+IM3Example.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIProgressView* progressView;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

-(BOOL) isIPhone;

@end


@interface AppDelegate(Nib)

-(id)loadInstanceOfClass: (Class)klass fromNib: (NSString*) nibName;

@end

@class ChairDatabase;

@interface AppDelegate(ChairDB)

/*
 * Initialize Couchbase instance.
 */
-(void) initChairDB;

@property (retain,nonatomic,readonly) ChairDatabase* chairDB;

@end
