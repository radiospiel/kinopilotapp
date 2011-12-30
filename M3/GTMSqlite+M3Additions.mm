#import "GTMSQLite+M3Additions.h"
#import "M3.h"

#include <objc/runtime.h> // objc_setAssociatedObject & co.

@implementation GTMSQLiteStatement(M3SqliteStatement)

static NSString* kUseArrayEnumeration = @"kUseArrayEnumeration";

-(void)setEnumerationPolicy: (M3SqliteStatementEnumerationPolicy)enumerationPolicy
{
  objc_setAssociatedObject(self, @"enumerationPolicy", 
                          (enumerationPolicy == M3SqliteStatementEnumerateUsingArrays ? kUseArrayEnumeration : nil), 
                           OBJC_ASSOCIATION_ASSIGN);
}

-(M3SqliteStatementEnumerationPolicy)enumerationPolicy;
{
  id currentPolicy = objc_getAssociatedObject(self, @"enumerationPolicy");
  if(currentPolicy == kUseArrayEnumeration)
    return M3SqliteStatementEnumerateUsingArrays;
  else
    return M3SqliteStatementEnumerateUsingDictionaries;
}

-(id)resultRow
{
  if([self enumerationPolicy] == M3SqliteStatementEnumerateUsingDictionaries)
    return [self resultRowDictionary];

  return [self resultRowArray];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
                                  objects:(id *)stackbuf 
                                    count:(NSUInteger)len;
{
  switch([self stepRow]) {
  case SQLITE_DONE:
    [self reset];
    return 0;
  case SQLITE_ROW:
    // stackbuf is an array for a few id entries on the stack, and
    // can be used to store ids, if needed. 
    *stackbuf = [self resultRow];

    state->state = 1;                             /* Apparently state must not be 0 ?? */
    state->itemsPtr = stackbuf;                   
    state->mutationsPtr = (unsigned long*)self;  
    return 1;
  default:
    return 0;
  }
}

-(int)bindObject: (id)obj atPosition: (NSUInteger)position
{
  if([obj isKindOfClass:[NSNull class]])
    return [self bindSQLNullAtPosition: (int)position];
  
  if([obj isKindOfClass:[NSString class]])
    return [self bindStringAtPosition: (int)position string:(NSString *)obj ];
  
  if([obj isKindOfClass:[NSData class]])
    return [self bindBlobAtPosition: (int)position data: (NSData *)obj];

  if([obj isKindOfClass:[NSNumber class]])
  {
    NSNumber* number = obj;

    const char* objCType = [number objCType];
    
    if (!strcmp(objCType, @encode(double)) || !strcmp(objCType, @encode(float)))
      return [self bindDoubleAtPosition: (int)position value: [number doubleValue]];
    
    // Instead of discriminate different integer lengths, we just bind all kind
    // of integers as long longs. The overhead of doing so is probably quite
    // negliable anyways, and there would be overhead of testing against 
    // all other @encodings.
    
    return [self bindNumberAsLongLongAtPosition: (int)position number: number];
  }

  if([obj isKindOfClass:[NSDate class]])
  {
    NSDate* date = (NSDate*)obj;
    
    NSNumber* number = [NSNumber numberWithInt: [date timeIntervalSince1970]];
    return [self bindNumberAsLongLongAtPosition: (int)position number: number];
  }
  NSLog(@"**** Trying to bind an unsupported object of type %@", [obj class]);
  [M3 logBacktrace];
  return -1;
}

@end


/*
 * The type of a SQL statement
 */
typedef enum {
  StatementTypeSelect = 0,
  StatementTypeInsert,
  StatementTypeUpdate,
  StatementTypeDelete,
  StatementTypeOther,
  
  StatementTypeSelectRow
} StatementType;

static StatementType statementTypeForSql(NSString* sql)
{
  NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: @"^\\s*(INSERT|DELETE|UPDATE|SELECT)"
                                                                         options: NSRegularExpressionCaseInsensitive
                                                                           error: NULL];

  NSArray* matches = [regex matchesInString:sql options: 0 range: NSMakeRange(0, [sql length])];
  if(!matches || [matches count] == 0) return StatementTypeOther;

  NSTextCheckingResult* match = [matches objectAtIndex:0];
  
  if(match) {
    NSRange matchRange = [match rangeAtIndex:1];
    NSString* matchedText = [sql substringWithRange:matchRange];
    
    matchedText = [matchedText uppercaseString];
    if([matchedText isEqualToString:@"INSERT"]) return StatementTypeInsert;
    if([matchedText isEqualToString:@"DELETE"]) return StatementTypeDelete;
    if([matchedText isEqualToString:@"UPDATE"]) return StatementTypeUpdate;
    if([matchedText isEqualToString:@"SELECT"]) return StatementTypeSelect;
  }
  
  return StatementTypeOther;
}

@implementation M3SqliteDatabase

-(void)dealloc
{
  // finalize all prepared SQL statements.
  [cached_statements_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [obj finalizeStatement];
  }];
  
  [cached_statements_ release]; cached_statements_ = nil;
  
  [uncacheable_statements_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj finalizeStatement];
  }];
  [uncacheable_statements_ release]; uncacheable_statements_ = nil;
  
  [super dealloc];
}

-(void) init_prepared_statements
{
  if(!cached_statements_)
    cached_statements_ = [[NSMutableDictionary alloc]init];

  if(!uncacheable_statements_)
    uncacheable_statements_ = [[NSMutableArray alloc]init];
}

-(GTMSQLiteStatement*)uncachedPrepareStatement: (NSString*)sql
{
  return [GTMSQLiteStatement statementWithSQL:sql inDatabase:self errorCode:NULL];
}

-(BOOL)isCacheableStatement: (NSString*)sql
{
  switch(statementTypeForSql(sql)) {
    case StatementTypeSelect:
    case StatementTypeInsert:
    case StatementTypeUpdate:
    case StatementTypeDelete: return YES;
    
    default: return NO;
  }
}

-(GTMSQLiteStatement*)prepareStatement: (NSString*)sql
{
  [self init_prepared_statements];
  
  GTMSQLiteStatement* statement;
  
  statement = [cached_statements_ objectForKey:sql];
  if(statement) return statement;

  statement = [self uncachedPrepareStatement: sql];
  if(!statement) return statement;
  
  if([self isCacheableStatement: sql]) {
    // NSLog(@"*** caching %@", sql);
    [cached_statements_ setObject: statement forKey:sql];
  }
  else {
    // NSLog(@"*** not caching %@", sql);
    [uncacheable_statements_ addObject: statement];
  }
  
  return statement;
}

// Execute a query and returns a single value result.
//
// The result is
//   the number of affected rows for UPDATEs and DELETEs
//   the lastInsertedId for INSERTs
//   the first value in the first row of the result set or nil for SELECTs 
//
// [db ask: @"SELECT COUNT(*) FROM foo"];
// [db ask: @"SELECT COUNT(*) FROM foo WHERE id > ? AND id < ?", @"a", @"b"];
//
-(id)askStatement: (GTMSQLiteStatement*)statement 
           ofType: (StatementType) statementType
{
  //
  // get the "sensible" return value
  id retVal = nil;
  
  int stepRowResult = [statement stepRow];
  
  switch(statementType) {
    case StatementTypeDelete:
    case StatementTypeUpdate:
      retVal = [NSNumber numberWithInt:[self lastChangeCount]];
      break;
    case StatementTypeInsert:
      retVal = [NSNumber numberWithUnsignedLongLong:[self lastInsertRowID]];
      break;
    case StatementTypeSelect:
      if(stepRowResult != SQLITE_DONE) {
        NSArray* row = [statement resultRowArray];
        retVal = [row objectAtIndex:0];
      }
      break;
    case StatementTypeSelectRow:
      if(stepRowResult != SQLITE_DONE) {
        retVal = [statement resultRowDictionary];
      }
      break;
    case StatementTypeOther:
      retVal = [NSNumber numberWithBool:YES];
      break;
  };
  
  [statement reset];
  return retVal;
}

-(id)askRow: (NSString*)sql, ...;
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  [statement reset];
  
  int count = [statement parameterCount]; 
  
  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  va_end(args);
  
  return [self askStatement: statement ofType: StatementTypeSelectRow ];
}

-(id)ask: (NSString*)sql, ...;
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  [statement reset];

  int count = [statement parameterCount]; 

  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  va_end(args);

  return [self askStatement: statement ofType: statementTypeForSql(sql) ];
}

-(id)ask: (NSString*)sql withParameters: (NSArray*)params
{
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  [statement reset];
  
  [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [statement bindObject: obj atPosition: idx+1];
  }];

  return [self askStatement: statement ofType: statementTypeForSql(sql) ];
}

// Execute a select and enumerate over the result set.
//
// for(NSDictionary* record in [db select: @"SELECT * FROM foo WHERE id > ? AND id < ?", @"a", @"b"]) {
//   ..
// }
//
-(GTMSQLiteStatement*) each: (NSString*)sql, ...
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  
  int count = [statement parameterCount]; 
  
  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  
  va_end(args);

  statement.enumerationPolicy = M3SqliteStatementEnumerateUsingDictionaries;
  return statement;
}

// Execute a select and enumerate over the result set as arrays.
//
// for(NSDictionary* record in [db select: @"SELECT * FROM foo WHERE id > ? AND id < ?", @"a", @"b"]) {
//   ..
// }
//
-(GTMSQLiteStatement*) eachArray: (NSString*)sql, ...
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  
  int count = [statement parameterCount]; 
  
  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  
  va_end(args);
  
  statement.enumerationPolicy = M3SqliteStatementEnumerateUsingArrays;
  return statement;
}

// Execute a query and return the first result set as NSDictionary
-(NSDictionary*)first: (NSString*)sql, ...;
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  
  int count = [statement parameterCount]; 
  
  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  
  va_end(args);
  
  statement.enumerationPolicy = M3SqliteStatementEnumerateUsingDictionaries;

  NSDictionary* result = nil;
  for(NSDictionary* record in statement) {
    result = record;
    break;
  }

  [statement reset];
  return result;
}

// Execute a query and return the complete result set as an array of dictionaries.
-(NSArray*)all: (NSString*)sql, ...;
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  
  int count = [statement parameterCount]; 
  
  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  
  va_end(args);
  
  statement.enumerationPolicy = M3SqliteStatementEnumerateUsingDictionaries;
  
  NSMutableArray* array = [NSMutableArray array];
  for(NSDictionary* record in statement) {
    [array addObject:record];
  }
  return array;
}

// Execute a query and return the complete result set as an array of arrays.
-(NSArray*)allArrays: (NSString*)sql, ...;
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  
  int count = [statement parameterCount]; 
  
  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i+1];
  }
  
  va_end(args);
  
  statement.enumerationPolicy = M3SqliteStatementEnumerateUsingArrays;
  
  NSMutableArray* array = [NSMutableArray array];
  for(NSArray* record in statement) {
    [array addObject:record];
  }
  return array;
}

-(void)transaction: (void(^)())block
{
  @try {
    [self ask: @"BEGIN"];
    block();
    [self ask: @"COMMIT"];
  }
  @catch (NSException *exception) {
    [self ask: @"ROLLBACK"];
  }
  @finally {
    ;
  }
}

-(void)logDatabaseStats: (NSString*)msg
{
  dlog << @"=== " << msg << " =========================================================================";
  
  dlog << "movies: " << [self ask: @"SELECT COUNT(*) FROM movies"];
  dlog << "schedules: " << [self ask: @"SELECT COUNT(*) FROM schedules"];
  dlog << "theaters: " << [self ask: @"SELECT COUNT(*) FROM theaters"];
}

-(void)importDiffHeader: (NSDictionary*)header
{
  NSDictionary* deletions = [header objectForKey:@"deletions"];
  [deletions enumerateKeysAndObjectsUsingBlock:^(NSString* tableName, NSArray* ids, BOOL *stop) {
    M3SqliteTable* table = [self tableWithName:tableName];
    [table deleteByIds:ids];
  }];
  
  [self logDatabaseStats: @"after deletions"];
}

-(void)importDump: (NSArray*)entries
{
  [self logDatabaseStats: @"before update"];

  [self ask: @"BEGIN"];

  NSDictionary* header = nil;
  BOOL diffMode = NO;
  
  for(NSArray* entry in entries) {
    if(!header) {
      header = [entry objectAtIndex:1];
      NSNumber* since = [header objectForKey:@"since"];
      diffMode = since.to_i > 0;
      
      if(diffMode)
        [self importDiffHeader: header];
      
      continue;
    }

    // The first entry is the name of the target table.
    // The second entry is an array of column names
    // The third column is an array of updates to insert into the table.  
    
    NSString* table_name = [entry objectAtIndex:0];
    if([table_name isKindOfClass: [NSNull class]]) continue;

    NSArray* columns = [entry objectAtIndex:1];
    NSArray* records = [entry objectAtIndex:2];
    
    M3SqliteTable* table = [self tableWithName:table_name andColumns:columns];

    if(!diffMode)
      [table deleteAll];

    [table insertArrays:records withColumns:columns];
  }
  
  [self logDatabaseStats: @"after import"];
  
  [self ask: @"COMMIT"];
}

+ (M3SqliteDatabase*)databaseWithPath:(NSString *)path
                      withCFAdditions:(BOOL)additions
                                 utf8:(BOOL)useUTF8
                            errorCode:(int *)err
{
  return [[[M3SqliteDatabase alloc]initWithPath: path 
                                withCFAdditions: additions 
                                           utf8: useUTF8 
                                      errorCode: err]
          autorelease];
}

+ (M3SqliteDatabase*)databaseWithPath:(NSString *)path
{
  return [M3SqliteDatabase databaseWithPath:path 
                            withCFAdditions:YES 
                                       utf8:YES 
                                  errorCode:NULL];
}

+ (M3SqliteDatabase*)databaseInMemory
{
  return [M3SqliteDatabase databaseWithPath:@":memory:"];
}

-(M3SqliteTable*)tableWithName: (NSString*)name 
{
  return [M3SqliteTable tableWithName:name inDatabase:self];
}

-(M3SqliteTable*)tableWithName: (NSString*)name andColumns: (NSArray*)columns
{
  return [M3SqliteTable tableWithName: name 
                           andColumns: columns
                           inDatabase: self];
}

@end

#pragma mark --- create the table, its columns and indices ---------------------

@implementation M3SqliteTable(TableCreation)

-(void)doAddMissingIndexOnColumn: (NSString*)column
{
  if(![column hasSuffix:@"_id"]) return;
  if([column isEqualToString:@"_id"]) return;
  
  NSString* sql = [NSString stringWithFormat: @"CREATE INDEX %@_%@_ix ON %@(%@)", 
                   self.tableName, column, 
                   self.tableName, column];
  [database_ ask: sql];
}

-(void)doCreateTableWithColumns: (NSArray*)column_names
{
  NSLog(@"creating table %@", self.tableName);
  
  NSMutableArray* column_definitions = [NSMutableArray array];
  for(NSString* column in column_names) {
    if([column isEqualToString:@"_id"])
      [column_definitions addObject: @"_id PRIMARY KEY"]; 
    else
      [column_definitions addObject: column]; 
  }
  
  NSString* sql = [NSString stringWithFormat: @"CREATE TABLE %@ (%@)", self.tableName, 
                   [column_definitions componentsJoinedByString: @", "]
                   ];
  [database_ ask: sql];
  
  for(NSString* column in column_names) {
    [self doAddMissingIndexOnColumn: column];
  }
}

-(void)doAddMissingColumns: (NSArray*)column_names
{
  NSArray* existing_columns = self.columnNames;
  
  for(NSString* column in column_names) {
    if([existing_columns indexOfObject:column] != NSNotFound) continue;
    
    NSString* sql = [NSString stringWithFormat: @"ALTER TABLE %@ ADD COLUMN %@", self.tableName, column];
    [database_ ask: sql];
    
    [self doAddMissingIndexOnColumn: column];
  }
}

@end

@implementation M3SqliteTable

@synthesize tableName = tableName_, database = database_;

-(M3SqliteTable*)initWithName: (NSString*)tableName 
                   inDatabase: (M3SqliteDatabase*)database
{
  self = [super init];
  if(!self) return nil;
  
  tableName_ = [tableName retain];
  database_ = [database retain];
  
  return self;
}

-(void)dealloc
{
  [tableName_ release]; tableName_ = nil;
  [database_ release]; database_ = nil;
}

+(M3SqliteTable*)tableWithName: (NSString*)name 
                    inDatabase: (M3SqliteDatabase*)database
{
  return [[[M3SqliteTable alloc]initWithName:name inDatabase:database]autorelease];
}

+(M3SqliteTable*)tableWithName: (NSString*)name 
                    andColumns: (NSArray*)column_names
                    inDatabase: (M3SqliteDatabase*)database
{
  M3SqliteTable* table = [[[M3SqliteTable alloc]initWithName:name inDatabase:database]autorelease];
  
  if(!table.exists)
    [table doCreateTableWithColumns: column_names];
  else
    [table doAddMissingColumns: column_names];
  
  return table;
}

-(BOOL)exists
{
  NSString* existing_name = [database_ ask: @"SELECT name FROM sqlite_master WHERE type=? AND name=?", @"table", self.tableName];
  return existing_name != nil;
}

#pragma mark --- table properties ----------------------------------------------

-(NSNumber*)count
{
  NSString* sql = [NSString stringWithFormat: @"SELECT COUNT(*) FROM %@", self.tableName];
  NSNumber* count = [database_ ask: sql];
  return count ? count : [NSNumber numberWithInt: 0];
}

-(NSArray*)columnNames
{
  NSMutableArray* columnNames = [NSMutableArray array];
  NSString* sql = [NSString stringWithFormat: @"PRAGMA table_info(%@)", self.tableName];
  for(NSDictionary* column_description in [database_ each: sql]) {
    [columnNames addObject: [column_description objectForKey:@"name"]];
  }
  
  return columnNames;
}

-(NSArray*)all
{
  NSString* sql = [ NSString stringWithFormat: @"SELECT * FROM %@", self.tableName];
  return [database_ all: sql];
}

#pragma mark --- delete from the table -----------------------------------------

-(void)deleteAll
{
  Benchmark(_.join(@"*** Deleting all entries from ", self.tableName));
  
  NSString* sql = [NSString stringWithFormat: @"DELETE FROM %@", self.tableName];
  [database_ ask: sql];
}

-(void)deleteById: (id)theId
{
  NSString* sql = [NSString stringWithFormat: @"DELETE FROM %@ WHERE _id=?", self.tableName];
  [database_ ask: sql, theId];
}

-(void)deleteByIds: (NSArray*)ids
{
  if(ids.count == 0) return;

  ids = [ids mapUsingSelector:@selector(sqliteEscape)];
  
  NSString* sql = [
                   NSString stringWithFormat: @"DELETE FROM %@ WHERE _id IN (%@)", 
                   self.tableName, 
                   [ids componentsJoinedByString:@","]
                   ];
  
  [database_ ask: sql];
}

#pragma mark --- insert into the table -----------------------------------------

-(void)insertArray: (NSArray*)record 
       withColumns: (NSArray*)columns
{
  NSArray* array_of_records = [NSArray arrayWithObject: record];
  [self insertArrays: array_of_records withColumns: columns ];
}

-(void)insertArrays: (NSArray*)array_of_records 
        withColumns: (NSArray*)columns
{
  [self doAddMissingColumns: columns];
  
  int count = [self.count intValue];
  
  if(count > 0) {
    NSUInteger idx_position = [columns indexOfObject: @"_id"];

    if(idx_position != NSNotFound) {
      NSMutableArray* ids = [NSMutableArray arrayWithCapacity: count];
      for(NSArray* record in array_of_records) {
        [ids addObject:[record objectAtIndex:idx_position]];
      }
      
      [self deleteByIds: ids];
    }
  }
  
  // create INSERT SQL command
  NSMutableArray* placeholders = [NSMutableArray array];
  [columns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *flag) {
    [placeholders addObject: @"?"];
  }];

  NSString* sql = [NSString stringWithFormat: @"INSERT OR REPLACE INTO %@ (%@) VALUES(%@)", 
                                    self.tableName, 
                                    [columns componentsJoinedByString: @", "],
                                    [placeholders componentsJoinedByString: @", "]];

  GTMSQLiteStatement* statement = [database_ prepareStatement:sql];

  [array_of_records enumerateObjectsUsingBlock:^(NSArray* record, NSUInteger idx, BOOL *stop) {
    [record enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [statement bindObject: obj atPosition: idx+1];
    }];

    [statement stepRow];
    [statement reset];
  }];
}

#pragma mark --- fetch from the table ------------------------------------------

-(id)decodeValue: (NSString*)value
{
  if([value isKindOfClass:[NSString class]] && [value hasPrefix:@"json:"])
    return [M3 parseJSON: [value substringFromIndex:5]];
  
  return value;
}

-(id)encodeValue: (id)value
{
  if(![value respondsToSelector:@selector(JSONString)])
    return value;

  return [ @"json:" stringByAppendingString: [value performSelector:@selector(JSONString)]];
}

-(NSDictionary*)get: (id)uid
{
  if(!uid || [uid isKindOfClass:[NSNull class]]) return nil;
  
  NSString* sql = [ NSString stringWithFormat: @"SELECT * FROM %@ WHERE _id=?", self.tableName];
  NSDictionary* r = [database_ askRow: sql, uid];
  if(!r) return nil;
  
  NSMutableDictionary* record = [NSMutableDictionary dictionary];
  [r enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
    if([obj isKindOfClass:[NSNull class]]) return;

    if([obj isKindOfClass:[NSString class]])
      obj = [self decodeValue:obj];

    [record setObject:obj forKey:key];
  }];
  
  return record;
}

#pragma mark --- k/v storage -------------------------------------------

-(id)objectForKey: (NSString*)key
{
  NSString* sql = [NSString stringWithFormat: @"SELECT value FROM %@ WHERE _id=?", self.tableName];
  NSString* stored_value = [database_ ask: sql, key];

  return [self decodeValue:stored_value];
}

-(void)setObject: (id)object forKey: (NSString*)key
{
  if(object) {
    [self insertArray:_.array(key, [self encodeValue:object]) 
          withColumns:_.array(@"_id", @"value")];
  }
  else {
    [self deleteById:key];
  }
}

@end


/* --- Tests --------------------------------------- */

#import "M3.h"

ETest(GTMSQLiteStatementM3SqliteStatement)

-(M3SqliteDatabase*) database
{
  M3SqliteDatabase* db = [M3SqliteDatabase databaseInMemory];
  [db executeSQL:@"CREATE TABLE t1 (x TEXT);"];
  
  // Insert data set
  [db executeSQL:@"INSERT INTO t1 VALUES ('foo');"];
  [db executeSQL:@"INSERT INTO t1 VALUES ('bar');"];
  [db executeSQL:@"INSERT INTO t1 VALUES ('yihaa');"];
  
  return db;
} 

-(void)test_sql_query_type
{
  assert_equal_int(StatementTypeDelete, statementTypeForSql(@"  Delete From"));
  assert_equal_int(StatementTypeSelect, statementTypeForSql(@"  sElECT From"));
  assert_equal_int(StatementTypeInsert, statementTypeForSql(@"INSert From"));
  assert_equal_int(StatementTypeUpdate, statementTypeForSql(@"Update From"));
}

-(void)test_ask_select
{
  M3SqliteDatabase* db = [M3SqliteDatabase databaseInMemory]; 
  NSNumber* one = [NSNumber numberWithInt: 1];
  assert_equal(([db ask: @"SELECT ?", one]), 1);
}

-(void)test_ask_insert
{
  M3SqliteDatabase* db = [self database];
  assert_equal(([db ask: @"SELECT COUNT(*) FROM t1"]), 3);
  assert_equal(([db ask: @"INSERT INTO t1 VALUES(?)", @"test"]), 4);
  assert_equal(([db ask: @"SELECT COUNT(*) FROM t1"]), 4);
}

-(void)test_ask_delete
{
  M3SqliteDatabase* db = [self database];
  assert_equal(([db ask: @"DELETE FROM t1 WHERE x=?", @"foo"]), 1);
  assert_equal(([db ask: @"DELETE FROM t1"]), 2);
  assert_equal(([db ask: @"DELETE FROM t1"]), 0);
}

-(void)test_ask_update
{
  M3SqliteDatabase* db = [self database];
  assert_equal(([db ask: @"UPDATE t1 SET x=? WHERE x=?", @"bar", @"foo"]), 1);
  assert_equal(([db ask: @"UPDATE t1 SET x=?", @"bar"]), 3);
}

// --------------------------------------

-(void)test_select_fast_enumeration
{
  M3SqliteDatabase* db = [self database];

  NSMutableArray* rows = [NSMutableArray array];
  for(NSArray* row in [db eachArray: @"SELECT * FROM t1"]) {
    [rows addObject: row];
  }

  assert_equal(rows, _.array( _.array("foo"),
                              _.array("bar"),
                              _.array("yihaa")
  ));

  rows = [NSMutableArray array];
  for(NSDictionary* row in [db each: @"SELECT * FROM t1"]) {
    [rows addObject: row];
  }

  assert_equal(rows, _.array( _.hash("x", "foo"),
                              _.hash("x", "bar"),
                              _.hash("x", "yihaa")
  ));
}

-(void)test_select_empty_fast_enumeration
{
  M3SqliteDatabase* db = [self database];

  NSMutableArray* rows = [NSMutableArray array];
  for(NSArray* row in [db eachArray: @"SELECT * FROM t1 WHERE x=1"]) {
    [rows addObject: row];
  }

  assert_equal(rows, _.array());

  rows = [NSMutableArray array];
  for(NSArray* row in [db each: @"SELECT * FROM t1 WHERE x=1"]) {
    [rows addObject: row];
  }
  assert_equal(rows, _.array());
}

-(void)test_select_fast_enumeration_with_binding
{
  M3SqliteDatabase* db = [self database];

  NSMutableArray* rows = [NSMutableArray array];
  for(NSArray* row in [db eachArray: @"SELECT * FROM t1 WHERE x < ? AND x > ?", @"mm", @"cc"]) {
    [rows addObject: row];
  }
  assert_equal(rows, _.array( _.array("foo")));

  rows = [NSMutableArray array];
  for(NSArray* row in [db eachArray: @"SELECT * FROM t1 WHERE x > ? AND x < ?", @"cc", @"mm"]) {
    [rows addObject: row];
  }
  assert_equal(rows, _.array( _.array("foo")));
}

#define REMOTE_SQL_URL  @"http://localhost:3000/db/images,berlin.sql"

-(void)test_import_sql
{
  M3SqliteDatabase* db = [M3SqliteDatabase databaseInMemory];
  
  NSArray* entries = [M3 readJSON: REMOTE_SQL_URL];
  if(![entries isKindOfClass: [NSArray class]])
    _.raise("Cannot read file", REMOTE_SQL_URL);
  

  [db importDump: entries];
}

@end

