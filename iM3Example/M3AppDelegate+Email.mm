//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MailComposeDelegate: NSObject<MFMailComposeViewControllerDelegate>
@end

@implementation MailComposeDelegate

+(MailComposeDelegate*) sharedMailComposeDelegate
{
  static MailComposeDelegate* mcd = nil;
  if(!mcd) {
    mcd = [[MailComposeDelegate alloc]init];
  }
  
  return mcd;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
  [app.window.rootViewController dismissModalViewControllerAnimated:NO];

  switch(result) {
    case MFMailComposeResultCancelled: 
      // The user cancelled the operation. No email message was queued.
      break;
  
    case MFMailComposeResultSaved:
      // The email message was saved in the user’s Drafts folder.
      [app alertMessage: @"Deine Email wurde im Entwurfordner gesichert."];
      break;

    case MFMailComposeResultSent:   
      // The email message was queued in the user’s outbox. It is ready to 
      // send the next time the user connects to email.
      [app alertMessage: @"Deine Email wird demnächst versendet."];
      break;

    case MFMailComposeResultFailed: 
      // The email message was not saved or queued, possibly due to an error.
      [app alertMessage: @"Deine Email konnte nicht versendet werden."];
      break;
  }
}

@end

@implementation M3AppDelegate(Email)

-(void)doComposeEmailWithSubject: (NSString*)subject
                         andBody: (NSString*)body
{
  // -- compose HTML message.
  MFMailComposeViewController* mc = nil;
  if([MFMailComposeViewController canSendMail])
    mc = [[MFMailComposeViewController alloc] init];

  if(!mc) {
    [app alertMessage: @"kinopilot kann auf Deinem Gerät keine Emails versenden. Ist Dein Email-Account korrekt eingerichtet?"];
    return;  
  }

  mc.mailComposeDelegate = [MailComposeDelegate sharedMailComposeDelegate];

  [mc setSubject: subject];
  [mc setMessageBody: body
              isHTML: YES];
   
  // -- show message composer.
  
  [app.window.rootViewController presentModalViewController:mc animated:YES];
}

-(void)composeEmailWithSubject: (NSString*)subject
                       andBody: (NSString*)body
{
  [app oneTimeHint: @"Mit Kinopilot kannst Du Emails über Deine Email-Anwendung versenden. "
                     "Oft schlagen wir Dir einen Text für Deine Email vor - "
                     "aber natürlich kannst Du diesen noch nach Belieben verändern."
           withKey: @"email"
     beforeCalling:^{ [self doComposeEmailWithSubject: subject andBody: body]; }
   ];
}

-(void)composeEmailWithTemplateFile: (NSString*)path 
                          andValues: (NSDictionary*)values
{
  NSString* email = [M3 interpolateFile: path
                             withValues: values]; 
  
  
  NSArray* parts = [email componentsSeparatedByString: @"\n---\n"];
  
  [app composeEmailWithSubject: parts.first
                       andBody: parts.second];  
}

@end
