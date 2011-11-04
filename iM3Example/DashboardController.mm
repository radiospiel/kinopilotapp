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
  return 90;
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

-(void)theaters
{
  rightAligned_ = YES;

  [self setLabel: @"{{chairDB.theaters.count}} Kinos"];
  [self setBackground: @"cinemas.png"];
  self.url = @"/theaters/list";
}

-(void)movies
{
  rightAligned_ = YES;

  [self setLabel: @"{{chairDB.movies.count}} Filme"];
  [self setBackground: @"movies.png"];
  self.url = @"/movies/list";
}

-(void)vicinity
{
  // rightAligned_ = YES;

  [self setLabel: @"%d Aufführungen nearby"];
  // [self setLabel2: [NSString stringWithFormat:@"in der Nähe", app.chairDB.movies.count]];
  [self setBackground: @"traffic.png"];
  self.url = @"/vicinity/show";
}

-(void)news
{
  [self setLabel: @"News"];
  [self setBackground: @"movies.png"];
  self.url = @"http://www.moviepilot.de";
}

-(void)moviepilot
{
  // rightAligned_ = YES;

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
    CGRect frame = self.textLabel.frame;
    CGSize sz = [self.textLabel sizeThatFits: frame.size];

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

  [self addSection: _.array(@"city", @"M3TableViewAdCell", @"theaters", @"movies", @"vicinity", @"news", @"moviepilot") 
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
  NSArray* latlong = [theater objectForKey:@"latlong"];
  
  NSNumber* lat = latlong.first;
  NSNumber* lng = latlong.second;
  
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

  self.dataSource = [[[DashboardDataSource alloc]init]autorelease];
}

-(BOOL)isFullscreen
{
  return YES;
}
@end
