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
#import "M3Router.h"

@class AppDelegate;
extern AppDelegate* app;

@interface NSString (IM3ExampleExtensions)

/*
 * The versionString contains strings like "omu" etc. This
 * normalizes the version string into proper spelling.
 */
-(NSString*) withVersionString: (NSString*)versionString;

@end

/*
 * The AppDelegate class and the global app object.
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIProgressView* progressView;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (retain, nonatomic,readonly) NSDictionary *config;

/*
 * returns the configuration. It is read from "app.json".
 */
-(NSDictionary*) config;

/*
 * returns TRUE if the current device is an iPhone (as opposed to an iPad).
 */
-(BOOL) isIPhone;

/*
 * can this URL be opened?
 */
-(BOOL)canOpen: (NSString*)url;

/*
 * open this URL.
 */
-(void)open: (NSString*)url;

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

#import "M3Router.h"

@interface AppDelegate(M3Router)

@property (nonatomic,retain,readonly) M3Router* router;

-(M3Router*) router;

@end
