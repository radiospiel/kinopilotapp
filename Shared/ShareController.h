#import "AppBase.h"

@class EKEvent;

@interface ShareController: UIViewController

// --- Subclasses must override these methods (if needed)

-(void)shareViaEmail;
-(void)shareViaTwitter;
-(void)shareViaCalendar;

// --- Helper methods

-(void)addCalendarEvent: (NSString*)title
           withLocation: (NSString*)location
           andStartDate: (NSDate*)startDate
            andDuration: (NSTimeInterval)duration
            onCompletion: (void (^)(EKEvent* event))onCompletion;

-(NSString*)teaserForMovie: (NSDictionary*)movie;

@end
