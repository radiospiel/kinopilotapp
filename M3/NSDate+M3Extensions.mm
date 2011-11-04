#import "M3.h"

static NSDateFormatter* dateFormatter(NSString* dateFormat) 
{
  NSMutableDictionary* tls = [[NSThread currentThread]threadDictionary];

  NSMutableDictionary* formatters = [tls objectForKey: @"m3_dateFormatters"];
  if(!formatters) {
    formatters = [NSMutableDictionary dictionary];
    [tls setObject:formatters forKey: @"m3_dateFormatters"];
  }

  NSDateFormatter* formatter = [formatters objectForKey: dateFormat];
  if(!formatter) {
    formatter = [[[NSDateFormatter alloc] init]autorelease];
    // formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"MDST"]; 
    // [NSTimeZone timeZoneForSecondsFromGMT:0];
    // formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    // formatter.locale = [NSLocale currentLocale];
    formatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]autorelease];
    formatter.dateFormat = dateFormat;
    
    [formatters setObject: formatter forKey: dateFormat];
  }

  return formatter;
}

@implementation NSDate (M3Extensions) 

+ (NSDate*) dateWithRFC3339String: (NSString*) string 
{
  // static NSDateFormatter* format25 = dateFormatter(@"yyyy-MM-dd'T'HH:mm:sszzz:00");
  // static NSDateFormatter* format22 = dateFormatter(@"yyyy-MM-dd'T'HH:mm:sszzz");
  // 
  NSDateFormatter* formatter = nil;
  switch(string.length) {
    case 22: formatter = dateFormatter(@"yyyy-MM-dd'T'HH:mm:sszzz"); break;
    case 25: formatter = dateFormatter(@"yyyy-MM-dd'T'HH:mm:sszzz:00"); break;
    default: return nil;
  }

  return [formatter dateFromString:string]; 
}

- (NSString*) stringWithFormat: (NSString*)format
{
  NSDateFormatter* formatter = dateFormatter(format);
  return [formatter stringFromDate:self];
}

-(NSString*) stringWithRFC3339Format
{
  return [self stringWithFormat: @"yyyy-MM-dd'T'HH:mm:sszzz"];
}

+(NSDate*)epoch
{
  static NSDate* epoch = [NSDate dateWithTimeIntervalSince1970: 0];
  return epoch;
}

+(NSDate*)dateByYear: (int)year andMonth: (int)month andDay: (int)day
{
  const char* tzString = "CET";
  
  NSString* dateString = [NSString stringWithFormat: @"%04d-%02d-%02d'T'00:00:00%s", year, month, day, tzString];
  return [NSDate dateWithRFC3339String: dateString];
}

#define COMPONENTS [[NSCalendar currentCalendar] components:0 fromDate:self]

-(NSUInteger) year
{
  return [COMPONENTS year];
}

-(NSUInteger) month
{
  return [COMPONENTS month];
}

-(NSUInteger) day
{
  return [COMPONENTS day];
}

-(NSUInteger) hour
{
  return [COMPONENTS hour];
}

-(NSUInteger) minute
{
  return [COMPONENTS minute];
}

-(NSUInteger) second
{
  return [COMPONENTS second];
}

-(NSDate*)to_day
{
  NSDate* day;
  
  [[NSCalendar currentCalendar] rangeOfUnit: NSDayCalendarUnit
                                  startDate: &day
                                   interval: NULL
                                    forDate: self];

  return day;
}

-(NSNumber*)to_number
{
  return [NSNumber numberWithDouble: [self timeIntervalSince1970]];
}

@end

@implementation NSNumber (M3Extensions) 

-(NSDate*)to_date
{
  return [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
}

-(NSDate*)to_day
{
  return self.to_date.to_day;
}

@end
