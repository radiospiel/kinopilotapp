#if TARGET_OS_IPHONE 

#import "M3.h"

//
// Enable sencha.io support? sencha.io delivers images in just the right size. This reduces 
// memory usage on the device, but increases the time needed to fetch all the images.
//
// For more on sencha.io see http://www.sencha.com/learn/how-to-use-src-sencha-io/
//

#define USE_SENCHA_IO 0

@implementation UIImage(M3Extensions)

-(NSString*) inspects
{
  return [NSString stringWithFormat: @"<NSImage %dx%d>", (int)self.size.width, (int)self.size.height];
}

@end

@implementation UIImageView(Http)

-(NSString*)imageURL;
{
  return [self instance_variable_get: @selector(imageURL)];
}

-(void)setImage: (UIImage*)image fromURL: (NSString*)url 
{
  self.image = image;
  [self instance_variable_set: @selector(imageURL) withValue:url];
}

-(void)setImageWithAnimation: (UIImage*)image fromURL: (NSString*)url 
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
                   }];
  
  [self instance_variable_set: @selector(imageURL) withValue:url];
}

-(void)setImageURL: (NSString*)url;
{
  if(!url) return;

#if USE_SENCHA_IO
  int width = self.frame.size.width;
  int height = self.frame.size.height;
  if(width > 0 && height > 0) {
    // TODO: add proper support for shards
    NSString* shard = @"";
    url = [NSString stringWithFormat: @"http://src%@.sencha.io/%d/%d/%@", shard, width, height, url];
  }
#endif
  
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
