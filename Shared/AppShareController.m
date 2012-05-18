#import "ShareController.h"

@interface AppShareController: ShareController
@end

@implementation AppShareController

-(void)shareViaEmail
{
  [ app composeEmailWithTemplateFile: @"$config/share_app_email.html"
                           andValues: [NSDictionary dictionary] 
   ];
}

-(void)shareViaTwitter
{
  [app sendTweet: [app.config objectForKey:@"app_tweet"]
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