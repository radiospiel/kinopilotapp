#import "M3AppDelegate.h"

@implementation M3AppDelegate(Alert)

-(void)alert: (NSString*)msg;
{
  UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: nil
                                message: msg
                               delegate: nil
                      cancelButtonTitle: @"Schließen"
                      otherButtonTitles: nil];

  [alert show];
  [alert release];
}
@end

