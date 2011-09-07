#import "M3.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

@implementation M3StopWatch

-(id)init
{
  if(!(self = [ super init ])) return nil;

  [ self startWatch ];
  return self;
}

-(void)startWatch
{ 
  started_ = mach_absolute_time(); 
}

-(uint64_t)nanoSeconds
{
  uint64_t end = mach_absolute_time();

  // Convert to nanoseconds.
  static mach_timebase_info_data_t    sTimebaseInfo;
  static BOOL    sTimebaseInfoSet = NO;

  // If this is the first time we run, get the timebase. 
  if (!sTimebaseInfoSet) {
      (void) mach_timebase_info(&sTimebaseInfo);
      sTimebaseInfoSet = YES;
  }

  return (end - started_) * sTimebaseInfo.numer / sTimebaseInfo.denom;
}

-(float) milliSeconds
{
  return 1e-6f * [ self nanoSeconds ];
}

-(float)seconds
{
  return 1e-9f * [ self nanoSeconds ];
}

@end
