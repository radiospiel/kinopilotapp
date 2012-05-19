#import "AppBase.h"

/*** Data sources for EventsListController ************************************/

@interface EventsDataSource: M3TableViewDataSource
@end

@implementation EventsDataSource

+(EventsDataSource*)dataSource
{
  EventsDataSource* ds = [[EventsDataSource alloc]initWithCellClass: @"EventsListCell"]; 
  
  NSArray* events = [ app.sqliteDB all: 
          @"SELECT events.*, locations.name AS location_name FROM events "
            "INNER JOIN locations ON events.location_id=locations._id "
            "WHERE starts_at > ? "
            "ORDER BY starts_at",
            [NSDate today]
          ];

  [ds addRecords: events];
  return [ds autorelease];
}

+(EventsDataSource*)dataSourceWithLocation: (NSDictionary*)location
{
  EventsDataSource* ds = [[EventsDataSource alloc]initWithCellClass: @"EventsByLocationListCell"]; 
  
  NSArray* events = [ app.sqliteDB all: 
          @"SELECT events.*, locations.name AS location_name FROM events "
            "INNER JOIN locations ON events.location_id=locations._id "
            "WHERE location_id=? AND starts_at > ? "
            "ORDER BY starts_at",
            [location objectForKey:@"_id"],
            [NSDate today]
          ];
  
  [ds addRecords: events];
  return [ds autorelease];
}

-(id)groupKeyForRecord:(NSDictionary *)event
{
  NSNumber* starts_at = [event objectForKey:@"starts_at"];
  return starts_at.to_day;
}

-(NSString*)groupLabelForKey:(NSDate*)day
{
  return [day stringWithFormat: @"dd. MMM"];
}

@end


/*** Cells for EventsLists ****************************************************/

@interface EventsListCell: M3TableViewProfileCell
@end

@implementation EventsListCell

-(void)setKey: (NSDictionary*)event
{
  [super setKey:event];
  if(!event) return;

  // [self setImageForMovie: movie];
  [self setText: [event objectForKey: @"name"]];
  NSString* location_name = [event objectForKey: @"location_name"];
  [self setDetailText: location_name];
}

-(NSString*) url
{
  return _.join(@"/events/show?id=", [self.key objectForKey:@"_id"]);
}

@end

@interface EventsByLocationListCell: M3TableViewProfileCell
@end

@implementation EventsByLocationListCell

-(void)setKey: (NSDictionary*)event
{
  [super setKey:event];
  
  // [self setImageForMovie: movie];
  [self setText: [event objectForKey: @"name"]];

  NSString* time = [event objectForKey:@"starts_at"];
  NSString* timeAsString = [time.to_date stringWithFormat:@"dd.MM. HH:mm"];
  NSString* genre = [event objectForKey:@"genre"];
  NSString* sub_genre = [event objectForKey:@"sub_genre"];
  if(sub_genre && ![sub_genre isKindOfClass:[NSNull class]])
    genre = [genre stringByAppendingFormat:@"/%@", sub_genre];

  [self setDetailText: [NSString stringWithFormat:@"%@ - %@", genre, timeAsString]];
}

-(NSString*) url
{
  return _.join(@"/events/show?id=", [self.key objectForKey:@"_id"]);
}

@end

/******************************************************************************/

@interface EventsListController: M3ListViewController

@property (readonly) NSDictionary* location;

@end

@implementation EventsListController

-(NSString*)title
{
  NSDictionary* location = self.location;
  
  if(location)
    return [location objectForKey: @"name"];
    
  return @"Events";
}

-(NSDictionary*)location
{
  id location_id = [self.url.to_url.params objectForKey:@"location_id"];
  return [app.sqliteDB.locations get: location_id];
}

-(void)reloadURL
{
  M3TableViewDataSource* ds;
  
  id location = self.location;
  
  if(location) {
    [self setRightButtonReloadAction];
    
    self.dataSource = [EventsDataSource dataSourceWithLocation: location];
    // self.tableView.tableHeaderView = [M3ProfileView profileViewForTheater: location]; 
  }
  else {
    self.dataSource = [EventsDataSource dataSource];
    [self setSearchBarEnabled: YES];
  }
}

@end
