@interface NSDate (M3Extensions) 

+(NSDate*) dateWithRFC3339String: (NSString*) string;

-(NSString*) stringWithFormat: (NSString*)format;
-(NSString*) stringWithRFC3339Format;

+(NSDate*)epoch;

@property (readonly,nonatomic) NSUInteger year;
@property (readonly,nonatomic) NSUInteger month;
@property (readonly,nonatomic) NSUInteger day;
@property (readonly,nonatomic) NSUInteger hour;
@property (readonly,nonatomic) NSUInteger minute;
@property (readonly,nonatomic) NSUInteger second;

@end

@interface NSNumber (M3Extensions) 

-(NSDate*)to_date;

@end
