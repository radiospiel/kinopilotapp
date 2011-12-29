/*
 * see http://docs.brightcove.com/en/iphone-sdk/
 */

#define BRIGHTCOVE_API_KEY @"QeK_7QLEYC-Q4eh-ulEVLfonGwsQhAZlqSaXoUiyYVHfIwheZpv70A.."

#import "M3AppDelegate.h"

#import "BCMediaAPI.h"
#import "BCMoviePlayerController.h"

// #import "UIViewController+M3Extensions.h"

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

  self.player = [[[BCMoviePlayerController alloc]init] autorelease];
  // limit bitrates??
  //
  // [self.player searchForRenditionsBetweenLowBitRate:[NSNumber numberWithInt:100000] 
  //                             andHighBitRate:[NSNumber numberWithInt:500000]
  // ];
  
  
  return self;
}

-(void)dealloc
{
  self.player = nil;
  [super dealloc];
}

-(void)perform {
  MPMoviePlayerController* moviePlayer = self.player;

  // Register to receive a notification when the movie has finished playing.  
  [[NSNotificationCenter defaultCenter] addObserver:self  
                                           selector:@selector(moviePlayBackDidFinish:)  
                                               name:MPMoviePlayerPlaybackDidFinishNotification  
                                             object:moviePlayer];  

  [app.topMostController presentModalViewController: self animated:NO];
  
  moviePlayer.controlStyle = MPMovieControlStyleFullscreen;  
  moviePlayer.shouldAutoplay = YES;
  [app.window  addSubview:moviePlayer.view];  
  [moviePlayer setFullscreen:YES animated:YES];
}

-(void)moviePlayBackDidFinish:(NSNotification*)notification
{
  MPMoviePlayerController *moviePlayer = [notification object];  
  [[NSNotificationCenter defaultCenter] removeObserver:self  
                                                  name:MPMoviePlayerPlaybackDidFinishNotification  
                                                object:moviePlayer];    
  
  [self dismissModalViewControllerAnimated:YES];
  self.player = nil;
}

-(void)reloadURL
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"] ;
  
  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  NSDictionary* videos = [movie objectForKey: @"videos"];
  NSDictionary* video = [videos objectForKey: @"video" ];
  
  NSNumber* brightcove_id = [video objectForKey: @"brightcove-id"];
  
  NSError* err = 0;  
  
  // --- set video --------------
  
  BCVideo *bc_video = [bc findVideoById: [brightcove_id longLongValue] error: &err];
  if (!bc_video) {
    NSString *errStr = [bc getErrorsAsString: err];
    dlog << "Cannot load video #" << brightcove_id << ": " << errStr;
    return;
  }
    
  [self.player setContentURL: bc_video];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

@end
