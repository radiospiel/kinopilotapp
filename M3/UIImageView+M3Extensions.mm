/**
 * The rotation interval
 */
#define ROTATION_INTERVAL 2.5

#if TARGET_OS_IPHONE 

#import "M3.h"

@implementation UIImageView(M3Extensions)

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
  url = [M3 imageURL:url forSize: self.frame.size];
  
  [[UIImage cachedImagesWithURL]buildAsync:url
                                  withCallback:^(UIImage* image, BOOL didExist) {
                                    block(image, didExist != NO);
                                  }];
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
  
  CGRect frame = self.frame;
  
  overlay.contentMode = UIViewContentModeScaleAspectFill;
  overlay.clipsToBounds = YES;

  // Initial setting.
  overlay.frame = CGRectMake(frame.origin.x + frame.size.width,   frame.origin.y,
                             0,                                   frame.size.height);
  overlay.alpha = 0.0;
  
  // start animation
  
  [UIView animateWithDuration:0.3
                   animations:^{ 
                     overlay.frame = CGRectMake(frame.origin.x,   frame.origin.y,
                                                frame.size.width, frame.size.height);
  
                     overlay.alpha = 1.0; 
                   }
                   completion:^(BOOL finished){
                     self.image = overlay.image;
                     [overlay removeFromSuperview];
                     [overlay release];
                   }];
}

-(void)addImageToRotation: (UIImage*)image
{
  if(!image) return;
  
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
