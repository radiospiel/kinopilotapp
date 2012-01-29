@interface M3 (Filenames)

+ (NSString*) symbolicDir: (NSString*)name;
+ (NSString*) expandPath: (NSString*)path;

+ (NSString*) dirname: (NSString*) path;
+ (NSString*) basename: (NSString*) path;
+ (NSString*) basename_wo_ext: (NSString*) path;

@end
