@interface M3(JSON)

+ (id) parseJSONData: (NSData*) data;
+ (id) parseJSON: (NSString*) data;
+ (NSString*) toJSON: (id) obj compact: (BOOL) compact;
+ (NSString*) toJSON: (id) obj;

+ (id) readJSON: (NSString*) path;
+ (void) writeJSONFile: (NSString*) path object: (id) object;

@end
