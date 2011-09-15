#import "M3.h"

@implementation NSString (Regexp)

- (NSString*) gsub: (id) regexp_or_string with: (NSString*) template
{
  NSRegularExpression* regexp = [ M3 regexp: regexp_or_string];

  return [regexp stringByReplacingMatchesInString:self
                                          options:0
                                            range:NSMakeRange(0, self.length)
                                     withTemplate:template];
}

- (NSUInteger) matches:(id)regexp_or_string
{
  NSRegularExpression* regexp = [ M3 regexp: regexp_or_string];
  
  return [regexp numberOfMatchesInString: self 
                                  options: 0
                                    range: NSMakeRange(0, self.length)];
                                                     
}

        
@end

@implementation M3(Regexp)

+(NSRegularExpression*) regexp: (id)regexp_or_string;
{
    if([regexp_or_string isKindOfClass: [NSRegularExpression class]])
        return regexp_or_string;
        
    NSError *error = NULL;
    return [NSRegularExpression regularExpressionWithPattern: regexp_or_string
                                                     options: 0 
                                                       error: &error];
}

@end
