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
    [p addObject: [directors.uniq componentsJoinedByString:@", "]];

    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@""]];
    [parts addObject: @"</p>"];
  }
  
  if(actors) {
    NSMutableArray* p = [NSMutableArray array];
    [p addObject: @"<b>Darsteller:</b> "];
    [p addObject: [actors.uniq componentsJoinedByString:@", "]];

    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@""]];
    [parts addObject: @"</p>"];
  }

  return [parts componentsJoinedByString:@""];
}

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  
  self.textLabel.text = @" ";
    
  NSString* html = [self shortInfoASHTML];
  htmlView.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(212, 1000)];
}

/* 
 * usually we would prepare the image views already in setKey:. However, as
 * setKey: is called for determining a cell's height on a temporary cell
 * object, we'll prepare the image later, during layoutSubviews, to prevent 
 * double loading of URLs.
 *
 * The imageView's imageURL attribute is used to determine whether preparing
 * is still needed.
 */ 
-(void)prepareImageView
{
  NSArray* class_and_movie = self.key;
  NSDictionary* movie = class_and_movie.last;
  M3AssertKindOf(movie, NSDictionary);

  if([self.imageView.imageURL isEqualToString: [movie objectForKey:@"image"]]) 
    return; 

  /* set imageView */
  
  self.imageView.image = [UIImage imageNamed:@"no_poster.png"];
  self.imageView.imageURL = [movie objectForKey:@"image"];
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.imageView.clipsToBounds = YES;
  
  NSArray* thumbnails = [movie objectForKey:@"thumbnails"];
  
  if(thumbnails.count > 1) {
    for(NSString* thumbnail in [movie objectForKey:@"thumbnails"]) {
      [self.imageView addImageURLToRotation: thumbnail];
    }
  }
  
  [self.imageView onTapOpen: _.join(@"/movies/images/", [movie objectForKey:@"_uid"]) ];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  self.imageView.frame = CGRectMake(10, 10, 90, 120);
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(107, 7, sz.width, sz.height);

  [self prepareImageView]; 
}

-(void)prepareForReuse
{
  self.imageView.imageURL = nil;
}

+(CGFloat)fixedHeight
{ 
  return 0; 
}

- (CGFloat)wantsHeight
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 17;
  CGFloat heightByImage = 140;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end