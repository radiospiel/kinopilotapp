//
//  VicinityShowController.m
//  M3
//
//  Created by Enrico Thierbach on 30.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"

#pragma mark -- VicinityShowController

@interface VicinityController: M3ListViewController
@end

@implementation VicinityController

-(void)perform
{
  [M3LocationManager updateLocationAndOpen: @"/vicinity/show"];
}

@end

#pragma mark -- VicinityTableCell

// VicinityTableCell defines some layout for the various Vicinity cells
//

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

// A VicinityScheduleCell defines some layout for the various Vicinity cells

@interface VicinityScheduleCell: VicinityTableCell
@end

@implementation VicinityScheduleCell

-(void)setKey: (NSDictionary*)schedule
{
  [super setKey:schedule];
  
  NSNumber* time = [schedule objectForKey: @"time"];
  self.textLabel.text = [time.to_date stringWithFormat: @"HH:mm"];

  NSString* title = [schedule objectForKey:@"title"];
  self.detailTextLabel.text = [title withVersionString: [schedule objectForKey:@"version"]];
}

-(NSString*)url
{
  return _.join(@"/movies/show?movie_id=", [self.key objectForKey: @"movie_id"]);
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

// A VicinityTheaterCell holds a "link" to /movies/list?theater_id=<theaters>

@interface VicinityTheaterCell: VicinityTableCell
@end

@implementation VicinityTheaterCell

-(id)init
{ 
  self = [super init];
  
  self.detailTextLabel.font = [UIFont italicSystemFontOfSize:13];
  self.detailTextLabel.text = @"mehr...";
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  return self;
}

-(void)setKey: (NSDictionary*)theater_id
{
  [super setKey: theater_id];
  self.url = _.join(@"/movies/list?theater_id=", theater_id);
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

  NSArray* theaters = [
    app.sqliteDB all: @"SELECT _id, name, lat, lng, distance(lat, lng, ?, ?) AS distance FROM theaters ORDER BY distance LIMIT 12", 
                      [NSNumber numberWithDouble: position.latitude], 
                      [NSNumber numberWithDouble: position.longitude]
  ];

  //
  // Time range: we'll show all schedules in the next 2 hours, i.e. less than
  // *then*. If we'll then have less than 6 (schedulesPerTheater) schedules 
  // (i.e. Arthouse cinema), we include schedules until we have those, if 
  // these are in the next 12 hours (i.e. before *then_max*.
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSTimeInterval then = now + 2 * 3600;
  NSTimeInterval then_max = now + 12 * 3600;

  for(NSDictionary* theater in theaters) {
    NSString* theater_id = [theater objectForKey:@"_id"];

    // Add all schedules between now and then, or, if we don't have at least 6 schedules
    // all schedules between now and then_max
    NSArray* schedules = [
      app.sqliteDB all: @"SELECT schedules.*, movies.title FROM schedules INNER JOIN movies ON movies._id=schedules.movie_id WHERE theater_id=? AND time BETWEEN ? AND ? ORDER BY time",
                        theater_id,
                        [NSNumber numberWithInt: now],
                        [NSNumber numberWithInt: then]
    ];

    if(schedules.count < 6) {
      schedules = [
        app.sqliteDB all: @"SELECT schedules.*, movies.title FROM schedules INNER JOIN movies ON movies._id=schedules.movie_id WHERE theater_id=? AND time BETWEEN ? AND ? ORDER BY time LIMIT 6",
          theater_id,
          [NSNumber numberWithInt: now],
          [NSNumber numberWithInt: then_max]
        ];
    }

    if(schedules.count == 0) continue;
    
    NSNumber* distance = [theater objectForKey: @"distance"];
    NSString* header = [NSString stringWithFormat:@"%@ (%.1f km)", 
                          [theater objectForKey:@"name"], 
                          [distance doubleValue]
                        ];

    [self addSection: [schedules arrayByAddingObject:theater_id]
         withOptions: _.hash(@"header", header)];
  }

  return self;
}

-(id)cellClassForKey:(id)key
{ 
  if([key isKindOfClass: [NSString class]])
    return [VicinityTheaterCell class];

  return [VicinityScheduleCell class];
}

@end

#pragma mark -- /vicinity/show

@interface VicinityShowController : M3ListViewController
@end

@implementation VicinityShowController

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