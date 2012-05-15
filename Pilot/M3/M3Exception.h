#import "M3.h"

/*
 * M3 exceptions
 */

@interface M3Exception: NSObject {
  NSString* error_;
  NSString* message_;
}

@property (retain,nonatomic) NSString* error;
@property (retain,nonatomic) NSString* message;

+(void) raise: (NSString*) error;
+(void) raise: (NSString*) error withMessage: (NSString*) message;
+(void) raiseOnError: (NSError*) error;

@end


/*
 * File related error numbers.
 */

@interface M3FileException: M3Exception {
  int code_;
  NSString* path_;
}

@property (retain,nonatomic) NSString* path;
@property (assign,nonatomic) int code;

/*
 * raises a M3FileException.
 */
+(void) raise: (NSString*) error 
      forPath: (NSString*) path 
     andErrno: (int) code;

/*
 * raises a M3FileException from an error number.
 */
+(void) raiseWithErrno: (int) code 
               forPath: (NSString*) path;

@end
