#import <Foundation/Foundation.h>
#import "NSArray+M3Extensions.h"
#include <glob.h>

@implementation NSArray (Globbing)

/* 
 * This is from https://gist.github.com/293959
 * Thanks, bkyle!
 */

+ (NSArray*) arrayWithFilesMatchingPattern: (NSString*) pattern 
                                inDirectory: (NSString*) directory 
{
  NSMutableArray* files = [NSMutableArray array];
  glob_t gt;

  NSString* globPathComponent = [NSString stringWithFormat: @"/%@", pattern];
  NSString* expandedDirectory = [directory stringByExpandingTildeInPath];
  const char* fullPattern = [[expandedDirectory stringByAppendingPathComponent: globPathComponent] UTF8String];
  
  if (glob(fullPattern, 0, NULL, &gt) == 0) {
    NSFileManager* fileman = [NSFileManager defaultManager];
    for (int i=0; i<gt.gl_matchc; i++) {
      size_t len = strlen(gt.gl_pathv[i]);
      NSString* filename = [fileman stringWithFileSystemRepresentation: gt.gl_pathv[i] length: len];
      [files addObject: filename];
    }
  }
  globfree(&gt);
  return [NSArray arrayWithArray: files];
}

@end

@implementation NSArray (M3Extensions)

-(id) first
{
  if(self.count < 1) return nil;
  return [self objectAtIndex: 0];
}

-(id) last
{
  if(self.count < 1) return nil;
  return [self objectAtIndex: (self.count - 1)];
}
                             
@end
