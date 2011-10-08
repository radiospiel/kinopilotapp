#import "M3.h"

#import "M3-Internals.h"

@implementation M3Cache

-(id)initWithBlock: (id (^)(id key))aBlock
{
  self = [super init];
  if(!self) return nil;
  
  objects_ = [[NSMutableDictionary alloc]init];
  theBlock_ = [aBlock copy];
  
  return self;
}

-(void)dealloc
{
  [objects_ release];
  [theBlock_ release];
  
  [super dealloc];
}

+(M3Cache*) cacheWithBlock: (id (^)(id key))block
{
  M3Cache* cache = [[M3Cache alloc]initWithBlock:block];
  return [cache autorelease];
}

-(id)setObject: (NSObject*)object forKey: (id)key
{
  @synchronized(self) {
    MAZeroingWeakRef* ref = [objects_ objectForKey:key];
    if(ref) return ref.target;

    [objects_ setObject:[MAZeroingWeakRef refWithTarget:object] 
                 forKey:key];

    return object;
  }
}

-(id)objectForKey: (id)key
{
  MAZeroingWeakRef* ref = [objects_ objectForKey:key];
  if(ref) return ref.target;

  return [self setObject: theBlock_(key) forKey: key];
}

-(void)asyncObjectForKey: (id)key 
                 toBlock: (void (^)(id key, BOOL instantlyAvailable))callback
{
  MAZeroingWeakRef* ref = [objects_ objectForKey:key];
  if(ref) {
    callback(ref.target, YES);
    return;
  }
  
  // read the object from the cache's block
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    id object = [self setObject: theBlock_(key) forKey: key];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(object, NO);
    });
  });
}

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


@interface M3CacheTestStruct: NSObject {
  NSString* string;
  int count;
};

@property (nonatomic,retain) NSString* string;
@property (nonatomic,assign) int count;

+(id)structWithString: (NSString*)string 
             andCount: (int)count;

@end

@implementation M3CacheTestStruct

@synthesize string, count;

-(id)initWithString: (NSString*)s 
            andCount: (int)c
{
  self = [super init];

  self.string = s; 
  self.count = c; 
  
  return self;
}

-(NSString*)description
  { return [NSString stringWithFormat:@"%d: %@", self.count, self.string]; }

+(id)structWithString: (NSString*)string 
             andCount: (int)count
  { return [[[self alloc]initWithString:string andCount:count]autorelease]; }

@end


ETest(M3Cache)

- (void)testCache
{
  @autoreleasepool {
    int __block counter = 0;
    
    M3Cache* cache = [[M3Cache alloc]initWithBlock:^(NSString* url) { 
      return [M3CacheTestStruct structWithString: url 
                                        andCount: counter++];
    }];
  
    // cache is initially empty. 
    assert_true([cache stats] == 0);

    id abc, abc2, def;
    
    @autoreleasepool {
      // get a piece of content.
      abc = [cache objectForKey:@"abc"];
      assert_equal_pod([cache stats], 1);
      assert_equal_pod([abc retainCount], 1);
      assert_equal_objects([cache allKeys], ([NSArray arrayWithObjects: @"abc", nil]));
      
      // get a different piece of content.
      def = [cache objectForKey:@"def"];
      assert_equal_objects([def description], @"1: def");
      assert_equal_pod([cache stats], 2);
      assert_equal_pod([def retainCount], 1);
      assert_equal_objects([cache allKeys], ([NSArray arrayWithObjects: @"abc", @"def", nil]));
      
      // fetch another ref to abc.
      abc2 = [cache objectForKey:@"abc"];
      assert_equal_objects([abc2 description], @"0: abc");
      assert_equal_pod([cache stats], 2);

      assert_equal_pod([abc retainCount], 2);
      assert_equal_pod(abc, abc2);
      
      assert_equal_objects([cache allKeys], 
                           ([NSArray arrayWithObjects: @"abc", @"def", nil]));
      
      // Closing the autoreleasepool should release both abc and def
    }
    
    assert_equal_pod([cache stats], 0);
  } 
}

@end

/*
 * === cached images ============================================================
 */

#if TARGET_OS_IPHONE

@interface M3Cache(ImageCaches)

+(M3Cache*) imagesByURL;
+(M3Cache*) imagesByPath;

@end

@implementation M3Cache(ImageCaches)

+(M3Cache*) imagesByURL
{
  static M3Cache* cache = nil;
  
  if(cache) return cache;
  
  @synchronized(self) {
    cache = [[M3Cache alloc]initWithBlock:^(NSString* url) { 
      return url; 
    }];
    
    return cache;
  }
}

+(M3Cache*) imagesByPath
{
  static M3Cache* cache = nil;
  
  if(cache) return cache;
  
  @synchronized(self) {
    cache = [[M3Cache alloc]initWithBlock:^(NSString* path) { 
      return [UIImage imageWithContentsOfFile: path];
    }];
    
    return cache;
  }
}

+(void)initialize
{
  [M3Cache imagesByPath];
  [M3Cache imagesByURL];
}

@end

@implementation UIImage (M3Cached)

+(void)imageWithURL: (NSString*)url
            toBlock: (void (^)(id key, BOOL instantlyAvailable))block;
{
  [[M3Cache imagesByURL] asyncObjectForKey:url toBlock:block];
}

+(UIImage*)imageWithFile: (NSString*)path
{
  return [[M3Cache imagesByPath] objectForKey:path];
}

@end

#endif
