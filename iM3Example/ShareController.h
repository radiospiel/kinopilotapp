#import "M3AppDelegate.h"

@interface ShareController: UIViewController

// --- Subclasses must override these methods (if needed)

-(void)shareViaEmail;
-(void)shareViaTwitter;
-(void)shareViaFacebook;
-(void)shareViaCalendar;

// --- Helper methods

-(BOOL)addCalendarEvent: (NSString*)title
           withLocation: (NSString*)location
           andStartDate: (NSDate*)startDate
            andDuration: (NSTimeInterval)duration;

-(NSString*)teaserForMovie: (NSDictionary*)movie;

@end
