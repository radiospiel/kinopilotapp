#import "GTMSQLite.h"

typedef enum M3SqliteStatementEnumerationPolicy {
  M3SqliteStatementEnumerateUsingDictionaries = 0,
  M3SqliteStatementEnumerateUsingArrays = 1
} M3SqliteStatementEnumerationPolicy;

@interface GTMSQLiteStatement(M3SqliteStatement)

@property (nonatomic,assign) M3SqliteStatementEnumerationPolicy enumerationPolicy;

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
                                 objects:(id *)stackbuf 
                                   count:(NSUInteger)len;

@end


@interface M3SqliteDatabase: GTMSQLiteDatabase {
  NSMutableDictionary* prepared_statements_;
}

-(GTMSQLiteStatement*)prepareStatement: (NSString*)sql;

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

// Execute a select and enumerate over the result set.
//
// for(NSDictionary* record in [db select: @"SELECT * FROM foo WHERE id > ? AND id < ?", @"a", @"b"]) {
//   ..
// }
//
-(id)each: (NSString*)sql, ...;

// Execute a select and enumerate over the result set as arrays.
//
// for(NSDictionary* record in [db select: @"SELECT * FROM foo WHERE id > ? AND id < ?", @"a", @"b"]) {
//   ..
// }
//
-(id)eachArray: (NSString*)sql, ...;

@end
