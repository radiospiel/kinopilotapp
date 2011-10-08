@interface M3Cache: NSObject {
  id (^theBlock_)(id key);
  NSMutableDictionary* objects_;
}

+(M3Cache*) cacheWithBlock: (id (^)(id key))block;
-(id)initWithBlock: (id (^)(id key))block;

-(id)setObject: (NSObject*)object 
        forKey: (id)key;
-(id)objectForKey: (id)key;

-(void)asyncObjectForKey: (id)key 
                 toBlock: (void (^)(id key, BOOL instantlyAvailable))block;

@end

#if TARGET_OS_IPHONE

@interface UIImage (M3Cached)

+(void)imageWithURL: (NSString*)url
            toBlock: (void (^)(id key, BOOL instantlyAvailable))block;


+(UIImage*)imageWithFile: (NSString*)path;

@end

#endif
