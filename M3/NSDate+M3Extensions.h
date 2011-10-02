@interface NSDate (M3Extensions) 

+ (NSDate*) dateWithRFC3339String: (NSString*) string;

- (NSString*) stringWithFormat: (NSString*)format;
- (NSString*) stringWithRFC3339Format;

+(NSDate*)epoch;

@end

@interface NSNumber (M3Extensions) 

-(NSDate*)to_date;

@end
