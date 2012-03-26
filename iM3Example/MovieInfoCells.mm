#import "M3AppDelegate.h"
#import "TTTAttributedLabel.h"
#import "M3TableViewCell.h"
#import "MoviesShowController.h"
#import "TheatersListController.h"

/* === MovieInfoCells: a base class which returns the movie object ============== */

@interface MovieInfoCell: M3TableViewCell

@property (nonatomic,readonly) NSDictionary* movie;

@end

@implementation MovieInfoCell

-(NSDictionary*)movie
{ 
  return [self.tableViewController performSelector:@selector(movie)];
}

-(NSString*)movie_id
{ 
  return [self.movie objectForKey: @"_id"];
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
  NSNumber* number = [self.movie objectForKey: @"average_community_rating"];
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
    
    //    ratingLabel_ = [[UILabel alloc]init];
    //    [self addSubview: [ratingLabel_ autorelease]];
    
    self.clipsToBounds = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}

-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  // Get rating: this is a number between 0 and 100.
  NSNumber* number = [self.movie objectForKey: @"average_community_rating"];
  if(number.to_i <= 0) return;
  
  ratingBackground_.frame = CGRectMake(190, 13, 96, 16);
  
  // We have 5 stars. Each star is 16 px wide. Between stars there is a 
  // 4 px distance. That means a rating of 
  //  0 .. 20 is mapped onto 0 .. 16
  // 20 .. 40 is mapped into 20 .. 36, 
  // etc.
  //
  int complete_stars = number.to_i / 20;                    // Each complete star is 20px wide.
  int incomplete_star = number.to_i - 20 * complete_stars;  // The incomplete star is in the range 0..19, and maps onto 0..16.
  ratingForeground_.frame = CGRectMake(190, 13, complete_stars * 20 + (incomplete_star * 16 + 10) / 20, 16);
  ratingForeground_.contentMode = UIViewContentModeLeft;
  ratingForeground_.clipsToBounds = YES;

  // Link to moviepilot
  self.url = [self.movie objectForKey:@"url"];
  
  //  CGRect labelFrame = self.textLabel.frame;
  //  
  //  ratingLabel_.font = [self.stylesheet fontForKey:@"h2"];
  //  ratingLabel_.frame = CGRectMake(267, labelFrame.origin.y, 46, labelFrame.size.height);
  //  ratingLabel_.font = self.textLabel.font;
  //  ratingLabel_.text = [NSString stringWithFormat: @"%.1f", number.to_i / 10.0];
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
  
  NSString* movie_id = self.movie_id;
  if(!movie_id) return;
  
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSArray* theater_ids = [
    app.sqliteDB allArrays: @"SELECT DISTINCT(theater_id) FROM schedules WHERE schedules.movie_id=? AND schedules.time > ?", 
                            movie_id,
                            [NSNumber numberWithInt:now]
  ];
  theater_ids = [theater_ids mapUsingSelector:@selector(first)];

  if(!theater_ids.count) {
    self.textLabel.text = @"Für diesen Film liegen uns keine Vorführungen vor.";
    self.textLabel.font = [UIFont italicSystemFontOfSize:14];
    self.textLabel.textColor = [UIColor colorWithName:@"#999"];
  }
  else {
    NSString* label = nil;
    
    if(theater_ids.count == 1) {
      NSDictionary* theater = [app.sqliteDB.theaters get: theater_ids.first];
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

@interface MovieShortInfoCell: MovieInfoCell

@property (nonatomic,retain) TTTAttributedLabel* htmlView;
@property (nonatomic,retain) UIImageView* posterView;

@end

@implementation MovieShortInfoCell

@synthesize htmlView, posterView;

-(id) init {
  self = [super init];
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  posterView = [[UIImageView alloc] initWithFrame: CGRectMake(7, 10, 90, 120)];
  [self addSubview: posterView];

  htmlView = [[TTTAttributedLabel alloc] init];
  [self addSubview: htmlView];

  return self;
}

-(void)dealloc
{
  self.posterView = nil;
  self.htmlView = nil;
  
  [super dealloc];
}

-(NSString*)markup
{
  NSDictionary* movie = self.movie;
  if(!movie) return nil;
  
  NSString* title =           [movie objectForKey:@"title"];
  NSNumber* runtime =         [movie objectForKey:@"runtime"];
  NSString* genre =           [[movie objectForKey:@"genres"] objectAtIndex:0];
  genre = [genre gsub:@"&amp;" with: @"&"];

  NSNumber* production_year = [movie objectForKey:@"production_year"];

  NSMutableArray* parts = [NSMutableArray array];

  [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title.htmlEscape]];

  if(genre || production_year || runtime) {
    NSMutableArray* p = [NSMutableArray array];
    if(genre) [p addObject: genre.htmlEscape];
    if(production_year) [p addObject: production_year];
    if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
    
    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@", "]];
    [parts addObject: @"</p>"];
    [parts addObject: @"<br />"];
  }

  return [parts componentsJoinedByString:@""];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(212, 1000)];
}

-(void)setKey:(id)key
{
  [super setKey:key];
  if(!key) return;

  self.textLabel.text = @" ";

  htmlView.numberOfLines = 0;
  NSString* markup = [self markup];
  if(!markup) markup = @"";
  htmlView.text = [NSAttributedString attributedStringWithMarkup: markup
                                                   forStylesheet: self.stylesheet];

  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(107, 7, sz.width, sz.height);

  NSArray* thumbnails = [self.movie objectForKey:@"thumbnails"];
  posterView.image = [app thumbnailForMovie: self.movie];
  posterView.imageURL = thumbnails.first;
  
  if(thumbnails.first && [app currentReachability]) {
    UIImageView* tapReceiver = [[UIImageView alloc] initWithFrame: CGRectMake(57, 86, 30, 30)];
    tapReceiver.image = [UIImage imageNamed:@"42-photos.png"];
    tapReceiver.contentMode = UIViewContentModeCenter;
    [posterView addSubview: [tapReceiver autorelease]];
    
    [posterView onTapOpen: _.join(@"/movies/images?movie_id=", self.movie_id) ];
  }
}

- (CGFloat)wantsHeight
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 17;
  CGFloat heightByImage = 140;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end

@interface MovieShortActionsCell: MovieShortInfoCell
@end

@implementation MovieShortActionsCell

-(void)addMediaActionToActions: (NSMutableArray*)actions
{
  NSDictionary* movie = self.movie;
  
  // Trailer? We always show the trailer link even if the app is not reachable.
  NSDictionary* videos = [movie objectForKey: @"videos"];
  if(videos.count) {
    [actions addObject: _.array(@"Trailer", _.join(@"/movies/trailer?movie_id=", self.movie_id))];
    return;
  }

  // No trailer, but reachable and images?
  NSArray* thumbnails = [movie objectForKey:@"thumbnails"];
  if([app currentReachability] && thumbnails.first)
    [actions addObject: _.array(@"Bilder", _.join(@"/movies/images?movie_id=", self.movie_id))];
}

-(NSArray*)actions
{
  NSMutableArray* actions = [NSMutableArray array];
  
  [self addMediaActionToActions: actions];
  [actions addObject: _.array(@"Mehr...", _.join(@"/movies/show?movie_id=", self.movie_id))];
  
  return actions;
}

-(void)setKey:(id)key
{
  [super setKey:key];
  
  // build buttons
  NSArray* buttons = [self.actions mapUsingBlock:^id(NSArray* action) {
    return [UIButton actionButtonWithURL:action.second andTitle:action.first];
  }];

  [UIButton layoutButtons:buttons withWidth: 90 andSpace: 10 andOffset:107];

  CGRect posterFrame = self.posterView.frame;
  
  int y = posterFrame.origin.y + posterFrame.size.height - 44;
  for(UIButton* button in buttons) {
    CGRect frame = button.frame;
    frame.origin.y = y;
    button.frame = frame;
    
    [self addSubview:button];
  }
}

@end


@interface MovieActionsCell: MovieShortActionsCell
@end

@implementation MovieActionsCell

-(NSString*) imdbURLForTitle: (NSString*)title
{
  NSString* imdbURL = _.join(@"imdb:///find?q=", title.urlEscape);
  if([app canOpen:imdbURL]) return imdbURL;
  
  return _.join(@"http://imdb.de/?q=", title.urlEscape);
}

-(NSArray*)actions
{
  NSMutableArray* actions = [NSMutableArray array];
  
  [self addMediaActionToActions: actions];
  
  NSString* title = [self.movie objectForKey:@"title"];
  [actions addObject: _.array(@"IMDB", [self imdbURLForTitle: title])];
  
  return actions;
}

@end

/* === MovieDescriptionCell: full movie description ============================= */

@interface MovieInfoHTMLCell: MovieInfoCell {
  TTTAttributedLabel* htmlView;
}
@end

@implementation MovieInfoHTMLCell

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

-(NSString*)markup
{
  return @"<p>Dummy Markup</p>";
}

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  
  self.textLabel.text = @" ";
  
  htmlView.numberOfLines = 0;
  NSString* markup = [self markup];
  if(!markup) markup = @"";
  htmlView.text = [NSAttributedString attributedStringWithMarkup: markup
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
  if(![self markup]) return 0;
  return [self htmlViewSize].height + 15; 
}

@end

@interface MovieDescriptionCell: MovieInfoHTMLCell
@end

@implementation MovieDescriptionCell

-(NSString*)markup
{
  NSString* description = [self.movie objectForKey:@"description"];
  return _.join(@"<p><b>Beschreibung: </b>", description.cdata, @"</p><br />");
}

@end

@interface MoviePersonsCell: MovieInfoHTMLCell
@end

@implementation MoviePersonsCell

-(NSString*)markup
{
  NSArray* actors =           [self.movie objectForKey:@"actors"];
  NSArray* directors =        [self.movie objectForKey:@"directors"];

  if(!actors.count && !directors.count) return nil;
  
  NSMutableArray* parts = [NSMutableArray array];
  
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
@end
