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
  return [self memoized: @selector(chairdb) usingBlock:^() {
    ChairDatabase* db = [[ChairDatabase alloc]init]; 
    
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
}

-(void) setChairDB: (ChairDatabase*) chairDB;
{
  [self instance_variable_set: @selector(chairdb) withValue: nil];
}

/*
 * Initialize Couchbase instance.
 */
-(void) initChairDB
{
  [self chairDB];
}

@end
