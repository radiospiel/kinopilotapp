#import "AppDelegate.h"
#import "SchedulesShowController.h"

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

  // [self addAction:@"Twitter"  withURL: _.join(@"/share/twitter?schedule_id=", schedule_id)];
  // [self addAction:@"Facebook" withURL: _.join(@"/share/facebook?schedule_id=", schedule_id)];
  [self addAction:@"Email"    withURL: _.join(@"/share/email?schedule_id=", schedule_id)];
  [self addAction:@"Kalender" withURL: _.join(@"/share/calendar?schedule_id=", schedule_id)];
}
@end
