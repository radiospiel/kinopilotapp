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

-(uint64_t) milliSeconds
{
  return [ self nanoSeconds ] / 1000000;
}

-(double)seconds
{
  return 1e-9 * [ self nanoSeconds ];
}

@end

@interface M3StopWatchTests: M3ETest {
  M3StopWatch* stop_watch;
}

@end


@implementation M3StopWatchTests

-(void)setUp
{
  stop_watch = [[ M3StopWatch alloc ] init];
}

-(void)tearDown
{
  [stop_watch release];
  stop_watch=nil;
}

- (void)testAssertionFailed
{
  int milliSeconds = [stop_watch milliSeconds];
  m3assert(milliSeconds >= 0);
}

@end

