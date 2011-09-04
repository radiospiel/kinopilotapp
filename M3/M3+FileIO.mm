#import "M3.h"
#import "Underscore.hh"
// #import "Additions.h"

@implementation M3 (FileIO)

+ (NSData*) readDataFromPath: (NSString*) path {

  NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath: path ];
  NSData* contents = [handle readDataToEndOfFile];
  if (!contents) {
//    NSString *curDir = [[NSFileManager defaultManager] currentDirectoryPath];
//    NSLog(@"I am in %@", curDir);

    _.raise("Cannot read from", path);  
  }
  
  return contents;
}

+(NSString*) read: (NSString*) path
{
  NSLog(@"********* read: %@", path);
  
  NSString* r = [[NSString alloc] initWithData: [ self readDataFromPath: path ] 
                                      encoding: NSUTF8StringEncoding];

  return [r autorelease];
}


+ (void) writeData: (NSData*) data toPath: (NSString*) path {
  path = [ self expandPath: path ];
  [ M3 mkdir_p: [ M3 dirname: path ] ];
  
  NSFileManager* fileManager = [NSFileManager defaultManager];
  
  BOOL fSuccess = [ fileManager createFileAtPath: path
                                        contents: data
                                      attributes: nil ];
  
  if(!fSuccess)
    _.raise("Cannot write to", path);
}

+(void) write: (NSString*)string toPath: (NSString*) path 
{
  [ self writeData: [string dataUsingEncoding:NSUTF8StringEncoding] 
            toPath: path];
}

/*
 * returns true if the file at \a path exists.
 */
+(BOOL) exists: (NSString*) path 
{
  return YES;
}


+(NSString*) expandPath: (NSString*) path {
  return [ path stringByExpandingTildeInPath]; 
}

// TODO: raise exception on error.

+(void) mkdir_p: (NSString*) dir {

  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath: dir] == NO) 
    [fileManager createDirectoryAtPath:dir 
           withIntermediateDirectories:YES 
                            attributes:nil
                                 error:nil];
}


@end

