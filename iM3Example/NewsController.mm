//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsController.h"

/*** A cell for the MoviesListCell *******************************************/

@interface NewsListCell: M3TableViewProfileCell
@end

@implementation NewsListCell

-(void)setKey: (NSDictionary*)news
{
  [super setKey:news];
  
  [self setImageURL: [news objectForKey: @"image"]];
  [self setText: [news objectForKey: @"title"]];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  CGRect frame = self.textLabel.frame;
  frame.size.height *= 2;
   
  self.textLabel.frame = frame;
}

-(NSString*)url
{
  NSDictionary* news = self.key;
  return _.join(@"/news/show?news_id=", [news objectForKey:@"_uid"]);
}

@end

/*** The datasource for MoviesList *******************************************/

@interface NewsListDataSource: M3TableViewDataSource
@end

@implementation NewsListDataSource

-(id)init
{
  self = [super initWithCellClass: @"NewsListCell"]; 
  
  [self addSection: app.chairDB.news.values withOptions: nil];
  
  return self;
}

@end

/******************************************************************************/

@implementation NewsListController

-(NSString*)title
{
  return @"News";
}

-(void)loadFromUrl:(NSString *)url
{
  if(!url) {
    self.dataSource = nil;
    return;
  }
  
  self.dataSource = [[[NewsListDataSource alloc] init] autorelease];
}

@end

/******************************************************************************/

@interface NewsShowDescriptionCell: M3TableViewHtmlCell
@end

@implementation NewsShowDescriptionCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"p"];
}

-(void)setKey:(id)key
{
  [super setKey:key];

  NSMutableArray* paragraphs = [NSMutableArray array];
  
  NewsShowController* nsc = (NewsShowController*)[self tableViewController]; 
  M3AssertKindOf(nsc, NewsShowController);
  
  NSNumber* published_at = [nsc.news objectForKey:@"published_at"];
  
  NSDictionary* data = _.hash(@"title",        [nsc.news objectForKey:@"title"],
                              @"published_at", [published_at.to_date stringWithFormat:@"dd. MMMM"],
                              @"teaser",       [nsc.news objectForKey:@"trailer"]);
  
  [paragraphs addObject: [M3 interpolateString: @"<h2><b>{{title}}</b></h2><p>{{published_at}}</p>" withValues:data]];
  [paragraphs addObject: [M3 interpolateString: @"<p><i>{{teaser}}</i></p>" withValues:data]];
  
  NSString* text = [nsc.news objectForKey:@"text"];
  NSArray* parts = [text componentsSeparatedByString:@"\n\n"];

  if(parts.count > 0)
    [paragraphs addObject: parts.first];
  if(parts.count > 1) {
    [paragraphs addObject: @""];
    
    NSString* part = parts.second;
    if(parts.count > 2) part = _.join(part, @" ...");
    [paragraphs addObject: part];
  }

  paragraphs = [paragraphs mapUsingBlock:^id(NSString* part) {
    return _.join(@"<p>", part, @"</p>");
  }];
  
  [self setHtml: [paragraphs componentsJoinedByString:@""]];
}

@end

@interface NewsShowMoreCell: M3TableViewUrlCell
@end

@implementation NewsShowMoreCell

-(void)setKey: (id)key
{
  [super setKey:key];

  self.textLabel.text = @"Weiterlesen auf moviepilot.de";

  NewsShowController* nsc = (NewsShowController*)[self tableViewController]; 
  M3AssertKindOf(nsc, NewsShowController);
  
  self.url = [nsc.news objectForKey:@"url"];
}

@end

@interface NewsShowDataSource: M3TableViewDataSource
@end

@implementation NewsShowDataSource

-(id) cellClassForKey:(id)key
{ 
  return key; 
}

@end

@implementation NewsShowController

-(NSString*)news_id
{
  return [self.url.to_url param:@"news_id"];
}

-(NSDictionary*)news
{
  return [app.chairDB.news get: [self news_id]];
}

-(NSString*)title
{
  return [[self news] objectForKey:@"title"];
}

-(void)loadFromUrl:(NSString *)url
{
  if(!url) {
    self.dataSource = nil;
    self.tableView.tableHeaderView = nil;
  }
  else {
    NewsShowDataSource* ds = [[[NewsShowDataSource alloc] init] autorelease];
    [ds addSection: _.array(@"NewsShowDescriptionCell", @"NewsShowMoreCell") 
       withOptions:nil ];
    
    self.dataSource = ds;
    UIImageView* iv = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, 320, 180)];
    [iv setImageURL: [self.news objectForKey:@"image"]];
    self.tableView.tableHeaderView = iv; 
  }
}
  
@end

  
/******************************************************************************/
