
@interface NSString (Regex)

- (NSString*) gsub: (id) regexp_or_string with: (NSString*) tmpl;
- (NSArray*) matches:(id)regexp_or_string;

@end

@interface M3(Regex)

+(NSRegularExpression*) regexp: (id)regexpAsString;
+(NSRegularExpression*) regexp: (id)regexp_or_string withOptions: (int)options;

@end
