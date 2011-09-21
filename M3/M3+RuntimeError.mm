#import "M3.h"

#include <execinfo.h>

@implementation RuntimeError

@synthesize backtrace=backtrace_, message=message_;

-(id)initWithMessage:(NSString*)theMessage
{
  self = [super initWithName:NSStringFromClass([self class]) reason:theMessage userInfo:nil];
  if(!self) return nil;

  // collect backtrace information
  NSMutableArray* backtrace_array = [NSMutableArray array];
  
  void* callstack[128];
  int frames = backtrace(callstack, 128);
  char** strs = backtrace_symbols(callstack, frames);
  for (int i = 0; i < frames; ++i) {
    [backtrace_array addObject: [NSString stringWithUTF8String: strs[i]]];
  }
  free(strs);
  
  backtrace_ = backtrace_array;
  message_ = [theMessage retain];
  
  return self;
}

-(void)dealloc
{
  [message_ release];
  [backtrace_ release];
  
  [super dealloc];
}
     
@end
