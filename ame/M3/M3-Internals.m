#import "M3.h"
#import "M3-Internals.h"

#define COREFOUNDATION_HACK_LEVEL 0
#define KVO_HACK_LEVEL 0

#import "MAZeroingWeakRef/MAZeroingWeakRef.m"

#pragma mark --- M3Internals embedded tests -----------------------------------

@interface M3InternalsTestStruct: NSObject {
  NSString* description;
};

@property (nonatomic,retain) NSString* description;

+(id)structWithString: (NSString*)description; 

@end

static int buildCount = 0;
static int deallocCount = 0;

@implementation M3InternalsTestStruct

@synthesize description;

-(id)initWithString: (NSString*)s 
{
  buildCount++; 

  self = [super init];
  self.description = s; 
  
  return self;
}

-(void)dealloc
{
  deallocCount++;
  
  self.description = nil;
  [super dealloc];
}

+(id)structWithString: (NSString*)string 
{ 
  return [[[self alloc]initWithString:string]autorelease]; 
}

@end

@interface NSObject(Internals)

+(void) clearCachedFactoryWithSelector: (SEL)selector; // internal, test only

@end

#if 0 

ETest(M3Internals)

-(void)setUp
{
  buildCount = deallocCount = 0;
  [M3InternalsTestStruct clearCachedFactoryWithSelector: @selector(structWithString:)];
}

- (void)testBasicDealloc
{
  id foo = [[M3InternalsTestStruct alloc]initWithString: @"foo"];
  [foo release];

  assert_equal_int(deallocCount, 1);
}

- (void)testWeakRefWithRetain
{
  id foo = [[M3InternalsTestStruct alloc]initWithString: @"foo"];

  MAZeroingWeakRef* ref = [[MAZeroingWeakRef refWithTarget: foo] retain];

  assert_equal_int(deallocCount, 0);
  assert_equal_pod(foo, ref.target);
  
  [foo release];

  assert_nil(ref.target);
  assert_equal_int(deallocCount, 1);
  
  [ref release];
}

@end

#endif
