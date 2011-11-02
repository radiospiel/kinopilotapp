@interface M3(Interpolate)

+(NSString*) interpolateString: (NSString*) templateString
                    withValues: (NSDictionary*) values;

+(NSString*) interpolateFile: (NSString*) templateFile
                  withValues: (NSDictionary*) values;

@end
