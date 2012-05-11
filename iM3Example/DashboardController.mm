//
//  DashboardController.m
//  M3
//
//  Created by Enrico Thierbach on 30.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "DashboardController.h"

#import "M3TableViewProfileCell.h"

static NSDictionary* dashboardConfig = nil;

static int button_width = 156;
static int button_height = 130; // 135
static int button_padding = 8;

static void initConstants()
{
  if(app.isFlk) {
    button_height = 128;
  }

  dashboardConfig = [app.config objectForKey: @"dashboard"];
}

/*** VicinityShowController cells *******************************************/

@interface DashboardButton: UIButton {
  UILabel* valueLabel;
  UIImageView* fgImageView;
}

@property (nonatomic,retain) NSString* dashboardKey;
@property (nonatomic,readonly) NSDictionary* config;

-(id)initWithFrame: (CGRect)frame andKey: (NSString*)key;
-(void)setButtonValue: (id)value;

@end

@implementation DashboardButton

@synthesize dashboardKey;

+(UIImage*) dashboardImage: (NSString*)name
{
  NSString* imageName = [NSString stringWithFormat: @"Dashboard/%@.png", name];
  return [app imageNamed: imageName];
}

-(void)setBackgroundImageByKey
{
  if([dashboardKey isEqualToString:@"about"]) return;

  UIImage* image = [DashboardButton dashboardImage:@"background"];
  image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:0];
  [self setBackgroundImage: image forState: UIControlStateNormal];
}

-(void)setForegroundImageByKey
{
  UIImage* image = [DashboardButton dashboardImage: [@"fg/" stringByAppendingString:dashboardKey]];
  if(!image) return;
  
  fgImageView = [[[UIImageView alloc]initWithImage:image]autorelease];
  fgImageView.userInteractionEnabled = NO;
  fgImageView.exclusiveTouch = NO;
  
  CGRect frame = self.frame;
  if(image.size.height > frame.size.height) {
    frame.size.height = image.size.height;
    self.frame = frame; 
  }

  [self addSubview:fgImageView];
}

-(id)initWithFrame: (CGRect)frame andKey: (NSString*)key
{
  self = [super initWithFrame: frame];
  if(!self) return nil;
  
  self.dashboardKey = key;

  [self setBackgroundImageByKey];
  [self setForegroundImageByKey];

  // -- set title
  
  [self setTitle: [self.config objectForKey: @"title"] 
        forState: UIControlStateNormal];
  
  self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26];
  self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 6, 10);
  
  // -- set actionURL

  self.actionURL = [self.config objectForKey: @"actionURL"];
  
  // --- make the buttons content appear in the top-left
  [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
  [self setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
  
  [self layoutSubviews];
  return self;
}

-(NSDictionary*)config
{
  return [dashboardConfig objectForKey: dashboardKey];
}

-(void)dealloc
{
  self.dashboardKey = nil;
  [super dealloc];
}

-(void)layoutFgImageView
{
  NSArray* topaligned_icons = [dashboardConfig objectForKey: @"topaligned-icons"];
  
  BOOL isTopAligned = [topaligned_icons indexOfObject: dashboardKey] != NSNotFound;

  CGRect fgFrame = fgImageView.frame;
  fgFrame.origin.x = 0;
  fgFrame.origin.y = isTopAligned ? 0 : self.frame.size.height - fgImageView.image.size.height;
  fgImageView.frame = fgFrame;
}

-(void)layoutValueLabel
{
  CGRect valueFrame = valueLabel.frame;
  valueFrame.origin.x = self.frame.size.width - 10 - valueFrame.size.width;
  valueFrame.origin.y = 0;
  valueLabel.frame = valueFrame;
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  if(fgImageView) [self layoutFgImageView];
  if(valueLabel)  [self layoutValueLabel];
}

-(void)setButtonValue: (id)value
{
  if(!value) return;
  
  valueLabel = [[UILabel alloc]init];
  valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:56];
  valueLabel.text = [value description];
  valueLabel.textColor = [UIColor whiteColor];
  valueLabel.backgroundColor = [UIColor clearColor];
  [valueLabel sizeToFit];
  
  [self addSubview: valueLabel];
}

@end

@interface DashboardInfoCell: M3TableViewCell
@end

@implementation DashboardInfoCell

+(CGFloat)fixedHeight
{
  return button_height + button_padding;
}

// --- some buttons can have additional values.

-(NSString*)calculateValueForKey: (NSString*) key
{
  NSString* sql = nil;
  
  if([key isEqualToString:@"movies"]) 
    sql = @"SELECT COUNT(DISTINCT movie_id) FROM schedules";
  else if([key isEqualToString:@"theaters"]) 
    sql = @"SELECT COUNT(*) FROM theaters";

  if(!sql) return nil;
  
  return [app.sqliteDB ask: sql, nil];
}

-(void)setKey: (NSString*)key
{
  if(!key) return;

  // The key is either a single key string of a string consisting of 
  // key components joined by "/"
  NSArray* buttonKeys = [key componentsSeparatedByString:@"/"];

  int idx = 0;
  for(NSString* buttonKey in buttonKeys) {
    
    CGRect frame = CGRectMake(idx++ * (button_padding + button_width),                                  0, 
                              buttonKeys.count > 1 ? button_width : button_padding + 2 * button_width,  button_height);
    DashboardButton* button = [[[DashboardButton alloc]initWithFrame: frame andKey:buttonKey]autorelease];
    [self addSubview:button];
    
    id value = [self calculateValueForKey: buttonKey];
    [button setButtonValue: value];
  }
}

@end

/*** The DashboardMoviesCell adds animated teaeser images ********************/

@interface DashboardMoviesTeaserView: UIView

@property (nonatomic,retain) UIImageView* imageView;
@property (nonatomic,retain) UILabel* label;

@end

@implementation DashboardMoviesTeaserView: UIView

@synthesize imageView, label;

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];

  label = [[UILabel alloc]initWithFrame:frame];
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
  label.textAlignment = UITextAlignmentCenter;
  label.lineBreakMode = UILineBreakModeTailTruncation;
  label.numberOfLines = 1;

  imageView = [[UIImageView alloc]initWithFrame:frame];
  imageView.contentMode = UIViewContentModeCenter;

  [self addSubview: self.imageView];
  [self addSubview: self.label];

  return self;
}

-(void)dealloc
{
  self.label = nil;
  self.imageView = nil;
  
  [super dealloc];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  CGRect frame = self.frame;

  self.imageView.frame = CGRectMake(0, 0, frame.size.width, 94); /* our thumbnails are 72x94 */
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  [self.label sizeToFit];
  self.label.frame = CGRectMake(0, 99, frame.size.width, self.label.frame.size.height);
}
@end

/*** The DashboardMoviesCell *****************************************/

@interface DashboardMoviesCell: DashboardInfoCell<M3RotatorDelegate>

@property (nonatomic,retain) M3Rotator* rotator;
@property (nonatomic,retain) NSArray* rotatorMovieIds;
  
@end

@implementation DashboardMoviesCell

@synthesize rotator, rotatorMovieIds;

-(void)unrotate
{
  self.rotator.delegate = nil;
  self.rotatorMovieIds = nil;
  self.rotator = nil;
}

-(void)dealloc
{
  [self unrotate];
  [super dealloc];
}

-(void)setKey: (NSString*)key
{
  [super setKey:key];
  [self unrotate];

  if(!key) return;

  // load movie_ids for current movies w/images
  NSArray* recs = [app.sqliteDB all: @"SELECT DISTINCT(movies._id) FROM movies "
                                      "INNER JOIN images ON images._id=movies.image "
                                      "INNER JOIN schedules ON schedules.movie_id=movies._id "
                                      "WHERE schedules.time > ?",
                                      [NSDate today]];

  self.rotatorMovieIds = [recs pluck: @"_id"];
  
  // create rotator
  self.rotator = [M3Rotator rotatorWithFrame: CGRectMake(10, 7, button_width - 20, button_height - 14)];
  self.rotator.delegate = self;
  [self addSubview:self.rotator];
  [self.rotator start];
}

- (NSUInteger)numberOfViewsInRotator: (M3Rotator*)rotator
{
  return self.rotatorMovieIds.count;
}

-(NSString*)movieIdAtIndex: (NSUInteger)index;
{
  return [self.rotatorMovieIds get:index]; 
}

- (void)rotator:(M3Rotator*)rotator activatedIndex:(NSUInteger)index
{
  NSString* movie_id = [self.rotatorMovieIds get:index];
  if(!movie_id) return;
  
  [app open: _.join("/movies/show?movie_id=", movie_id)];
}

- (UIView *)rotator:(M3Rotator*)rotator viewForItemAtIndex:(NSUInteger)index
{
  NSString* movie_id = [self.rotatorMovieIds get:index];
  if(!movie_id) return nil;

  NSDictionary* movie = [app.sqliteDB first: @"SELECT movies.* FROM movies WHERE _id=?", movie_id ];
  if(!movie) return nil;
  
  DashboardMoviesTeaserView* view = [[DashboardMoviesTeaserView alloc]init];
  view.label.text = [movie objectForKey:@"title"];
  view.imageView.image = [app thumbnailForMovie:movie];

  return [view autorelease];
}

@end

@interface DashboardVSpacer: M3TableViewCell
@end

@implementation DashboardVSpacer

+(CGFloat)fixedHeight
  { return 6; }

@end

/*** The datasource for MoviesList *******************************************/

@interface DashboardDataSource: M3TableViewDataSource 
@end

@implementation DashboardDataSource

+(void)initialize
{
  initConstants();
}

-(id)init
{
  self = [super init];
  NSArray* sections = [dashboardConfig objectForKey: @"sections"];
  M3AssertKindOf(sections, NSArray);
  
  [self addSection: _.array(@"DashboardVSpacer")];
  [self addSection: sections];
  return self;
}

-(id)cellClassForKey:(NSString*)key
{ 
  M3AssertKindOf(key, NSString);
  
  if([key isEqualToString:@"DashboardVSpacer"]) return @"DashboardVSpacer";
  if([key isEqualToString:@"movies"]) return @"DashboardMoviesCell";
  
  return [DashboardInfoCell class];
}

@end

@implementation DashboardController

-(id)init 
{
  self = [super init];
  [app on: @selector(updated) notify:self with:@selector(reload)];
  return self;
}

-(void)setBackgroundView
{
  UIImage* background = [app imageNamed: @"Dashboard/flk_dashboard.png"];
  if(background)
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:background];
}

-(void)reload
{
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.scrollEnabled = NO;

  [self setBackgroundView];
  
  [self requestAdBannerOnTop];
  self.dataSource = [[[DashboardDataSource alloc]init]autorelease];
}

-(BOOL)isFullscreen
{
  return YES;
}
@end
