#import "AppDelegate.h"

#import <MessageUI/MessageUI.h>

@interface ShareController: UIViewController<MFMailComposeViewControllerDelegate> {
  NSDictionary *movie_, *theater_, *schedule_;
}

@property (nonatomic,retain) NSDictionary* movie;
@property (nonatomic,retain) NSDictionary* theater;
@property (nonatomic,retain) NSDictionary* schedule;

@end
