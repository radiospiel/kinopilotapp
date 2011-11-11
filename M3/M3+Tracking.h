@interface M3(Tracking)

+(void)trackEvent: (NSString*) event 
       properties: (NSDictionary*) parameters;

+(void)trackEvent: (NSString*) event;

@end
