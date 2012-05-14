#import "AppBase.h"

#import "MoviesShowController.h"
#import "TheatersListController.h"

/* === MovieInfoCells: a base class which returns the movie object ============== */

@interface MovieInfoCell: M3TableViewCell

@property (nonatomic,retain) NSDictionary* movie;
@property (nonatomic,readonly) NSString* movie_id;

@property (nonatomic,readonly) NSString* imdbURL;
@property (nonatomic,readonly) NSString* trailerURL;
@property (nonatomic,readonly) NSString* youtubeURL;

@end

@implementation MovieInfoCell

@synthesize movie;

-(void)setKey: (id)key
{
  self.movie = [app.sqliteDB.movies get: key];
  [super setKey: key];
}

-(NSString*)movie_id
{ 
  return [self.movie objectForKey: @"_id"];
}

-(NSString*) imdbURL
{
  NSString* title = [self.movie objectForKey:@"title"];
  if(!title) return nil;

  NSString* imdb_id = [[self.movie objectForKey:@"imdb_id"] description];
  
  if([app canOpen:@"imdb:///test"]) {
    if(imdb_id)
      return _.join(@"imdb:///title/", imdb_id, @"/");
    else
      return _.join(@"imdb:///find?q=", title.urlEscape);
  }

  if(imdb_id)
    return _.join(@"http://www.imdb.de/title/", imdb_id, "/");
  else
    return _.join(@"http://www.imdb.de/?q=", title.urlEscape);
}


-(NSString*)trailerURL
{  
  id videos = [self.movie objectForKey: @"videos"];
  if([videos isKindOfClass: [NSDictionary class]]) {
    return _.join(@"/movies/trailer?movie_id=", self.movie_id);
  }
  
  if([videos isKindOfClass: [NSArray class]]) {
    return [videos first];
  }
  
  return nil;
}

-(NSString*)youtubeURL
{  
  NSString* trailerURL = self.trailerURL;
  if([trailerURL containsString:@".youtube."]) return trailerURL;
  
  return nil;
}

@end

/* === MovieRatingCell: This cell shows the community rating ==================== */

@interface MovieRatingCell: MovieInfoCell {
  UIImageView* ratingBackground_;
  UIImageView* ratingForeground_;
  UILabel*     ratingLabel_;
}

@property (readonly) int rating;

@end

@implementation MovieRatingCell

-(int)rating
{
  NSNumber* number = [self.movie objectForKey: @"average_community_rating"];
  if(number) return number.to_i;

  number = [self.movie objectForKey: @"rating"];
  if(number) return 10 * [ number floatValue ];

  return 0;
}

-(CGFloat)wantsHeight
{
  return self.rating > 0 ? 44 : 0;
}

-(id)init
{
  self = [super init];

  self.textLabel.text = app.isKinopilot ? @"moviepilot.de Rating" : @"Community-Rating";
  
  if(self) {
    ratingBackground_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unstars.png"]];
    [self addSubview: [ratingBackground_ autorelease]];
    
    ratingForeground_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stars.png"]];
    [self addSubview: [ratingForeground_ autorelease]];
    
    //    ratingLabel_ = [[UILabel alloc]init];
    //    [self addSubview: [ratingLabel_ autorelease]];
    
    self.clipsToBounds = YES;
  }
  return self;
}

-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  // Get rating: this is a number between 0 and 100.
  int rating = self.rating;
  
  ratingBackground_.frame = CGRectMake(190, 13, 96, 16);
  
  // We have 5 stars. Each star is 16 px wide. Between stars there is a 
  // 4 px distance. That means a rating of 
  //  0 .. 20 is mapped onto 0 .. 16
  // 20 .. 40 is mapped into 20 .. 36, 
  // etc.
  //
  int complete_stars = rating / 20;                    // Each complete star is 20px wide.
  int incomplete_star = rating - 20 * complete_stars;  // The incomplete star is in the range 0..19, and maps onto 0..16.
  ratingForeground_.frame = CGRectMake(190, 13, complete_stars * 20 + (incomplete_star * 16 + 10) / 20, 16);
  ratingForeground_.contentMode = UIViewContentModeLeft;
  ratingForeground_.clipsToBounds = YES;

  if(app.isKinopilot) {
    self.url = [self.movie objectForKey:@"url"];         // Link to movie URL.
    if(self.url)
      self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
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

  NSString* currentlyLabel = @"Zur Zeit";
  
  if(app.isFlk) {
    currentlyLabel = @"Läuft";
  }
  
  if(!theater_ids.count) {
    self.textLabel.text = @"Für diesen Film liegen uns keine Vorführungen vor.";
    self.textLabel.font = [UIFont italicSystemFontOfSize:14];
    self.textLabel.textColor = [UIColor colorWithName:@"#999"];
  }
  else {
    NSString* label = nil;
    
    if(theater_ids.count == 1) {
      NSDictionary* theater = [app.sqliteDB.theaters get: theater_ids.first];
      label = [NSString stringWithFormat: @"%@ im %@", currentlyLabel, [theater objectForKey:@"name"]];
    }
    else {
      label = [NSString stringWithFormat: @"%@ in %d Kinos", currentlyLabel, theater_ids.count];
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

  posterView.image = [app thumbnailForMovie: self.movie];

  if(![app currentReachability])
    return;
    
  if([self.movie objectForKey:@"images"] || [self.movie objectForKey:@"image"]) {
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

-(NSArray*)actions
{
  NSMutableArray* actions = [NSMutableArray array];

  if(self.trailerURL) {
    [actions addObject: _.array(@"Trailer", self.trailerURL)];
  }

  [actions addObject: _.array(@"Mehr...", _.join(@"/movies/show?movie_id=", self.movie_id))];

  if(!self.trailerURL) {
    [actions addObject: _.array(@"IMDB", self.imdbURL)];
  }
  
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


// 
// The MovieActionsCell is used in /movies/show. It shows a short overview over
// the movie (as does MovieShortActionsCell), but does not contain a "More"
// link. The order of action buttons could be different also, resulting
// in a different set of displayed buttons.
//
@interface MovieActionsCell: MovieShortActionsCell
@end

@implementation MovieActionsCell

-(NSArray*)actions
{
  NSMutableArray* actions = [NSMutableArray array];

  if(self.trailerURL && !self.youtubeURL) {
    [actions addObject: _.array(@"Trailer", self.trailerURL)];
  }
  
  [actions addObject: _.array(@"IMDB", self.imdbURL)];
  
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

-(void)writeMarkupForFunction: (NSString*)key 
                    withTitle: (NSString*)title
                    intoArray: (NSMutableArray*)parts 

{
  NSArray* persons = [self.movie objectForKey: key];
  if(!persons) return;
  
  NSArray* p = [NSArray arrayWithObjects: 
                @"<b>", 
                title, 
                @":</b> ", 
                [persons.uniq componentsJoinedByString:@", "],
                nil];
    
  [parts addObject: @"<p>"];
  [parts addObject: [p componentsJoinedByString:@""]];
  [parts addObject: @"</p>"];
}

-(NSString*)markup
{
  NSMutableArray* parts = [NSMutableArray array];
  [self writeMarkupForFunction: @"directors" withTitle: @"Regie" intoArray: parts];
  [self writeMarkupForFunction: @"actors" withTitle: @"Darsteller" intoArray: parts];
  [self writeMarkupForFunction: @"writers" withTitle: @"Drehbuch" intoArray: parts];
  
  if(!parts.count) return nil;
  return [parts componentsJoinedByString:@""];
}
@end


// ------------------------------------------------------------------------

@interface MovieTrailerCell: MovieInfoCell {
  UIWebView* trailerWebView;
}

@property (nonatomic,readonly) int videoWidth;
@property (nonatomic,readonly) int videoHeight;

@end

@implementation MovieTrailerCell

-(int)videoWidth
{
  return 320;
}

-(int)videoHeight
{
  return 100;
}

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  
  if(!self.youtubeURL) return;
  
  self.textLabel.text = @" ";

  if(!trailerWebView) {
    trailerWebView = [[UIWebView alloc]initWithFrame: CGRectMake(0, 0, self.videoWidth, self.videoHeight)];
    [self addSubview: trailerWebView];
  }
  
  NSString *html = [M3 interpolateString: [self htmlTemplate] withValues: self]; 
  [trailerWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://nowhere.test"]];
}

-(CGFloat)wantsHeight
{
  return self.youtubeURL ? self.videoHeight : 0;
}

#if TARGET_IPHONE_SIMULATOR

-(NSString*)htmlTemplate
{
  return @"On a real device this should show a youtube video from {{youtubeURL}}";
}

#else

-(NSString*)htmlTemplate
{
  return @"<html>"
          "<head>"
            "<meta name='viewport' content='initial-scale=1.0, user-scalable=no, width={{videoWidth}}'/>"
          "</head>"
          "<body style='background:#F00;margin-top:0px;margin-left:0px'>"
            "<div>"
              "<object width='{{videoWidth}}' height='{{videoHeight}}'>"
                "<param name='movie' value='{{youtubeURL}}'></param> "
                "<param name='wmode' value='transparent'></param> "
                "<embed src='{{youtubeURL}}' "
                  "type='application/x-shockwave-flash' wmode='transparent' width='{{videoWidth}}' height='{{videoHeight}}'></embed>" 
              "</object>"
            "</div>"
          "</body>"
          "</html>";
}

#endif

-(void)layoutSubviews
{
  [super layoutSubviews];
}

@end
