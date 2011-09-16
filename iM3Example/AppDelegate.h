//
//  AppDelegate.h
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIProgressView* progressView;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

-(BOOL) isIPhone;

@end


@interface AppDelegate(Nib)

-(id)loadInstanceOfClass: (Class)klass fromNib: (NSString*) nibName;

@end