//
//  M3Inflector.h
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
// #import "M3AppDelegate.h"

#define URL_TEMPLATE @"http://imgio.kinopilotapp.de/jpg/60/th/{{width}}x{{height}}/{{url}}"

/**
 * Enable sencha.io support? sencha.io delivers images in just the right size. This reduces 
 * memory usage on the device, but increases the time needed to fetch all the images.
 *
 * For more on sencha.io see http://www.sencha.com/learn/how-to-use-src-sencha-io/
 *
 * An example sencha URL template is
 *
 * #define URL_TEMPLATE @"http://src.sencha.io/jpg70/{{width}}/{{height}}/{{url}}"
 */

@implementation M3(Image)

/**
 * converts the source image URL into the image URL to actually fetch the image
 */

+(NSString*)imageURL: (NSString*) url forSize: (CGSize)size
{
#ifndef URL_TEMPLATE
  return url;
#else
  int w = size.width, h = size.height;
  if(!w || !h) return url;
  
#if TARGET_OS_IPHONE
  if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    w = w * [UIScreen mainScreen].scale; 
    h = h * [UIScreen mainScreen].scale;
  }
#endif
  
  return [M3 interpolateString: URL_TEMPLATE
                    withValues: _.hash(@"width", w, @"height", h, @"url", url)];
#endif
}
@end
