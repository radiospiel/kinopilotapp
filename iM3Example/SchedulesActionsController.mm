#import "M3ActionSheetController.h"

/*
 *
 * "...Clicking on a schedule opens a schedule (modal) view, which allows
 * to share the event, under `/schedules/show?schedule_id=<schedule_id>`...
 *
 */

@interface SchedulesActionsController : M3ActionSheetController
@end

@implementation SchedulesActionsController

-(void)setUrl: (NSString*)urlString
{
  [super setUrl: urlString];
  
  NSURL* url = urlString.to_url;
  
  NSString* schedule_id = [url param: @"schedule_id"];
  
  NSDictionary* schedule = [app.sqliteDB.schedules get: schedule_id];
  NSDictionary* theater = [app.sqliteDB.theaters get: [schedule objectForKey: @"theater_id"]];
  NSNumber* time = [schedule objectForKey: @"time"];
  self.title = [ NSString stringWithFormat: @"%@, im %@", 
                  [time.to_date stringWithFormat: @"dd. MMM HH:mm"],
                  [theater objectForKey: @"name"]
                ];

  [self addAction:@"Twitter"  withURL: _.join(@"/share/schedule/twitter?schedule_id=", schedule_id)];

  if(FACEBOOK)
    [self addAction:@"Facebook" withURL: _.join(@"/share/schedule/facebook?schedule_id=", schedule_id)];

  [self addAction:@"Email"    withURL: _.join(@"/share/schedule/email?schedule_id=", schedule_id)];
  [self addAction:@"Kalender" withURL: _.join(@"/share/schedule/calendar?schedule_id=", schedule_id)];
}
@end

