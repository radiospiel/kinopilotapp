#import "M3.h"

#import "M3-Internals.h"

@implementation M3CachedFactory

#pragma mark --- life cycle ----------------------------------------------------

-(id) initWithClass:(id)target 
        andSelector:(SEL)selector
{
  self = [super init];
  if(!self) return nil;

  target_ = [target retain];
  selector_ = selector;
  objects_ = [[NSMutableDictionary alloc]init];
  
  return self;
}

-(void)dealloc
{
  [objects_ release];
  [target_ release];
  
  [super dealloc];
}

#pragma mark --- private methods -----------------------------------------------

#define DLOG_CLASS(var) NSLog(@"%s(%d): %s is a %@", __FILE__, __LINE__, #var, [var class])

-(id)setObject: (NSObject*)object 
  forParameter: (id)parameter
{
  @synchronized(self) {
    MAZeroingWeakRef* ref = [objects_ objectForKey:parameter];
    if(ref) return ref.target;

    ref = [MAZeroingWeakRef refWithTarget:object];
    [objects_ setObject:ref
                 forKey:parameter];

    return object;
  }
}

#pragma mark --- build non retained objects ------------------------------------

-(id)buildObjectWithParameter:(id)parameter
{
  return [target_ performSelector:selector_ withObject:parameter];
}

-(id)build:(id)parameter
{
  // reuse existing objects, if any
  MAZeroingWeakRef* ref = [objects_ objectForKey:parameter];
  if(ref) return ref.target;
  
  // No existing object? Build a new one, then,
  id object = [self buildObjectWithParameter:parameter];
  return [self setObject: object forParameter: parameter];
}

-(BOOL)buildAsync: (id)parameter
         callback: (void (^)(id builtObject, BOOL didExist))callback
{
  MAZeroingWeakRef* ref = [objects_ objectForKey:parameter];
  if(ref) {
    callback(ref.target, YES);
    return YES;
  }
  
  // read the object from the cache's block
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    id object = [target_ performSelector:selector_ withObject:parameter];
    object = [self setObject:object forParameter:parameter];
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(object, NO);
    });
  });
  
  return NO;
}

#pragma mark --- create retained objects ---------------------------------------

-(id)newObject:(id)parameter
{
  return [[self build:parameter]retain];
}

-(BOOL)newObjectAsync: (id)parameter
       callback: (void (^)(id newObject, BOOL didExist))callback
{
  return [self buildAsync:parameter callback:^(id builtObject, BOOL didExist) {
    callback([builtObject retain], didExist);
  }];
}

#pragma mark --- private methods for debugging and testing purposes ------------

// returns the number of references that are nil.
-(unsigned)stats
{
  @autoreleasepool {
    unsigned count = 0;

    for(MAZeroingWeakRef* ref in objects_.allValues) {
      if(ref.target) count += 1;
    }

    return count;
  }
}

-(NSArray*)allKeys
{
  NSMutableArray* array = [NSMutableArray array];
  
  @autoreleasepool {
    for(id key in objects_) {
      MAZeroingWeakRef* ref = [objects_ objectForKey:key];
      if(ref.target) 
        [array addObject:key];
    }
  }

  return array;
}

@end

#pragma mark --- Cached factory in classes -------------------------------------

@implementation NSObject(M3CachedFactory)

+(M3CachedFactory*) cachedFactoryWithSelector: (SEL)selector
{
  NSString* factory_selector = [ @"cached." stringByAppendingString: NSStringFromSelector(selector)];
  
  return [self memoized: factory_selector.to_sym usingBlock:^() {
    M3CachedFactory* factory = [[M3CachedFactory alloc] initWithClass:self andSelector:selector];
    return [factory autorelease];
  }];
}

+(void) clearCachedFactoryWithSelector: (SEL)selector // internal, test only
{
  NSString* factory_selector = [ @"cached." stringByAppendingString: NSStringFromSelector(selector)];
  [self instance_variable_set: factory_selector.to_sym withValue: nil];
}

@end

#pragma mark --- Cached UIImage ------------------------------------------------

#if TARGET_OS_IPHONE

@implementation UIImage (M3Cached)

+(UIImage*)imageWithContentsOfURL: (NSString*)url
{
  UIImage* image = nil;
  NSString* cachePath = [NSString stringWithFormat: @"$cache/%@.bin", [M3 md5: url]];
  NSData* data = [M3Http requestData: @"GET" 
                                 url: url
                         withOptions: nil];
  
  if(!data) return nil;
  
  image = [UIImage imageWithData:data];
  if(!image) return nil;
  
  [M3 writeData: data toPath: cachePath];
  return image;
}

+(M3CachedFactory*)cachedImagesWithURL
{
  return [UIImage cachedFactoryWithSelector: @selector(imageWithContentsOfURL:)];
}

+(M3CachedFactory*)cachedImagesWithPath
{
  return [UIImage cachedFactoryWithSelector: @selector(imageWithContentsOfFile:)];
}

@end

#endif

#pragma mark --- ETest ---------------------------------------------------------

@interface M3CacheTestStruct: NSObject {
  NSString* description;
};

@property (nonatomic,retain) NSString* description;

+(id)structWithString: (NSString*)description; 

@end

static int buildCount = 0;
static int deallocCount = 0;

@implementation M3CacheTestStruct

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


ETest(M3Cache)

static M3CachedFactory* cache = nil;

-(void)setUp
{
  buildCount = deallocCount = 0;
  [M3CacheTestStruct clearCachedFactoryWithSelector: @selector(structWithString:)];
  cache = [M3CacheTestStruct cachedFactoryWithSelector:@selector(structWithString:)];
}

- (void)testCacheStats
{
  // cache is initially empty. 
  assert_true([cache stats] == 0);

  [cache build: @"foo"];
  assert_true([cache stats] == 1);
}

- (void)testAutoreleaseObjects
{
  id foo, foo2;
  
  @autoreleasepool {
    // foo, foo2 will be autoreleased
    foo = [cache build: @"foo"];
    assert_equal_int(deallocCount, 0);
    assert_true([cache stats] == 1);
    
    // building an object with the identical key
    foo2 = [cache build: @"foo"];
    assert_equal_pod(foo2, foo);
  }
  
  // releasing the autoreleasepool releases foo and consequently 
  // clear out the cache.
  assert_equal_int(deallocCount, 1);
  assert_true([cache stats] == 0);

  // Building the same object again actually builds a new object.
  // Note that foo has still the old value set, even though it does
  // no longer point to a valid object.
  foo2 = [cache build: @"foo"];
  assert_not_equal_pod(foo2, foo);
}


- (void)testManualRetain
{
  id foo;
  
  @autoreleasepool {
    foo = [[[M3CacheTestStruct alloc]initWithString: @"foo"]autorelease];
    [[foo retain]autorelease];
    [foo retain];
  }

  assert_equal_int(deallocCount, 0);
  [foo release];
  assert_equal_int(deallocCount, 1);
}

- (void)testCacheWithManualRetain
{
  id foo;
  
  @autoreleasepool {
    foo = [cache build: @"foo"];
    [foo retain];
    
    // Closing the autoreleasepool must not release foo: it is still retained
  }

  assert_equal_int(deallocCount, 0);
  assert_equal_int([cache stats], 1);

  [foo release];

  assert_equal_int(deallocCount, 1);
  assert_equal_int([cache stats], 0);
}


- (void)testCacheWithAutorelease
{
  id foo;
  
  @autoreleasepool {
    assert_equal_int(buildCount, 0);
    assert_equal_int(deallocCount, 0);

    // --- Build first piece.
    foo = [cache build: @"foo"];

    // verify cache stats
    assert_equal_int([cache stats], 1);
    assert_equal_int(buildCount, 1);
    assert_equal_int(deallocCount, 0);
    
    // --- get a different piece of content.
    id bar = [cache build: @"bar"];

    // verify cache stats
    assert_equal_int([cache stats], 2);
    assert_equal_int(buildCount, 2);
    assert_equal_int(deallocCount, 0);

    // --- fetch another reference to foo, and retain it.
    id foo2 = [cache build: @"foo"];

    assert_equal_pod(foo, foo2);        // yes, it is the same object
    assert_equal_int(buildCount, 2);    // and yes, no new object has been built
    assert_equal_int([cache stats], 2); // and yes, we have still two objects

    [foo2 retain];

    // verify cache stats

    // Closing the autoreleasepool releases both foo and bar
  }
  
  assert_equal_int(deallocCount, 1);
  assert_equal_int([cache stats], 1);

  // The final release for foo.
  [foo release];

  assert_equal_int(deallocCount, 2);
  assert_equal_int([cache stats], 0);
}

@end
