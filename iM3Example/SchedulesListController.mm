#import "M3ListViewController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"

/*
 
 ## Schedules List
 
 - **`/schedules/list?theater_id=<theater_id>&movie_id=<movie_id>`** show a list 
 of play times for a given theater and movie combination. The header 
 cell contains a description a la "&lt;movie title&gt; in &lt;theater name&gt;".
 Below is a list of schedules, grouped by day. Clicking on a schedule opens a
 schedule (modal) view, which allows to share the schedule, 
 under *`/schedules/show?schedule_id=<schedule_id>`*
 
 */
@interface SchedulesListController: M3ListViewController

@property (readonly) NSString* theater_id;
@property (readonly) NSDictionary* theater;

@property (readonly) NSString* movie_id;
@property (readonly) NSDictionary* movie;

@end

@implementation SchedulesListController

-(NSString*)title
{ 
  return nil; 
}

-(NSString*)theater_id
{
  return [self.url.to_url.params objectForKey: @"theater_id"];
}

-(NSDictionary*)theater
{
  return [app.sqliteDB.theaters get: self.theater_id];
}

-(NSDate*)day
{
  NSString* dayString = [self.url.to_url.params objectForKey: @"day"];
  return dayString.to_number.to_date;
}

-(NSDictionary*)movie
{
  return [app.sqliteDB.movies get: self.movie_id];
}

-(NSString*)movie_id
{
  return [self.url.to_url.params objectForKey: @"movie_id"];
}

-(UIView*) headerView
{
  NSString* important = [self.url.to_url param: @"important"];
  return [important isEqualToString: @"movie"] ? 
    [M3ProfileView profileViewForMovie: self.movie] :
    [M3ProfileView profileViewForTheater: self.theater];
}

-(void)reloadURL
{
  [self setRightButtonReloadAction];
  
  self.dataSource = [M3DataSource schedulesByTheater:self.theater_id 
                                            andMovie: self.movie_id
                                               onDay: [self day]
                     ]; 
  self.tableView.tableHeaderView = [self headerView];
}

@end

@interface ScheduleListCell: M3TableViewCell
@end

@implementation ScheduleListCell

-(id)init
{ 
  self = [super initWithStyle: UITableViewCellStyleValue1]; 
  // self.textLabel.font = [UIFont boldSystemFontOfSize:14];
  
  return self;
}

+(CGFloat)fixedHeight
{
  return 44;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect frame = self.textLabel.frame;
  frame.origin.x = 7;
  self.textLabel.frame = frame;
}

-(void)setKey: (NSDictionary*)schedule
{
  [super setKey:schedule];

  NSNumber* time = [schedule objectForKey: @"time"];
  
  NSString* textLabel = [time.to_date stringWithFormat: @"dd. MMM HH:mm"];
  self.textLabel.text = [textLabel withVersionString: [schedule objectForKey:@"version"]];

  self.url = _.join(@"/schedules/show?schedule_id=", [schedule objectForKey: @"_id"]);
}

@end
