#import "AppDelegate.h"
#import "MovieShortInfoCell.h"
#import "TTTAttributedLabel.h"

@implementation MovieShortInfoCell

-(id) init {
  self = [super init];
  if(!self) return nil;

  self.selectionStyle = UITableViewCellSelectionStyleNone;

  htmlView = [[[TTTAttributedLabel alloc]init]autorelease];
  [self addSubview:htmlView];

  return self;
}

-(NSString*)shortInfoASHTML
{
  NSDictionary* model = self.model;
  
  NSString* title =           [model objectForKey:@"title"];
  NSNumber* runtime =         [model objectForKey:@"runtime"];
  NSString* genre =           [[model objectForKey:@"genres"] objectAtIndex:0];
  NSNumber* production_year = [model objectForKey:@"production-year"];
  NSArray* actors =           [model objectForKey:@"actors"];
  NSArray* directors =        [model objectForKey:@"directors"];
  // NSString* original_title =  [model objectForKey:@"original-title"];
  // NSString* average-community-rating: 56,  
  // NSString* cinema_start_date = [self.model objectForKey: @"cinema-start-date"]; // e.g. "2011-08-25T00:00:00+02:00"

  NSMutableArray* parts = [NSMutableArray array];

  [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title]];

  if(genre || production_year || runtime) {
    NSMutableArray* p = [NSMutableArray array];
    if(genre) [p addObject: genre];
    if(production_year) [p addObject: production_year];
    if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
    
    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@", "]];
    [parts addObject: @"</p>"];
    [parts addObject: @"<br />"];
  }

  if(directors) {
    NSMutableArray* p = [NSMutableArray array];
    [p addObject: @"<b>Regie:</b> "];
    [p addObject: [directors componentsJoinedByString:@", "]];

    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@""]];
    [parts addObject: @"</p>"];
  }
  
  if(actors) {
    NSMutableArray* p = [NSMutableArray array];
    [p addObject: @"<b>Darsteller:</b> "];
    [p addObject: [actors componentsJoinedByString:@", "]];

    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@""]];
    [parts addObject: @"</p>"];
  }

  return [parts componentsJoinedByString:@""];
}

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];
  
  self.imageView.image = [UIImage imageNamed:@"no_poster.png"];
  self.imageView.imageURL = [self.model objectForKey:@"image"];
  
  self.textLabel.text = @" ";
    
  NSString* html = [self shortInfoASHTML];
  htmlView.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(196, 1000)];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  self.imageView.frame = CGRectMake(10, 10, 94, 126);
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(114, 7, sz.width, sz.height);
}

- (CGFloat)wantsHeightForWidth: (CGFloat)width
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 17;
  CGFloat heightByImage = 140;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end