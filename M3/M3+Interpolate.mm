#import "M3.h"


@interface M3Interpolation: NSObject
@end

@implementation M3Interpolation

+(id) resolveSingleKey: (NSString*)key fromObject: (id) object
{
  if([object isKindOfClass:[NSDictionary class]]) {
    NSDictionary* dict = (NSDictionary*)object;
    id r = [dict objectForKey:key];
    if(r) return r;
    
    if([object respondsToSelector: key.to_sym])
      return [object performSelector: key.to_sym ];
    
    return nil;
  }
  
  return [object valueForKey:key];
}

+(NSString*) resolveKey: (NSString*)key fromObject: (id)object
{
  for(NSString* part in [key componentsSeparatedByString: @"."]) {
    object = [M3Interpolation resolveSingleKey:part fromObject:object];
    if(!object)
      return [NSString stringWithFormat: @"Interpolation error: %@", [key inspect]];
  }
  
  if([object isKindOfClass:[NSString class]])
    return object;
  if([object respondsToSelector:@selector(to_s)])
    return [object performSelector: @selector(to_s)];
  if([object respondsToSelector:@selector(to_string)])
    return [object performSelector: @selector(to_string)];
  
  return [object description];
}

+(NSString*) interpolationForKey: (NSString*)key fromValues: (id)values
{
  NSArray* parts = [key componentsSeparatedByString: @":"];
  NSString* format = nil;
  
  if(parts.count == 2) {
    format = parts.first;
    key = parts.last;
  }
  
  NSString* value = [self resolveKey:key fromObject: values];
  if(!format)
    return [value htmlEscape];
  
  return value;
}

+(NSString*) interpolateString: (NSString*) templateString
                    withValues: (id) values
{
  // The regex basically matches everything in double curly braces,
  // and cuts of leading and trailing whitespace.
  NSString* regex = @"\\{\\{\\s*([^\\}]*)\\s*\\}\\}";
  
  return [templateString stringByReplacingOccurrencesOfRegex:regex
                                       usingBlock:^NSString *(NSInteger count, NSString *const *strings, const NSRange *ranges, 
                                                              volatile BOOL *const stop) {
                                         return [M3Interpolation interpolationForKey: strings[1] 
                                                                          fromValues:values
                                                 ];
                                       }];
}

@end


@implementation M3(Interpolate)


+(NSString*) interpolateString: (NSString*) templateString
                    withValues: (NSDictionary*) values;
{
  return [M3Interpolation interpolateString:templateString withValues:values ];
}

+(NSString*) interpolateFile: (NSString*) templateFile
                  withValues: (NSDictionary*) values;
{
  return [self interpolateString: [M3 read:templateFile]
                      withValues: values];
}

@end

ETest(M3Interpolate)

-(void)test_regexp_t
{
  NSString* (^tf)(NSString* foo) = ^(NSString* foo) {
    return [M3 interpolateString:foo withValues:_.hash(@"foo", @"bar")];
  };
  
  assert_equal_objects(@"foo bar foo", tf(@"foo {{foo}} foo"));
  assert_equal_objects(@"foo bar bar", tf(@"foo {{foo}} {{foo}}"));
}

-(void)test_regexp_interpolation
{
  NSDictionary* dict = _.hash(@"foo", @"bar");
  
  assert_equal(@"Interpolation error: \"key\"", [M3Interpolation resolveKey:@"key" fromObject: dict]);
  assert_equal(@"Interpolation error: \"abc.def\"", [M3Interpolation resolveKey:@"abc.def" fromObject: dict]);
  assert_equal_objects([M3Interpolation resolveKey:@"foo" fromObject: dict], @"bar");
}


-(void)test_get_subkey
{
  NSDictionary* dict = _.hash(@"sub", _.hash(@"foo", @"bar"));
  
  DLOG(dict);

  assert_equal([M3Interpolation resolveKey:@"sub.foo" fromObject: dict], @"bar");

  assert_equal(@"Interpolation error: \"key\"", [M3Interpolation resolveKey:@"key" fromObject: dict]);
  assert_equal(@"Interpolation error: \"foo\"", [M3Interpolation resolveKey:@"foo" fromObject: dict]);
  assert_equal(@"Interpolation error: \"inv.foo\"", [M3Interpolation resolveKey:@"inv.foo" fromObject: dict]);
  
  assert_equal(@"Interpolation error: \"sub.key\"", [M3Interpolation resolveKey:@"sub.key" fromObject: dict]);
  assert_equal([M3Interpolation resolveKey:@"sub.foo" fromObject: dict], @"bar");
}

@end
