//
//  M3Inflector.m
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//
// Pieces of that code are based on https://github.com/ciaran/inflector:
//
// - M3Inflector#humanize
// - M3Inflector#preloadInflectorData's data
 
#import "M3.h"

static NSMutableSet* uncountables = nil;
static NSMutableArray* plurals = nil;
static NSMutableArray* singulars = nil;

@interface M3Inflector: NSObject 

+(NSString*)pluralize: (NSString*) string;
+(NSString*)singularize: (NSString*) string;
+(NSString*)humanize: (NSString*) string;

@end

@implementation M3(Inflector)

+ (NSString*)pluralize: (NSString*) string;
{
  return [M3Inflector pluralize:string];
}

+ (NSString*)singularize: (NSString*) string;
{
  return [M3Inflector singularize:string];
}

+ (NSString*)humanize: (NSString*) string;
{
  return [M3Inflector humanize:string];
}

@end

@implementation M3Inflector

+(NSString*)pluralize: (NSString*) string;
{
  for(NSString* regexp in uncountables) {
    if([string imatches: regexp]) return string;
  }
  
  for(NSArray* regexp_and_repl in [plurals reverseObjectEnumerator]) {
    NSString* regexp = [regexp_and_repl objectAtIndex:0];
    NSString* replacement = [regexp_and_repl objectAtIndex:1];
    
    if([ string imatches: regexp])
      return [string igsub: regexp with: replacement];
  }

  return string;
}

+(NSString*)singularize: (NSString*) string;
{
  for(NSString* regexp in uncountables) {
    if([string matches: regexp]) return string;
  }

  for(NSArray* regexp_and_repl in [singulars reverseObjectEnumerator]) {
    NSString* regexp = [regexp_and_repl objectAtIndex:0];
    NSString* replacement = [regexp_and_repl objectAtIndex:1];
    
    if([ string imatches: regexp])
      return [string igsub: regexp with: replacement];
  }
  
  return string;
}


// With thanks to https://github.com/ciaran/inflector
+ (NSString*)humanize:(NSString*)word;
{
	NSString* result = word;
	if([result length] > 3 && [[result substringFromIndex:([result length]-3)] isEqualToString:@"_id"])
		result = [result substringToIndex:([result length]-3)];
	result = [result stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	return [[[result substringToIndex:1] uppercaseString] stringByAppendingString:[result substringFromIndex:1]];
}

#define regexp(a) a

// With thanks to https://github.com/ciaran/inflector
+(void)initialize
{
  plurals = [[ NSMutableArray array ] retain];
  singulars = [[ NSMutableArray array ] retain];
  uncountables = [[ NSMutableArray array ] retain];

#define plural(a, b) [plurals addObject: [ NSArray arrayWithObjects: regexp(a), b, nil ]]
  
  plural(@"$", @"s");
  plural(@"s$", @"s");
  plural(@"(ax|test)is$", @"$1es");
  plural(@"(octop|vir)us$", @"$1i");
  plural(@"(alias|status)$", @"$1es");
  plural(@"(bu)s$", @"$1ses");
  plural(@"(buffal|tomat)o$", @"$1oes");
  plural(@"([ti])um$", @"$1a");
  plural(@"sis$", @"ses");
  plural(@"(?:([^f])fe|([lr])f)$", @"$1$2ves");
  plural(@"(hive)$", @"$1s");
  plural(@"([^aeiouy]|qu)y$", @"$1ies");
  plural(@"(x|ch|ss|sh)$", @"$1es");
  plural(@"(matr|vert|ind)ix|ex$", @"$1ices");
  plural(@"([m|l])ouse$", @"$1ice");
  plural(@"^(ox)$", @"$1en");
  plural(@"(quiz)$", @"$1zes");

  /* irregular words */
  
  plural(@"(p)erson$", @"$1eople");
  plural(@"(m)ove$", @"$1oves");
  plural(@"(s)ex$", @"$1exes");
  plural(@"(c)hild$", @"$1hildren");
  plural(@"(m)an$", @"$1en");

#define singular(a, b) [singulars addObject: [ NSArray arrayWithObjects: regexp(a), b, nil ]]

	singular(@"s$", @"");
	singular(@"(n)ews$", @"$1ews");
	singular(@"([ti])a$", @"$1um");
	singular(@"((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$", @"$1$2sis");
	singular(@"(^analy)ses$", @"$1sis");
	singular(@"([^f])ves$", @"$1fe");
	singular(@"(hive)s$", @"$1");
	singular(@"(tive)s$", @"$1");
	singular(@"([lr])ves$", @"$1f");
	singular(@"([^aeiouy]|qu)ies$", @"$1y");
	singular(@"(s)eries$", @"$1eries");
	singular(@"(m)ovies$", @"$1ovie");
	singular(@"(x|ch|ss|sh)es$", @"$1");
	singular(@"([m|l])ice$", @"$1ouse");
	singular(@"(bus)es$", @"$1");
	singular(@"(o)es$", @"$1");
	singular(@"(shoe)s$", @"$1");
	singular(@"(cris|ax|test)es$", @"$1is");
	singular(@"(octop|vir)i$", @"$1us");
	singular(@"(alias|status)es$", @"$1");
	singular(@"^(ox)en", @"$1");
	singular(@"(vert|ind)ices$", @"$1ex");
	singular(@"(matr)ices$", @"$1ix");
	singular(@"(quiz)zes$", @"$1");

  /* irregular words */
  
  singular(@"(p)eople$", @"$1erson");
  singular(@"(m)oves$", @"$1ove");
  singular(@"(s)exes$", @"$1ex");
  singular(@"(c)hildren$", @"$1hild");
  singular(@"(m)en$", @"$1an");

#define uncountable(a) [uncountables addObject: regexp(a) ]

  uncountable(@"equipment");
  uncountable(@"information");
  uncountable(@"rice");
  uncountable(@"money");
  uncountable(@"species");
  uncountable(@"series");
  uncountable(@"fish");
  uncountable(@"sheep");
}

@end

#if 0

ETest(M3Inflector)

-(void)test_inflector
{
	assert_equal([M3 pluralize: @"Man"], @"Men");
	assert_equal([M3 pluralize: @"Cat"], @"Cats");
	assert_equal([M3 pluralize: @"bus"], @"buses");
	assert_equal([M3 pluralize: @"man"], @"men");
  
	assert_equal([M3 singularize: @"Cats"], @"Cat");
	assert_equal([M3 singularize: @"buses"], @"bus");
	assert_equal([M3 singularize: @"men"], @"man");
}

@end

#endif
