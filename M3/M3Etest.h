#ifdef __cplusplus
#include "underscore.hh"
#endif

@class M3ETestResults;

@interface M3ETest: NSObject {
  M3ETestResults* results_;
  NSString* name_;
};

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) M3ETestResults* results;

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

#define m3_assert(expr, msg)        do { @autoreleasepool { if(!expr) m3_etest_failed(msg, __FILE__, __LINE__); else m3_etest_success(); } } while(0)
#define m3_msg3(fmt, p1, p2, p3)    [ NSString stringWithFormat:fmt, p1, p2, p3]
#define m3_msg2(fmt, p1, p2)        m3_msg3(fmt, p1, p2, nil)
#define m3_msg1(fmt, p1)            m3_msg3(fmt, p1, nil, nil)
#define m3_msg0(fmt)                m3_msg3(fmt, nil, nil, nil)

#define assert_equal_pod(a, e)      m3_assert((a == e),           m3_msg2(@"'%s' should equal '%s'", #a, #e))
#define assert_equal_int(a, e)      m3_assert((a == e),           m3_msg3(@"'%s' should equal %d, but is %d", #a, (int)e, (int)a))
#define assert_equal_objects(a, e)  m3_assert([(a) isEqual: (e)], m3_msg2(@"%@ should equal %@", [a inspect], [e inspect]))

#define assert_not_equal_pod(a, e)      m3_assert((a != e),             m3_msg2(@"'%s' should not equal '%s'", #a, #e))
#define assert_not_equal_int(a, e)      m3_assert((a != e),             m3_msg2(@"'%s' must not equal %d.", #a, (int)e))
#define assert_not_equal_objects(a, e)  m3_assert(![(a) isEqual: (e)],  m3_msg2(@"%@ should not equal %@", [a inspect], [e inspect]))

#ifdef UNDERSCORE_HH

#define assert_equal(a, e)          assert_equal_objects(_.object(a), _.object(e))
#define assert_not_equal(a, e)      assert_not_equal_objects(_.object(a), _.object(e))

#endif

#define assert_nil(a)               m3_assert(((a) == nil), m3_msg1(@"%s should be nil", #a))
#define assert_not_nil(a)           m3_assert((a),          m3_msg1(@"%s must not be nil", #a))
#define assert_true(a)              m3_assert((a),          m3_msg1(@"%s should be trueish", #a))
#define assert_false(a)             m3_assert((!(a)),       m3_msg1(@"%s should be false", #a))

