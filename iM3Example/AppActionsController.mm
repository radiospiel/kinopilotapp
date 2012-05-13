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
  
  if(FACEBOOK)
    [self addAction:@"Facebook"   withURL: @"/app/share/facebook"];

  [self addAction:@"Email"    withURL: @"/app/share/email"];
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
  [app sendTweet: @"Mit der Kinopilot-App hab ich jetzt die Berliner Kinotermine immer auf meinem iPhone dabei! http://bit.ly/wJNpfb"
         withURL: nil
        andImage: nil];
}

-(void)shareViaFacebook
{
  [app sendToFacebook: @"Mit der Kinopilot-App hab ich jetzt die Berliner Kinotermine immer auf meinem iPhone dabei!"
            withTitle: @"Kinopilot.app"
          andImageURL: @"http://kinopilotupdates2.heroku.com/images/icon_72px.png"
               andURL: @"http://kinopilotapp.de"
  ];
}
@end
