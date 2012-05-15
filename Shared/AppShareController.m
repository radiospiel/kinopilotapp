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
