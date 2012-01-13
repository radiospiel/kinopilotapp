#import "ShareController.h"

#import <EventKit/EventKit.h> // EKEventStore, for calendar access 

@implementation ShareController

-(void)perform
{
  if([self.url containsString: @"/email"])
    [self shareViaEmail];
  else if([self.url containsString: @"/twitter"])
    [self shareViaTwitter];
  else if([self.url containsString: @"/facebook"])
    [self shareViaFacebook];
  else if([self.url containsString: @"/calendar"])
    [self shareViaCalendar];
}

// --- Helper methods

-(BOOL)addCalendarEvent: (NSString*)title
           withLocation: (NSString*)location
           andStartDate: (NSDate*)startDate
            andDuration: (NSTimeInterval)duration
{
  EKEventStore *eventDB = [[[EKEventStore alloc] init]autorelease];
  EKEvent *event  = [EKEvent eventWithEventStore:eventDB];
  
  event.title     = title;
  event.location  = location;
  event.startDate = startDate;
  event.endDate   = [startDate dateByAddingTimeInterval: duration];
  
  [event setCalendar:[eventDB defaultCalendarForNewEvents]];
  
  NSError *err;
  [eventDB saveEvent:event span:EKSpanThisEvent error:&err]; 
  
  return err != nil;
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

-(void)shareViaFacebook
{
  dlog << "Missing implementation: shareViaFacebook";
}

-(void)shareViaCalendar
{
  dlog << "Missing implementation: shareViaCalendar";
}

@end
