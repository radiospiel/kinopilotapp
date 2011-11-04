@interface NSDate (M3Extensions) 

+(NSDate*) dateWithRFC3339String: (NSString*) string;

-(NSString*) stringWithFormat: (NSString*)format;
-(NSString*) stringWithRFC3339Format;

+(NSDate*)epoch;

+(NSDate*)dateByYear: (int)year andMonth: (int)month andDay: (int)day;

@property (readonly,nonatomic) NSUInteger year;
@property (readonly,nonatomic) NSUInteger month;
@property (readonly,nonatomic) NSUInteger day;
@property (readonly,nonatomic) NSUInteger hour;
@property (readonly,nonatomic) NSUInteger minute;
@property (readonly,nonatomic) NSUInteger second;

@property (readonly,nonatomic) NSDate* to_day;
@property (readonly,nonatomic) NSNumber* to_number;

@end
