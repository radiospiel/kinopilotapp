@interface NSString (Regex)

- (NSString*) gsub:  (NSString*) regexp with: (NSString*) tmpl;
- (NSString*) igsub: (NSString*) regexp with: (NSString*) tmpl;

- (NSArray*) matches: (NSString*)regexp;
- (NSArray*) imatches:(NSString*)regexp;

- (NSString*) gsub_:  (NSString*) regexp with: (NSString*) tmpl;
- (NSString*) igsub_: (NSString*) regexp with: (NSString*) tmpl;

/*
 * All of the methods above store the match results in a thread local
 * storage area. Later calls to NSString.getRecentMatchAtIndex: can be
 * used to retrieve these matches.
 *
 * Note: we recommend you use the $0, ... pseudo 
 */
+ (NSString*)getRecentMatchAtIndex: (NSUInteger)idx;

@end


#define $0 [NSString getRecentMatchAtIndex: 0]
#define $1 [NSString getRecentMatchAtIndex: 1]
#define $2 [NSString getRecentMatchAtIndex: 2]
#define $3 [NSString getRecentMatchAtIndex: 3]
#define $4 [NSString getRecentMatchAtIndex: 4]
#define $5 [NSString getRecentMatchAtIndex: 5]
#define $6 [NSString getRecentMatchAtIndex: 6]
#define $7 [NSString getRecentMatchAtIndex: 7]
#define $8 [NSString getRecentMatchAtIndex: 8]
#define $9 [NSString getRecentMatchAtIndex: 9]

// @interface M3(Regex)
// 
// +(NSRegularExpression*) regexp: (id)regexpAsString;
// +(NSRegularExpression*) regexp: (id)regexp_or_string withOptions: (int)options;
// 
// @end
