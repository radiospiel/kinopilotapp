@interface M3(Callers)

+(NSArray*)callers;
+(NSArray*)callersWithLimit: (NSUInteger)limit;
+(NSString*)caller;
+(NSString*)callerWithIndex: (NSUInteger)index;
+(void)logBacktrace;

@end
