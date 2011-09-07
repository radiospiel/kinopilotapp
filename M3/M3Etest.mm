#import "M3.h"

@interface M3ETestAssertionFailed: NSObject {
  const char* expression;
  const char* file;
  int line;
}

@property (nonatomic,assign) const char* expression;
@property (nonatomic,assign) const char* file;
@property (nonatomic,assign) int line;

@end

@implementation M3ETestAssertionFailed

@synthesize expression;
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

-(void)reportFailure:(M3ETestAssertionFailed*)exception
{
  NSLog(@"Test Case '%@' failed (%d msecs).", [ self testcase ], [self milliSeconds]);
  NSLog(@"%s(%d): assertion %s failed.", exception.file, exception.line, exception.expression);
}

-(void)reportException:(NSString*)exception
{
  NSLog(@"ETest Case '%@' crashed (%d msecs).", [ self testcase ], [self milliSeconds]);
  NSLog(@"Exception: %@", exception);
}

-(NSString*) testcase
{
  return [NSString stringWithFormat: @"-[%@ %@]", [ etest_ class ], [ etest_ name ]];
}

-(void)reportSuccess
{
  NSLog(@"ETest Case '%@' passed after %d msecs", [ self testcase ], [ self milliSeconds]);
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
    if([method matches: @"^test"])
      [testMethods addObject: method];
  }
  
  return [testMethods sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end

static M3ETest* currentEtest = nil;

@implementation M3ETest

@synthesize name = name_;

+(void) do_assert: (BOOL)expr 
         asString: (const char*) expression
           inFile: (const char*) file
           atLine: (int)line;
{
  if(expr) return;
  
  M3ETestAssertionFailed* exception = [[ M3ETestAssertionFailed alloc]init];
  exception.expression = expression;
  exception.file = file;
  exception.line = line;
  
  @throw exception;
}

// dummy setUp and tearDown implementations
-(void) setUp { }
-(void) tearDown { }

// perform a single test
-(void) performTest: (NSString*)testName
{
  if(!results_) results_ = [[ M3ETestResults alloc ]initWithEtest: self];

  currentEtest = self;
  
  @try {
    name_ = testName;
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
    name_ = nil;
    [self tearDown ];
  }
}

-(void) run {
  for(NSString* method in [ M3ETest testMethodsForClass: [ self class ]]) {
    [ self performTest: method ];
  }
}

+(void)runAll {
  for(Class klass in ClassGetSubclasses([ M3ETest class ])) {
    id test = [[ klass alloc ] init ];
    [test run];
    [test release];
  }
}

@end

//
// Event Tests

@interface M3EventsTests: M3ETest
@end


@implementation M3EventsTests
 
- (void)testWithFailedAssert
{
  m3assert(1 == 0);
}

- (void)testWithException
{
  NSLog(@"Throwing");
  @throw @"Exception";
}

@end
