#import "AppDelegate.h"
#import "M3.h"
#import "Chair.h"

@implementation AppDelegate(ChairDB)

/*
 * Return an instance 
 */
-(ChairDatabase*) chairDB
{
  return [self memoized: @selector(chairdb) usingBlock:^() {
    
    rlog << "Initializing database";
    
    // NSString* dbPath = @"$app/data/berlin.json";
    NSString* dbPath = @"http://kinopilotupdates2.heroku.com/db/berlin";
    
    Benchmark(_.join("Loading database from ", dbPath));
    
    ChairDatabase* db = [[ChairDatabase alloc]init]; 
    [db import: dbPath];

    rlog(1) << "Loaded database from " << dbPath << ": " << db;

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
