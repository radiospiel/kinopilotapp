@interface M3(Interpolate)

+(NSString*) interpolateString: (NSString*) templateString
                    withValues: (id) values;

+(NSString*) interpolateFile: (NSString*) templateFile
                  withValues: (id) values;

@end
