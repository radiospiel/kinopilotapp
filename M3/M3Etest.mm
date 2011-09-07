#import "M3.h"

@interface M3ETestResults: M3StopWatch {
  M3ETest* etest_;
  NSString* current_test_;
}

@property (nonatomic,retain) NSString* current_test;

@end

@implementation M3ETestResults

@synthesize current_test = current_test_;

-(id)initWithEtest: (M3ETest*)etest {
  if(!(self = [ super init ])) return nil;
  
  etest_ = etest;
  return self;
}

-(void)dealloc
{
  self.current_test = nil;
}

-(void)startTest:(NSString*)name;
{
  [self startWatch];
  self.current_test = name;
}

-(void)reportFailure:(NSString*)reason
{
  NSLog(@"Test Case '-[%@ %@]' failed (%.3f seconds).", [ etest_ class ], current_test_, [self seconds]);
  // NSLog(@"%@: Failure: after %.1f msecs", current_test_, [self milliSeconds]);
  // NSLog(@"%@", reason);
}

-(void)reportException:(NSString*)exception
{
  NSLog(@"Test Case '-[%@ %@]' failed (%.3f seconds).", [ etest_ class ], current_test_, [self seconds]);
  // NSLog(@"%@: Exception: after %.1f msecs", current_test_, [self milliSeconds]);
  // NSLog(@"%@", exception);
}

-(void)reportSuccess;
{
  NSLog(@"Test Case '-[%@ %@]' passed (%.3f seconds).", [ etest_ class ], current_test_, [self seconds]);
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

@implementation M3ETest(testMethodsForClass)

+(NSArray*) testMethodsForClass:(Class) klass
{
  NSArray* methods = [ NSMutableArray array ];
  reflectOnClass(klass, NO, methods, nil);
  
  NSMutableArray* testMethods = [ NSMutableArray array ]; 
  for(NSString* method in methods) {
    if([method matches: @"^-test"])
      [testMethods addObject: method];
  }
  
  return [testMethods sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end

@interface M3ETestAssertionFailed: NSException
@end

@implementation M3ETestAssertionFailed

@end

@implementation M3ETest

// dummy setUp and tearDown implementations
-(void) setUp { }
-(void) tearDown { }

// perform a single test
-(void) performTest: (NSString*)testName
{
  if(!results_) results_ = [[ M3ETestResults alloc ]init];

  @try {
    name_ = testName;
    [self setUp];
    [self performSelector: NSSelectorFromString(testName)];
    [ results_ reportSuccess ];
  }
  @catch(M3ETestAssertionFailed* exception) {
    [ results_ reportFailure: [exception description] ];
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

@end

//
// Event Tests

@interface M3EventsTests: M3ETest
@end


@implementation M3EventsTests
 
- (void)testEachWithEmptyArray
{
  // STFail(@"Hoho: intentional failure.");
}


@end
