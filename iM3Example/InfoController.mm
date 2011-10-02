//
//  InfoController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "InfoController.h"
#import "M3TableViewDataSource.h"

@interface Info: NSObject
@end

// --- Custom values ---------

@implementation Info

+(NSString*) updated_at
{ 
  NSDictionary* stats = app.chairDB.stats.first;
  NSNumber* updated_at = [stats objectForKey: @"updated_at"]; 
  return [updated_at.to_date stringWithFormat: @"dd. MM. yyyy HH:mm"];
}

+(NSString*) theaters_count
  { return [NSString stringWithFormat: @"%d", app.chairDB.theaters.count]; }

+(NSString*) movies_count
  { return [NSString stringWithFormat: @"%d", app.chairDB.movies.count]; }

+(NSString*) schedules_count
  { return [NSString stringWithFormat: @"%d", app.chairDB.schedules.count]; }

+(NSString*) build_at
  { return [NSString stringWithFormat: @"%s %s", __DATE__, __TIME__]; }

@end

@interface InfoControllerCellOneValue: M3TableViewCell
@end

@interface InfoControllerCellTwoValues: M3TableViewCell
@end

@implementation InfoControllerCellOneValue

-(id)init
{
  return [super initWithStyle: UITableViewCellStyleDefault];
}

-(void)setKey: (NSString*)key
{
  M3AssertKindOf(key, NSString);

  [super setKey: key];
  
  self.textLabel.text = key;
  self.textLabel.numberOfLines = 0;
  self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.textLabel.textAlignment = UITextAlignmentCenter;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)wantsHeight
{
  NSString* text = self.key;
  
  CGSize stringSize = [text sizeWithFont:self.textLabel.font
                       constrainedToSize:CGSizeMake(260, 9999) 
                           lineBreakMode:UILineBreakModeWordWrap ];

  return stringSize.height + 10;
}

@end

@implementation InfoControllerCellTwoValues

-(id)init
  { return [super initWithStyle: UITableViewCellStyleValue1]; }

+(CGFloat) fixedHeight;
  { return 35; }

-(NSString*)resolveCustomValue: (NSString*)name
{
  SEL selector = NSSelectorFromString(name);
  if(![Info respondsToSelector: selector]) 
    return name;
  
  return [Info performSelector:selector];
}

-(void)setKey: (NSArray*)key
{
  [super setKey: key];
  
  self.textLabel.text = key.first;
  self.textLabel.font = [UIFont boldSystemFontOfSize:13];
  
  NSString* text = [self resolveCustomValue: key.last];
  if([key.last matches:@"(http://|https://|mailto:)(.*)"]) {
    [self.detailTextLabel onTapOpen: text];
    text = $2;
  }
  self.detailTextLabel.text = text;
  self.detailTextLabel.textColor = [UIColor colorWithName: @"#385487"];
}

@end

@interface InfoControllerDataSource: M3TableViewDataSource
@end

@implementation InfoControllerDataSource

-(id)init
{
  self = [super init];
  if(!self) return nil;

  NSArray* infoSections = [[app.config objectForKey: @"info"]retain];
  M3AssertKindOf(infoSections, NSArray);
  for(NSDictionary* section in infoSections) {
    M3AssertKindOf(section, NSDictionary);
    
    id content = [section objectForKey:@"content"];
    
    // Read "header", "footer", and "index" from the configuration.
    [self addSection: content withOptions: section];
  }
  
  return self;
}

-(Class) cellClassForKey: (NSArray*)key;
{
  if([key isKindOfClass:[NSArray class]])
    return [InfoControllerCellTwoValues class];

  return [InfoControllerCellOneValue class];
}

@end

@implementation InfoController

-(id)init
{
  return [super initWithStyle: UITableViewStyleGrouped];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.dataSource = [[InfoControllerDataSource alloc]init];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
 
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(NSString*)title
{
  return @"Info";
}

#pragma mark - Table view delegate

@end

