#import "Underscore.hh"

#include <mach/mach.h>
#include <mach/mach_time.h>

namespace RS {

BenchmarkLogger::BenchmarkLogger(NSString* msg) {
  stopWatch_ = [[M3StopWatch alloc]init];
  msg_ = [ msg retain ];
}

BenchmarkLogger::~BenchmarkLogger() {
  rlog << msg_ << @": " << [stopWatch_ milliSeconds] << @" msecs";
  [msg_ release ];
  [stopWatch_ release];
}

/*
 * C++-like logging
 */

void Logger::append(NSString* string) const {
  if(!parts_) parts_ = [NSMutableArray array];
  [parts_ addObject: string];
}

Logger::~Logger()
{
  if(!parts_) return;

  static const char* severityLabels[] = {
    "[ERR] ",
    "[WRN] ",
    "[INF] ",
    "[DBG] "
  };
  
  const char* severityLabel = "";
  if(severity_ < sizeof(severityLabels)/sizeof(severityLabels[0]))
    severityLabel = severityLabels[severity_];

  
  if(mode_ != Debug) {
    NSString* module = [M3 basename_wo_ext: [NSString stringWithUTF8String: file_]];
    _.puts(@"%s%@: %@", severityLabel, module, [parts_ componentsJoinedByString: @""]);
  }
  else
    _.puts(@"%s%s(%d): %@", severityLabel, file_, line_, [parts_ componentsJoinedByString: @""]);
}

}
