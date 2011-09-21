@interface NSString (Regex)

- (NSString*) gsub:  (NSString*) regexp with: (NSString*) tmpl;
- (NSString*) igsub: (NSString*) regexp with: (NSString*) tmpl;

- (NSArray*) matches: (NSString*)regexp;
- (NSArray*) imatches:(NSString*)regexp;

@end

// @interface M3(Regex)
// 
// +(NSRegularExpression*) regexp: (id)regexpAsString;
// +(NSRegularExpression*) regexp: (id)regexp_or_string withOptions: (int)options;
// 
// @end
