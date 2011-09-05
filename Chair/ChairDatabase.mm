//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"
#import "Underscore.hh"

@implementation ChairDatabase

-(id)init {
  self = [super init];
  if(!self) return nil;
   
  tables_ = [[NSMutableDictionary alloc] init]; 
  return self;
}

-(NSString*)description {
  return [NSString stringWithFormat: @"<%@: %d table(s)>", [self class], tables_.count];
}

-(void)dealloc {
  LOG_DEALLOC;
  
  [tables_ release];
  [super dealloc];
}

+(ChairDatabase*) database 
{
  ChairDatabase* database = [[self alloc] init];
  return AUTORELEASE(database);
}

+(ChairTable*) tableForDictionary_: (NSMutableDictionary*) tables 
                           andName: (NSString*) name 
{
  ChairTable* table = [tables objectForKey: name];
  if(!table) {
    table = [[ChairTable alloc] initWithName: name]; 
    [tables setObject: table forKey: name];
    [table release];
  }
  
  return table;
}

-(ChairTable*) tableForName: (NSString*) name {
  return [ChairDatabase tableForDictionary_: tables_ andName: name];
}

//
// replace all tables with tables in \a tables

-(void) mergeTables: (NSMutableDictionary*) tables
{
  for(NSString* name in tables) {
    ChairTable* table = [tables objectForKey: name];
    ChairTable* old_table = [tables_ objectForKey: name];
    if(old_table && old_table.revision > table.revision) {
      table.revision = old_table.revision + 1; 
    }
    
    [tables_ setObject: table forKey:name];
  }
}

-(void) import: (NSString*) path
{
  NSArray* entries = [M3 readJSONFile: path];
  if(![entries isKindOfClass: [NSArray class]])
    _.raise("Cannot read file", path);
  
  NSMutableDictionary* tables = [[NSMutableDictionary alloc] init]; 

  for(id entry in entries) {
    
    // Add dictionaries into the respective table.
    if([entry isKindOfClass: [NSDictionary class]]) {
      NSString* table_name = [entry objectForKey: @"_type"];
      ChairTable* table = [ChairDatabase tableForDictionary_: tables 
                                                     andName: table_name];
     
      [table upsert: entry];
      continue;
    }

    // The header part of the dump might have additional Array
    // entries describing the dump. These are
    //
    // - [diff, { revision: 365005, type: dump }]
    //   This dump is a diff, of type dump, at revision 365005.
    //
    // - [table, theaters]
    //   This input holds values for theaters.
    //
    // We can safely ignore these entries.
  }

  [self mergeTables: tables];
  [tables release];
}

-(void) export: (NSString*) path
{
  NSMutableArray* entries = [NSMutableArray array];
  
  // TODO: Add header record
  
  for(NSString* name in tables_) {
    ChairTable* table = [tables_ objectForKey: name];
    [table each:^(NSDictionary* value, id key) {
      NSMutableDictionary* record = [NSMutableDictionary dictionaryWithDictionary: value];
      [record setObject: name forKey: @"_type"];
      [entries addObject: record];
    }];
  }

  [M3 writeJSONFile:path object: entries];
}

-(void) save: (NSString*) basedir
{
  basedir = [M3 expandPath: basedir];
  [M3 mkdir_p: basedir];
  
  for(NSString* name in tables_) {
    ChairTable* table = [tables_ objectForKey: name];
    [table saveToFile: _.join(basedir, "/", name, ".bin")];
  }
}

-(void) load: (NSString*) basedir
{
  basedir = [M3 expandPath: basedir];
  
  NSMutableDictionary *tables = [[NSMutableDictionary alloc] init];
  
  NSArray* dbfiles = [NSArray arrayWithFilesMatchingPattern: @"*.bin" inDirectory: basedir];
  
  for(NSString* file in dbfiles) {
    ChairTable* table = [ChairTable tableWithFile: file];
    [tables setObject: table forKey: table.name];
  }
  
  [self mergeTables: tables];
  [tables release];
}

@end
