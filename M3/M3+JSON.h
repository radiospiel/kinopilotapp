@interface M3(JSON)

+ (id) parseJSON: (NSString*) data;
+ (NSString*) toJSON: (id) obj compact: (BOOL) compact;
+ (NSString*) toJSON: (id) obj;

+ (id) readJSONFile: (NSString*) path;
+ (void) writeJSONFile: (NSString*) path object: (id) object;

@end
