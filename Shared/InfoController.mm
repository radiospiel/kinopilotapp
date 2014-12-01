//
//  InfoController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"

/* 
 * This cell shows one value (i.e. one piece of text). The text might span
 * over multiple lines.
 */

@interface InfoTextCell: M3TableViewCell
@end

@implementation InfoTextCell

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
  M3AssertKindOf(key, NSString);

  [super setKey: key];
  self.textLabel.text = self.key;
}

- (CGFloat)wantsHeight
{
  [self layoutSubviews];

  CGSize stringSize = [self.key sizeWithFont:self.textLabel.font
                           constrainedToSize:CGSizeMake(260, 9999) 
                               lineBreakMode:UILineBreakModeWordWrap ];

  return stringSize.height + 20;
}

@end

/* 
 * This cell shows a label and a value
 */

@interface InfoTextValueCell: M3TableViewCell
@end

@implementation InfoTextValueCell

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

-(NSString*)resolveValue: (NSString*)infoKey
{
  NSString* text = [app.infoDictionary objectForKey:infoKey];
  if(!text) return infoKey;

  return [text description];
}

-(void)setKey: (NSArray*)key
{
  [super setKey: key];

  NSString* label = key.first;
  NSString* infoKey = key.second;
  
  self.textLabel.text = label;
  self.textLabel.textAlignment = UITextAlignmentRight;

  NSString* value = [self resolveValue: infoKey];
  if([value matches:@"(http://|https://|mailto:)(.*)"]) {
    [self.detailTextLabel onTapOpen: value];
    value = $2;
  }

  self.detailTextLabel.textAlignment = UITextAlignmentLeft;
  self.detailTextLabel.text = value;
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
@end

@implementation InfoControllerDataSource

-(Class) cellClassForKey: (id)key;
{
  if(![key isKindOfClass:[NSArray class]])
    return [InfoTextCell class];

  return [InfoTextValueCell class];
}

-(Class)cellValueForKey: (id)key
{
  return key;
}

-(id)init
{
  self = [super init];
  
  NSArray* infoSections = [app.config objectForKey: @"info"];
  M3AssertKindOf(infoSections, NSArray);

  for(NSDictionary* section in infoSections) {
    M3AssertKindOf(section, NSDictionary);

    [self addSection: [section objectForKey:@"content"]   // fetch "content" from \a section
         withOptions: section];                           // use "header", "footer", and "index" from \a section.
  }
  
  return self;
}

@end

@interface InfoController: M3TableViewController
@end

@implementation InfoController

-(id)init
{ 
  self = [super initWithStyle: UITableViewStyleGrouped];
  [app on: @selector(db_updated) notify:self with:@selector(reload)];
  return self;
}

#pragma mark - Low memory management

-(void)reloadURL
{
  self.dataSource = [[[InfoControllerDataSource alloc]init]autorelease];
}

-(NSString*)title
{
  return @"Info";
}

@end
