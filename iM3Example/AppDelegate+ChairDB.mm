#import "AppDelegate.h"

#define SQLITE_PATH @"$documents/kinopilot.sqlite3"


@implementation M3AppDelegate(SqliteDB)

-(M3SqliteDatabase*) sqliteDB
{
  return [self memoized: @selector(sqliteDB) usingBlock:^() {
    return [self sqliteDatabase];
  }];
}

-(M3SqliteDatabase*)sqliteDatabase
{
  NSString* dbPath = [M3 expandPath: SQLITE_PATH];
  M3SqliteDatabase* db = [M3SqliteDatabase databaseWithPath:dbPath
                                            withCFAdditions:NO 
                                                       utf8:YES 
                                                  errorCode:0];
   
  [db synchronousMode:NO];
  return db;
}

@end

@implementation M3SqliteDatabase(M3Additions)

-(M3SqliteTable*) movies
{
  return [self tableWithName:@"movies"];
}

-(M3SqliteTable*) theaters
{
  return [self tableWithName:@"theaters"];
}

-(M3SqliteTable*) schedules
{
  return [self tableWithName:@"schedules"];
}

-(M3SqliteTable*) images
{
  return [self tableWithName:@"images"];
}

@end
