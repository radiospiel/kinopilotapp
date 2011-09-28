#import "M3.h"

@implementation M3 (FileNames)

+ (NSString*) dirname: (NSString*) path {
    return [path gsub_: @"(.*)/[^/]+$" with: @"$1"];
}

+ (NSString*) basename: (NSString*) path {
    return [path gsub_: @".*/([^/]+)$" with: @"$1"];
}

+ (NSString*) basename_wo_ext: (NSString*) path {
  NSString* basename = [self basename: path];
  return [basename gsub_: @"\\.([^\\.]*)$" with: @""];
}

+ (NSString*) symbolicDir: (NSString*)name
{
  if(![name startsWith: @"$"]) return name;

  if([name isEqualToString: @"$cache"])
  {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
  }
  
  if([name isEqualToString: @"$tmp"])
    return NSTemporaryDirectory();

  if([name isEqualToString: @"$documents"]) 
  {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
  }

  if([name isEqualToString: @"$root"]) 
    return [ self dirname: [ self symbolicDir: @"$documents" ] ];

  if([name isEqualToString: @"$app"]) {
    NSString* documentsDirectory = [ self dirname: [ self symbolicDir: @"$documents" ] ];
    
    NSArray* matchingDirectory = [ NSArray arrayWithFilesMatchingPattern: @"*.app" inDirectory: documentsDirectory ];
    if([matchingDirectory count] == 1)
      return [matchingDirectory objectAtIndex: 0];

    dlog << "Matching '$app' directories: " << matchingDirectory;
  } 

  _.raise(@"*** Unknown key'", name, "'");

// TODO: define $app
//  if([name isEqualToString: @"$app"])
//    return [ NSString stringWithFormat: @"%@/m2.app", [ Dir root ] ];

  return nil;
}

+(NSString*) expandPath: (NSString*) path {
  path = [path stringByExpandingTildeInPath]; 
  NSString* firstPart = [path gsub_: @"/.*" with: @""];
  NSString* symbolicDir = [ self symbolicDir: firstPart ];
  if(symbolicDir) {
    return [path gsub_: @"^[^/]+" with: symbolicDir ];
  }
  return path;
}

@end
