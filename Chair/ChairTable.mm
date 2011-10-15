//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"
#import "Underscore.hh"

@implementation ChairMaterializedView

@synthesize dictionary = dictionary_;

-(id) initWithDictionary: (ChairDictionary*) dictionary
{
  self = [super init];
  if(self) {
    self.dictionary = dictionary;
  }
  
  return self;
}

-(id) init
{
  return [self initWithDictionary: [ChairDictionary dictionary]];
}

-(void)dealloc
{
  self.dictionary = nil;
  [super dealloc];
}

-(void)do_update {
  if(!source_view_) return;
  
  NSMutableArray* values = [NSMutableArray array];
  NSMutableArray* keys = [NSMutableArray array];
  
  [source_view_ each:^(id value, id key) {
    [values addObject: value];
    [keys addObject: key];
  }];
  
  self.dictionary = [[[ChairDictionary alloc] initWithObjects: values andKeys: keys]autorelease];
  
  revision_ += 1;
}

- (void) each: (void (^)(NSDictionary* value, id key)) iterator
          min: (id)min
          max: (id)max
 excludingEnd: (BOOL)excludingEnd;
{
  [super update];
  
  [dictionary_ each: iterator
                 min: min
                 max: max 
        excludingEnd: excludingEnd 
 ];
}

/**

 TODO: add a count implementation for ChairMultiDictionaries.
 
 */
@end

/**
 
 A ChairTable is a view which has own storage: it keeps all entries

 */

@implementation ChairTable

@synthesize name = name_;

- (id) initWithName: (NSString*) name {
  self = [super init];
  self.name = name;
  
  return self;
}

-(id)upsert:(NSDictionary *)record {
  return [self upsert:record withKey: nil];
}

-(id)upsert:(NSDictionary *)record withKey:(NSString *)key {
  if(!record && !key)
    _.raise("Needs record OR key");
  
  if(record)
    key = [Chair uid: record];
  
  [dictionary_ setObject: record forKey: key];
  
  revision_ += 1;
  return record ? key : nil;
}

-(NSArray*)keys
{
  return [dictionary_ keys];
}

-(NSString*) description
{
  NSString* format = @"<%@: %ld records>";
  return [NSString stringWithFormat: format, self.name, dictionary_.count];
}

// -- I/O --------------------------------------------------------

-(void) saveToFile:(NSString*) path
{
  // Benchmark(_.join(@"save to file ", [M3 basename: path]));
  
  NSMutableDictionary* extraData = _.hash(@"revision", [NSNumber numberWithInt:self.revision]);
  
  [self.dictionary saveToJSONFile: path 
                    withExtraData: extraData ];
}

-(void)loadFromFile: (NSString*)path
{
  // Benchmark(_.join(@"load from file ", [M3 basename: path]));

  NSMutableDictionary* extraData = [NSMutableDictionary dictionary];
  self.dictionary = [[[ChairDictionary alloc]initWithJSONFile: path withExtraData: extraData] autorelease];
  
  NSNumber* revision = [extraData objectForKey: @"revision"];
  
  M3AssertKindOf(revision, NSNumber);
                 
  self.revision = [revision intValue];
}

+(ChairTable*) table 
{
  return [[[ChairTable alloc]init]autorelease];
}

+(ChairTable*) tableWithFile:(NSString*) path 
{
  ChairTable* table =  [ChairTable table];
  table.name = [M3 basename_wo_ext: path];
  [table loadFromFile: path];
  return table;
}

@end
