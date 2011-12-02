#import "DashboardController.h"

//
//  DashboardController.m
//  M3
//
//  Created by Enrico Thierbach on 30.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "VicinityShowController.h"
#import "M3TableViewProfileCell.h"
#import "AppDelegate.h"
#import "M3.h"

#define NUMBER_OF_THEATERS    12
#define SCHEDULES_PER_THEATER 6

/*** VicinityShowController cells *******************************************/

@interface DashboardInfoCell: M3TableViewCell {
  BOOL rightAligned_;
}

@end

@implementation DashboardInfoCell

+(CGFloat)fixedHeight
{
  return 80;
}

-(void)setLabel: (NSString*)label
{
  self.textLabel.text = [M3 interpolateString: label withValues: (id) app];
}

-(void)setBackground: (NSString*)imageName
{
  self.backgroundColor = [UIColor blackColor];

  UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
  self.backgroundView = [imageView autorelease];

  [[self contentView] setBackgroundColor: [UIColor colorWithName:@"00000060"]];

  UIView* bgView = [[UIView alloc]init];
  [bgView setBackgroundColor:[UIColor clearColor]];
  self.selectedBackgroundView = [bgView autorelease];
}

-(void)setKey: (NSString*)key
{
  [super setKey: key];
  if(key)
    [self performSelector: key.to_sym];
}

-(void)city
{
  [self setLabel: @"Berlin"];
  [self setBackground: @"berlin.png"];
  self.url = @"/info";
}

-(void)search
{
  [self setLabel: @"Suche..."];
  [self setBackground: @"berlin.png"];
  self.url = @"/search";
}

-(void)theaters
{
  rightAligned_ = YES;

  [self setLabel: @"{{sqliteDB.theaters.count}} Kinos"];
  
  [self setBackground: @"cinemas.png"];
  self.url = @"/theaters/list";
}

-(void)movies
{
  rightAligned_ = YES;

  [self setLabel: @"{{sqliteDB.movies.count}} Filme"];
  [self setBackground: @"movies.png"];
  self.url = @"/movies/list";
}

-(void)vicinity
{
  [self setLabel: @"{{sqliteDB.schedules.count}} in der Nähe"];
  [self setBackground: @"traffic.png"];
  self.url = @"/vicinity/show";
}

-(void)moviepilot
{
  [self setLabel: @"Danke moviepilot!"];
  [self setBackground: @"berlin.png"];
  self.url = @"http://www.moviepilot.de";
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  if([self.key isEqualToString: @"city"])
    self.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:36];
  else
    self.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:24];
  
  self.textLabel.textColor = [UIColor colorWithName:@"ffffff"];
  // self.textLabel.highlightedTextColor= [UIColor colorWithName:@"000000"];
  self.textLabel.backgroundColor = [UIColor clearColor];

  if(rightAligned_) {
    self.textLabel.textAlignment = UITextAlignmentRight;
    CGRect frame = self.textLabel.frame;
    CGSize sz = [self.textLabel sizeThatFits: frame.size];
    sz.width = 280;
    
    self.textLabel.frame = CGRectMake(320 - frame.origin.x - sz.width, frame.origin.y,
                                      sz.width, frame.size.height);
  }
}

@end

/*** The datasource for MoviesList *******************************************/

@interface DashboardDataSource: M3TableViewDataSource {
  CLLocationCoordinate2D currentPosition_;
}

-(double) distanceToTheater:(NSDictionary*) theater;

@end

@implementation DashboardDataSource

-(id)init
{
  self = [super init];
  if(!self) return nil;

  [self addSection: _.array(@"city", @"search",
                            //  @"M3TableViewAdCell", 
                            @"theaters", @"movies", @"vicinity", @"moviepilot") 
       withOptions: nil];

  return self;
}

-(id)cellClassForKey:(NSString*)key
{ 
  M3AssertKindOf(key, NSString);
  
  if([key isEqualToString:@"M3TableViewAdCell"])
    return @"M3TableViewAdCell";
  
  return [DashboardInfoCell class];
}

/* Distance from current position to [lat2,lng2] */

static double distance(double lat1, double lng1, double lat2, double lng2) 
{
#define PI_DIVIDED_BY_180   0.0174532925199
#define DEG_TO_RAD(deg)     deg * PI_DIVIDED_BY_180
#define RADIUS              6371
  
  lat1 = DEG_TO_RAD(lat1);
  lng1 = DEG_TO_RAD(lng1);
  
  lat2 = DEG_TO_RAD(lat2);
  lng2 = DEG_TO_RAD(lng2);
  
  double x = (lng2-lng1) * cos((lat1+lat2)/2);
  double y = (lat2-lat1);
  
  return sqrt(x*x + y*y) * RADIUS;
}

-(double) distanceToTheater:(NSDictionary*) theater
{
  NSNumber* lat = [theater objectForKey:@"lat"];
  NSNumber* lng = [theater objectForKey:@"lng"];
  
  M3AssertKindOf(lat, NSNumber);
  M3AssertKindOf(lng, NSNumber);
  
  return distance(currentPosition_.latitude, currentPosition_.longitude, 
                         [lat floatValue], [lng floatValue]);
}

@end

@implementation DashboardController

-(void)reload
{
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched; 
  self.tableView.backgroundColor = [UIColor blackColor];

  self.tableView.scrollEnabled = NO;
  
  self.dataSource = [[[DashboardDataSource alloc]init]autorelease];
}

-(BOOL)isFullscreen
{
  return YES;
}
@end
