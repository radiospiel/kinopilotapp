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

#define BUTTON_WIDTH    156
#define BUTTON_HEIGHT   130 // 135
#define BUTTON_PADDING  8

#if APP_FLK
#undef  BUTTON_HEIGHT
#define BUTTON_HEIGHT   128
#endif

/*** VicinityShowController cells *******************************************/

@interface DashboardButton: UIButton {
  UILabel* valueLabel;
  UIImageView* fgImageView;
}

@property (nonatomic,retain) NSString* dashboardKey;

-(id)initWithFrame: (CGRect)frame andKey: (NSString*)key;
-(void)setButtonValue: (id)value;

@end

@implementation DashboardButton

@synthesize dashboardKey;

+(UIImage*) dashboardImage: (NSString*)name
{
  NSString* imageName = [ NSString stringWithFormat: @"Dashboard.bundle/%@.png", name ];
  return [UIImage imageNamed: imageName ];
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

-(void)setTitleByKey
{
  NSString* title = @"";
  
#if APP_FLK
  if([dashboardKey isEqualToString: @"city"])      title = @"Freiluft";
#else
  if([dashboardKey isEqualToString: @"city"])      title = @"Berlin";
#endif

  if([dashboardKey isEqualToString: @"theaters"])  title = @"Kinos";
  if([dashboardKey isEqualToString: @"movies"])    title = @"Filme";
  if([dashboardKey isEqualToString: @"vicinity"])  title = @"Was läuft jetzt?!";
  if([dashboardKey isEqualToString: @"today"])     title = @"Kalender";
  
  [self setTitle: title forState:UIControlStateNormal];

  self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26];
  self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 6, 10);
}

-(void)setActionURLByKey
{
  if([dashboardKey isEqualToString: @"city"])      self.actionURL = @"/map/show";
  if([dashboardKey isEqualToString: @"theaters"])  self.actionURL = @"/theaters/list";
  if([dashboardKey isEqualToString: @"movies"])    self.actionURL = @"/movies/list";
  if([dashboardKey isEqualToString: @"about"])     self.actionURL = @"/info";
  if([dashboardKey isEqualToString: @"vicinity"])  self.actionURL = @"/vicinity";
  if([dashboardKey isEqualToString: @"today"])     self.actionURL = @"/movies/calendar";
}

-(id)initWithFrame: (CGRect)frame andKey: (NSString*)key
{
  self = [super initWithFrame: frame];
  if(!self) return nil;
  
  self.dashboardKey = key;

  [self setBackgroundImageByKey];
  [self setForegroundImageByKey];
  [self setTitleByKey];
  [self setActionURLByKey];
  
  // --- make the buttons content appear in the top-left
  [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
  [self setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
  
  [self layoutSubviews];
  return self;
}

-(void)dealloc
{
  self.dashboardKey = nil;
  
  [super dealloc];
}

-(BOOL)fgIsTopAligned
{
  // if([dashboardKey isEqualToString: @"city"])      return NO;
  // if([dashboardKey isEqualToString: @"theaters"])  return NO;
  // if([dashboardKey isEqualToString: @"movies"])    return NO;
  // if([dashboardKey isEqualToString: @"about"])     return NO;
  if([dashboardKey isEqualToString: @"vicinity"])  return YES;
#if APP_FLK
  if([dashboardKey isEqualToString: @"city"])  return YES;
  if([dashboardKey isEqualToString: @"today"])  return YES;
#endif

  return NO;
}

-(void)layoutFgImageView
{
  CGRect fgFrame = fgImageView.frame;
  if([self fgIsTopAligned])
    fgFrame.origin = CGPointMake(0, 0);
  else
    fgFrame.origin = CGPointMake(0, self.frame.size.height - fgImageView.image.size.height);
  
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
  return BUTTON_HEIGHT + BUTTON_PADDING;
}

// --- some buttons can have additional values.

-(NSString*)calculateValueForKey: (NSString*) key
{
  id value = nil;
  
  if([key isEqualToString:@"movies"]) 
    value = [app.sqliteDB ask: @"SELECT COUNT(DISTINCT movie_id) FROM schedules"];
  else if([key isEqualToString:@"theaters"]) 
    value = [app.sqliteDB ask: @"SELECT COUNT(*) FROM theaters"];
  
  return value;
}

-(void)setKey: (NSString*)key
{
  if(!key) return;

  // The key is either a single key string of a string consisting of 
  // key components joined by "/"
  NSArray* buttonKeys = [key componentsSeparatedByString:@"/"];

  int idx = 0;
  for(NSString* buttonKey in buttonKeys) {
    
    CGRect frame = CGRectMake(idx++ * (BUTTON_PADDING + BUTTON_WIDTH),                                  0, 
                              buttonKeys.count > 1 ? BUTTON_WIDTH : BUTTON_PADDING + 2 * BUTTON_WIDTH,  BUTTON_HEIGHT);
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

-(id)init
{
  self = [super init];
  if(!self) return nil;
  
  return self;
}

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
  self.rotator = [M3Rotator rotatorWithFrame: CGRectMake(10, 7, BUTTON_WIDTH - 20, BUTTON_HEIGHT - 14)];
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


#if APP_FLK
#define SECTIONS @"DashboardVSpacer;city/theaters;movies;about/today"
#else
#define SECTIONS @"DashboardVSpacer;city/theaters;movies;about/vicinity"
#endif

-(id)init
{
  self = [super init];
  [self addSection: [SECTIONS componentsSeparatedByString:@";"]];
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
  if(self) {
    [app on: @selector(updated) notify:self with:@selector(reload)];
  }
  return self;
}

-(void)setBackgroundView
{
  UIImage* background = nil;
#if APP_FLK
  background = [UIImage imageNamed: @"Dashboard.bundle/flk_dashboard.png"];
#endif
  
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
