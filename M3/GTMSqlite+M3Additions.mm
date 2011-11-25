#import "GTMSQLite+M3Additions.h"

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

  NSLog(@"**** Trying to bind an unsupported object of type %@", [obj class]);
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
  StatementTypeOther
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
  int errCode = 0;
  GTMSQLiteStatement* statement = [GTMSQLiteStatement statementWithSQL:sql inDatabase:self errorCode:&errCode];
  if(statement) return statement;
  
  NSLog(@"Error on preparing %@", sql);
  return nil; // Error! Do something!
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
    case StatementTypeOther:
      retVal = [NSNumber numberWithBool:YES];
      break;
  };
  
  [statement reset];
  return retVal;
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

-(void)importDump: (NSArray*)entries
{
  [entries enumerateObjectsUsingBlock:^(NSArray* obj, NSUInteger idx, BOOL *stop) {
    if(idx == 0) return;

    NSString* sql = [obj objectAtIndex:0];

    GTMSQLiteStatement* statement = [self prepareStatement:sql];
    
    if(obj.count == 1) {
      int stepRowResult = [statement stepRow];
      [statement reset];

      return;
    }

    [obj enumerateObjectsUsingBlock:^(NSArray* params, NSUInteger idx, BOOL *stop) {
      if(idx == 0)
        return; // The SQL string is on index 0

      [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [statement bindObject: obj atPosition: idx+1];
      }];

      int stepRowResult = [statement stepRow];
      [statement reset];
    }];
  }];
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
