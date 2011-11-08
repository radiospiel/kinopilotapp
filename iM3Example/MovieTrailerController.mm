/*
 * see http://docs.brightcove.com/en/iphone-sdk/
 */

#define BRIGHTCOVE_API_KEY @"ABC"

#import "BCMediaAPI.h"
#import "BCMoviePlayerController.h"

#import "M3.h"
#import "AppDelegate.h"
#import "UIViewController+M3Extensions.h"

@interface MovieTrailerController: UIViewController {
  BCMoviePlayerController* player_;
}

@property (nonatomic,retain) BCMoviePlayerController* player;

@end

@implementation MovieTrailerController

@synthesize player = player_;

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

  self.player = [[BCMoviePlayerController alloc]init];
  
  // [self initWithContentURL: searchForRenditionWithLowBitRate:andHighBitRate:
  return self;
}

-(void)dealloc
{
  self.player = nil;
  [super dealloc];
}

-(unsigned long)brightcove_id
{
  // get movie from url
  NSString* movie_id = [self.url.to_url param: @"movie_id"];
  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  NSDictionary* videos = [movie objectForKey: @"videos"];
  NSDictionary* video = [videos objectForKey: @"video"];
//  NSString* title = [video objectForKey: @"title"];
//  NSString* thumbnail = [video objectForKey: @"thumbnail"];
  DLOG(video);
  NSNumber* brightcove_id = [video objectForKey: @"brightcove_id"];

  return [brightcove_id unsignedLongValue];
}

-(void)loadFromUrl: (NSString*)url
{

  NSError* err = 0;  
  BCVideo *video = [bc findVideoById: [self brightcove_id] error: &err];
  if (!video) {
    NSString *errStr = [bc getErrorsAsString: err];
    NSLog(@"ERROR: %@", errStr);
    return;
  }

  // limit bitrates
  // [self searchForRenditionsBetweenLowBitRate:[NSNumber numberWithInt:100000] 
  //                             andHighBitRate:[NSNumber numberWithInt:500000]
  // ];

  // set video
  [self.player setContentURL: video];

}

-(void)perform
{
  [self.player.view setFrame: CGRectMake(0, 0, 480, 320)];

  [self.view addSubview: self.player.view];
  
  // what does prepare to play do? -- is it needed?
  [self.player prepareToPlay];

  if ([self.player isPreparedToPlay]) {
    NSLog(@"prepared to play");
  }
  else {
    NSLog(@"not prepared to play");
  }
 
  [self.player play];     // start player
}

@end
