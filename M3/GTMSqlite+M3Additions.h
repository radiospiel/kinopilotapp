#import "GTMSQLite.h"

typedef enum M3SqliteStatementEnumerationPolicy {
  M3SqliteStatementEnumerateUsingDictionaries = 0,
  M3SqliteStatementEnumerateUsingArrays = 1
} M3SqliteStatementEnumerationPolicy;

@interface GTMSQLiteStatement(M3SqliteStatement)

@property (nonatomic,assign) M3SqliteStatementEnumerationPolicy enumerationPolicy;

//
// Implements the NSFastEnumeration protocol.
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
                                 objects:(id *)stackbuf 
                                   count:(NSUInteger)len;

@end

@interface M3SqliteDatabase: GTMSQLiteDatabase {
  NSMutableDictionary* prepared_statements_;
}

// returns an autorelese M3SqliteDatabase
+ (M3SqliteDatabase*)databaseWithPath:(NSString *)path
                      withCFAdditions:(BOOL)additions
                                 utf8:(BOOL)useUTF8
                            errorCode:(int *)err;

// returns an autorelese M3SqliteDatabase on a given path
+ (M3SqliteDatabase*)databaseWithPath:(NSString *)path;

// returns an autorelese M3SqliteDatabase in memory.
+ (M3SqliteDatabase*)databaseInMemory;

// Execute a query and returns a single value result.
//
// This method returns
// - the number of affected rows for UPDATEs and DELETEs
// - the lastInsertedId for INSERTs
// - the first value in the first row of the result set or nil for SELECTs 
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
