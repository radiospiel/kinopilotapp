#import "AppBase.h"
#import "ShareController.h"
#import <EventKit/EventKit.h> // EKEventStore, for calendar access 

@implementation ShareController

-(void)perform
{
  if([self.url containsString: @"/email"])
    [self shareViaEmail];
  else if([self.url containsString: @"/twitter"])
    [self shareViaTwitter];
  else if([self.url containsString: @"/calendar"])
    [self shareViaCalendar];
}

// --- Helper methods

-(void)grantCalendar: (void(^)(EKEventStore* eventStore))onCompletion
{
  EKEventStore *eventStore = [[[EKEventStore alloc] init]autorelease];
  
  if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
    // iOS 6 and later
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
      if(granted) {
        onCompletion(eventStore);
      }
      else
      {
        onCompletion(nil);
      }
    }];
  }
  else {
    onCompletion(eventStore);
  }
}

-(void)addCalendarEvent: (NSString*)title
           withLocation: (NSString*)location
           andStartDate: (NSDate*)startDate
            andDuration: (NSTimeInterval)duration
           onCompletion: (void (^)(EKEvent*))onCompletion;
{
  [self grantCalendar:^(EKEventStore *eventStore) {
    if(!eventStore) {
      onCompletion(nil);
      return;
    }

    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    
    event.title     = title;
    event.location  = location;
    event.startDate = startDate;
    event.endDate   = [startDate dateByAddingTimeInterval: duration];
    
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    NSError *err = nil;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    
    onCompletion(err ? nil : event);
  }];
}

// --- get a teaser string for a movie

#define TEASER_LENGTH 200

-(NSString*)teaserForMovie: (NSDictionary*)movie
{
  NSString* description = [movie objectForKey:@"description"];
  if(!description) return nil;
  
  NSArray* sentences = [description componentsSeparatedByString:@". "];
  sentences = [sentences mapUsingBlock:^id(NSString* sentence) {
    return [sentence stringByAppendingString:@"."];
  }];
  
  NSMutableString* teaser = [NSMutableString stringWithCapacity: TEASER_LENGTH + 100];
  
  for(NSString* sentence in sentences) {
    [teaser appendFormat:@" %@", sentence];
    if(teaser.length > TEASER_LENGTH) return teaser;
  }
  
  return description;
}

// --- Subclasses must override these methods (if needed)

-(void)shareViaEmail
{
  dlog << "Missing implementation: shareViaEmail";
}

-(void)shareViaTwitter
{
  dlog << "Missing implementation: shareViaTwitter";
}

-(void)shareViaCalendar
{
  dlog << "Missing implementation: shareViaCalendar";
}

@end
