//
//  AppDelegate.h
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M3.h"
#import "UIViewController+M3Extensions.h"
#import "UIView+M3Stylesheets.h"

#import "Chair.h"
#import "ChairDatabase+IM3Example.h"
#import "M3TableViewDataSource.h"
#import "M3TableViewProfileCell.h"
#import "M3DataSource.h"
#import "M3ProfileView.h"

@interface NSString (IM3ExampleExtensions)

/*
 * The versionString contains strings like "omu" etc. This
 * normalizes the version string into proper spelling.
 */
-(NSString*) withVersionString: (NSString*)versionString;

@end

@class ChairDatabase;

@interface M3AppDelegate(ChairDB)

/*
 * Initialize Chair DB.
 */
-(void) initChairDB;

@property (retain,nonatomic,readonly) ChairDatabase* chairDB;

@end


@interface M3AppDelegate(Info)

-(NSString*) infoForKey: (NSString*)key;

@end

