//
//  M3Data.m
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#if 0

#import "M3.h"

@implementation M3Data

+(NSString*) plainAnalyze: (id)data
{ 
  if([data isKindOfClass:[NSString class]]) return @"String";
  if([data isKindOfClass:[NSArray class]]) return @"Array";
  if([data isKindOfClass:[NSDictionary class]]) {
    NSDictionary* dictionary = data;
    NSString* type = [dictionary objectForKey:@"_type"]; 
    if([type isKindOfClass:[NSString class]])
      return [[type copy]autorelease];
    
    return @"Dictionary";
  }
  Class klass = [data class];
  
  if([klass respondsToSelector: @selector(datatype)])
    return [klass datatype];

  NSString* className = NSStringFromClass(klass);
  className = [className gsub:@"^(__)?NSCF([A-Z].*)" with:@"XX$2"];
  className = [className gsub:@"^[A-Z][A-Z0-9]([A-Z].*)" with:@"$1"];
  return className; 
}

+(NSString*) analyze: (id)data
{ 
  if([data isKindOfClass:[NSArray class]]) {
    if([data count] == 0) return @"Array";
    
    id first = [data objectAtIndex:0];
    return [M3 pluralize: [self plainAnalyze:first]];
  }

  return [self plainAnalyze:data];
}

+(NSString*) supertype:(NSString *)type
{ 
  if([type isEqualToString:@"Object"]) return nil;

  if([type matches: @"s$"]) {
    NSString* singular = [M3 singularize: type];
    if(![singular isEqualToString:type])
      return @"Array";
  }
  
  return @"Object";
}

@end

@interface M3DataTestClass: NSObject

+(NSString*) datatype;

@end

@implementation M3DataTestClass

+(NSString*) datatype
{ 
  return @"testclass"; 
}

@end

ETest(M3Data)

-(void)test_analyze
{
  
  assert_equal(@"String",     [M3Data analyze: @"s"]);
  assert_equal(@"Strings",    [M3Data analyze: _.array(@"a", @"b")]);
  assert_equal(@"Array",      [M3Data analyze: _.array()]);
  assert_equal(@"Arrays",     [M3Data analyze: _.array(_.array())]);
  assert_equal(@"Dictionary", [M3Data analyze: _.hash("key", "value")]);
  assert_equal(@"Dictionary", [M3Data analyze: _.hash()]);
  assert_equal(@"dummy",      [M3Data analyze: _.hash(@"_type", @"dummy")]);

  assert_equal(@"Men",        [M3Data analyze: _.array(_.hash(@"_type", @"Man"))]);

  assert_equal(@"Data",       [M3Data analyze: [[[M3Data alloc]init]autorelease] ]);
  assert_equal(@"testclass",  [M3Data analyze: [[M3DataTestClass new]autorelease] ]);
}

-(void)test_supertype
{
  assert_equal(@"Object", [M3Data supertype: @"Yummy"]);
  assert_true(nil == [M3Data supertype: @"Object"]);
  assert_equal(@"Array", [M3Data supertype: @"Objects"]);
}

@end

#endif
