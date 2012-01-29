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
      arguments_ = [[[NSMutableArray alloc]init]autorelease];
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
      NSMutableArray* args = [NSMutableArray array];
      for(id entry in arguments_) {
        if([entry isKindOfClass: [NSNull class]]) continue;
        [args addObject: entry];
      }

      return [args componentsJoinedByString: @""];
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

    inline NSString* string(Class obj) 
    { 
      NSString* className = NSStringFromClass(obj);
      return [className stringByReplacingOccurrencesOfString:@"_MAZeroingWeakRefSubclass" withString:@""];
    }
    
    inline NSString* string(SEL selector) 
      { return [@":" stringByAppendingString: NSStringFromSelector(selector)]; }
    
    template <class T>
    inline NSString* string(T obj) 
      { return [ object(obj) description]; }
    
    // The ptr method
    NSString* ptr(const NSObject* obj)
    { 
      NSString* className = NSStringFromClass([obj class]);
      className = [className stringByReplacingOccurrencesOfString:@"_MAZeroingWeakRefSubclass" withString:@""];
      
      return [NSString stringWithFormat: @"<%@ @ 0x%08lx>", className, (long)obj]; 
    }
      
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
  };
};

extern RS::UnderscoreAdapter _;

inline NSInteger RS::UnderscoreAdapter::compare(id a, id b, void* dummy) {
  return _.compare_(a, b);
}

#include "Underscore+Logger.hh"

#endif
