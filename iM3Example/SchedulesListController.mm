#import "AppDelegate.h"
#import "SchedulesListController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"

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
  
  NSString* textLabel = [time.to_date stringWithFormat: @"dd. MMM HH:mm:00"];
  self.textLabel.text = [textLabel withVersionString: [schedule objectForKey:@"version"]];

  self.url = _.join(@"/schedules/show?schedule_id=", [schedule objectForKey: @"_id"]);
}

@end
