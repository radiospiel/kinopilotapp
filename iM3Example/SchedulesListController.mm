#import "SchedulesListController.h"
#import "AppDelegate.h"

@implementation SchedulesListController

-(NSString*)title
{
  return nil;
}

-(NSDictionary*)theater
{
  return [app.chairDB.theaters get: self.theater_id];
}

-(NSString*)theater_id
{
  return [self.url.to_url.params objectForKey: @"theater_id"];
}

-(NSDictionary*)movie
{
  return [app.chairDB.movies get: self.movie_id];
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

-(void)loadFromUrl:(NSString *)url
{
  self.dataSource = [M3DataSource schedulesByTheater:self.theater_id 
                                            andMovie: self.movie_id]; 
  self.tableView.tableHeaderView = [self headerView];
}

@end

@interface ScheduleListCell: M3TableViewCell
@end

@implementation ScheduleListCell

-(id)init
{ 
  self = [super initWithStyle: UITableViewCellStyleValue1]; 
  self.textLabel.font = [UIFont boldSystemFontOfSize:14];
  
  return self;
}

+(CGFloat)fixedHeight
{
  return 25;
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

  self.url = _.join(@"/schedules/show?schedule_id=", [schedule objectForKey: @"_uid"]);
}

@end


@implementation SchedulesShowController

-(NSString*)schedule_id
{
  return [self.url.to_url param: @"schedule_id"];
}

-(NSString*)title
{
  return nil;
}

-(NSDictionary*)schedule
{
  return [app.chairDB.schedules get: self.schedule_id];
}

-(UIView*) headerView
{
  // ---- get objects ----------------------------------------------------
  
  NSDictionary* schedule = self.schedule;

  NSString* theater_id = [self.schedule objectForKey:@"theater_id"];
  NSDictionary* theater = [app.chairDB.theaters get: theater_id];

  NSString* movie_id = [self.schedule objectForKey:@"movie_id"];
  NSDictionary* movie = [app.chairDB.movies get: movie_id];

  // ---- create header view --------------------------------------------
  
  M3ProfileView* pv = [[[M3ProfileView alloc]init]autorelease];
  
  // -- set descriptions
  
  {
    NSMutableString* html = [NSMutableString string];
    
    NSString* name = [theater objectForKey:@"name"];
    NSString* title = [movie objectForKey:@"title"];
    
    [html appendFormat:@"<h2><b>%@</b>, im <b>%@</b></h2>", title.cdata, name.cdata];
    
    NSString* address = [theater objectForKey:@"address"];
    if(address)
      [html appendFormat: @"<p>%@</p>", address.cdata]; 

    NSNumber* time = [schedule objectForKey:@"time"];
    if(time)
      [html appendFormat: @"<p>%@</p>", time.inspect.cdata]; 

    
    [pv setHtmlDescription:html];
  }

  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

-(void)loadFromUrl:(NSString *)url
{
  self.dataSource = nil;
  
  // if(!url)
  //   self.dataSource = nil;
  // else if([self.url matches: @"/movies/list\\?theater_id=(.*)"])
  //   self.dataSource = [M3DataSource moviesListFilteredByTheater:$1]; 
  // else if([self.url matches: @"/movies/list\\?filter=(.*)"])
  //   self.dataSource = [M3DataSource moviesListWithFilter: $1];
  // else
  //   self.dataSource = [M3DataSource moviesListWithFilter: @"new"];
  
  self.tableView.tableHeaderView = [self headerView];
}

@end

