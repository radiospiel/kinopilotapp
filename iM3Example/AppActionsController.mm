//
//  AppShareController.m
//  M3
//
//  Created by Enrico Thierbach on 13.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "M3ActionSheetController.h"

@interface AppActionsController : M3ActionSheetController
@end

@implementation AppActionsController

-(void)setUrl: (NSString*)urlString
{
  [self addAction:@"Twitter"    withURL: @"/app/share/twitter"];
  // [self addAction:@"Twitter"  withURL: _.join(@"/share/schedule/twitter?schedule_id=", schedule_id)];
  // [self addAction:@"Facebook" withURL: _.join(@"/share/schedule/facebook?schedule_id=", schedule_id)];
  [self addAction:@"Email"    withURL: @"/app/share/email"];
  // [self addAction:@"Kalender" withURL: _.join(@"/application/share/calendar?schedule_id=", schedule_id)];
}
@end


#import "ShareController.h"

@interface AppShareController: ShareController
@end

@implementation AppShareController

-(void)shareViaEmail
{
  [ app composeEmailWithTemplateFile: @"$app/share_app_email.html"
                           andValues: [NSDictionary dictionary] 
   ];
}

-(void)shareViaTwitter
{
  [app sendTweet: @"Welcome from kinopilot! #kinopilot"
         withURL: nil 
        andImage: nil];
}
@end
