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
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = dateFormat;
    
    [formatters setObject: formatter forKey: dateFormat];
  }

  return formatter;
}

@implementation NSDate (Rfc3339) 

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

- (NSString*) to_string
{
  return [self stringWithFormat: @"yyyy-MM-dd'T'HH:mm:sszzz"];
}

@end
