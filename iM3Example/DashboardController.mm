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
#define BUTTON_HEIGHT   135
#define BUTTON_PADDING  8

/*** VicinityShowController cells *******************************************/

@interface DashboardInfoCell: M3TableViewCell {
}

@property (nonatomic,retain) NSArray* keys;

@end

@implementation DashboardInfoCell

@synthesize keys;

static NSDictionary *titlesByKey, *urlsByKey;

+(void)initialize
{
  titlesByKey = [_.hash(@"city",     @"Berlin",
                       @"theaters", @"Kinos",
                       @"movies",   @"Filme",
                       @"about",    @"",
                       @"vicinity", @"Was läuft jetzt?!")retain];
  
  urlsByKey = [_.hash( @"city",     @"/map/show",
                      @"theaters", @"/theaters/list",
                      @"movies",   @"/movies/list",
                      @"about",    @"/info",
                      @"vicinity", @"/vicinity")retain];
}

+(CGFloat)fixedHeight
{
  return 143;
}

-(UIImage*)tileImageWithTile: (NSString*)tile
{
  NSString* imageName = [ NSString stringWithFormat: @"Dashboard.bundle/background/%@.png", tile ];
  return [UIImage imageNamed: imageName ];
}

-(UIImage*)backgroundImageWithKey: (NSString*)key
{
  UIImage* image = [self tileImageWithTile: key];
  if(!image) {
    image = [self tileImageWithTile: @"narrow"];
    image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:0];
  }
  return image;
}

// set title, adjust button size

-(UIButton*) dashboardButtonWithKey: (NSString*)key 
{
  UIButton* btn = [UIButton buttonWithType: UIButtonTypeCustom];
  
  // --- set background images, colors and font.
  
  UIImage* backgroundImage = [self backgroundImageWithKey: key];
  [btn setBackgroundImage: backgroundImage forState: UIControlStateNormal];
  
  btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26];

  // --- set URL and title

  btn.actionURL = [urlsByKey objectForKey: key];
  [btn setTitle: [titlesByKey objectForKey: key] forState:UIControlStateNormal];

  // --- adjust button size
  
  int buttonWidth = self.keys.count > 1 ? BUTTON_WIDTH :
                                          BUTTON_PADDING + 2 * BUTTON_WIDTH;
  int buttonHeight = MAX(BUTTON_HEIGHT, backgroundImage.size.height);
  btn.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);

  // --- make the buttons content appear in the top-left
  [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
  [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
  
  btn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
  
  // --- move text 10 pixels down and right
  [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 6, 10)];

  return btn;
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

-(UIView*)valueViewForKey: (NSString*) key
{
  NSString* value = [[self calculateValueForKey: key] description];
  if(!value) return nil;
  
  UILabel* label = [[[UILabel alloc]init]autorelease];
  label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:56];
  label.text = value;
  label.textColor = [UIColor whiteColor];
  label.backgroundColor = [UIColor clearColor];
  
  return label;
}

-(void)setKey: (NSString*)key
{
  if(!key) return;

  // The key is either a single key string of a string consisting of 
  // key components joined by "/"
  self.keys = [key componentsSeparatedByString:@"/"];

  [self.keys enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
    UIButton* button = [self dashboardButtonWithKey:key];
    
    CGRect frame = button.frame;
    frame.origin.x = idx * (BUTTON_PADDING + BUTTON_WIDTH);
    frame.origin.y = 0;
    button.frame = frame;
    
    [self addSubview:button];

    // add a value view, if needed.
    
    UIView* valueView = [self valueViewForKey: key];
    if(!valueView) return;
    
    [valueView sizeToFit];
    CGRect valueFrame = valueView.frame;
    valueFrame.origin.x = frame.size.width - 10 - valueFrame.size.width;
    valueFrame.origin.y = 0; // frame.size.height - 36 - valueFrame.size.height;
    valueView.frame = valueFrame;
    
    [button addSubview: valueView];
  }];
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

@end

@implementation DashboardMoviesCell

@synthesize rotator;

-(id)init
{
  self = [super init];
  if(!self) return nil;
  
  return self;
}

-(void)unrotate
{
  self.rotator.delegate = nil;
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
  
  self.rotator = [M3Rotator rotatorWithFrame: CGRectMake(10, 10, BUTTON_WIDTH - 20, 120)];
  self.rotator.delegate = self;
  [self addSubview:self.rotator];
  [self.rotator start];
}

- (NSUInteger)numberOfViewsInRotator: (M3Rotator*)rotator
{
  return [[app.sqliteDB ask: @"SELECT COUNT(*) FROM movies"] to_i];
}

-(NSDictionary*)movieAtIndex: (NSUInteger)index;
{
  return [app.sqliteDB first: @"SELECT movies.* FROM movies INNER JOIN images ON images._id=movies.image LIMIT 1 OFFSET ?", 
                              [NSNumber numberWithInt: index]];
}

- (void)rotator:(M3Rotator*)rotator activatedIndex:(NSUInteger)index
{
  NSDictionary* movie = [self movieAtIndex: index];
  if(!movie) return;
  
  NSString* url = _.join("/movies/show?movie_id=", [movie objectForKey: @"_id"]);
  [app open: url];
}

- (UIView *)rotator:(M3Rotator*)rotator viewForItemAtIndex:(NSUInteger)index
{
  NSDictionary* movie = [self movieAtIndex: index];

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
  { return 5; }

@end

#import "M3TableViewAdCell.h"

@interface DashboardAdCell: M3TableViewAdCell
@end

@implementation DashboardAdCell

-(CGFloat)wantsHeight
{
  CGFloat wantsHeight = [super wantsHeight];
  return wantsHeight > 0 ? wantsHeight + BUTTON_PADDING : 0;
}

@end

/*** The datasource for MoviesList *******************************************/

@interface DashboardDataSource: M3TableViewDataSource 
@end

@implementation DashboardDataSource

-(id)init
{
  self = [super init];
  [self addSection: _.array(@"DashboardVSpacer",
                            @"city/theaters", 
                            @"DashboardAdCell",
                            @"movies", @"about/vicinity") 
       withOptions: nil];

  return self;
}

-(id)cellClassForKey:(NSString*)key
{ 
  M3AssertKindOf(key, NSString);
  
  if([key isEqualToString:@"M3TableViewAdCell"]) return @"M3TableViewAdCell";
  if([key isEqualToString:@"DashboardAdCell"]) return @"DashboardAdCell";
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

-(void)reload
{
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.scrollEnabled = NO;
  
  self.dataSource = [[[DashboardDataSource alloc]init]autorelease];
}

-(BOOL)isFullscreen
{
  return YES;
}
@end
