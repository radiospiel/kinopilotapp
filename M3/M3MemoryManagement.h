#define M3_MEMORY_LOGGED
#ifndef M3_MEMORY_LOGGED
  #define M3_MEMORY_LOGGED
  #if __has_feature(objc_arc) 
    #warning "Compiling for ARC"
  #else
    #warning "Compiling for non-ARC"
  #endif
#endif

#if __has_feature(objc_arc) 
  #define START_AUTORELEASEPOOL @autoreleasepool {
  #define END_AUTORELEASEPOOL }

  inline id underscore_arc_dummy_(id obj) { return obj; }

  #define AUTORELEASE(obj)  underscore_arc_dummy_(obj)
  #define RELEASE(obj)      underscore_arc_dummy_(obj)
  #define RETAIN(obj)       underscore_arc_dummy_(obj)
#else
  #define START_AUTORELEASEPOOL NSAutoreleasePool *__auto_release_pool__ = [[NSAutoreleasePool alloc] init]; {
  #define END_AUTORELEASEPOOL }; [__auto_release_pool__ release]

  #define AUTORELEASE(obj)  [obj autorelease]
  #define RELEASE(obj)      [obj release]
  #define RETAIN(obj)       [obj retain]
#endif

// #define LOG_DEALLOC        NSLog(@"%@ dealloc", [self class])
#define LOG_DEALLOC        (void)0
