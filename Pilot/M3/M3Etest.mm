#if 0 

#import "M3.h"

@interface M3ETestAssertionFailed: RuntimeError {
  const char* file;
  int line;
}

@property (nonatomic,assign) const char* file;
@property (nonatomic,assign) int line;

@end

@implementation M3ETestAssertionFailed

@synthesize file;
@synthesize line;

@end

@interface M3ETestResults: M3StopWatch {
  M3ETest* etest_;
}

@end

@implementation M3ETestResults

-(id)initWithEtest: (M3ETest*)etest {
  if(!(self = [ super init ])) return nil;
  
  etest_ = etest;
  return self;
}

-(void)startTest:(NSString*)name;
{
  [self startWatch];
}

-(NSString*) testcase
{
  return [NSString stringWithFormat: @"-[%@ %@]", [ etest_ class ], [ etest_ name ]];
}

-(void)reportFailure:(M3ETestAssertionFailed*)exception
{
  _.puts(@"\n%s(%d): ETest Case '%@' failed (%d msecs).", exception.file, exception.line, [ self testcase ], [self milliSeconds]);
  _.puts(@"\n%s(%d): %@", exception.file, exception.line, exception.message);
  // _.puts(@"in\n\t%@", [[exception backtrace] componentsJoinedByString:@"\n\t"]);
}

-(void)reportException:(NSString*)exception
{
  _.puts(@"\nETest Case '%@' crashed (%d msecs).", [ self testcase ], [self milliSeconds]);
  _.puts(@"Exception: %@", exception);
}

-(void)reportSuccess
{
  _.print(".");
  // _.puts(@"ETest Case '%@' passed after %d msecs", [ self testcase ], [ self milliSeconds]);
}

@end


#import <objc/runtime.h>

static void reflectOnClass(Class inspectedClass, 
                  BOOL includeInheritedMethods, 
                  id methods,     // NSMutableArray or NSMutableSet
                  id properties)  // NSMutableArray or NSMutableSet
{
  while (1)
  {
    if(methods) {
      unsigned int methodCount;
      Method *methods_ = class_copyMethodList(inspectedClass, &methodCount);
      for (unsigned i=0; i<methodCount; i++)
      {
        NSString *name = [NSString stringWithFormat:@"%s", sel_getName(method_getName(methods_[i]))];
        [methods addObject: name];
      }
    }
    
    if(properties) {
      unsigned int propertyCount;
      objc_property_t *properties_ = class_copyPropertyList(inspectedClass, &propertyCount);
      
      for (unsigned i=0; i<propertyCount; i++)
      {
        NSString *name = [NSString stringWithFormat:@"%s", property_getName(properties_[i])];
        [properties addObject: name];
      }
    }
    
    if(!includeInheritedMethods || inspectedClass == [ NSObject class ]) break;
  }
}

// http://cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
static NSArray *ClassGetSubclasses(Class parentClass)
{
  int numClasses = objc_getClassList(NULL, 0);
  Class *classes = NULL;

  classes = (Class*) malloc(sizeof(Class) * numClasses);
  numClasses = objc_getClassList(classes, numClasses);
   
  NSMutableArray *result = [NSMutableArray array];
  for (NSInteger i = 0; i < numClasses; i++)
  {
    Class superClass = classes[i];
    do {
      superClass = class_getSuperclass(superClass);
    } while(superClass && superClass != parentClass);
       
    if (superClass == nil)
      continue;
       
    [result addObject:classes[i]];
  }

  free(classes);

  return result;
}

@implementation M3ETest(testMethodsForClass)

+(NSArray*) testMethodsForClass:(Class) klass
{
  NSArray* methods = [ NSMutableArray array ];
  reflectOnClass(klass, NO, methods, nil);
  
  NSMutableArray* testMethods = [ NSMutableArray array ]; 
  for(NSString* method in methods) {
    if([method hasPrefix: @"test"])
      [testMethods addObject: method];
  }
  
  return [testMethods sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end

extern "C" void m3_etest_success()
{
  _.print(".");
}

extern "C" void m3_etest_failed(NSString* msg, const char* file, int line)
{
  M3ETestAssertionFailed* exception = [[ M3ETestAssertionFailed alloc]initWithMessage: msg];

  exception.file = file;
  exception.line = line;
  
  @throw exception;
}

@implementation M3ETest

@synthesize name = name_, results = results_;

// dummy setUp and tearDown implementations
-(void) setUp { }
-(void) tearDown { }

// perform a single test
-(void) performTest: (NSString*)testName
{
  if(!self.results) self.results = [[ M3ETestResults alloc ]initWithEtest: self];

  @try {
    self.name = testName;
    [self setUp];
    [self performSelector: NSSelectorFromString(testName)];
    
    [ results_ reportSuccess ];
  }
  @catch(M3ETestAssertionFailed* exception) {
    [ results_ reportFailure: exception ];
  }
  @catch(id exception) {
    [ results_ reportException: exception ];
  }
  @finally {
    [self tearDown ];
    self.name = nil;
  }
}

-(void) run {
  NSString* etests = [[[NSProcessInfo processInfo] environment] objectForKey:@"ETESTS"];
  
  for(NSString* method in [ M3ETest testMethodsForClass: [ self class ]]) {
    if(etests && ![method matches: etests]) continue;
    
    @autoreleasepool {
      [ self performTest: method ];
    }
  }
}

+(void)runAll {
  NSArray* test_classes = ClassGetSubclasses([ M3ETest class ]);

  test_classes = [ test_classes sortedArrayUsingComparator:^NSComparisonResult(Class obj1, Class obj2) {
    return [ NSStringFromClass(obj1) compare: NSStringFromClass(obj2) ];
  } ];
  
  for(Class klass in test_classes) {
    id test = [[ klass alloc ] init ];
    [test run];
    [test release];
  }
  _.puts("");
}

@end

//
// ETest tests: they do fail intentionally, so they are disabled by default.

#if 0 

@interface M3ETestTests: M3ETest
@end


@implementation M3ETestTests
 
- (void)testWithFailedAssert
{
  assert_equal(1, 0)
}

- (void)testWithException
{
  NSLog(@"Throwing");
  @throw @"Exception";
}

@end

#endif

#endif

