#import "M3AppDelegate.h"
#import "SVProgressHUD.h"

#define SQLITE_PATH       @"$documents/kinopilot2.sqlite3"
#define SEED_PATH         @"$app/seed.sqlite3"

#define UPDATE_TIME_SPAN  18 * 3600

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

-(M3SqliteTable*) settings
{
  return [self tableWithName:@"settings" andColumns:_.array(@"_id", @"value")];
}

-(BOOL)isLoaded
{
  return self.movies.count.to_i > 0;
}

-(void)importDatabaseFromURL: (NSString*)url
{  
  NSNumber* current_revision = [self.settings objectForKey: @"revision"];
  if(current_revision.to_i > 0) {
    url = [url stringByAppendingFormat:@"?since=%@", current_revision];
  }
  NSString* db_uuid = [self.settings objectForKey: @"uuid"];
  if(db_uuid) {
    url = [url stringByAppendingFormat:@"&uuid=%@", db_uuid];
  }

  NSArray* entries = [M3 readJSON: url];
  if(![entries isKindOfClass: [NSArray class]])
    _.raise("Cannot read file", url);
  
  Benchmark(_.join("Importing database from ", url));

  [self transaction:^() {
    [self importDump:entries];
    
    NSArray* headerArray = entries.first;
    NSDictionary* header = headerArray.second;

    [self.settings setObject: [header objectForKey: @"revision"] 
                      forKey: @"revision"];
    [self.settings setObject: [header objectForKey: @"uuid"] 
                      forKey: @"uuid"];
    [self.settings setObject: [NSDate now].to_number 
                      forKey: @"updated_at"];
  }];
}

@end

@implementation M3AppDelegate(SqliteDB)

-(M3SqliteDatabase*)buildSqliteDatabase
{
  if(![M3 fileExists: SQLITE_PATH]) {
    [M3 copyFrom:SEED_PATH to:SQLITE_PATH];
  }
  
  NSString* dbPath = [M3 expandPath: SQLITE_PATH];
  M3SqliteDatabase* db = [M3SqliteDatabase databaseWithPath:dbPath
                                            withCFAdditions:NO 
                                                       utf8:YES 
                                                  errorCode:0];
  
  [db synchronousMode:NO];
  
  return db;
}

-(void)updateDatabase
{
  [SVProgressHUD showWithStatus:@"Updating" maskType: SVProgressHUDMaskTypeBlack];
  
  // run in background...
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    M3SqliteDatabase* db = [self buildSqliteDatabase];
    @try {
      [db importDatabaseFromURL: REMOTE_SQL_URL];

      dispatch_async(dispatch_get_main_queue(), ^{
        [self emit:@selector(updated)];
        [SVProgressHUD dismissWithSuccess:@"Aktualisierung erfolgreich!" ];
      });
    }
    @catch (M3Exception* exception) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismissWithError: [exception description] afterDelay: 2.5 ];
      });
    }
  });
}

-(void)updateDatabaseIfNeeded
{
  NSNumber* updated_at = [self.sqliteDB.settings objectForKey: @"updated_at"];
  int diff = [NSDate now].to_number.to_i - updated_at.to_i;
  if(diff < UPDATE_TIME_SPAN)                          // 18 hours.
    return;

  [self updateDatabase];
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

@end
