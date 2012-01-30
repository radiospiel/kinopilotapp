#if TARGET_OS_IPHONE 

#import <UIKit/UIKit.h>

#import "M3.h"
#ifdef __cplusplus
#import "Underscore.hh"
#endif

#import "UIViewController+M3Extensions.h"
#import "FBConnect.h"

// Show "Facebook" sharing?
#define FACEBOOK NO

@interface NSString (IM3ExampleExtensions)

/*
 * The versionString contains strings like "omu" etc. This
 * normalizes the version string into proper spelling, and 
 * appends it to the receiver.
 */
-(NSString*) withVersionString: (NSString*)versionString;

@end

@class M3AppDelegate;
extern M3AppDelegate* app;

/*
 * The AppDelegate class and the global app object.
 */
@interface M3AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, 
                                           UINavigationControllerDelegate, FBSessionDelegate, FBDialogDelegate>

@property (nonatomic, retain) Facebook *facebook;
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UITabBarController *tabBarController;

/*
 * returns the aplication configuration. It is read from the 
 * "app.json" resource file.
 */
@property (retain, nonatomic, readonly) NSDictionary *config;


-(UINavigationController*)topMostController;
-(void)presentControllerOnTop: (UIViewController*)viewController;

@end

@interface M3AppDelegate(ApplicationURL)

/*
 * can this URL be opened? This method returns NO, if the url is an 
 * internal URL, or if the URL is an external URL and the respective
 * application is installed.
 */
-(BOOL)canOpen: (NSString*)url;

/*
 * open the passed-in URL.
 */
-(void)open: (NSString*)url;
-(void)openFromModalView: (NSString*)url;

/*
 * returns an UIViewController for the passed-in URL.
 */
-(UIViewController*)controllerForURL: (NSString*)url;

@end

@interface M3AppDelegate(EventTracking)

-(void)trackEvent: (NSString*) event 
       properties: (NSDictionary*) parameters;

-(void)trackEvent: (NSString*) event;

@end

@interface M3AppDelegate(RemoteNotification)

-(void)enableRemoteNotifications;

@end

#import "GTMSqlite+M3Additions.h"

@interface M3SqliteDatabase(M3Additions)

@property (nonatomic,retain,readonly) M3SqliteTable* movies;
@property (nonatomic,retain,readonly) M3SqliteTable* theaters;
@property (nonatomic,retain,readonly) M3SqliteTable* schedules;
@property (nonatomic,retain,readonly) M3SqliteTable* images;
@property (nonatomic,retain,readonly) M3SqliteTable* settings;
@property (nonatomic,retain,readonly) M3SqliteTable* flags;

-(void)migrate;

@end

@interface M3AppDelegate(SqliteDB)

@property (retain,nonatomic,readonly) M3SqliteDatabase* sqliteDB;

-(UIImage*) thumbnailForMovie: (NSDictionary*) movie;

-(BOOL)isFlagged: (NSString*) key;
-(void)setFlagged: (BOOL)flag onKey: (NSString*)key;

-(void)updateDatabase;
-(void)updateDatabaseIfNeeded;

@end

@interface M3AppDelegate(Alert)

-(void)alertMessage: (NSString*)msg;
-(void)alertMessage: (NSString*)msg onDialogClose: (void(^)())onDialogClose;

-(void)oneTimeHint: (NSString*)msg
           withKey: (NSString*)key
     beforeCalling: (void(^)())callback;

@end

@interface M3AppDelegate(Email)

-(void)composeEmailWithSubject: (NSString*)subject
                       andBody: (NSString*)body;

-(void)composeEmailWithTemplateFile: (NSString*)path 
                          andValues: (NSDictionary*)values;

@end

@interface M3AppDelegate(Twitter)

-(void)sendTweet: (NSString*)tweet 
         withURL: (NSString*)url 
        andImage: (UIImage*)image;

@end

@interface M3AppDelegate(Facebook)

-(BOOL)isLoggedIntoFacebook;

-(void)sendToFacebook: (NSString*)message 
            withTitle: (NSString*)title 
          andImageURL: (NSString*)imageURL
               andURL: (NSString*)url;

@end

@interface M3AppDelegate(AppInfo)

@property (nonatomic,readonly) NSDictionary* infoDictionary;

@end

#endif
