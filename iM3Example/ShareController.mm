#import "ShareController.h"

@interface ShareController(Email)
-(void)email;
@end

//@interface ShareController(Twitter)
//-(void)twitter;
//@end
//
//@interface ShareController(Facebook)
//-(void)facebook;
//@end

@interface ShareController(Calendar)
-(void)calendar;
@end

@implementation ShareController

@synthesize movie = movie_, theater = theater_, schedule = schedule_;

-(void)setUrl:(NSString*)url
{
  [super setUrl:url];
  
  NSDictionary* params = url.to_url.params;

  self.schedule = [app.sqliteDB.schedules get: [params objectForKey: @"schedule_id"]];
  self.theater = [app.sqliteDB.theaters get: [self.schedule objectForKey:@"theater_id"]];
  self.movie = [app.sqliteDB.movies get: [self.schedule objectForKey:@"movie_id"]];
}

-(void)dealloc
{
  self.movie = self.theater = self.schedule = nil;
  [super dealloc];
}


+(NSString*)teaserForDescription: (NSString*) description 
                        ofLength: (int)minLength
{
  
  NSArray* sentences = [description componentsSeparatedByString:@". "];
  sentences = [sentences mapUsingBlock:^id(NSString* sentence) {
    return [sentence stringByAppendingString:@"."];
  }];
  
  NSMutableString* teaser = [NSMutableString stringWithCapacity: 300];
  
  for(NSString* sentence in sentences) {
    [teaser appendFormat:@" %@", sentence];
    if(teaser.length > minLength) return teaser;
  }
  
  return description;
}

-(NSString*)teaser
{
  NSString* description = [self.movie objectForKey:@"description"];
  if(!description) return nil;
  return [ShareController teaserForDescription:description ofLength:200];
}

-(NSString*)teaserAsHtml
{
  NSString* description = [self.movie objectForKey:@"description"];
  if(!description) return nil;
  NSString* teaser = [ShareController teaserForDescription:description ofLength:200];
  NSString* url = [self.movie objectForKey:@"url"];
  
  if(!url || teaser.length > description.length - 15) 
    return teaser.htmlEscape;
  
  return [teaser.htmlEscape stringByAppendingFormat:@"... <a href='%@'>Mehr auf moviepilot.de</a>", url];
}

-(NSDictionary*)interpolationContext
{
  NSNumber* time = [self.schedule objectForKey: @"time"];

  return [NSDictionary dictionaryWithObjectsAndKeys:
            self.movie,                                         @"movie",       
            self.theater,                                       @"theater",     
            [time.to_date stringWithFormat: @"dd. MMM HH:mm"],  @"nice_time",   
            [self teaserAsHtml],                                @"htmlTeaser",      
            nil 
          ];
}

-(void)perform
{
  if([self.url hasPrefix:@"/share/email"])
    [self email];
//  else if([self.url hasPrefix:@"/share/twitter"])
//    [self twitter];
//  else if([self.url hasPrefix:@"/share/facebook"])
//    [self facebook];
  else if([self.url hasPrefix:@"/share/calendar"])
    [self calendar];
}

@end

@implementation ShareController(Email)

-(void)email
{
  NSDictionary* context = [self interpolationContext];

  NSString* subject = [M3 interpolateString: @"{{nice_time}}: {{movie.title}} im {{theater.name}}"
                                 withValues: context];
  NSString* body = [M3 interpolateFile: @"$app/invitation_mail.html"
                            withValues: context]; 

  [app composeEmailWithSubject: subject
                       andBody: body];  
}

@end
//
//
//@implementation ShareController(Twitter)
//
//-(void)twitter
//{
//  
//}
//
//@end
//
//@implementation ShareController(Facebook)
//
//-(void)facebook
//{
//  
//}
//
//@end

#import <EventKit/EventKit.h>

@implementation ShareController(Calendar)

-(void)calendar
{
  NSNumber* time = [self.schedule objectForKey: @"time"];
  NSNumber* runtime = [self.movie objectForKey: @"runtime"];
  NSTimeInterval runtimeInSecs = runtime ? runtime.to_i * 60 : 90 * 60;
  
  EKEventStore *eventDB = [[[EKEventStore alloc] init]autorelease];
  EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];

  myEvent.title     = [self.movie objectForKey:@"title"];
  myEvent.startDate = time.to_date;
  myEvent.endDate   = [myEvent.startDate dateByAddingTimeInterval: runtimeInSecs + 30 * 60];
  myEvent.location  = [self.theater objectForKey:@"name"];

  [myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];

  NSError *err;
  [eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err]; 

  if (!err) {
    [app alert: @"Die Aufführung wurde in Deinen Kalender eingetragen"];
  }
  else {
    [app alert: @"Die Aufführung konnte nicht in Deinen Kalender eingetragen werden."];
  }
}

@end
