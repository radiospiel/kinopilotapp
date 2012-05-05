#import "M3AppDelegate.h"
#import "SVProgressHUD.h"
#import "M3+JSON.h"

#if APP_KINOPILOT

  #define SQLITE_PATH       @"$documents/kinopilot2.sqlite3"
  #define SEED_PATH         @"$app/seed.sqlite3"
  #define REMOTE_SQL_URL    @"http://kinopilotupdates2.heroku.com/db/images,berlin.sql"
  #define DEBUG_SQL_URL     @"http://localhost:3000/db/images,berlin.sql"

#elif APP_FLK

  #define SQLITE_PATH       @"$documents/flk2.sqlite3"
  #define SEED_PATH         @"$app/seed-flk.sqlite3"
  #define REMOTE_SQL_URL    @"http://update.16b.org/flk"
  #define DEBUG_SQL_URL     @"http://localhost:9292/flk"

#endif

#define UPDATE_TIME_SPAN  18 * 3600

#if 0
  #undef REMOTE_SQL_URL
  #define REMOTE_SQL_URL DEBUG_SQL_URL
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

-(M3SqliteTable*) settings
{
  return [self tableWithName:@"settings"];
}

-(M3SqliteTable*) flags
{
  return [self tableWithName:@"flags"];
}

-(void)migrate
{
  [self tableWithName:@"settings" andColumns:_.array(@"_id", @"value")];
  [self tableWithName:@"flags" andColumns:_.array(@"key_id")];
}

-(BOOL)isLoaded
{
  return self.movies.count.to_i > 0;
}

-(NSArray*)fetchDiffFromURL: (NSString*)url
{
  NSNumber* current_revision = [self.settings objectForKey: @"revision"];
  if(current_revision.to_i > 0) {
    url = [url stringByAppendingFormat:@"?since=%@", current_revision];
  }
  NSString* db_uuid = [self.settings objectForKey: @"uuid"];
  if(db_uuid) {
    url = [url stringByAppendingFormat:@"&uuid=%@", db_uuid];
  }
  
  NSData* data = [M3Http requestData: @"GET" 
                                 url: url
                         withOptions: nil];
  
  NSArray* diff = [M3 parseJSONData: data];
  if(![diff isKindOfClass: [NSArray class]])
    _.raise("Cannot read file ", url);

  return diff;
}

-(void)saveHeaderValue: (id)value 
                forKey: (NSString*)key
{
  if(!value) return;
  
  [self.settings setObject: value forKey: key];
}

-(void)saveHeaderValueWithName: (NSString*)name 
                    fromHeader: (NSDictionary*)header
{
  [self saveHeaderValue: [header objectForKey: name] forKey: name];
}

-(void)importDatabaseFromRemote
{  
  NSString* url = [self.settings objectForKey:@"update_url"];
  if(!url) url = REMOTE_SQL_URL;

  NSArray* entries = [self fetchDiffFromURL: url];
  
  Benchmark(_.join("Importing database from ", url));

  [self transaction:^() {
    [self importDump:entries];
    
    NSArray* headerArray = entries.first;
    NSDictionary* header = headerArray.second;

    [self saveHeaderValueWithName:@"imgio"        fromHeader:header];
    [self saveHeaderValueWithName:@"update_url"   fromHeader:header];
    [self saveHeaderValueWithName:@"revision"     fromHeader:header];
    [self saveHeaderValueWithName:@"uuid"         fromHeader:header];
    [self saveHeaderValue:[NSDate now].to_number forKey:@"updated_at"];
  }];
}

@end

#include <sys/xattr.h>

@implementation M3AppDelegate(SqliteDB)

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path
{
  path = [M3 expandPath: path];
  const char* filePath = [path UTF8String];
  
  const char* attrName = "com.apple.MobileBackup";
  u_int8_t attrValue = 1;
  
  int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
  return result == 0;
}

-(M3SqliteDatabase*)buildSqliteDatabase
{
  if(![M3 fileExists: SQLITE_PATH]) {
    [M3 copyFrom:SEED_PATH to:SQLITE_PATH];
    [self addSkipBackupAttributeToItemAtPath: SQLITE_PATH];
  }
  
  NSString* dbPath = [M3 expandPath: SQLITE_PATH];
  M3SqliteDatabase* db = [M3SqliteDatabase databaseWithPath:dbPath
                                            withCFAdditions:NO 
                                                       utf8:YES 
                                                  errorCode:0];
  
  [db synchronousMode:NO];
  
  return db;
}

-(void)updateDatabaseWithFeedback: (BOOL)feedback
{
  if(feedback)
    [SVProgressHUD showWithStatus:@"Aktualisieren..." maskType: SVProgressHUDMaskTypeBlack];
  
  // run in background...
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    M3SqliteDatabase* db = [self buildSqliteDatabase];
    @try {
      [db importDatabaseFromRemote];
    
      dispatch_async(dispatch_get_main_queue(), ^{
        [self emit:@selector(updated)];
        if(feedback)
          [SVProgressHUD dismissWithSuccess:@"Aktualisierung erfolgreich!" ];
      });
    }
    @catch (M3Exception* exception) {
      if(feedback) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD dismissWithError: [exception description] afterDelay: 2.5 ];
        });
      }
    }
    @catch (id exception) {
      if(feedback) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD dismissWithError: @"Aktualisierung fehlgeschlagen!" afterDelay: 2.5 ];
        });
      }
    }
  });
}

// Database update was explicitely requested
-(void)updateDatabase
{
  [self updateDatabaseWithFeedback:YES];
}

// Database update if needed
-(void)updateDatabaseIfNeeded
{
  NSNumber* updated_at = [self.sqliteDB.settings objectForKey: @"updated_at"];
  int diff = [NSDate now].to_number.to_i - updated_at.to_i;
  if(diff < UPDATE_TIME_SPAN)                          // 18 hours.
    return;

  // If there are still future schedules in the database, the user probably 
  // does not need error feedback. 
  id aFutureSchedule = [app.sqliteDB ask: @"SELECT * FROM schedules WHERE time>? LIMIT 1", [NSDate today]];
  [self updateDatabaseWithFeedback: (aFutureSchedule == nil)];
}

-(M3SqliteDatabase*)sqliteDatabase
{
  return [self buildSqliteDatabase];
}

-(M3SqliteDatabase*) sqliteDB
{
  return [self memoized: @selector(sqliteDB) usingBlock:^() {
    return [self sqliteDatabase];
  }];
}

-(UIImage*) thumbnailForMovie: (NSDictionary*) movie;
{
  NSString* url = [movie objectForKey:@"image"];
  if(!url) return nil;

  NSDictionary* imageData = [app.sqliteDB.images get: url];
  NSString* encodedImage = [imageData objectForKey:@"data"];
  if(!encodedImage) return nil;
  
  NSData* data = [M3 decodeBase64WithString:encodedImage];
  if(!data) return nil;
  
  return [UIImage imageWithData: data];
}

#pragma mark -- flagging

-(BOOL)isFlagged: (NSString*)key
{
  return [self.sqliteDB ask: @"SELECT key_id FROM flags WHERE key_id=?", key] != nil; 
}

-(void)setFlagged: (BOOL)flag onKey: (NSString*)key
{
  if(flag)
    [self.sqliteDB ask: @"INSERT INTO flags (key_id) VALUES(?)",  key]; 
  else
    [self.sqliteDB ask: @"DELETE FROM flags WHERE key_id=?", key];
}

#pragma mark -- flagging (end)

@end
