@interface M3CachedFactory: NSObject {
  NSMutableDictionary* objects_;

  id target_;
  SEL selector_;
}

-(id)initWithClass: (id)target andSelector: (SEL)selector;

-(id)newObject:(id)parameter;

-(id)build:(id)parameter;

-(BOOL)buildAsync: (id)parameter
         callback: (void (^)(id builtObject, BOOL didExist))callback;

-(BOOL)newObjectAsync: (id)parameter
             callback: (void (^)(id newObject, BOOL didExist))callback;

@end

@interface NSObject(M3CachedFactory)

+(M3CachedFactory*) cachedFactoryWithSelector: (SEL)selector;

@end

#if TARGET_OS_IPHONE

@interface UIImage (M3Cached)

+(UIImage*)imageWithContentsOfURL: (NSString*)url;

+(M3CachedFactory*)cachedImagesWithURL;
+(M3CachedFactory*)cachedImagesWithPath;

@end

#endif
