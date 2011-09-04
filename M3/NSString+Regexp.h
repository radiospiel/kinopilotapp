
@interface NSString (Regex)

- (NSString*) gsub: (id) regexp_or_string with: (NSString*) tmpl;
- (NSUInteger) matches:(id)regexp_or_string;

@end
