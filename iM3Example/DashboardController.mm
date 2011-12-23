#import "DashboardController.h"

//
//  DashboardController.m
//  M3
//
//  Created by Enrico Thierbach on 30.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3TableViewProfileCell.h"
#import "AppDelegate.h"
#import "M3.h"

/*** VicinityShowController cells *******************************************/

@interface DashboardInfoCell: M3TableViewCell {
}

@property (nonatomic,retain) NSArray* keys;

@end

@implementation DashboardInfoCell

@synthesize keys;

static NSDictionary *titlesByKey, *urlsByKey;

+(void)initialize
{
  titlesByKey = [_.hash(@"city",     @"Berlin",
                       @"theaters", @"Kinos",
                       @"movies",   @"Filme",
                       @"about",    @"about",
                       @"vicinity", @"Jetzt")retain];
  
  urlsByKey = [_.hash( @"city",     @"/map/show",
                      @"theaters", @"/theaters/list",
                      @"movies",   @"/movies/list",
                      @"about",    @"/info", // ?section=moviepilot",
                      @"vicinity", @"/vicinity/show")retain];
}

+(CGFloat)fixedHeight
{
  return 143;
}

-(UIImage*)tileImageWithTile: (NSString*)tile
{
  NSString* imageName = [ NSString stringWithFormat: @"Dashboard.bundle/background/%@.png", tile ];
  return [UIImage imageNamed: imageName ];
}

-(UIImage*)backgroundImageWithKey: (NSString*)key
{
  UIImage* image = [self tileImageWithTile: key];
  if(image) return image;
  
  return [self tileImageWithTile: self.keys.count == 1 ? @"wide" : @"narrow"];
}

// set title, adjust button size

-(UIButton*) dashboardButtonWithKey: (NSString*)key 
{
  UIButton* btn = [UIButton buttonWithType: UIButtonTypeCustom];
  
  // set background images, colors and font.
  
  btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
  [btn setTitleColor: [UIColor colorWithName: @"4c4b4b"] forState: UIControlStateNormal];
  
  [btn setTitleShadowColor: [UIColor whiteColor] forState: UIControlStateNormal];
  btn.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);

  UIImage* backgroundImage = [self backgroundImageWithKey: key];
  [btn setBackgroundImage: backgroundImage forState: UIControlStateNormal];
  
  // set URL and title

  btn.actionURL = [urlsByKey objectForKey: key];
  [btn setTitle: [titlesByKey objectForKey: key] forState:UIControlStateNormal];

  // adjust button size
  btn.frame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);

  return btn;
}

-(void)setKey: (NSString*)key
{
  if(!key) return;

  // The key is either a single key string of a string consisting of 
  // key components joined by "/"
  self.keys = [key componentsSeparatedByString:@"/"];

  [self.keys enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
    UIButton* button = [self dashboardButtonWithKey:key];
    
    CGRect frame = button.frame;
    frame.origin.x = 10 + idx * 156;
    frame.origin.y = 10;
    button.frame = frame;
    
    [self addSubview:button];
  }];
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  // add buttons
  
  
  // if([self.key isEqualToString: @"city"])
  //   self.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:36];
  // else
  //   self.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:24];
  // 
  // self.textLabel.textColor = [UIColor colorWithName:@"ffffff"];
  // // self.textLabel.highlightedTextColor= [UIColor colorWithName:@"000000"];
  // self.textLabel.backgroundColor = [UIColor clearColor];
}

@end

/*** The datasource for MoviesList *******************************************/

@interface DashboardDataSource: M3TableViewDataSource 
@end

@implementation DashboardDataSource

-(id)init
{
  self = [super init];
  [self addSection: _.array(@"city/theaters", @"movies", @"about/vicinity") 
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

@end

@implementation DashboardController

-(id)init 
{
  self = [super init];
  if(self) {
    [app on: @selector(updated) notify:self with:@selector(reload)];
  }
  return self;
}

-(void)reload
{
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched; 
  self.tableView.separatorColor = [UIColor blackColor];
  // self.tableView.backgroundColor = [UIColor blackColor];
  // self.tableView.bor
  // x
  self.tableView.scrollEnabled = NO;
  
  self.dataSource = [[[DashboardDataSource alloc]init]autorelease];
}

-(BOOL)isFullscreen
{
  return YES;
}
@end
