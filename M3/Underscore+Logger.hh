/*
 * Streamish logging
 *
 * This file implements two classes: 
 *
 * a) A Logger class, which looks like a ostream from the outside. It eats up everything that
 * is shifted into it, converts it properly (via NSObject#inspect or similar), and writes it
 * out on dtor time.
 *
 * and
 *
 * b) a NoLogger class, which looks the same, but just doesn't do anything.
 *
 */

#ifndef UNDERSCORE_LOGGER_HH
#define UNDERSCORE_LOGGER_HH

@class M3StopWatch;

namespace RS {
  
//! Measure a block
class BenchmarkLogger {
  NSString* msg_;
  M3StopWatch* stopWatch_;
public:
  BenchmarkLogger(NSString* msg);
  ~BenchmarkLogger();
};

#define Benchmark(msg) RS::BenchmarkLogger __log_block(msg)
  
//! The logger, which isn't.
class NoLogger {
public:
  NoLogger() {};
  
  const NoLogger& setSource(NSString* src) const { return *this; };
  
  const NoLogger& operator()(unsigned severity) const { return *this; }
};

//! The logging, object.
class Logger {
  int mode_;
  const char* file_;
  int line_;
  
  mutable NSString* src_;
  mutable unsigned severity_;
  mutable NSMutableArray* parts_;
  
public:
  enum { Debug = 0, Release = 1 };
  
  Logger(int mode, const char* file, int line);
  ~Logger();

  const Logger& setSource(NSString* src) const;
  
  const Logger& operator()(unsigned severity) const { severity_ = severity; return *this; }
  
  void append(NSString* string) const;
};

template <class T>
inline const RS::NoLogger& operator << (const RS::NoLogger& logger, T obj)
  { return logger; }


#define nolog RS::NoLogger()

#ifndef NDEBUG
  
#define rlog RS::Logger(RS::Logger::Debug, __FILE__, __LINE__)
#define dlog RS::Logger(RS::Logger::Debug, __FILE__, __LINE__)
  
#else
  
#define rlog RS::Logger(RS::Logger::Release, __FILE__, __LINE__)
#define dlog RS::NoLogger()
  
#endif
  
#define RLOG(x) rlog << #x "=" << [x inspect]
#define DLOG(x) dlog << #x "=" << [x inspect]
  
} // namespace RS {

template <class T>
inline const RS::Logger& operator << (const RS::Logger& logger, T obj) { 
  logger.append(_.string(obj)); 
  return logger; 
}

inline const RS::Logger& operator << (const RS::Logger& logger, id obj) { 
  if(obj)
    logger.append([obj inspect]); 
  else
    logger.append(@"nil");
    
  return logger; 
}

inline const RS::Logger& operator << (const RS::Logger& logger, CGRect rect) { 
  logger.append([NSString stringWithFormat: @"(%d,%d+%d+%d)", 
    (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height]);
  return logger;
}

// 
// inline const RS::Logger& operator << (const RS::Logger& logger, CGPoint point) { 
//   logger.append([NSString stringWithFormat: @"%d,%d", (int)point.x, (int)point.y]);
//   return logger;
// }
// 
// inline const RS::Logger& operator << (const RS::Logger& logger, CGSize size) { 
//   logger.append([NSString stringWithFormat: @"+%d+%d", (int)size.width, (int)size.height]);
//   return logger;
// }
// 

#endif
