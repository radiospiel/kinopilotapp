#import "Underscore.hh"

RS::UnderscoreAdapter _;

#include <mach/mach.h>
#include <mach/mach_time.h>

namespace RS {
  
StopWatch::StopWatch(): start_(mach_absolute_time()) {}

double StopWatch::operator()() const {
  uint64_t end = mach_absolute_time();

  // Convert to nanoseconds.

  static mach_timebase_info_data_t    sTimebaseInfo;
  static BOOL    sTimebaseInfoSet = NO;

  // If this is the first time we've run, get the timebase.
  // We can use denom == 0 to indicate that sTimebaseInfo is 
  // uninitialised because it makes no sense to have a zero 
  // denominator is a fraction.

  if (!sTimebaseInfoSet) {
      (void) mach_timebase_info(&sTimebaseInfo);
      sTimebaseInfoSet = YES;
  }

  uint64_t elapsedNano = (end - start_) * sTimebaseInfo.numer / sTimebaseInfo.denom;

  // Convert to seconds.

  return 1e-9 * elapsedNano;
}
  
BlockLogger::BlockLogger(const char* pretty_function): pretty_function_(pretty_function) {
  // NSLog(@"Enter %s", pretty_function_);
}

BlockLogger::~BlockLogger() {
  NSLog(@"%.03f msecs: %s", stop_watch_() * 1000, pretty_function_);
}

}
