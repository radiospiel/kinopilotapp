/*
 * see http://docs.brightcove.com/en/iphone-sdk/
 */

#define BRIGHTCOVE_API_KEY @"QeK_7QLEYC-Q4eh-ulEVLfonGwsQhAZlqSaXoUiyYVHfIwheZpv70A.."

#import "BCMediaAPI.h"
#import "BCMoviePlayerController.h"

#import "M3.h"
#import "AppDelegate.h"
#import "UIViewController+M3Extensions.h"

@interface MoviesTrailerController: UIViewController {
  BCMoviePlayerController* player_;
}

@property (nonatomic,retain) BCMoviePlayerController* player;

@end

@implementation MoviesTrailerController

@synthesize player = player_;

/* initialize the BRIGHTCOVE API */
static BCMediaAPI *bc = nil;
+(void)initialize
{
  bc = [[BCMediaAPI alloc] initWithReadToken:BRIGHTCOVE_API_KEY];
  [bc setMediaDeliveryType:BCMediaDeliveryTypeHTTP];
  // [bc setUdsSupportOn:YES];
}

-(id)init
{
  self = [super init];

  return self;
}

-(BCMoviePlayerController*)player
{
  if(player_) return player_;
  
  self.player = [[BCMoviePlayerController alloc]init];

  // limit bitrates??
  //
  // [self.player searchForRenditionsBetweenLowBitRate:[NSNumber numberWithInt:100000] 
  //                             andHighBitRate:[NSNumber numberWithInt:500000]
  // ];

  [self.player.view setFrame: CGRectMake(0, 64, 320, 300)];
  [self.view addSubview: self.player.view];

  return player_;
}

-(void)dealloc
{
  self.player = nil;
  [super dealloc];
}

-(void)reloadURL
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"] ;

  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  NSDictionary* videos = [movie objectForKey: @"videos"];
  NSDictionary* video = [videos objectForKey: @"video" ];

  NSNumber* brightcove_id = [video objectForKey: @"brightcove-id"];
  
  NSError* err = 0;  

  BCVideo *bc_video = [bc findVideoById: [brightcove_id longLongValue] error: &err];
  if (!bc_video) {
    NSString *errStr = [bc getErrorsAsString: err];
    dlog << "Cannot load video #" << brightcove_id << ": " << errStr;
    return;
  }

  dlog << "Loading video " << bc_video;

  // --- set video --------------
  [self.player setContentURL: bc_video];
  [self.player play];     // start player
}

@end
