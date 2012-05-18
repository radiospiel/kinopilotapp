#import "AppBase.h"

@interface LocationsListController: M3ListViewController
@end

/*** Datasources for LocationsListControllers *************************************************/


/**** LocationsListDataSource **********************************/

@interface LocationsListDataSource: M3TableViewDataSource

@end

@implementation LocationsListDataSource

-(id)initWithFilter: (NSString*)filter
{
  self = [super initWithCellClass: @"LocationsListCell"]; 

  NSArray* locations;
  
  if([filter isEqualToString:@"fav"]) {
    locations = [app.sqliteDB all:
      @"SELECT locations._id, locations.name, GROUP_CONCAT(e.name, ', ') AS events "
       "FROM locations "
       "INNER JOIN flags ON flags.key_id=locations._id "
       "INNER JOIN ( "
       "            SELECT events.location_id, strftime('%d-%m: ', events.starts_at, 'unixepoch') || events.name AS name "
       "            FROM events "
       "            WHERE events.starts_at > ? "
       "            ORDER BY events.starts_at "
       "            ) e ON locations._id=e.location_id "
       "GROUP BY e.location_id "
       "ORDER BY locations.name ",
       [NSDate today]
    ];
  }
  else {
    locations = [app.sqliteDB all:
      @"SELECT locations._id, locations.name, GROUP_CONCAT(e.name, ', ') AS events "
       "FROM locations "
       "INNER JOIN ( "
       "            SELECT events.location_id, strftime('%d-%m: ', events.starts_at, 'unixepoch') || events.name AS name "
       "            FROM events "
       "            WHERE events.starts_at > ? "
       "            ORDER BY events.starts_at "
       "            ) e ON locations._id=e.location_id "
       "GROUP BY e.location_id "
       "ORDER BY locations.name ",
       [NSDate today]
    ];
  }

  //    
  //    
  if(locations.count > 10) {
    NSDictionary* groupedHash = [locations groupUsingBlock:^id(NSDictionary* location) {
      return [M3TableViewDataSource indexKey: location];
    }];

    NSArray* groups = [groupedHash.to_array sortBySelector:@selector(first)];
    for(NSArray* group in groups) {
      [self addSection: group.second 
           withOptions:_.hash(@"header", group.first, 
                              @"index", group.first)];
    }
  }
  else if(locations.count > 0) {
    [self addSection: locations];
  }
  
  if([filter isEqualToString:@"fav"])
    [self addFallbackSectionIfNeeded: @"NoFavsCell" ];
  else
    [self addFallbackSectionIfNeeded ];
  
  return self;
}

@end

// --- LocationsListCell ------------------------------------------------

@interface LocationsListCell: M3TableViewProfileCell {
  BOOL hasSchedules;
}

@property (nonatomic,retain) id location_id;
@end

@implementation LocationsListCell

@synthesize location_id;

-(BOOL)onFlagging: (BOOL)isNowFlagged;
{
  [app setFlagged:isNowFlagged onKey: self.location_id];
  return isNowFlagged;
}

-(NSArray*)eventNamesForVenue: (NSDictionary*)location
{
  NSArray* events = [app.sqliteDB all: @"SELECT events.name FROM events "
                                        "WHERE events.location_id=? AND events.starts_at > ?", 
                                        [location objectForKey: @"_id"],
                                        [NSDate today]];
  
  return [events mapUsingBlock:^id(NSDictionary* movie) { return [movie objectForKey:@"name"]; }];
}

-(void)setKey: (NSDictionary*)location
{
  [super setKey:location];

  self.location_id = [location objectForKey: @"_id"];

  if(!location) return;
  
  [super setFlagged: [app isFlagged: [self location_id]]];
  [self setText: [location objectForKey: @"name"]];

  [self setDetailText: [location objectForKey: @"events"]];
  
//  NSArray* names = [self eventNamesForVenue: location];
//  hasSchedules = names.count > 0;
//  
//  if(hasSchedules) {
//    [self setDetailText: [names componentsJoinedByString: @", "]];
//  }
//  else {
//    [self setDetailText: @"Für diese Location liegen uns keine Termine vor."];
//  }
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  if(!hasSchedules)
    self.detailTextLabel.textColor = [UIColor grayColor];
}

-(NSString*)url 
{
  return _.join(@"/events/list?location_id=", self.location_id);
}

@end

/*** The LocationsListController ***************************************************/

@implementation LocationsListController

-(NSString*)title
{
  return @"Venues";
}

-(NSString*) movie_id
{
  return [self.url.to_url param: @"movie_id"];
}

-(void)addSegmentedFilters
{
  if([self hasSegmentedControl]) return;
  
  [self addSegment: @"Alle" 
        withFilter: @"all" 
          andTitle: @"Alle"];
  [self addSegment: [UIImage imageNamed:@"unstar15.png"] 
        withFilter: @"fav" 
          andTitle: @"Favorites"];
}

-(void)reloadURL
{
  [self addSegmentedFilters];
  [self setSearchBarEnabled: YES];

  NSDictionary* params = self.url.to_url.params;
  NSString* filter = [params objectForKey: @"filter"];
  M3TableViewDataSource* ds = [[LocationsListDataSource alloc]initWithFilter: filter];
  [ds addFallbackSectionIfNeeded];

  self.dataSource = [ds autorelease];
}

-(void)setFilter:(NSString*)filter
{
  if([filter isEqualToString:@"all"])
    self.url = _.join(@"/locations/list");
  else    
    self.url = _.join(@"/locations/list?filter=", filter);
}

@end
