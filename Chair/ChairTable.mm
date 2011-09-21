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

-(id) init;
{
  self = [super init];
  if(self) {
    dictionary_ = [[ChairDictionary alloc] init];
  }
  
  return self;
}

-(id) initWithDictionary: (ChairDictionary*) dictionary;
{
  self = [super init];
  if(self) {
    self.dictionary = dictionary;
  }
  
  return self;
}

-(void)dealloc
{
  LOG_DEALLOC;

  self.dictionary = nil;
  [super dealloc];
}

-(void)do_update {
  if(!source_view_) return;
  
  NSMutableArray* values = [NSMutableArray array];
  NSMutableArray* keys = [NSMutableArray array];
  
  NSUInteger old_revision = revision_;
  
  [source_view_ each:^(id value, id key) {
    [values addObject: value];
    [keys addObject: key];
  }];
  
  self.dictionary = [[[ChairDictionary alloc] initWithObjects: values andKeys: keys]autorelease];
  
  revision_ = old_revision + 1;
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
  if(!(self = [super init])) return nil;
  
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

-(NSString*) description
{
  return [NSString stringWithFormat:  @"<%@: %ld dependants, %ld records>", 
                                      self.name,
                                      dependant_objects_.count,
                                      dictionary_.count];
}

// -- NSCoding --------------------------------------------------------

-(void) encodeWithCoder: (NSCoder *)coder { 
  [coder encodeObject: self.dictionary forKey: @"dictionary"];
} 

-(id) initWithCoder: (NSCoder *)coder { 
  if (self = [super init]) { 
    self.dictionary = [coder decodeObjectForKey:@"dictionary"]; 
  } 
  return self; 
}

+(ChairTable*) tableWithFile:(NSString*) path {
  NSDictionary * rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path]; 

  ChairTable* table = [rootObject valueForKey:@"table"];
  table.name = [M3 basename_wo_ext: path];
  return table;
}

-(void) saveToFile:(NSString*) path;
{
  NSMutableDictionary * rootObject = _.hash(@"table", self);
  [NSKeyedArchiver archiveRootObject: rootObject toFile: path]; 
}

@end
