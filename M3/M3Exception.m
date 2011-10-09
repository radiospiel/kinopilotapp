#import "M3.h"

@implementation M3Exception

@synthesize error = error_;
@synthesize message = message_;

-(id) initWithError: (NSString*) error andMessage: (NSString*) message {
  if(!(self = [super init])) return nil;

  self.error = error;
  self.message = message;
  
  return self;
}

-(NSString*)description {
  if(message_)
    return [NSString stringWithFormat: @"%@: %@", error_, message_];
  else
    return error_;
}

-(void)dealloc {
  self.error = nil;
  self.message = nil;

  [super dealloc];
}

+(void) raise: (NSString*) error withMessage: (NSString*) message {
  M3Exception* exception = [[M3Exception alloc] initWithError: error andMessage: message];

  NSLog(@"*** Exception: %@\n%@", exception.error, exception.message);
  
  @throw exception;
}

+(void) raise: (NSString*) error {
  [M3Exception raise: error withMessage: nil];
}


+(void) raiseOnError: (NSError*) error {
  if(!error) return;

  [M3Exception raise: error.localizedDescription 
         withMessage: error.localizedFailureReason];
}

@end


@implementation M3FileException

@synthesize path = path_;
@synthesize code = code_;

+(NSString*) errorStringWithErrno: (int) code
{
  return [NSString stringWithFormat: @"%s", strerror(code)];
}

-(id) initWithError: (NSString*) error 
            forPath: (NSString*) path 
           andErrno: (int) code 
{
  if(!error)
    error = [M3FileException errorStringWithErrno: code];
  
  self = [super initWithError: [NSString stringWithFormat: @"%@: %@", error, path]
                    andMessage: nil];
  
  if(self) {
    self.code = code;
    self.path = path;
  };
  
  return self;
}

-(void)dealloc 
{
  self.path = nil;
  
  [super dealloc];
}


/*
 * raises a M3FileException.
 */
+(void) raise: (NSString*) error 
      forPath: (NSString*) path 
     andErrno: (int) code
{
  @throw [[M3FileException alloc] initWithError: error 
                                          forPath: path
                                         andErrno: code];
}

/*
 * raises a M3FileException from an error number.
 */
+(void) raiseWithErrno: (int) code 
               forPath: (NSString*) path
{
  @throw [[M3FileException alloc] initWithError: nil
                                          forPath: path
                                         andErrno: code];
}

@end
