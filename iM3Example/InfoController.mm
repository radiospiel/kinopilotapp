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

static UIFont* regularFont()
{
  static UIFont* regularFont_ = [UIFont systemFontOfSize:13];
  return regularFont_;
}

@interface Info
@end

@implementation Info
// --- Custom values ---------

+(NSString*) updated_at
  { return @"updated_at"; }

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

-(void)setKey: (NSArray*)key
{
  self.textLabel.text = key.first;
  self.textLabel.font = regularFont();
  self.textLabel.numberOfLines = 0;
  self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.textLabel.textAlignment = UITextAlignmentCenter;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)wantsHeight
{
  NSString* text = [self.key first];
  
  CGSize stringSize = [text sizeWithFont:regularFont()
                       constrainedToSize:CGSizeMake(260, 9999) 
                           lineBreakMode:UILineBreakModeWordWrap ];

  return stringSize.height + 10;
}

@end

@implementation InfoControllerCellTwoValues

+(CGFloat) fixedHeight;
{
  return 35;
}

-(NSString*)resolveCustomValue: (NSString*)name
{
  SEL selector = NSSelectorFromString(name);
  if(![InfoController respondsToSelector: selector]) 
    return name;
  
  return [InfoController performSelector:selector];
}

-(void)setKey: (NSArray*)key
{
  [super setKey: key];
  
  dlog << "setKey: "<< key;
  
  self.textLabel.text = key.first;
  self.textLabel.textColor = [UIColor colorWithName: @"#000"];
  
  NSString* text = [self resolveCustomValue: key.last];
  if([key.last matches:@"(http://|https://|mailto:)(.*)"]) {
    [self.detailTextLabel onTapOpen: text];
    text = $2;
  }
  self.detailTextLabel.text = text;
  self.detailTextLabel.font = regularFont();
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
    if([content isKindOfClass:[NSString class]])
      content = [NSArray arrayWithObject:content];
    
    [self addSection: content
          withHeader: [section objectForKey:@"header"]
           andFooter: [section objectForKey:@"footer"]
       andIndexTitle: nil];
  }
  
  return self;
}

-(Class) cellClassForKey: (NSArray*)key;
{
  M3AssertKindOf(key, NSArray);
  return key.count == 1 ?  [InfoControllerCellOneValue class] : [InfoControllerCellTwoValues class];
}

@end

@implementation InfoController

-(id)init
{
  self = [super initWithStyle: UITableViewStyleGrouped];
  return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.dataSource = [[M3TableViewDataSource alloc]init];
  
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

