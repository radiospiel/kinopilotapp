#import "AppDelegate.h"

#define SQLITE_PATH @"$documents/kinopilot.sqlite3"

#if 1
#define REMOTE_SQL_URL  @"http://kinopilotupdates2.heroku.com/db/images,berlin.sql"
#else
#define REMOTE_SQL_URL  @"http://localhost:3000/db/images,berlin.sql"
#endif

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


-(BOOL)isLoaded
{
  return self.movies.count > 0;
}

-(void) updateCompleted
{
  [self emit:@selector(updated)];
}

-(BOOL)loadRemoteURL
{  
  NSArray* entries = [M3 readJSON: REMOTE_SQL_URL];
  if(![entries isKindOfClass: [NSArray class]])
    _.raise("Cannot read file", REMOTE_SQL_URL);
  
  Benchmark(_.join("Importing database from ", REMOTE_SQL_URL));
  
  [self importDump:entries];
  
  [self updateCompleted];
  
  return YES;
}

/*
 * Updates the database if an update is needed.
 *
 * If the in-memory database is still empty, this method loads the database
 * from the on-disk copy, if it exists, or from the remote URL.
 *-
 * If the in-memory database is not empty, this method loads the database
 * from the remote URL, if the local copy is outdated.
 */

-(void)update
{
  [self loadRemoteURL];
}

@end

@implementation M3AppDelegate(SqliteDB)

-(M3SqliteDatabase*)buildSqliteDatabase
{
  NSString* dbPath = [M3 expandPath: SQLITE_PATH];
  M3SqliteDatabase* db = [M3SqliteDatabase databaseWithPath:dbPath
                                            withCFAdditions:NO 
                                                       utf8:YES 
                                                  errorCode:0];
  
  [db synchronousMode:NO];
  
  return db;
}


-(M3SqliteDatabase*)sqliteDatabase
{
  M3SqliteDatabase* db = [self buildSqliteDatabase];
  if([db isLoaded]) return db;

  // For reasons yet unknown the initial import of the database
  // leaves the database's table objects in an unusable state.
  // Just creating a new M3SqliteDatabase object fixes things; 
  // and it then has the newly imported data as well. 
  [db loadRemoteURL];
  return [self buildSqliteDatabase];
}

-(M3SqliteDatabase*) sqliteDB
{
  return [self memoized: @selector(sqliteDB) usingBlock:^() {
    return [self sqliteDatabase];
  }];
}
@end
