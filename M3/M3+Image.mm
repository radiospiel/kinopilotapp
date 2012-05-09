//
//  M3Inflector.h
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
#import "M3AppDelegate.h"

const char* M3SenchaSupportFull = "M3SenchaSupportFull";
const char* M3SenchaSupportLarge = "M3SenchaSupportLarge";

// #define URL_TEMPLATE @"http://src.sencha.io/jpg70/{{width}}/{{height}}/{{url}}"
#define URL_TEMPLATE @"http://imgio.16b.org/jpg/70/fit/{{width}}x{{height}}/{{url}}"


/**
 * Enable sencha.io support? sencha.io delivers images in just the right size. This reduces 
 * memory usage on the device, but increases the time needed to fetch all the images.
 *
 * For more on sencha.io see http://www.sencha.com/learn/how-to-use-src-sencha-io/
 */

@implementation M3(Image)

static const char* enabled_sencha = 0;
static BOOL sencha_retina_display = NO;

/**
 * converts the source image URL into the image URL to actually fetch the image
 */

+(void) enableImageHost: (const char*)name
  scaleForRetinaDisplay: (BOOL)supportingRetinaDisplay;
{
  enabled_sencha = name;
  sencha_retina_display = supportingRetinaDisplay;
}

/**
 * converts the source image URL into the image URL to actually fetch the image
 */

+(NSString*)imageURL: (NSString*) url forSize: (CGSize)size
{
  if(!enabled_sencha) return url;

  int w = size.width, h = size.height;
  if(!w || !h) return url;
  
  // if(enabled_sencha == M3SenchaSupportLarge && (w+h) < 200) return url;
  
#if TARGET_OS_IPHONE

  if(sencha_retina_display && [[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    w = w * [UIScreen mainScreen].scale; 
    h = h * [UIScreen mainScreen].scale;
  }
#endif
  
  return [M3 interpolateString: URL_TEMPLATE
                    withValues: _.hash(@"width", w, @"height", h, @"url", url)];
}
@end
