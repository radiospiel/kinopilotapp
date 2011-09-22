#import "Underscore.hh"

#include <mach/mach.h>
#include <mach/mach_time.h>

namespace RS {

BenchmarkLogger::BenchmarkLogger(NSString* msg) {
  stopWatch_ = [[M3StopWatch alloc]init];
  msg_ = [ msg retain ];
}

BenchmarkLogger::~BenchmarkLogger() {
  NSString* msg = [NSString stringWithFormat: @"%@: %d msecs", msg_, [stopWatch_ milliSeconds]];
  rlog << [msg UTF8String];
  
  [msg_ release ];
  [stopWatch_ release];
}

/*
 * C++-like logging
 */

void Logger::append(NSString* string) const {
  if(!parts_) parts_ = [NSMutableArray array];
  if(!string) string = @"nil";
  [parts_ addObject: string];
}

#if TARGET_CPU_ARM
  // Device
  #define shouldShortenSourceLocation(mode) YES
#else
  // Simulator
  // #define shouldShortenSourceLocation(mode) (mode != Logger::Debug)
  #define shouldShortenSourceLocation(mode) YES
#endif

Logger::~Logger()
{
  if(!parts_) return;

  static const char* severityLabels[] = {
    "[ERR] ",
    "[WRN] ",
    "[INF] ",
    "[DBG] "
  };
  
  static M3StopWatch* stopWatch = 0;
  if(!stopWatch)
    stopWatch = [[M3StopWatch alloc]init];

  
  const char* severityLabel = "";
  if(severity_ < sizeof(severityLabels)/sizeof(severityLabels[0]))
    severityLabel = severityLabels[severity_];

  double secs = [stopWatch nanoSeconds] / 1e9;
  
  if(shouldShortenSourceLocation(mode_)) {
    NSString* module = [M3 basename_wo_ext: [NSString stringWithUTF8String: file_]];
    _.puts(@"[%.2f secs] %s%@: %@", secs, severityLabel, module, [parts_ componentsJoinedByString: @""]);
  }
  else
    _.puts(@"[%.2f secs] %s%s(%d): %@", secs, severityLabel, file_, line_, [parts_ componentsJoinedByString: @""]);
}

}
