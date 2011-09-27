@interface NSDate (Rfc3339) 

+ (NSDate*) dateWithRFC3339String: (NSString*) string;

- (NSString*) stringWithFormat: (NSString*)format;
- (NSString*) to_string;

@end
