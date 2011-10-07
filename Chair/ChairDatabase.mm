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
  if((self = [super init])) {
    tables_ = [[NSMutableDictionary alloc] init]; 
  };
  
  return self;
}

-(NSString*)description {
  return [NSString stringWithFormat: @"%d table(s): %@", tables_.count, tables_.allValues.inspect];
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

+(ChairTable*) tableWithName: (NSString*) name 
                  inDictionary: (NSMutableDictionary*)tables
{
  ChairTable* table = [tables objectForKey: name];
  if(!table) {
    table = [[[ChairTable alloc] initWithName: name]autorelease]; 
    [tables setObject: table forKey: name];
  }
  
  return table;
}

-(ChairTable*) tableForName: (NSString*) name {
  return [ChairDatabase tableWithName: name inDictionary: tables_];
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
  NSArray* entries = [M3 readJSON: path];
  if(![entries isKindOfClass: [NSArray class]])
    _.raise("Cannot read file", path);

  Benchmark(_.join("*** import data ", path));

  NSMutableDictionary* tables = [[NSMutableDictionary alloc] init]; 

  // [self emit: @selector(progress)];
  
  Class dictionaryClass = [NSDictionary class];
  
  for(NSDictionary* entry in entries) {
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
    
    // Add dictionaries into the respective table.
    if(![entry isKindOfClass: dictionaryClass]) 
      continue;
    
    NSString* table_name = [entry objectForKey: @"_type"];
    ChairTable* table = [ChairDatabase tableWithName:table_name inDictionary: tables];
    [table upsert: entry];
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
    dlog << "table " << table.name << _.ptr(table);
    
    [table saveToFile: _.join(basedir, "/", name, ".json")];
  }
}

-(void) load: (NSString*) basedir
{
  basedir = [M3 expandPath: basedir];
  
  NSMutableDictionary *tables = [[NSMutableDictionary alloc] init];
  
  NSArray* dbfiles = [NSArray arrayWithFilesMatchingPattern: @"*.json" inDirectory: basedir];
  
  for(NSString* file in dbfiles) {
    ChairTable* table = [ChairTable tableWithFile: file];
    [tables setObject: table forKey: table.name];
  }
  
  [self mergeTables: tables];
  [tables release];
}

@end


@implementation NSDictionary(ChairDatabaseAdditions)

-(NSMutableDictionary*) joinWith: (ChairView*)view 
                              on: (NSString*)foreign_key 
                           inner: (BOOL)innerJoin
{
  id foreign_id = [self objectForKey: foreign_key];
  NSArray* foreign_records = [view valuesWithKey: foreign_id];
  NSDictionary* foreign_record = foreign_records.first;

  if(foreign_record) {
    NSMutableDictionary* joined_record = [NSMutableDictionary dictionaryWithDictionary:foreign_record];
    [joined_record addEntriesFromDictionary:self];
    return joined_record;
  }

  if(!innerJoin)
    return [NSMutableDictionary dictionaryWithDictionary:self];
  
  return nil;
}

-(NSMutableDictionary*) joinWith: (ChairView*)view 
                              on: (NSString*)key
{
  return [self joinWith:view on: key inner:NO];
}

-(NSMutableDictionary*) innerJoinWith: (ChairView*)view 
                                   on: (NSString*)key
{
  return [self joinWith:view on: key inner:YES];
}

@end

@implementation NSArray(ChairDatabaseAdditions)

-(NSArray*) joinWith: (ChairView*)view 
                  on: (NSString*)foreign_key 
               inner: (BOOL)innerJoin
{
  NSMutableArray* r = [NSMutableArray arrayWithCapacity: self.count];
  
  for(NSDictionary* record in self) {
    id foreign_id = [record objectForKey: foreign_key];
    NSArray* foreign_records = [view valuesWithKey: foreign_id];
    if([foreign_records count] == 0) {
      if(!innerJoin)
        [r addObject: [NSMutableDictionary dictionaryWithDictionary:record]];
      continue;
    }
    
    for(NSDictionary* foreign_record in foreign_records) {
      NSMutableDictionary* joined_record = [NSMutableDictionary dictionaryWithDictionary:foreign_record];
      [joined_record addEntriesFromDictionary:record];
      [r addObject: joined_record];
    }
  }
  
  return r;
}

-(NSArray*) joinWith: (ChairView*)view 
                  on: (NSString*)key
{
  return [self joinWith:view on: key inner:NO];
}

-(NSArray*) innerJoinWith: (ChairView*)view 
                       on: (NSString*)key
{
  return [self joinWith:view on: key inner:YES];
}
@end


ETest(ChairDatabase)

- (void)test_import_table
{
  ChairDatabase* db = [ChairDatabase database];

  [db import: @"fixtures/theaters.json"];
  ChairTable* theaters = [db tableForName: @"theaters"];
  assert_equal(13, theaters.count);
}

-(void)test_import_load_and_save
{
  ChairDatabase* db = [ChairDatabase database];

  
  // [db import: @"fixtures/flk.json"];
  [db save: @"tmp/"];
  [db load: @"tmp"];
}

-(void)test_import
{
  ChairDatabase* db = [ChairDatabase database];
                       
  [db import: @"fixtures/flk.json"];

  ChairTable* theaters = [db tableForName: @"theaters"];
  assert_equal(13, theaters.count);

  ChairTable* schedules = [db tableForName: @"schedules"];
  assert_equal(102, schedules.count);

  ChairTable* movies = [db tableForName: @"movies"];
  assert_equal(83, movies.count);
}

-(void)test_import_from_server
{
  rlog(2) << [self class] << ": test disabled " << [self name];
  return;
  
  ChairDatabase* db = [[ChairDatabase alloc] init];
  {
    Benchmark(@"Importing http://kinopilotupdates2.heroku.com/db/berlin");
    [db import: @"http://kinopilotupdates2.heroku.com/db/berlin"];
  }
  
  dlog << "Read database " << db;
  
  ChairTable* theaters = [db tableForName: @"theaters"];
  DLOG(theaters);
  assert_true(theaters.count > 0);

  ChairTable* schedules = [db tableForName: @"schedules"];
  DLOG(schedules);
  assert_true(schedules.count > 0);

  ChairTable* movies = [db tableForName: @"movies"];
  DLOG(movies);
  assert_true(movies.count > 0);
}

-(void)test_alloc_and_release
{
  ChairDatabase* db = [ChairDatabase database];
  ChairTable* schedules = [db tableForName: @"schedules"];

  [schedules viewWithMap:nil andReduce:nil];
  ChairView* view = [schedules viewWithMap: nil andReduce: nil];

  /* NSUInteger count = */ [view count];
}

-(void)test_group_and_view
{
  ChairDatabase* db = [ChairDatabase database];
  [db import: @"fixtures/flk.json"];

  // --------------------------------------------------------

  ChairTable* schedules = [db tableForName: @"schedules"];
  assert_equal(102, schedules.count);

  ChairView* schedules_ordered_by_theater_id = 
    [schedules viewWithMap: nil
                   andGroup: ^(NSDictionary* value, id key) { return [value objectForKey: @"theater_id"]; }
                  andReduce: nil];

  // 
  assert_equal(102, schedules_ordered_by_theater_id.count);

  ChairView* schedules_by_theater;
  schedules_by_theater = [schedules viewWithMap: nil 
                                        andGroup: ^(NSDictionary* value, id key) { return [value objectForKey: @"theater_id"]; }
                                       andReduce: ^(NSArray* values, id key) { return _.hash("count", values.count); }];

  // [schedules_by_theater update];
  assert_equal([schedules_by_theater keys], _.array(
    267534162, 374391607, 624179285, 837728461, 1223633946, 1592415747,
    1600891278, 1954940838, 2885852417, 3190279602, 3619205751
  ));

  assert(![schedules_by_theater get: _.object(1)]);
  assert_equal(11, schedules_by_theater.count);

  assert_equal(_.hash("count", 8), [schedules_by_theater get: _.object(267534162)]);
}

-(void)test_group_by_name
{
  ChairDatabase* db = [ChairDatabase database];

  [db import: @"fixtures/flk.json"];

  // --------------------------------------------------------

  ChairTable* schedules = [db tableForName: @"schedules"];
  assert_equal(102, schedules.count);

  ChairView* schedules_by_theater = [schedules viewWithMap: nil
                                        andGroup: [Chair groupBy: @"theater_id"]
                                       andReduce: [Chair reduceBy: @"count"]
                       ];

  // [schedules_by_theater update];
  assert_equal([schedules_by_theater keys], _.array(
    267534162, 374391607, 624179285, 837728461, 1223633946, 1592415747,
    1600891278, 1954940838, 2885852417, 3190279602, 3619205751
  ));

  assert(![schedules_by_theater get: _.object(1)]);
  assert_equal(11, schedules_by_theater.count);

  assert_equal(_.hash("count", 8), [schedules_by_theater get: _.object(267534162)]);
}

-(void)test_table_count
{
  ChairDatabase* db = [ChairDatabase database];
  [db import: @"fixtures/theaters.json"];
  ChairTable* theaters = [db tableForName: @"theaters"];

  assert_equal(13, theaters.count);
  assert_equal(13, [theaters countFrom: nil to: nil excludingEnd: NO]);

  [theaters each: ^(id value, id key) {
                   }
              min: nil
              max: _.object(267534163) 
     excludingEnd: NO];

  // 

  [theaters each: ^(id value, id key) {
                   }
              min: nil
              max: nil
     excludingEnd: NO];
}

@end
