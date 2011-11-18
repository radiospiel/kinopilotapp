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

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
                                  objects:(id *)stackbuf 
                                    count:(NSUInteger)len;
{
  if([self stepRow] == SQLITE_DONE) {
    [self reset];
    return 0;
  }

  if([self enumerationPolicy] == M3SqliteStatementEnumerateUsingDictionaries)
    *stackbuf = [self resultRowDictionary];
  else
    *stackbuf = [self resultRowArray];

  state->mutationsPtr = (unsigned long*)self;  
  return 1;
}

-(int)bindNumber: (NSNumber*)number atPosition: (NSUInteger)position
{
  const char* objCType = [number objCType];

  if (!strcmp(objCType, @encode(double)) || !strcmp(objCType, @encode(float)))
    return [self bindDoubleAtPosition: position value: [number doubleValue]];

  // Instead of discriminate different integer lengths, we just bind all kind
  // of integers as long longs. The overhead of doing so is probably quite
  // negliable anyways, and there would be overhead of testing against 
  // all other @encodings.

  return [self bindNumberAsLongLongAtPosition: position number: number];
}

-(int)bindObject: (id)obj atPosition: (NSUInteger)position
{
  if([obj isKindOfClass:[NSNumber class]])
    return [self bindNumber: obj atPosition:position];

  if([obj isKindOfClass:[NSNull class]])
    return [self bindSQLNullAtPosition: (int)position];

  if([obj isKindOfClass:[NSString class]])
    return [self bindStringAtPosition: (int)position string:(NSString *)obj ];
  
  if([obj isKindOfClass:[NSData class]])
    return [self bindBlobAtPosition: (int)position data: (NSData *)obj];

  NSLog(@"Trying to bind an unsupported object of type %@", [obj class]);
  return -1;
}

@end


/*
 * The type of a SQL statement
 */
typedef enum {
  GTMSQLiteStatementTypeSelect = 0,
  GTMSQLiteStatementTypeInsert,
  GTMSQLiteStatementTypeUpdate,
  GTMSQLiteStatementTypeDelete,
  GTMSQLiteStatementTypeOther
} GTMSQLiteStatementType;

static GTMSQLiteStatementType statementTypeForSql(NSString* sql)
{
  NSError* error = nil;
  NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: @"^\\s*(INSERT|DELETE|UPDATE|SELECT)"
                                                                         options: NSRegularExpressionCaseInsensitive
                                                                           error: &error];
  
  
  NSArray* matches = [regex matchesInString:sql options: 0 range: NSMakeRange(0, [sql length])];
  if([matches objectAtIndex:0]) {
    NSString* match = nil;
    match = [match uppercaseString];
    if([match isEqualToString:@"INSERT"]) return GTMSQLiteStatementTypeInsert;
    if([match isEqualToString:@"DELETE"]) return GTMSQLiteStatementTypeDelete;
    if([match isEqualToString:@"UPDATE"]) return GTMSQLiteStatementTypeUpdate;
    if([match isEqualToString:@"SELECT"]) return GTMSQLiteStatementTypeSelect;
  }
  
  return GTMSQLiteStatementTypeOther;
}

@implementation M3SqliteDatabase

-(void)dealloc
{
  // finalize all prepared SQL statements.
  [prepared_statements_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [obj finalizeStatement];
  }];
  
  [prepared_statements_ release]; prepared_statements_ = nil;
  
  [super dealloc];
}

-(void) init_prepared_statements
{
  if(!prepared_statements_) {
    prepared_statements_ = [NSMutableDictionary dictionary];
  }
}

-(GTMSQLiteStatement*)prepareStatement: (NSString*)sql
{
  [self init_prepared_statements];
  
  GTMSQLiteStatement* preparedStatement = [prepared_statements_ objectForKey:sql];
  if(preparedStatement) return preparedStatement;
  
  int errCode = 0;
  preparedStatement = [GTMSQLiteStatement statementWithSQL:sql inDatabase:self errorCode:&errCode];
  if(preparedStatement) {
    [prepared_statements_ setObject: preparedStatement forKey:sql];
    return preparedStatement;
  }
  
  return nil;
  // error!
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
-(id)ask: (NSString*)sql, ...;
{
  va_list args;
  va_start(args, sql);
  
  GTMSQLiteStatement* statement = [self prepareStatement:sql];
  
  int count = [statement parameterCount]; 

  for( int i = 0; i < count; i++ ) {
    id arg = va_arg(args, id);
    [statement bindObject: arg atPosition: i];
  }
  
  va_end(args);

  switch(statementTypeForSql(sql)) {
    case GTMSQLiteStatementTypeDelete:
    case GTMSQLiteStatementTypeUpdate:
      return [NSNumber numberWithInt:[self lastChangeCount]];
    case GTMSQLiteStatementTypeInsert:
      return [NSNumber numberWithUnsignedLongLong:[self lastInsertRowID]];
    case GTMSQLiteStatementTypeSelect:
    {
      NSArray* row = nil;
      if([statement stepRow] != SQLITE_DONE)
        row = [statement resultRowArray];
      
      if([row count] < 1) return nil;
      return [row objectAtIndex:0];
    }
    case GTMSQLiteStatementTypeOther:
      return [NSNumber numberWithBool:YES];
  };
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
    [statement bindObject: arg atPosition: i];
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
    [statement bindObject: arg atPosition: i];
  }
  
  va_end(args);
  
  statement.enumerationPolicy = M3SqliteStatementEnumerateUsingArrays;
  return statement;
}

@end
