#import "M3ActionSheetController.h"
#import "AppDelegate.h"

@implementation M3ActionSheetController

@synthesize actions = actions_;

-(id)init
{
  self = [super init];
  self.actions = [NSMutableArray array];
  return self;
}

-(void)dealloc
{
  self.actions = nil;
  [super dealloc];
}

-(void)addAction: (NSString*)label withURL: (NSString*)url
{
  [self.actions addObject: _.array(label, url)];
}

-(UIActionSheet*) actionSheet
{
  UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle: self.title 
                                                    delegate: self
                                           cancelButtonTitle: nil
                                      destructiveButtonTitle: nil
                                           otherButtonTitles: nil];

  sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;

  for(NSArray* action in self.actions) {
    [sheet addButtonWithTitle:action.first];
  }

  [sheet addButtonWithTitle:@"Abbruch"];

  sheet.cancelButtonIndex = self.actions.count;
  // sheet.destructiveButtonIndex = self.actions.count;

  return [sheet autorelease];
}

-(void)perform
{
  UINavigationController* nc = [app topMostController];
  
  [self retain];
  [[self actionSheet] showInView:nc.view];
}

-(void)openAction:(NSString*)label
{
  NSArray* action = [self.actions detectUsingBlock:^BOOL(NSArray* obj) {
    return [label isEqualToString:obj.first];
  }];
  
  [app open: action.second];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  [self openAction: [actionSheet buttonTitleAtIndex:buttonIndex]];
}

@end