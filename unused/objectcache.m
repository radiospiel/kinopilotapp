@interface M3ImageCache {
  NSMutableDictionary* images_;
}

-(NSData*)dataForURL:(NSString*)url;

-(void)imageForURL:(NSString*)url;
-(void)imageFromFile:(NSString*)path;

@end

@implementation M3ImageCache

-(id)init
{
  self = [super init];
  if(self) {
    images_ = [[NSMutableDictionary alloc]init];
  }
  
  return self;
}

-(void)dealloc
{
  [images_ release];

  [super dealloc];
}

//
// This puts the image into the cache. If the cache already contains 
// an image for this url, this method RELEASES THE PASSED IN IMAGE
// and returns a retained copy of the image in the cache.

-(UIImage*)addCacheImage: (UIImage*)image forURL:(NSString*)url
{
    // If we have an image in the cache release the passed in image and
    // return a retained copy of the image in the cache.
    MAZeroingWeakRef* imageRef = [images_ objectForKey: url];
    if(imageRef) {
      if([imageRef target]) return [imageRef target];
    }

    // Image is not yet in the cache. Add it.
    if(image) {
      imageRef = [MAZeroingWeakRef refWithTarget: image];
    }
     return;
    
    }
    UIImage* img = [self newCachedImageForURL:url];
    if(img) {
      [image release];
      return img;
    }

    MAZeroingWeakRef* imageRef = cachedImage = [images_ objectForKey: url];
    if(imageRef && [imageRef target])
      return [[imageRef target]retain];

    return nil;

    MAZeroingWeakRef* imageRef = cachedImage = [images_ objectForKey: url];
    if(imageRef && [imageRef target])
      return [[imageRef target]retain];

    return nil;
}

-(UIImage*)imageForURL:(NSString*)url;
{
  // Is the image already loaded and in-memory?
  MAZeroingWeakRef* imageRef = cachedImage = [images_ objectForKey: url];
  if(imageRef && [imageRef target])
    return [imageRef target];

  // Is the image downloaded? Load it from disk.
  NSString* cachePath = _.join("$cache/", [M3 md5: url], ".jpeg");
  if([M3 fileExists: cachePath]) {
    NSData *data = [M3 readDataFromPath: cachePath];
    UIImage* image = [UIImage imageWithData:data];
    
    imageRef = [MAZeroingWeakRef refWithTarget: image];
    [images_ setObject: imageRef forKey: url];
    
    // call block
    block(image, NO);
    return;
  }
  
  // read image from URL in background
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData* data = [M3Http requestData: @"GET" 
                                   url: url
                           withOptions: nil];
    if(!data) return;

    [M3 writeData: data toPath: cachePath];
    
    UIImage* image = [UIImage imageWithData:data];
    if(!image) return;

    dispatch_async(dispatch_get_main_queue(), ^{
      block(image, YES);
    });
  });
}

url = [self sourceImageURL: url];



@end

