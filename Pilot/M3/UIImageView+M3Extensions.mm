/**
 * The rotation interval
 */

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
  overlay.contentMode = UIViewContentModeScaleAspectFill;
  overlay.clipsToBounds = YES;
  
  [self.superview addSubview: overlay];
  overlay.frame = self.frame;
  overlay.alpha = 0.0; // initially hide the image
  
  [UIView animateWithDuration:0.2
                   animations:^{ overlay.alpha = 1.0; }
                   completion:^(BOOL finished){
                     self.image = overlay.image;
                     self.clipsToBounds = YES;
                     self.contentMode = UIViewContentModeScaleAspectFill;

                     [overlay removeFromSuperview];
                     [overlay release];
                   }];
}

-(void)setImageURL: (NSString*)url
{
  if(!url) {
    [self setImage: [UIImage imageNamed:@"no_poster.png"]];
    return;
  }

  url = [M3 imageURL:url forSize: self.frame.size];

  [[UIImage cachedImagesWithURL]buildAsync:url
                              withCallback:^(UIImage* image, BOOL didExist) {
                                
                                [self instance_variable_set:@selector(imageURL) withValue:url];
                                if(!image) return;
                                
                                if(didExist) {
                                  self.image = image;
                                  self.contentMode = UIViewContentModeScaleAspectFill;
                                  self.clipsToBounds = YES;
                                }
                                else
                                  [self setImageWithAnimation: image];
                              }];
}

@end
#endif
