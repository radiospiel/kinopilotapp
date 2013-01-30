#import "AppBase.h"

/*** The datasource for SchedulesList *******************************************/

@interface SchedulesListDataSource: M3TableViewDataSource
@end

@implementation SchedulesListDataSource

-(id)initWithTheaterId: (id)theater_id 
              andMovie: (id)movie_id
                 onDay: (NSDate*)day
{
  self = [super initWithCellClass: @"ScheduleListCell"];
  
  M3AssertKindOf(day, NSDate);
  if(!day) day = [NSDate today];
  
  //
  // get all schedules for the theater and for the movie, and 
  // remove all schedules, that are in the past.
  NSArray* schedules = [
    app.sqliteDB all: @"SELECT * FROM schedules WHERE theater_id=? AND movie_id=? AND time > ? ORDER BY time", 
    theater_id, 
    movie_id,
    day
  ];
  
  // group schedules by *day* into sectionsHash
  NSMutableDictionary* sectionsHash = [schedules groupUsingBlock:^id(NSDictionary* schedule) {
    NSNumber* time = [schedule objectForKey:@"time"];
    
    time = [NSNumber numberWithInt: time.to_i - 6 * 2400];
    return [time.to_date stringWithFormat:@"dd.MM."];
  }];
  
  NSArray* sectionsArray = [sectionsHash allValues];
  sectionsArray = [sectionsArray sortedArrayUsingComparator:^NSComparisonResult(NSArray* schedules1, NSArray* schedules2) {
    NSNumber* time1 = [schedules1.first objectForKey:@"time"];
    NSNumber* time2 = [schedules2.first objectForKey:@"time"];
    
    return [time1 compare:time2];
  }];
  
  for(NSArray* schedules in sectionsArray) {
    M3AssertKindOf(schedules, NSArray);
    NSNumber* time = [schedules.first objectForKey:@"time"];
    [self addSection: schedules
         withOptions: _.hash(@"header", [time.to_date stringWithFormat:@"ccc dd. MMM"])];
  }

  // [self addCellOfClass: @"MovieTrailerCell" withKey: movie_id];
  
  return self;
}

@end

/*** The datasource for ScheduleListCell *******************************************/

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
  
  self.url = _.join(@"/schedules/actions?schedule_id=", [schedule objectForKey: @"_id"]);
}

@end

/*** The SchedulesListController *******************************************/

@interface SchedulesListController: M3ListViewController

@end

@implementation SchedulesListController

// returns YES if the header view contains movie information

-(BOOL)movieMode
{
  NSString* important = [self.url.to_url param: @"important"];
  return [important isEqualToString: @"movie"];
}

-(NSString*)title
{
  if([self movieMode]) {
    id theater_id = [self.url.to_url.params objectForKey: @"theater_id"];
    NSDictionary* theater = [app.sqliteDB.theaters get: theater_id];
    
    return [theater objectForKey:@"name"];
  }
  else {
    id movie_id = [self.url.to_url.params objectForKey: @"movie_id"];
    NSDictionary* movie = [app.sqliteDB.movies get: movie_id];

    return [movie objectForKey:@"title"];
  }
}

-(void)reloadURL
{
  [self setRightButtonReloadAction];

  id theater_id = [self.url.to_url.params objectForKey: @"theater_id"];
  NSDictionary* theater = [app.sqliteDB.theaters get: theater_id];
  theater_id =  [theater objectForKey:@"_id"];

  id movie_id = [self.url.to_url.params objectForKey: @"movie_id"];
  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  movie_id =    [movie objectForKey:@"_id"];
  
  
  NSString* day = [self.url.to_url.params objectForKey: @"day"];

  M3TableViewDataSource* ds;
  ds = [[SchedulesListDataSource alloc]initWithTheaterId: theater_id 
                                                andMovie: movie_id
                                                   onDay: day.to_number.to_date];

  [ds addFallbackSectionIfNeeded];
  
  if([self movieMode]) {
    [ds prependCellOfClass: @"MovieShortActionsCell" withKey: movie_id];
  }
  else {
    self.tableView.tableHeaderView = [M3ProfileView profileViewForTheater: theater];
  }

  self.dataSource = [ds autorelease];
}

@end
