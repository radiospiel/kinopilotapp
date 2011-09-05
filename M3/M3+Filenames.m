#import "M3.h"

@implementation M3 (FileNames)

+ (NSString*) dirname: (NSString*) path {
    return [path gsub: @"(.*)/[^/]+$" with: @"$1"];
}

+ (NSString*) basename: (NSString*) path {
    return [path gsub: @".*/([^/]+)$" with: @"$1"];
}

+ (NSString*) basename_wo_ext: (NSString*) path {
  NSString* basename = [self basename: path];
  return [basename gsub: @"\\.([^\\.]*)$" with: @""];
}

@end
