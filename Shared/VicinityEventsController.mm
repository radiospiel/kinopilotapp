//
//  VicinityEventsController.m
//

#import "AppBase.h"

#pragma mark -- Cells for /vicinity

@interface VicinityTableCell: M3TableViewCell
@end

@implementation VicinityTableCell

-(id)init
{ 
  self = [super initWithStyle: UITableViewCellStyleValue1]; 
  self.textLabel.font = [UIFont boldSystemFontOfSize:14];
  self.detailTextLabel.font = [UIFont systemFontOfSize:13];
  
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

@end

// A VicinityEventCell defines some layout for the various Vicinity cells

@interface VicinityEventCell: VicinityTableCell
@end

@implementation VicinityEventCell

-(void)setKey: (NSDictionary*)event
{
  [super setKey:event];
  
  // NSNumber* starts_at = [event objectForKey: @"starts_at"];
  // self.textLabel.text = [starts_at.to_date stringWithFormat: @"dd. MMM"];
  self.detailTextLabel.text = [event objectForKey:@"name"];
}

-(NSString*)url
{
  return _.join(@"/events/show?event_id=", [self.key objectForKey: @"_id"]);
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  self.detailTextLabel.numberOfLines = 1;
  self.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
  
  CGRect frame = self.detailTextLabel.frame;
  frame.origin.y = 4;
  self.detailTextLabel.frame = frame;
}

@end

// A VicinityLocationCell holds a "link" to /movies/list?theater_id=<theaters>

@interface VicinityLocationCell: VicinityTableCell
@end

@implementation VicinityLocationCell

-(id)init
{ 
  self = [super init];
  
  self.detailTextLabel.font = [UIFont italicSystemFontOfSize:13];
  self.detailTextLabel.text = @"mehr...";
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  return self;
}

-(NSString*)url
{
  NSDictionary* event = self.key;
  id location_id = [event objectForKey:@"location_id"];
  return _.join(@"/events/list?location_id=", location_id);
}

@end

#pragma mark -- The datasource for /vicinity/show

@interface VicinityShowDataSource: M3TableViewDataSource
@end

@implementation VicinityShowDataSource

-(id)init
{
  self = [super init];
  if(!self) return nil;

  CLLocationCoordinate2D position = [M3LocationManager coordinates];

  NSTimeInterval today = [[NSDate today] timeIntervalSince1970];
  NSTimeInterval tomorrow = today + 24 * 3600;

  // The real event data.
  NSArray* events = [
    app.sqliteDB all: 
      @"SELECT events.*, locations.name AS location_name, distance(lat, lng, ?, ?) AS distance FROM events "
       "INNER JOIN locations ON events.location_id=locations._id "
       "WHERE lat AND starts_at BETWEEN ? AND ? "
       "ORDER BY distance, starts_at",
       [NSNumber numberWithDouble: position.latitude], 
       [NSNumber numberWithDouble: position.longitude],
       [NSNumber numberWithInt: today],
       [NSNumber numberWithInt: tomorrow]
  ];

  // For each event location we'll add a dummy entry, which will then 
  // show up as a "Show more..." table cell. We'll append these to the
  // events array, so that they don't mess with the original order. When
  // adding records, they will be grouped away to the end of the location's
  // group.
  NSArray* location_ids = [events mapUsingBlock:^id(NSDictionary* event) {
    return [event objectForKey:@"location_id"];
  }];

  NSArray* location_markers = [location_ids.uniq mapUsingBlock:^id(id location_id) {
    return [NSDictionary dictionaryWithObjectsAndKeys: location_id, @"location_id", @"VicinityLocationCell", @"cell-type", nil];
  }];
  
  
  [self addRecords:[events arrayByAddingObjectsFromArray:location_markers]
        withGroupingThreshold:0];

  return self;
}

-(id)groupKeyForRecord:(NSDictionary *)event
{
  return [event objectForKey:@"location_id"];
}

-(NSString*)groupLabelForKey:(id)location_id
{
  CLLocationCoordinate2D position = [M3LocationManager coordinates];

  NSArray* locations = [
    app.sqliteDB all:
      @"SELECT locations.*, distance(lat, lng, ?, ?) AS distance FROM locations WHERE _id=?", 
      [NSNumber numberWithDouble: position.latitude], 
      [NSNumber numberWithDouble: position.longitude],
      location_id
  ];
  
  NSDictionary* location = locations.first;
  
  NSNumber* distance = [location objectForKey: @"distance"];
  if(!distance || [distance isKindOfClass:[NSNull class]])
    return [location objectForKey:@"name"]; 
      
  return [NSString stringWithFormat:@"%@ (%.1f km)", 
    [location objectForKey:@"name"], 
    [distance doubleValue]
  ];
}

-(id)cellClassForKey:(NSDictionary*)record
{ 
  NSString* cellType = [record objectForKey:@"cell-type"];
  return cellType ? cellType : [VicinityEventCell class];
}

@end

// The VicinityController updates the device location and opens /vicinity/show

@interface VicinityController: M3ListViewController
@end

@implementation VicinityController

-(void)perform
{
  [M3LocationManager updateLocationAndOpen: @"/vicinity/show"];
}

@end

// VicinityEventsController: /vicinity/events
//
// The VicinityController shows all of today's events, sorted by the distance

#pragma mark -- /vicinity/show

@interface VicinityEventsController : M3ListViewController
@end

@implementation VicinityEventsController

-(id)init
{
  self = [super init];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  return self;
}

-(void)reload
{
  self.dataSource = [[[VicinityShowDataSource alloc]init] autorelease];
}

@end