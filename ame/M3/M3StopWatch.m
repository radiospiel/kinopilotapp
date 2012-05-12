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

-(int)milliSeconds
{
  return (int)([ self nanoSeconds ] / 1000000);
}

-(double)seconds
{
  return 1e-9 * [ self nanoSeconds ];
}

+(M3StopWatch*) stopWatch;
{
  return [[[self alloc]init]autorelease];
}

+(double)measure: (M3StopWatchCallback) callback
{
  M3StopWatch* stopWatch = [[[self alloc]init]autorelease];
  callback();
  return [stopWatch seconds];
}

+(double)measure: (M3StopWatchCallback) callback 
     withMessage: (NSString*)msg
{
  M3StopWatch* stopWatch = [[[self alloc]init]autorelease];
  callback();
  NSLog(@"%@: %d msecs", msg, stopWatch.milliSeconds);
  
  return [stopWatch seconds];
}


@end

#if 0

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

- (void)testStopWatch
{
  int milliSeconds = [stop_watch milliSeconds];
  assert_true(milliSeconds >= 0);
  
  usleep(5000);
  
  milliSeconds = [stop_watch milliSeconds];
  assert_true(milliSeconds >= 5);
}

- (void)testBenchmark
{
  int __block count = 0;
  [M3StopWatch measure:^(){
    count += 1;
    usleep(5000);
  }];
  assert_equal_pod(count, 1);
}

@end

#endif
