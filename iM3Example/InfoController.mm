//
//  InfoController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "InfoController.h"

/* 
 * This cell shows one value (i.e. one piece of text). The text might span
 * over multiple lines.
 */

@interface InfoControllerCellOneValue: M3TableViewCell
@end

@implementation InfoControllerCellOneValue

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"h2"];
}

-(id)init
{
  self = [super initWithStyle: UITableViewCellStyleDefault];

  self.textLabel.numberOfLines = 0;
  self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.textLabel.textAlignment = UITextAlignmentLeft;
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  return self;
}

-(void)setKey: (NSString*)key
{
  [super setKey: key];
  
  M3AssertKindOf(key, NSString);
  self.textLabel.text = key;
}

- (CGFloat)wantsHeight
{
  [self layoutSubviews];

  NSString* text = self.key;
  
  CGSize stringSize = [text sizeWithFont:self.textLabel.font
                       constrainedToSize:CGSizeMake(260, 9999) 
                           lineBreakMode:UILineBreakModeWordWrap ];

  return stringSize.height + 20;
}

@end

/* 
 * This cell shows a label and a value
 */

@interface InfoControllerCellTwoValues: M3TableViewCell
@end

@implementation InfoControllerCellTwoValues

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont boldSystemFontOfSize:14] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"details"];
}

-(id)init
{ 
  return [super initWithStyle: UITableViewCellStyleValue1]; 
}

+(CGFloat) fixedHeight;
{ 
  return 35; 
}

-(void)setKey: (NSArray*)key
{
  [super setKey: key];
  
  self.textLabel.text = key.first;
  self.textLabel.textAlignment = UITextAlignmentRight;
  
  NSString* text = key.last;
  if([text matches:@"(http://|https://|mailto:)(.*)"]) {
    [self.detailTextLabel onTapOpen: text];
    text = $2;
  }

  self.detailTextLabel.textAlignment = UITextAlignmentLeft;
  self.detailTextLabel.text = text;
  self.detailTextLabel.textColor = [UIColor colorWithName: @"#385487"];
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  // right align textLabel and left align detailTextLabel 
  CGRect frame = self.textLabel.frame;
  frame.size.width = 130;
  self.textLabel.frame = frame;

  frame = self.detailTextLabel.frame;
  frame.origin.x = 160;
  frame.size.width = 130;
  self.detailTextLabel.frame = frame;
}
@end

/*
 * The data source for the InfoController
 */
@interface InfoControllerDataSource: M3TableViewDataSource

-(id)infoForKey: (NSString*)key;

@end

@implementation InfoControllerDataSource

-(id)init
{
  self = [super init];
  if(!self) return nil;

  NSArray* infoSections = [app.config objectForKey: @"info"];
  M3AssertKindOf(infoSections, NSArray);
  for(NSDictionary* section in infoSections) {
    M3AssertKindOf(section, NSDictionary);
    
    id content = [section objectForKey:@"content"];
    if(!content)
      content = [NSArray array];

    content = [content mapUsingBlock:^id(NSArray* entry) {
      if(![entry isKindOfClass:[NSArray class]]) return entry;
      id key = entry.last;
      return [NSArray arrayWithObjects:entry.first, [self infoForKey:key], nil];
    }];
    // Read "header", "footer", and "index" from the configuration.
    [self addSection: content withOptions: section];
  }
  
  return self;
}

-(id)infoForKey:(NSString *)key
{
  if([key isEqualToString: @"updated_at"]) { 
    NSDictionary* stats = app.chairDB.stats.first;
    NSNumber* updated_at = [stats objectForKey: @"updated_at"]; 
    return [updated_at.to_date stringWithFormat: @"dd.MM.yyyy HH:mm"];
  }

  if([key isEqualToString: @"theaters_count"])
    return [NSString stringWithFormat: @"%d", app.chairDB.theaters.count];

  if([key isEqualToString: @"movies_count"])
    return [NSString stringWithFormat: @"%d", app.chairDB.movies.count]; 

  if([key isEqualToString: @"schedules_count"])
    return [NSString stringWithFormat: @"%d", app.chairDB.schedules.count];

  if([key isEqualToString: @"built_at"])
    return [NSString stringWithFormat: @"%s %s", __DATE__, __TIME__]; 

  return key;
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

#pragma mark - Low memory management

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.dataSource = [[[InfoControllerDataSource alloc]init]autorelease];
}

- (void)viewDidUnload
{
  self.dataSource = nil;
  [super viewDidLoad];
}

-(NSString*)title
{
  return @"Info";
}

@end

