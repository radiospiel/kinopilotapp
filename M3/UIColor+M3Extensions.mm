#import "M3.h"

#if TARGET_OS_IPHONE 

static float px(NSString* name, int startPos, int length)
{
  NSString* hexString = [name substringWithRange:NSMakeRange(startPos, length)];
  
  unsigned int number;  
  [[NSScanner scannerWithString:hexString] scanHexInt: &number];  
  return number / (length == 1 ? 15.0f : 255.0f); 
}

@implementation UIColor(M3Extensions)

+ (UIColor *)colorWithName:(NSString*)name
{
  name = [name stringByReplacingOccurrencesOfString:@"#" withString:@""];
  
  float r,g,b,a = 1.0;
  switch(name.length) {
  case 3:
    r = px(name, 0, 1);
    g = px(name, 1, 1);
    b = px(name, 2, 1);
    break;
    case 6: case 8:
    r = px(name, 0, 2);
    g = px(name, 2, 2);
    b = px(name, 4, 2);
    if(name.length == 8) a = px(name, 6, 2);
    break;
  };
  
  return [UIColor colorWithRed:r green: g blue: b alpha: a];
}

@end

#endif
