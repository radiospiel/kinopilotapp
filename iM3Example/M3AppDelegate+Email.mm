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
      [app alert: @"Deine Email wurde im Entwurfordner gesichert."];
      break;

    case MFMailComposeResultSent:   
      // The email message was queued in the user’s outbox. It is ready to 
      // send the next time the user connects to email.
      [app alert: @"Deine Email wird demnächst versendet."];
      break;

    case MFMailComposeResultFailed: 
      // The email message was not saved or queued, possibly due to an error.
      [app alert: @"Deine Email konnte nicht versendet werden."];
      break;
  }
}

@end

@implementation M3AppDelegate(Email)

-(void)composeEmailWithSubject: (NSString*)subject
                       andBody: (NSString*)body
{
  // -- compose HTML message.
  
  MFMailComposeViewController* mc = nil;
  if([MFMailComposeViewController canSendMail])
    mc = [[MFMailComposeViewController alloc] init];

  if(!mc) {
    [app alert: @"kinopilot kann auf Deinem Gerät keine Emails versenden. Ist Dein Email-Account korrekt eingerichtet?"];
    return;  
  }

  mc.mailComposeDelegate = [MailComposeDelegate sharedMailComposeDelegate];

  NSLog(@"%@", body);
  
  [mc setSubject: subject];
  [mc setMessageBody: body
              isHTML: YES];
   
  // -- show message composer.
  
  [app.window.rootViewController presentModalViewController:mc animated:YES];
}

@end
