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

@class AppDelegate;
extern AppDelegate* app;

@interface NSString (IM3ExampleExtensions)

-(NSString*) withVersionString: (NSString*)versionString;

@end

/*
 * The AppDelegate class and the global app object.
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIProgressView* progressView;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

-(BOOL) isIPhone;

-(BOOL)canOpen: (NSString*)url;
-(void)open: (NSString*)url;

-(NSDictionary*) config;
@property (retain, nonatomic,readonly) NSDictionary *config;

-(UIViewController*)viewControllerForURL: (NSString*)url;

@end

@class ChairDatabase;

@interface AppDelegate(ChairDB)

/*
 * Initialize Chair DB.
 */
-(void) initChairDB;

@property (retain,nonatomic,readonly) ChairDatabase* chairDB;

@end


@interface AppDelegate(Info)

-(NSString*) infoForKey: (NSString*)key;

@end
