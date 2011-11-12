#import "AppDelegate.h"
#import "TTTAttributedLabel.h"
#import "M3TableViewCell.h"
#import "MoviesShowController.h"

/* === MovieInfoCells: a base class which returns the movie object ============== */

@interface MovieInfoCell: M3TableViewCell

@property (nonatomic,readonly) NSDictionary* movie;

@end

@implementation MovieInfoCell

-(NSDictionary*)movie
{ 
  MoviesShowController* msc = (MoviesShowController*)self.tableViewController;
  M3AssertKindOf(msc, MoviesShowController);
  return msc.movie;
}

@end

/* === MovieRatingCell: This cell shows the community rating ==================== */

@interface MovieRatingCell: MovieInfoCell {
  UIImageView* ratingBackground_;
  UIImageView* ratingForeground_;
  UILabel*     ratingLabel_;
}
@end

@implementation MovieRatingCell

-(CGFloat)wantsHeight
{
  NSNumber* number = [self.movie objectForKey: @"average-community-rating"];
  return number.to_i <= 0 ? 0 : 44;
}

-(id)init
{
  self = [super init];
  
  self.textLabel.text = @"moviepilot.de Rating";
  
  if(self) {
    ratingBackground_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unstars.png"]];
    [self addSubview: [ratingBackground_ autorelease]];
    
    ratingForeground_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stars.png"]];
    [self addSubview: [ratingForeground_ autorelease]];
    
    ratingLabel_ = [[UILabel alloc]init];
    [self addSubview: [ratingLabel_ autorelease]];
    
    self.clipsToBounds = YES;
  }
  return self;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  // Get rating: this is a number between 0 and 100.
  NSNumber* number = [self.movie objectForKey: @"average-community-rating"];
  if(number.to_i <= 0) return;
  
  ratingBackground_.frame = CGRectMake(180, 13, 96, 16);
  ratingForeground_.frame = CGRectMake(180, 13, (number.to_i * 96 + 50)/100, 16);
  ratingForeground_.contentMode = UIViewContentModeLeft;
  ratingForeground_.clipsToBounds = YES;
  
  // TODO: make me right aligned
  CGRect labelFrame = self.textLabel.frame;
  
  ratingLabel_.font = [self.stylesheet fontForKey:@"h2"];
  ratingLabel_.frame = CGRectMake(287, labelFrame.origin.y, 46, labelFrame.size.height);
  ratingLabel_.font = self.textLabel.font;
  ratingLabel_.text = [NSString stringWithFormat: @"%.1f", number.to_i / 10.0];
}

@end

/* === MovieTrailerCell: a link to a movie trailer controller =================== */

@interface MovieTrailerCell: MovieInfoCell
@end

@implementation MovieTrailerCell

-(id)init
{
  self = [super init];
  self.textLabel.text = @"Show Trailer";
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  return self;
}

-(NSString*)url
{
  return [app.chairDB trailerURLForMovie: [self.movie objectForKey:@"_uid"]];
}

-(CGFloat)wantsHeight
{
  return self.url ? 44 : 0;
}

@end

/* === MovieInCinemasCell: a link to a list of cinemas that show the movie ====== */

@interface MovieInCinemasCell: MovieInfoCell
@end

@implementation MovieInCinemasCell

+(CGFloat)fixedHeight
{ 
  return 44;
}

-(void)setKey: (id)key
{
  [super setKey: key];
  
  // --- fill in cell.
  
  NSString* movie_id = [self.movie objectForKey: @"_uid"];
  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  
  if(!theater_ids.count) {
    self.textLabel.text = @"Für diesen Film liegen uns keine Termine vor.";
    self.textLabel.font = [UIFont italicSystemFontOfSize:14];
    self.textLabel.textColor = [UIColor colorWithName:@"#999"];
  }
  else {
    NSString* label = nil;
    
    if(theater_ids.count == 1) {
      NSDictionary* theater = [app.chairDB.theaters get: theater_ids.first];
      label = [NSString stringWithFormat: @"Zur Zeit im %@", [theater objectForKey:@"name"]];
    }
    else {
      label = [NSString stringWithFormat: @"Zur Zeit in %d Kinos", theater_ids.count];
    }
    
    self.textLabel.font = [UIFont boldSystemFontOfSize:14];
    self.textLabel.text = label;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  // --- set URL
  switch(theater_ids.count) {
    case 0:   self.url = nil;
    case 1:   self.url = _.join(@"/schedules/list?movie_id=", movie_id, "&theater_id=", theater_ids.first); break;
    default:  self.url = _.join(@"/theaters/list?movie_id=", movie_id); break;
  }
  
}

@end

/* === MovieShortInfoCell: short info ====== */

@interface MovieShortInfoCell: MovieInfoCell {
  TTTAttributedLabel* htmlView;
}
@end

@implementation MovieShortInfoCell

-(id) init {
  self = [super init];

  self.selectionStyle = UITableViewCellSelectionStyleNone;
  htmlView = [[[TTTAttributedLabel alloc] init] autorelease];
  [self addSubview: htmlView];

  return self;
}

-(NSString*)markup
{
  NSDictionary* movie = self.movie;
  if(!movie) return nil;
  
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

-(void)setKey: (id)key
{
  [super setKey:key];
  
  self.textLabel.text = @" ";

  htmlView.text = [NSAttributedString attributedStringWithMarkup: [self markup] 
                                                   forStylesheet: self.stylesheet];
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
  NSDictionary* movie = self.movie;
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
  
  [self.imageView onTapOpen: _.join(@"/movies/images?movie_id=", [movie objectForKey:@"_uid"]) ];
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

- (CGFloat)wantsHeight
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 17;
  CGFloat heightByImage = 140;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end

/* === MovieDescriptionCell: full movie description ============================= */

@interface MovieDescriptionCell: MovieInfoCell {
  TTTAttributedLabel* htmlView;
}
@end

@implementation MovieDescriptionCell

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

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  
  self.textLabel.text = @" ";
  
  NSString* description = [self.movie objectForKey:@"description"];
  NSString* html = _.join(@"<p><b>Beschreibung: </b>", description.cdata, @"</p><br />");
  
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
