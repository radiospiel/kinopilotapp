#import "SchedulesListController.h"
#import "AppDelegate.h"

@implementation SchedulesListController

-(NSDictionary*)parameters
{
  if([self.url matches: @"/schedules/list\\?theater_id=(.*)&movie_id=(.*)"]) 
    return _.hash(@"theater_id", $1, @"movie_id", $2);
  else if([self.url matches: @"/schedules/list\\?movie_id=(.*)&theater_id=(.*)"]) 
    return _.hash(@"movie_id", $1, @"theater_id", $2);
  
  return nil;
}

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
  return [[self parameters] objectForKey: @"theater_id"];
}

-(NSDictionary*)movie
{
  return [app.chairDB.movies get: self.movie_id];
}

-(NSString*)movie_id
{
  return [[self parameters] objectForKey: @"movie_id"];
}

-(UIView*) headerView
{
  NSDictionary* theater = self.theater;
  NSDictionary* movie = self.movie;
  
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
    
    [pv setHtmlDescription:html];
  }
  
  // -- set actions
  
  {
    NSMutableArray* actions = _.array();
    
    NSString* address = [theater objectForKey:@"address"];
    
    if(address)
      [actions addObject: _.array(@"Fahrinfo", _.join(@"fahrinfo-berlin://connection?to=", address.urlEscape))];
    
    NSString* fon = [theater objectForKey:@"telephone"];
    if(fon)
      [actions addObject: _.array(@"Fon", _.join(@"tel://", fon.urlEscape))];
    
    NSString* web = [theater objectForKey:@"website"];
    if(web)
      [actions addObject: _.array(@"Website", web)];
    
    [pv setActions: actions];
  }
  
  // -- add a map view
  
  {
    NSArray* latlong = [theater objectForKey:@"latlong"];
    [pv setCoordinate: CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue])];
  }  
  
  NSString* url = _.join(@"/map/show?theater_id=", [theater objectForKey:@"_uid" ]);
  
  [pv setProfileURL:url];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
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
  [self.url matches: @"/schedules/show\\?schedule_id=(.*)"];
  return $1;
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

