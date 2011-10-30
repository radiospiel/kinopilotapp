#import "AppDelegate.h"
#import "SchedulesShowController.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@implementation SchedulesShowController

-(void)setUrl: (NSString*)urlString
{
  [super setUrl: urlString];
  
  NSURL* url = urlString.to_url;
  
  NSString* schedule_id = [url param: @"schedule_id"];
  
  NSDictionary* schedule = [app.chairDB.schedules get: schedule_id];
  NSDictionary* theater = [app.chairDB.theaters get: [schedule objectForKey: @"theater_id"]];
  NSNumber* time = [schedule objectForKey: @"time"];
  self.title = [ NSString stringWithFormat: @"%@, im %@", 
                  [time.to_date stringWithFormat: @"dd. MMM HH:mm"],
                  [theater objectForKey: @"name"]
                ];

  [self addAction:@"Twitter"  withURL: _.join(@"/share/twitter?schedule_id=", schedule_id)];
  [self addAction:@"Facebook" withURL: _.join(@"/share/facebook?schedule_id=", schedule_id)];
  [self addAction:@"Email"    withURL: _.join(@"/share/email?schedule_id=", schedule_id)];
  [self addAction:@"Kalender" withURL: _.join(@"/share/calendar?schedule_id=", schedule_id)];
}

-(void)sendEmail
{
  NSString* schedule_id = [self.url.to_url param: @"schedule_id"];
  NSDictionary* schedule = [app.chairDB.schedules get: schedule_id];

  NSNumber* time = [schedule objectForKey: @"time"];
  NSDictionary* movie = [app.chairDB.movies get: [schedule objectForKey:@"movie_id"]];
  NSDictionary* theater = [app.chairDB.theaters get: [schedule objectForKey:@"theater_id"]];
  
  NSArray* latlong = [theater objectForKey:@"latlong"];

  NSDictionary* context = _.hash(
                              @"movie", movie,
                              @"theater", theater,
                              @"nice_time",   [time.to_date stringWithFormat: @"dd. MMM HH:mm"],
                              @"coordinates",   [latlong componentsJoinedByString: @","]
                              );  
  
  // -- compose HTML message.

  MFMailComposeViewController* mailCo = [[[MFMailComposeViewController alloc] init] autorelease];
  
  [mailCo setSubject: [@"{{nice_time}}: {{movie.title}} im {{theater.name}}" interpolate: context]];

  NSString* tmpl = [M3 read: @"$app/invitation_mail.html"];
  
  [mailCo setMessageBody: [tmpl interpolate: context] isHTML:YES]; 
  
  // -- show message composer.
  
  [app.window.rootViewController presentModalViewController:mailCo animated:YES];
}

-(void)openAction:(NSString*)label
{
  if([label isEqualToString:@"Email"]) {
    [self sendEmail];
    return;
  }
  
  [super openAction:label];
}

@end
