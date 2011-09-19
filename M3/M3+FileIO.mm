#import "M3.h"
#import "Underscore.hh"
// #import "Additions.h"

@implementation M3 (FileIO)

+ (NSData*) readDataFromPath: (NSString*) path {
  path = [M3 expandPath: path];

  NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath: path];
  NSData* contents = [handle readDataToEndOfFile];
  if (!contents) 
    _.raise("Cannot read from ", path);  
    
  return contents;
}

+(NSString*) read: (NSString*) path
{
  path = [M3 expandPath: path];
  
  NSString* r = [[NSString alloc] initWithData: [self readDataFromPath: path] 
                                      encoding: NSUTF8StringEncoding];

  return [r autorelease];
}


+ (void) writeData: (NSData*) data toPath: (NSString*) path {
  path = [self expandPath: path];
  [M3 mkdir_p: [M3 dirname: path]];
  
  NSFileManager* fileManager = [NSFileManager defaultManager];
  
  BOOL fSuccess = [fileManager createFileAtPath: path
                                        contents: data
                                      attributes: nil];
  
  if(!fSuccess)
    _.raise("Cannot write to", path);
}

+(void) write: (NSString*)string toPath: (NSString*) path 
{
  path = [M3 expandPath: path];

  [self writeData: [string dataUsingEncoding:NSUTF8StringEncoding] 
            toPath: path];
}

/*
 * returns true if the file at \a path exists.
 */
+(BOOL) fileExists: (NSString*) path 
{
  path = [self expandPath: path];
  return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

// TODO: raise exception on error.

+(void) mkdir_p: (NSString*) dir {
  dir = [M3 expandPath: dir];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath: dir] == NO) 
    [fileManager createDirectoryAtPath:dir 
           withIntermediateDirectories:YES 
                            attributes:nil
                                 error:nil];
}


@end

ETest(M3FileIO)
-(void)testExists
{
  assert_true([M3 fileExists: _.string(__FILE__)]);
  assert_false([M3 fileExists: _.join(__FILE__, "i_do_not_exist")]);
}

@end

