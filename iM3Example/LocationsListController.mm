//
//  LocationsListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "M3TableViewProfileCell.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"
#import "M3ListViewController.h"

@interface LocationsListController: M3ListViewController
@end


/*** A cell for the LocationsListController ***************************************************/

@interface LocationsListCell: M3TableViewProfileCell {
  BOOL hasSchedules;
}
@end

@implementation LocationsListCell

-(NSString*)location_id
{
  NSDictionary* location = self.key;
  return [location objectForKey: @"_id"];
}

-(BOOL)onFlagging: (BOOL)isNowFlagged;
{
  [app setFlagged:isNowFlagged onKey: [self location_id]];
  return isNowFlagged;
}

-(NSArray*)eventNamesForLocation: (NSDictionary*)location
{
  NSArray* movies = [app.sqliteDB all: @"SELECT DISTINCT(movies.title) FROM movies "
                                        "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                        "WHERE schedules.location_id=? AND schedules.time > ?", 
                                        [location objectForKey: @"_id"],
                                        [NSDate today]];
  
  return [movies mapUsingBlock:^id(NSDictionary* movie) { return [movie objectForKey:@"title"]; }];
}

-(void)setKey: (NSDictionary*)location
{
  [super setKey:location];
  if(!location) return;
  
  [super setFlagged: [app isFlagged: [self location_id]]];
  
  [self setText: [location objectForKey: @"name"]];

  NSArray* eventNames = [self eventNamesForLocation: location];
  if(eventNames.count > 0) {
    [self setDetailText: [eventNames componentsJoinedByString: @", "]];
  }
  else {
    [self setDetailText: @"Für diese Location liegen uns keine Veranstaltungen vor."];
  }
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  if(!hasSchedules)
    self.detailTextLabel.textColor = [UIColor grayColor];
}

-(NSString*)url 
{
  NSDictionary* location = self.key;
  NSString* location_id = [location objectForKey: @"_id"];

  return _.join(@"/movies/list?location_id=", location_id);
}

@end

// --- LocationsListFiltered ----------------------------------------------

@interface LocationsListFilteredByMovieCell: M3TableViewProfileCell
@end

@implementation LocationsListFilteredByMovieCell

static CGFloat textHeight = 0, detailTextHeight = 0;

+(void)initialize {
  textHeight = [self.stylesheet fontForKey:@"h2"].lineHeight;
  detailTextHeight = [self.stylesheet fontForKey:@"detail"].lineHeight;
}

+ (CGFloat)fixedHeight
{ 
  return 2 + textHeight + detailTextHeight + 3; 
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  self.detailTextLabel.numberOfLines = 1;
}

-(NSArray*)schedules
{
  return [self.key objectForKey:@"schedules"];
}

-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  NSString* location_id = [key objectForKey: @"location_id"];
  
  NSDictionary* location = [app.sqliteDB.locations get: location_id];
  
  [self setText: [location objectForKey: @"name"]];
  
  NSArray* schedules = [self schedules];
  schedules = [schedules sortByKey:@"time"];
  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];
}

@end

/*** The LocationsListController ***************************************************/

@implementation LocationsListController

-(NSString*)title
{
  return @"Locations";
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
  if(!filter) filter = @"all";
  self.dataSource = [M3DataSource locationsListWithFilter: filter];
}

-(void)setFilter:(NSString*)filter
{
  if([filter isEqualToString:@"all"])
    self.url = _.join(@"/locations/list");
  else    
    self.url = _.join(@"/locations/list?filter=", filter);
}

@end
