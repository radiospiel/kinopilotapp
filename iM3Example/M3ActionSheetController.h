#import <UIKit/UIKit.h>

@interface M3ActionSheetController: UIViewController <UIActionSheetDelegate> {
  NSMutableArray* actions_;
}

@property (nonatomic,retain) NSMutableArray* actions;

-(void)addAction: (NSString*)label withURL: (NSString*)url;
-(UIActionSheet*) actionSheet;

-(void)openAction:(NSString*)label;

@end
