/**
 * Enable sencha.io support? sencha.io delivers images in just the right size. This reduces 
 * memory usage on the device, but increases the time needed to fetch all the images.
 *
 * For more on sencha.io see http://www.sencha.com/learn/how-to-use-src-sencha-io/
 */
#define USE_SENCHA_IO 0

/**
 * The rotation interval
 */
#define ROTATION_INTERVAL 2.5


#if TARGET_OS_IPHONE 

#import "M3.h"

@implementation UIImageView(M3Extensions)

/**
 * converts the image URL into the image URL, where the image will be fetched.
 */

-(NSString*)sourceImageURL: (NSString*)url
{
#if USE_SENCHA_IO
  int width = self.frame.size.width;
  int height = self.frame.size.height;
  if(width > 0 && height > 0) {
    // TODO: add proper support for shards
    NSString* shard = @"";
    url = [NSString stringWithFormat: @"http://src%@.sencha.io/%d/%d/%@", shard, width, height, url];
  }
#endif

  return url;
}

#pragma mark - Image loading via HTTP

-(NSString*)imageURL
{
  return [self instance_variable_get: @selector(imageURL)];
}

-(void)setImageWithAnimation: (UIImage*)image
{
  // Add the image on top of the current image
  UIImageView *overlay = [[UIImageView alloc] initWithImage:image];
  
  [self.superview addSubview: overlay];
  overlay.frame = self.frame;
  overlay.alpha = 0.0; // initially hide the image
  
  [UIView animateWithDuration:0.2
                   animations:^{ overlay.alpha = 1.0; }
                   completion:^(BOOL finished){
                     self.image = overlay.image;
                     [overlay removeFromSuperview];
                     [overlay release];
                   }];
}

-(void)loadImageFromURL:(NSString*)url andExecute: (void (^)(UIImage* image, BOOL backgrounded))block
{
  url = [self sourceImageURL: url];

  NSString* cachePath = _.join("$cache/", [M3 md5: url], ".bin");
  
  if([M3 fileExists: cachePath]) {
    NSData *data = [M3 readDataFromPath: cachePath];
    UIImage * image = [UIImage imageWithData:data];
    block(image, NO);
    return;
  }
  
  // read image from URL in background
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData* data = [M3Http requestData: @"GET" 
                                   url: url
                           withOptions: nil];
    if(!data) return;
    
    UIImage* image = [UIImage imageWithData:data];
    if(!image) return;
    
    [M3 writeData: data toPath: cachePath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      block(image, YES);
    });
  });
}

// -(void)loadImageInBackground: ^(NSImage* image)
-(void)setImageURL: (NSString*)url
{
  if(!url) return;

  [self loadImageFromURL:url andExecute:^(UIImage *image, BOOL backgrounded) {
    if(backgrounded)
      [self setImageWithAnimation: image];
    else
      [self setImage: image];
    
    [self instance_variable_set: @selector(imageURL) withValue:url];
  }];
}

#pragma mark - Image rotation

-(NSTimer*)rotationTimer_
{
  NSTimer* timer = [NSTimer timerWithTimeInterval: ROTATION_INTERVAL
                                           target: self
                                         selector: @selector(rotateImage)
                                         userInfo: nil
                                          repeats: YES];

  [[NSRunLoop mainRunLoop] addTimer:timer 
                            forMode:NSDefaultRunLoopMode];
  
  return timer;
}

-(NSTimer*)rotationTimer
{
  return [self memoized:@selector(rotationTimer) usingSelector:@selector(rotationTimer_)];
}

-(void)rotateImage
{
  NSArray* animationImages = [NSMutableArray arrayWithArray:self.animationImages];
  if(animationImages.count == 0) return;
  
  NSNumber* rotationIndex = [self instance_variable_get:@selector(rotationIndex)];
  int rotationNo = [rotationIndex intValue] + 1;
  
  [self instance_variable_set: @selector(rotationIndex) 
                    withValue: [NSNumber numberWithInt:rotationNo]];

  UIImage* image = [animationImages objectAtIndex: rotationNo % animationImages.count];
  
  
  // Add the image on top of the current image
  UIImageView *overlay = [[UIImageView alloc] initWithImage:image];
    
  [self.superview addSubview: overlay];
  
  overlay.frame = self.frame;
  overlay.contentMode = UIViewContentModeScaleAspectFill;
  overlay.clipsToBounds = YES;

  overlay.alpha = 0.0; // initially hide the image
    
  [UIView animateWithDuration:0.2
                   animations:^{ overlay.alpha = 1.0; }
                   completion:^(BOOL finished){
                     self.image = overlay.image;
                     [overlay removeFromSuperview];
                     [overlay release];
                   }];
}

-(void)addImageToRotation: (UIImage*)image
{
  // If needed initialise rotationTimer.
  [self rotationTimer];

  NSMutableArray* animationImages = [NSMutableArray arrayWithArray:self.animationImages];
  [animationImages addObject: image];

  self.animationImages = animationImages;
}

-(void)addImageURLToRotation: (NSString*)url
{
  if(!url) return;
  
  [self loadImageFromURL:url andExecute:^(UIImage *image, BOOL backgrounded) {
    [self addImageToRotation:image];
  }];
}

@end
#endif
