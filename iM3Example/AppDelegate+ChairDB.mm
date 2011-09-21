#import "AppDelegate.h"
#import "M3.h"
#import "Chair.h"

#define REMOTE_URL  @"http://kinopilotupdates2.heroku.com/db/berlin"
// #define DB_PATH     @"$documents/chairdb/berlin.json"
#define DB_PATH     @"$documents/chairdb/kinopilot"

@implementation AppDelegate(ChairDB)

/*
 * Return an instance 
 */
-(ChairDatabase*) chairDB
{
  ChairDatabase* db = [self memoized: @selector(chairdb) usingBlock:^() {
    ChairDatabase* db = [ChairDatabase database];
                         
    if([M3 fileExists: DB_PATH]) {
      Benchmark(_.join("Loading database from ", DB_PATH));
      [db load: DB_PATH];
    }
    else {
      {
        Benchmark(_.join("Loading database from ", REMOTE_URL));
        [db import: REMOTE_URL];
      }
      
      {
        Benchmark(_.join("Exporting database to ", DB_PATH));
        [db save: DB_PATH];
      }
    }

    return db; 
  }];

  return db;
}

/*
 * Initialize Couchbase instance.
 */
-(void) initChairDB
{
  [self chairDB];
}

@end
