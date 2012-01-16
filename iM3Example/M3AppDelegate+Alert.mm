#import "M3AppDelegate.h"

typedef void (^VoidCallback)();


@implementation M3AppDelegate(RunLater)

-(void)runLater: (void(^)())callback;
{
  if(!callback) return;
  dispatch_async(dispatch_get_main_queue(), callback);
}

@end

@interface M3AlertView: UIAlertView

@property (retain, nonatomic) NSMutableDictionary* callbacks;

@end

@implementation M3AlertView

@synthesize callbacks;

-(void)setCallback: (VoidCallback)callback
           atIndex: (NSInteger) index
{
  NSNumber* key = [NSNumber numberWithInt:index];
  
  if(callback && !self.callbacks)
    self.callbacks = [NSMutableDictionary dictionary];
  
  if(callback) {
    self.delegate = self;
  
    callback = [[callback copy] autorelease];
    [self.callbacks setObject:callback forKey:key];
  }
  else
    [self.callbacks removeObjectForKey:key];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  VoidCallback callback = [self.callbacks objectForKey: [NSNumber numberWithInt:buttonIndex]];
  [app runLater: callback];
}

@end

@implementation M3AppDelegate(Alert)

-(void)alertMessage: (NSString*)msg
    withButtonTitle: (NSString*)buttonTitle
      onDialogClose: (void(^)())onDialogClose;
{
  if(!buttonTitle) buttonTitle = @"Schließen";

  M3AlertView *alertView = [[M3AlertView alloc] initWithTitle: nil
                                                      message: msg
                                                     delegate: nil
                                            cancelButtonTitle: buttonTitle
                                            otherButtonTitles: nil];

  [alertView setCallback: onDialogClose atIndex: 0];
  
  [alertView show];
  [alertView release];
}

-(void)alertMessage: (NSString*)msg 
      onDialogClose: (void(^)())onDialogClose;
{
  [ self  alertMessage: msg 
       withButtonTitle: nil
         onDialogClose: onDialogClose
  ];
}

-(void)alertMessage: (NSString*)msg;
{
  [self alertMessage: msg 
     withButtonTitle: nil
       onDialogClose: nil];
}

-(void)oneTimeHint: (NSString*)msg
           withKey: (NSString*)key
     beforeCalling: (void(^)())callback
{
  key = [@"hint_" stringByAppendingString: (key ? key : msg)];

  // The message has been shown already? 
  if([app.sqliteDB.settings objectForKey: key]) {
    [app runLater: callback];
    return;
  }
  
 [app.sqliteDB.settings setObject: [NSDate now].to_number 
                           forKey: key];

  [self alertMessage: msg 
     withButtonTitle: @"Weiter"
       onDialogClose: callback];
}

@end
