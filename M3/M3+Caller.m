#import "M3.h"

#include <execinfo.h>

@implementation M3(Callers)

+(NSArray*)callersWithLimit: (NSUInteger)limit andOffset: (NSUInteger)offset
{
  // collect backtrace information
  NSMutableArray* callers = [NSMutableArray array];
  
  if(limit > 127) limit = 127;
  void* callstack[128];
  int frames = backtrace(callstack, limit);
  char** strs = backtrace_symbols(callstack, frames);
  
  while(offset < frames) {
    [callers addObject: [NSString stringWithUTF8String: strs[offset]]];
    offset++;
  }

  free(strs);
  
  return callers;
}

+(NSArray*)callersWithLimit: (NSUInteger)limit
{
  return [M3 callersWithLimit: limit andOffset: 3];
}

+(NSArray*)callers
{
  return [M3 callersWithLimit: 128 andOffset: 3];
}

+(NSString*)callerWithIndex: (NSUInteger)index;
{
  if(index > 20) index = 20;
  
  void* callstack[21];
  int frames = backtrace(callstack, index+1);
  char** strs = backtrace_symbols(callstack, frames);

  NSString* caller = [NSString stringWithUTF8String: strs[index]];
  free(strs);

  if([caller matches: @"([+-][^\\]]*\\])"]) return $1;
  return caller;
}

+(NSString*)caller
{
  return [self callerWithIndex: 3];
}

@end