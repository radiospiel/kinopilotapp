#import "Underscore.hh"

#include <mach/mach.h>
#include <mach/mach_time.h>

namespace RS {

BenchmarkLogger::BenchmarkLogger(NSString* msg) {
  stopWatch_ = [[M3StopWatch alloc]init];
  msg_ = [ msg retain ];
}

BenchmarkLogger::~BenchmarkLogger() {
  int milliSeconds = [stopWatch_ milliSeconds];
  if(milliSeconds > 50) {
    NSString* msg = [NSString stringWithFormat: @"%@: %d msecs", msg_, milliSeconds];
    NSString* caller = [M3 callerWithIndex: 3];

    rlog.setSource(caller).append(msg);
  }
  
  [stopWatch_ release];
}

/*
 * C++-like logging
 */

Logger::Logger(int mode, const char* file, int line): mode_(mode), file_(file), line_(line), severity_(2), parts_(nil), src_(nil)
{
}

const Logger& Logger::setSource(NSString* src) const
{
  src_ = [src retain];
  return *this;
}

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
  if(!stopWatch) {
    #if DEBUG
    NSLog(@"Firing up underscore logger");
    #endif
    stopWatch = [[M3StopWatch alloc]init];
  }

  
  const char* severityLabel = "";
  if(severity_ < sizeof(severityLabels)/sizeof(severityLabels[0]))
    severityLabel = severityLabels[severity_];

  double secs = [stopWatch nanoSeconds] / 1e9;

  if(src_) {
    _.puts(@"[%.2f secs] %s%@: %@", secs, severityLabel, src_, [parts_ componentsJoinedByString: @""]);
  }
  else if(shouldShortenSourceLocation(mode_)) {
    NSString* module = [M3 basename_wo_ext: [NSString stringWithUTF8String: file_]];
    _.puts(@"[%.2f secs] %s%@: %@", secs, severityLabel, module, [parts_ componentsJoinedByString: @""]);
  }
  else
    _.puts(@"[%.2f secs] %s%s(%d): %@", secs, severityLabel, file_, line_, [parts_ componentsJoinedByString: @""]);

  [src_ release];
}

}
