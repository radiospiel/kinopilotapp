#import "M3.h"

@interface M3(FileIO) 

+(NSData*) readDataFromPath: (NSString*) path;

+(NSString*) read: (NSString*) path;

+(void) writeData: (NSData*) data toPath: (NSString*) path;


/*
 * writes the string \a data to the file \a path. If the file exists, it
 * will be replaced. If the file does not exist, it will be created. If
 * writing fails, a M3Exception exception is raised. 
 */
+(void) write: (NSString*)data toPath: (NSString*) path;

/*
 * returns true if the file at \a path exists.
 */
+(BOOL) fileExists: (NSString*) path;

/*
 * returns mtime of a file
 */
+(NSDate*) mtime: (NSString*) path;

/*
 * Creates a directory and all needed subdirs
 */
+(void) mkdir_p: (NSString*) path;

/*
 * Creates a directory and all needed subdirs
 */
+(void) copyFrom: (NSString*) path to: (NSString*)dest;

#if TARGET_OS_IPHONE

+(UIImage*) readImageFromPath: (NSString*) path;

#endif


@end
