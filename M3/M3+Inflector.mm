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

@interface M3Inflector: NSObject {
  NSDictionary *irregulars, *reverse_irregulars;
  NSMutableSet* uncountables;
  NSMutableArray* plurals;
  NSMutableArray* singulars;
}

-(NSString*)pluralize: (NSString*) string;
-(NSString*)singularize: (NSString*) string;
-(NSString*)humanize: (NSString*) string;

-(void)preloadInflectorData;

@end

@implementation M3(Inflector)

static M3Inflector* inflector()
{
  static M3Inflector* inflector = 0;
  
  if(!inflector)
    inflector = [[M3Inflector alloc]init];

  return inflector;
}

+ (NSString*)pluralize: (NSString*) string;
{
  return [inflector() pluralize:string];
}

+ (NSString*)singularize: (NSString*) string;
{
  return [inflector() singularize:string];
}

+ (NSString*)humanize: (NSString*) string;
{
  return [inflector() humanize:string];
}

@end

ETest(M3Inflector)


-(void)test_inflector
{
	assert_equal([M3 pluralize: @"Cat"], @"Cats");
	assert_equal([M3 pluralize: @"bus"], @"buses");
	assert_equal([M3 pluralize: @"man"], @"men");
  
	assert_equal([M3 singularize: @"Cats"], @"Cat");
	assert_equal([M3 singularize: @"buses"], @"bus");
	assert_equal([M3 singularize: @"men"], @"man");
}

@end


@implementation M3Inflector

-(id)init {
  if(!(self = [ super init ])) return nil;

  irregulars = [[ NSMutableDictionary dictionary ] retain];
  reverse_irregulars = [[ NSMutableDictionary dictionary ] retain];
  
  plurals = [[ NSMutableArray array ] retain];
  singulars = [[ NSMutableArray array ] retain];
  uncountables = [[ NSMutableArray array ] retain];

  [ self preloadInflectorData ];
  return self;
}

-(void)dealloc {
  [irregulars release];
  [reverse_irregulars release];
  [plurals release];
  [singulars release];
  [uncountables release];

  [super dealloc];
}

-(NSString*)pluralize: (NSString*) string;
{
  if([uncountables containsObject: string]) return string;
  
  NSString* irregular_plural = [irregulars objectForKey: string];
  if(irregular_plural) 
    return irregular_plural;
  
  for(NSArray* regexp_and_repl in [plurals reverseObjectEnumerator]) {
    NSRegularExpression* regexp = [regexp_and_repl objectAtIndex:0];
    NSString* replacement = [regexp_and_repl objectAtIndex:1];
    
    if([ string matches: regexp])
      return [string gsub: regexp with: replacement];
  }

  return string;
}

-(NSString*)singularize: (NSString*) string;
{
  if([uncountables containsObject: string]) return string;
  
  NSString* irregular_singular = [reverse_irregulars objectForKey: string];
  if(irregular_singular) 
    return irregular_singular;
  
  for(NSArray* regexp_and_repl in [singulars reverseObjectEnumerator]) {
    NSRegularExpression* regexp = [regexp_and_repl objectAtIndex:0];
    NSString* replacement = [regexp_and_repl objectAtIndex:1];
    
    if([ string matches: regexp])
      return [string gsub: regexp with: replacement];
  }
  
  return string;
}


// With thanks to https://github.com/ciaran/inflector
- (NSString*)humanize:(NSString*)word;
{
	NSString* result = word;
	if([result length] > 3 && [[result substringFromIndex:([result length]-3)] isEqualToString:@"_id"])
		result = [result substringToIndex:([result length]-3)];
	result = [result stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	return [[[result substringToIndex:1] uppercaseString] stringByAppendingString:[result substringFromIndex:1]];
}

// With thanks to https://github.com/ciaran/inflector
-(void)preloadInflectorData;
{
  
#define irregular(a, b) [ irregulars setValue: b forKey: a ]; [ reverse_irregulars setValue: a forKey: b]
  
  irregular(@"person", @"people");
  irregular(@"man", @"men");
  irregular(@"child", @"children");
  irregular(@"sex", @"sexes");
  irregular(@"move", @"moves");

#define plural(a, b) [plurals addObject: [ NSArray arrayWithObjects: [M3 regexp: a], b, nil ]]
  
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

#define singular(a, b) [singulars addObject: [ NSArray arrayWithObjects: [M3 regexp: a], b, nil ]]

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

#define uncountable(a) [uncountables addObject: a ]

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

