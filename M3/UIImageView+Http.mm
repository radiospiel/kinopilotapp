#if TARGET_OS_IPHONE 

#import "M3.h"

@implementation UIImageView(Http)

-(NSString*)imageURL;
{
  return [self instance_variable_get: @selector(imageURL)];
}

-(void)setImage: (UIImage*)image fromURL: (NSString*)url 
{
  @synchronized(self) {
    self.image = image;
    [self instance_variable_set: @selector(imageURL) withValue:url];
  }
}

-(void)setImageWithAnimation: (UIImage*)image fromURL: (NSString*)url 
{
  @synchronized(self) {
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
                     }];

    [self instance_variable_set: @selector(imageURL) withValue:url];
  }
}

-(void)setImageURL: (NSString*)url;
{
  if(!url || [url isEqualToString: self.imageURL]) return;

  NSString* cachePath = _.join("$cache/", [M3 md5: url], ".bin");

  if([M3 fileExists: cachePath]) {          // read image from file, if it exists
    NSData *data = [M3 readDataFromPath: cachePath];
    [self setImage: [UIImage imageWithData:data] fromURL: url];
  }
  else {                                    // read image from URL in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData* data = [M3Http requestData: @"GET" 
                                     url: url
                             withOptions: nil];
      if(!data) return;
                           
      UIImage* image = [UIImage imageWithData:data];
      if(!image) return;

      [M3 writeData: data toPath: cachePath];
                                   
      dispatch_async(dispatch_get_main_queue(), ^{
        [self setImageWithAnimation: image fromURL: url];
      });
    });
  }
}

@end

#endif
