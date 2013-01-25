//
//  AppShareController.m
//  M3
//
//  Created by Enrico Thierbach on 13.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "AppBase.h"

@interface AppActionsController : M3ActionSheetController
@end

@implementation AppActionsController

-(void)setUrl: (NSString*)urlString
{
  [self addAction:@"Twitter"    withURL: @"/app/share/twitter"];
  [self addAction:@"Email"    withURL: @"/app/share/email"];
}
@end
