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
  
  NSArray* all_news = [app.chairDB.news values];
  [self addSection: all_news  
       withOptions: nil];
  
  return self;
}

@end

/******************************************************************************/

@implementation NewsListController

-(id)init
{
  self = [super init];
  return self;
}

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


/** M3TableViewHtmlCell *******************************************************/

/*
 * M3TableViewHtmlCell: This cell shows a description of the movie.
 */

@interface M3TableViewHtmlCell: M3TableViewCell {
  TTTAttributedLabel* htmlView;
}

@end

@implementation M3TableViewHtmlCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"p"];
}

-(id) init {
  self = [super init];
  if(!self) return nil;
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  htmlView = [[[TTTAttributedLabel alloc]init]autorelease];
  [self addSubview:htmlView];
  
  return self;
}

-(void)setHtml: (NSString*)html
{
  self.textLabel.text = @" ";
  htmlView.text = [NSAttributedString attributedStringWithMarkup: html 
                                                   forStylesheet: self.stylesheet];
}

-(CGSize)htmlViewSize
{ 
  return [htmlView sizeThatFits: CGSizeMake(300, 1000)]; 
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(10, 5, sz.width, sz.height);
}

- (CGFloat)wantsHeight
{ 
  return [self htmlViewSize].height + 15; 
}

@end

/******************************************************************************/

@interface NewsShowTeaserCell: M3TableViewHtmlCell
@end

@implementation NewsShowTeaserCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont italicSystemFontOfSize:14] forKey:@"h2"];
  [stylesheet setFont: [UIFont italicSystemFontOfSize:14] forKey:@"p"];
}

-(void)setKey:(id)key
{
  [super setKey:key];
  
  NewsShowController* nsc = (NewsShowController*)[self tableViewController]; 
  M3AssertKindOf(nsc, NewsShowController);
  
  NSString* html = [M3 interpolateString:@"<i>{{trailer}}</i>" withValues: nsc.news];
  [self setHtml: html];
}

@end

@interface NewsShowDescriptionCell: M3TableViewHtmlCell
@end

@implementation NewsShowDescriptionCell

-(void)setKey:(id)key
{
  [super setKey:key];

  NewsShowController* nsc = (NewsShowController*)[self tableViewController]; 
  M3AssertKindOf(nsc, NewsShowController);
  
  NSString* text = [nsc.news objectForKey:@"text"];
  NSArray* parts = [[text componentsSeparatedByString:@"\n\n"] mapUsingBlock:^id(NSString* part) {
    return _.join(@"<p>", part.cdata, @"</p>");
  }];
  
  NSString* html = [parts componentsJoinedByString:@"<p></p>"];
  [self setHtml: html];
}

@end

@interface NewsShowMoreCell: M3TableViewHtmlCell
@end

@implementation NewsShowMoreCell

-(CGFloat)wantsHeight
{
  return 44;
}

-(id)init
{
  self = [super init];
  
  self.textLabel.text = @"Weiterlesen auf moviepilot.de";
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  return self;
}

-(void)setKey: (id)key
{
  [super setKey:key];
  
  NewsShowController* nsc = (NewsShowController*)[self tableViewController]; 
  M3AssertKindOf(nsc, NewsShowController);
  
  self.url = [nsc.news objectForKey:@"url"];
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  self.textLabel.font = [UIFont boldSystemFontOfSize:14];
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

-(id)init
{
  self = [super init];
  return self;
}
  
-(void)setUrl:(NSString *)url
{
  [super setUrl:url];
}

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
    [ds addSection: _.array(@"NewsShowTeaserCell", @"NewsShowMoreCell", @"NewsShowDescriptionCell") 
       withOptions:nil ];
    
    self.dataSource = ds;
    self.tableView.tableHeaderView = [M3ProfileView profileViewForNews: self.news];
  }
}
  
@end

  
/******************************************************************************/

