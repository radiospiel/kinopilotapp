#import "AppDelegate.h"
#import "M3.h"
#import "Chair.h"

@implementation AppDelegate(ChairDB)

/*
 * Return an instance 
 */
-(ChairDatabase*) chairDB
{
  ChairDatabase* db = [self memoized: @selector(chairdb) usingBlock:^() {
    ChairDatabase* db = [ChairDatabase database];
    [self on: @selector(resumed) notify: db with:@selector(updateIfNeeded)];
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
