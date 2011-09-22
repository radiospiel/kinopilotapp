/*!

The underscore.m file provides a port of most functionality of the 
underscore.js framework to Obj-C.

Copyright (c) radiospiel, <a href="http://radiospiel.github.com">http://radiospiel.github.com</a>

*/

#import "M3.h"

#ifndef UNDERSCORE_HH
#define UNDERSCORE_HH

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


namespace RS {
  
  // 
  // Convert types into objects
  inline id object(id n) {
    return n ? n : [NSNull null];
  }
  
  inline id object(const char* s) {
    return [NSString stringWithUTF8String: s];
  }
  
  inline id object(char n)                { return [NSNumber numberWithChar:n]; }
  inline id object(unsigned char n)       { return [NSNumber numberWithUnsignedChar: n]; }
  inline id object(short n)               { return [NSNumber numberWithShort:n]; }
  inline id object(unsigned short n)      { return [NSNumber numberWithUnsignedShort: n]; }
  inline id object(int n)                 { return [NSNumber numberWithInt: n]; }
  inline id object(unsigned int n)        { return [NSNumber numberWithUnsignedInt: n]; }
  inline id object(long n)                { return [NSNumber numberWithLong: n]; }
  inline id object(unsigned long n)       { return [NSNumber numberWithUnsignedLong: n]; }
  inline id object(long long n)           { return [NSNumber numberWithLongLong: n]; }
  inline id object(unsigned long long n)  { return [NSNumber numberWithUnsignedLongLong: n]; }
  inline id object(float n)               { return [NSNumber numberWithFloat: n]; }
  inline id object(double n)              { return [NSNumber numberWithDouble: n]; }
  inline id object(bool n)                { return [NSNumber numberWithBool: n]; }
  
  /*
   * NSIntegers and NSUIntegers are typedef'ed to int or long types. 
   * Therefore, these two implementations are neither needed nor valid 
   * (as they duplicate already existing implementations) 
   */
  
  // inline id object(NSInteger n)  { return [NSNumber numberWithInteger: n]; }
  // inline id object(NSUInteger n) { return [NSNumber numberWithUnsignedInteger: n]; }
  
  //
  // -- The VariadicFactory class helps building things off
  //    a list of other objects. The maximum number of supported
  //    parameters depends on how many variants of 
  //    VariadicFactory#operator()(T0 n0, ...)
  //    are implemented. 
  //
  class VariadicFactoryArguments {
  public:
    VariadicFactoryArguments() {
      arguments_ = [NSMutableArray array];
    }
    
    template <class T> 
    VariadicFactoryArguments& arg(T& arg) {
      [arguments_ addObject: object(arg)];
      return *this;
    };
    
  protected:
    NSMutableArray* arguments_;
  };
  
  template <class Factory>
  class VariadicFactory {
    typedef typename Factory::Type Type;
  public:
    Type operator()() const {
      Factory factory;
      return factory.run();
    }
    
    template <class T0>
    Type operator()(T0 n0)
    {
      Factory factory;
      factory.arg(n0);
      return factory.run();
    }
    
    template <class T0, class T1>
    Type operator()(T0 n0, T1 n1)
    {
      Factory factory;
      factory.arg(n0).arg(n1);
      return factory.run();
    }
    
    template <class T0, class T1, class T2>
    Type operator()(T0 n0, T1 n1, T2 n2)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4, class T5>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4, T5 n5)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4).arg(n5);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4, class T5, class T6>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4, T5 n5, T6 n6)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4).arg(n5).arg(n6);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4, class T5, class T6, class T7>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4, T5 n5, T6 n6, T7 n7)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4).arg(n5).arg(n6).arg(n7);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4, class T5, class T6, class T7, class T8>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4, T5 n5, T6 n6, T7 n7, T8 n8)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4).arg(n5).arg(n6).arg(n7).arg(n8);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4, class T5, 
    class T6, class T7, class T8, class T9>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4, T5 n5, T6 n6, T7 n7, T8 n8, T9 n9)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4).arg(n5).arg(n6).arg(n7).arg(n8).arg(n9);
      return factory.run();
    }
    
    template <class T0, class T1, class T2, class T3, class T4, class T5, 
    class T6, class T7, class T8, class T9, class T10>
    Type operator()(T0 n0, T1 n1, T2 n2, T3 n3, T4 n4, T5 n5, T6 n6, T7 n7, T8 n8, T9 n9, T10 n10)
    {
      Factory factory;
      factory.arg(n0).arg(n1).arg(n2).arg(n3).arg(n4).arg(n5).arg(n6).arg(n7).arg(n8).arg(n9).arg(n10);
      return factory.run();
    }
  };
  
  // An array factory
  struct ArrayFactory: VariadicFactoryArguments {
    typedef NSMutableArray* Type;
    inline NSMutableArray* run() const {
      return arguments_;
    }
  };

  // A string joining factory
  struct JoinFactory: VariadicFactoryArguments {
    typedef NSString* Type;
    NSString* run() const {
      return [arguments_ componentsJoinedByString: @""];
    }
  };
  
  // An exception throwing factory
  struct RaiseFactory: VariadicFactoryArguments {
    typedef NSString* Type;
    NSString* run() const;
  };
  
  // A hash factory
  //
  // Note: hash() takes arguments in key, value order.
  struct HashFactory: VariadicFactoryArguments {
    typedef NSMutableDictionary* Type;
    NSMutableDictionary* run() const {
      NSMutableDictionary* dict = [NSMutableDictionary dictionary];
      unsigned idx = 0;
      while(idx < arguments_.count) {
        id key = [arguments_ objectAtIndex: idx++];
        id val = [arguments_ objectAtIndex: idx++]; 
        [dict setObject: val forKey: key];
      }
      
      return dict;
    }
  };
  
  // A set factory
  struct SetFactory: VariadicFactoryArguments {
    typedef NSMutableSet* Type;
    NSMutableSet* run() const {
      NSMutableSet* set = [NSMutableSet set];
      unsigned idx = 0;
      while(idx < arguments_.count) {
        id obj = [arguments_ objectAtIndex: idx++];
        [set addObject: obj];
      }
      
      return set;
    }
  };
  
  struct UnderscoreAdapter {
    // convert POD objects into NSObjects
    template <class T>
    inline id object(T t) { return RS::object(t); }
    
    // 
    // Convert strings into NSStrings
    inline NSString* string(NSString* str) 
      { return str; }
    
    inline NSString* string(const char* s) 
      { return [NSString stringWithUTF8String: s]; }

    inline NSString* string(const CGRect& r)
      { return [NSString stringWithFormat: @"[%dx%d+%d+%d]", 
                r.origin.x, r.origin.y, r.size.width, r.size.height];}

    inline NSString* string(id obj) 
      { return [obj description]; }

    template <class T>
    inline NSString* string(T obj) 
      { return [ object(obj) description]; }
    
    // "Functions" to build strings, arrays, and hashes.  
    VariadicFactory<ArrayFactory> array;
    VariadicFactory<HashFactory> hash;
    VariadicFactory<JoinFactory> join;
    VariadicFactory<SetFactory> set;
    VariadicFactory<RaiseFactory> raise;
    
    // _.compare
    template <class T0, class T1>
    NSComparisonResult compare(T0 value, T1 other)
      { return compare_(object(value), object(other)); }

    NSComparisonResult compare_(id a, id b);
  
    static NSInteger compare(id a, id b, void* dummy);
    
    /* write to stderr(sic!) */
    void print(const char* s);
    void print(NSString *format, ...);
    void puts(const char* s);
    void puts(NSString *format, ...);

    #if 0 
    // _.each
    id each(id list, void (^iterator)(id value, id key))
      { return [M3 each: list with: iterator]; }
    id each(id list, void (^iterator)(id value, NSUInteger index))
      { return [M3 each: list withIndex: iterator]; }
    
    // _.inject
    template <class T>
    id inject(id list, T memo, id (^iterator)(id memo, id value, id key))
      { return [M3 inject: list memo: object(memo) with: iterator]; }
    template <class T>
    id inject(id list, T memo, id (^iterator)(id memo, id value, NSUInteger key))
      { return [M3 inject: list memo: object(memo) withIndex: iterator]; }
    id inject(id list, id (^iterator)(id memo, id value, id key))
      { return [M3 inject: list with: iterator]; }
    id inject(id list, id (^iterator)(id memo, id value, NSUInteger key))
      { return [M3 inject: list withIndex: iterator]; }
    
    // _.map
    NSMutableArray* map(id list, id (^iterator)(id value, id key))
      { return [M3 map: list with: iterator]; }
    NSMutableArray* map(id list, id (^iterator)(id value, NSUInteger idx))
      { return [M3 map: list withIndex: iterator]; }
    
    // _.detect
    id detect(id list,  BOOL (^iterator)(id value, id key))
      { return [M3 detect: list with: iterator]; }
    id detect(id list,  BOOL (^iterator)(id value, NSUInteger key))
      { return [M3 detect: list withIndex: iterator]; }
    
    // _.select
    NSMutableArray* select(id list, BOOL (^iterator)(id value, id key))
      { return [M3 select: list with: iterator]; }
    NSMutableArray* select(id list, BOOL (^iterator)(id value, NSUInteger key))
      { return [M3 select: list withIndex: iterator]; }
    
    // _.reject
    NSMutableArray* reject(id list, BOOL (^iterator)(id value, id key))
      { return [M3 reject: list with: iterator]; }
    NSMutableArray* reject(id list, BOOL (^iterator)(id value, NSUInteger key))
      { return [M3 reject: list withIndex: iterator]; }
    
    // _.all
    BOOL all(id list,  BOOL (^iterator)(id value, id key))
      { return [M3 all: list with: iterator]; }
    BOOL all(id list,  BOOL (^iterator)(id value, NSUInteger key))
      { return [M3 all: list withIndex: iterator]; }
    
    // _.any
    BOOL any(id list,  BOOL (^iterator)(id value, id key))
      { return [M3 any: list with: iterator]; }
    BOOL any(id list,  BOOL (^iterator)(id value, NSUInteger key))
      { return [M3 any: list withIndex: iterator]; }
    
    // _.include
    template <class T>
    BOOL include(id list, T value)
      { return [M3 include: list value: object(value)]; }
    
    // _.pluck
    template <class T>
    NSMutableArray* pluck(id list, T propertyName)
      { return [M3 pluck: list name: string(propertyName)]; }
    
    
    // _.max
    id max(id list)
      { return [M3 max: list]; }
    id max(id list, id (^iterator)(id value, id key))
      { return [M3 max: list with: iterator]; }
    id max(id list, id (^iterator)(id value, NSUInteger idx))
      { return [M3 max: list withIndex: iterator]; }
    
    // _.min
    id min(id list)
      { return [M3 min: list]; }
    id min(id list,  id (^iterator)(id value, id key))
      { return [M3 min: list with: iterator]; }
    id min(id list,  id (^iterator)(id value, NSUInteger idx))
      { return [M3 min: list withIndex: iterator]; }
    
    // _.group_by
    id group_by(id list, id (^iterator)(id value))
      { return [M3 group: list by: iterator]; }
    #endif
  };
};

extern RS::UnderscoreAdapter _;

inline NSInteger RS::UnderscoreAdapter::compare(id a, id b, void* dummy) {
  return _.compare_(a, b);
}

namespace RS {
  
  class BenchmarkLogger {
    NSString* msg_;
    M3StopWatch* stopWatch_;
  public:
    BenchmarkLogger(NSString* msg);
    ~BenchmarkLogger();
  };
  
#define Benchmark(msg) RS::BenchmarkLogger __log_block(msg)
  
  /*
   * C++-like logging
   */
  
  class NoLogger {
  public:
    NoLogger() {};
    
    const NoLogger& operator()(unsigned severity) const { return *this; }
  };
  
  class Logger {
    int mode_;
    const char* file_;
    int line_;
    mutable unsigned severity_;
    mutable NSMutableArray* parts_;
    
  public:
    enum { Debug = 0, Release = 1 };
    
    Logger(int mode, const char* file, int line): mode_(mode), file_(file), line_(line), severity_(2), parts_(nil) {};
    ~Logger();
    
    const Logger& operator()(unsigned severity) const { severity_ = severity; return *this; }
    
    void append(NSString* string) const;
  };
  
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
// inline const RS::Logger& operator << (const RS::Logger& logger, CGRect rect) { 
//   logger.append([NSString stringWithFormat: @"(%d,%d+%d+%d)", 
//     (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height]);
//   return logger;
// }

template <class T>
inline const RS::NoLogger& operator << (const RS::NoLogger& logger, T obj)
  { return logger; }
  

#endif
