#import "AppBase.h"

@interface UserVoiceController: NSObject
@property (retain,nonatomic) NSString* url;
@end

@implementation UserVoiceController

@synthesize url = _url;

-(void)perform
{
  [app oneTimeHint: @"Danke für Dein Feedback!\n\n"
                     "Wir benutzen das Feedbacksystem von UserVoice - "
                     "um nitzumachen, musst Du Dich dort eventuell registrieren." 
           withKey: @"user_voice_register" 
     beforeCalling: ^{
       [UserVoice presentUserVoiceModalViewControllerForParent: app.topMostController
                                                       andSite:@"http://kinopilot.uservoice.com/"
                                                        andKey:@"K3EoDPEyFEipbUX1daA"
                                                     andSecret:@"gHkvOHmPkqEA5z6OXi6h0aLQdQLvAd6h2PqMq1cUkVM"];
     }
  ];
}

-(NSString*)title
{
  return @"Feedback";
}
@end
