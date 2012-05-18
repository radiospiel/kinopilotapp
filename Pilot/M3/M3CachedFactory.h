@interface M3CachedFactory: NSObject {
  NSMutableDictionary* objects_;

  id target_;
  SEL selector_;
}

-(id)initWithClass: (id)target andSelector: (SEL)selector;

-(id)build:(id)parameter;

-(BOOL)buildAsync: (id)parameter
     withCallback: (void (^)(id builtObject, BOOL didExist))callback;

-(BOOL)buildAsync: (id)parameter
       withTarget: (id)target
      andSelector: (SEL)selector;

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
