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

  self.schedule = [app.chairDB.schedules get: [params objectForKey: @"schedule_id"]];
  self.theater = [app.chairDB.theaters get: [self.schedule objectForKey:@"theater_id"]];
  self.movie = [app.chairDB.movies get: [self.schedule objectForKey:@"movie_id"]];
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
  if([self.url startsWith:@"/share/email"])
    [self email];
//  else if([self.url startsWith:@"/share/twitter"])
//    [self twitter];
//  else if([self.url startsWith:@"/share/facebook"])
//    [self facebook];
  else if([self.url startsWith:@"/share/calendar"])
    [self calendar];
}

@end

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@implementation ShareController(Email)

-(void)email
{
  dlog << "*** email";
  
  NSDictionary* context = [self interpolationContext];
  
  // -- compose HTML message.
  
  MFMailComposeViewController* mailCo = [[[MFMailComposeViewController alloc] init] autorelease];
  
  [mailCo setSubject: [M3 interpolateString: @"{{nice_time}}: {{movie.title}} im {{theater.name}}"
                                 withValues: context]];
  
  [mailCo setMessageBody: [M3 interpolateFile: @"$app/invitation_mail.html"
                                   withValues: context] 
                  isHTML: YES]; 
  
  // -- show message composer.
  
  [app.window.rootViewController presentModalViewController:mailCo animated:YES];
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
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: nil //, @"Die Aufführung wurde in Deinen Kalender aufgenommen"
      message:@"Die Aufführung wurde in Deinen Kalender eingetragen"
      delegate:nil
      cancelButtonTitle:@"Schließen"
      otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

@end
