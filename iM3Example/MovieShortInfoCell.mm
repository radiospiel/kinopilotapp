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
  NSArray* class_and_movie = self.key;
  NSDictionary* movie = class_and_movie.last;
  
  NSString* title =           [movie objectForKey:@"title"];
  NSNumber* runtime =         [movie objectForKey:@"runtime"];
  NSString* genre =           [[movie objectForKey:@"genres"] objectAtIndex:0];
  NSNumber* production_year = [movie objectForKey:@"production-year"];
  NSArray* actors =           [movie objectForKey:@"actors"];
  NSArray* directors =        [movie objectForKey:@"directors"];
  // NSString* original_title =  [movie objectForKey:@"original-title"];
  // NSString* average-community-rating: 56,  
  // NSString* cinema_start_date = [self.movie objectForKey: @"cinema-start-date"]; // e.g. "2011-08-25T00:00:00+02:00"

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

-(void)setKey: (NSArray*)class_and_movie
{
  M3AssertKindOf(class_and_movie, NSArray);
  M3AssertKindOf(class_and_movie.last, NSDictionary);

  [super setKey:class_and_movie];
  
  NSDictionary* movie = class_and_movie.last;
  
  self.imageView.image = [UIImage imageNamed:@"no_poster.png"];
  self.imageView.imageURL = [movie objectForKey:@"image"];
  
  self.textLabel.text = @" ";
    
  NSString* html = [self shortInfoASHTML];
  htmlView.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(212, 1000)];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  self.imageView.frame = CGRectMake(10, 10, 90, 120);
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(107, 7, sz.width, sz.height);
}

+(CGFloat)fixedHeight
  { return 0; }

- (CGFloat)wantsHeight
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 17;
  CGFloat heightByImage = 140;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end