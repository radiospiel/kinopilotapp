#ifdef __cplusplus
#include "underscore.hh"
#endif

@class M3ETestResults;

@interface M3ETest: NSObject {
  M3ETestResults* results_;
  NSString* name_;
};

@property (nonatomic,assign,readonly) NSString* name;

-(void)run;
+(void)runAll;

@end

#define ETest(name)                           \
          @interface name ## ETest: M3ETest   \
          @end                                \
          @implementation name ## ETest

extern 
#ifdef __cplusplus
"C" 
#endif
void m3_etest_failed(NSString* msg, const char* file, int line);

extern 
#ifdef __cplusplus
"C" 
#endif
void m3_etest_success();

#define m3_assert(expr, msg)        do { if(!expr) m3_etest_failed(msg, __FILE__, __LINE__); else m3_etest_success(); } while(0)
#define m3_msg(fmt, p1, p2)         [ NSString stringWithFormat:fmt, p1, p2]

#define assert_equal_pod(a, e)      m3_assert((a == e),           m3_msg(@"'%s' should equal '%s'", #a, #e))
#define assert_equal_objects(a, e)  m3_assert([(a) isEqual: (e)], m3_msg(@"%@ should equal\n%@", (a), (e)))

#define assert_not_equal_pod(a, e)      m3_assert((a != e),           m3_msg(@"'%s' should not equal '%s'", #a, #e))
#define assert_not_equal_objects(a, e)  m3_assert(![(a) isEqual: (e)], m3_msg(@"%@ should not equal\n%@", (a), (e)))

#ifdef UNDERSCORE_HH

#define assert_equal(a, e)          assert_equal_objects(_.object(a), _.object(e))
#define assert_not_equal(a, e)      assert_not_equal_objects(_.object(a), _.object(e))

#endif

#define assert_true(a)              m3_assert((a), @"Should be true")
#define assert_false(a)             m3_assert((a), @"Should be false")

