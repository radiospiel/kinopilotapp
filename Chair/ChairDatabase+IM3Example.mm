#import "AppDelegate.h"
#import "GTMSqlite+M3Additions.h"

#if 1
#define REMOTE_URL  @"http://kinopilotupdates2.heroku.com/db/images,berlin"
#define REMOTE_SQL_URL  @"http://kinopilotupdates2.heroku.com/db/images,berlin.sql"
#else
#define REMOTE_URL      @"http://localhost:3000/db/images,berlin"
#define REMOTE_SQL_URL  @"http://localhost:3000/db/images,berlin.sql"
#endif

@interface ChairDatabase(Private)

-(void)resetMemoizedViews;

@end

#error HO

@implementation ChairDatabase(IM3Example)

-(BOOL)isLoaded
{
  return self.movies.count > 0;
}

-(void) updateCompleted
{
  [self resetMemoizedViews];
  [self emit:@selector(updated)];
}

-(BOOL)loadRemoteURL
{  
  M3SqliteDatabase* db = [app sqliteDatabase];
  NSNumber* movie_count = [db ask: @"SELECT COUNT(*) FROM movies"];
  if(movie_count.to_i > 0) {
    dlog << "DB already initialized";
    return YES;
  }
  
  NSArray* entries = [M3 readJSON: REMOTE_SQL_URL];
  if(![entries isKindOfClass: [NSArray class]])
    _.raise("Cannot read file", REMOTE_SQL_URL);
    
  Benchmark(_.join("Importing database from ", REMOTE_SQL_URL));
  
  [db importDump:entries];
  
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

-(ChairTable*) stats
{
  return [self tableForName:@"stats"];
}

-(ChairTable*) movies
{
  return [self tableForName:@"movies"];
}

-(ChairTable*) theaters
{
  return [self tableForName:@"theaters"];
}

-(ChairTable*) schedules
{
  return [self tableForName:@"schedules"];
}

-(ChairTable*) news
{
  return [self tableForName:@"news"];
}

-(ChairTable*) images
{
  return [self tableForName:@"images"];
}

-(UIImage*)thumbnailForMovie: (NSString*)movie_id
{
  NSDictionary* thumbnailData = [self.images get: movie_id];
  NSString* encodedImage = [thumbnailData objectForKey:@"data"];
  if(!encodedImage) return nil;
  
  NSData* data = [M3 decodeBase64WithString:encodedImage];
  if(!data) return nil;
  
  return [UIImage imageWithData: data];
}

-(NSString*)trailerURLForMovie: (NSString*)movie_id
{
  NSDictionary* movie = [self.movies get: movie_id];
  NSDictionary* videos = [movie objectForKey: @"videos"];
  NSDictionary* video = [videos objectForKey: @"video"];

  NSNumber* brightcove_id = [video objectForKey: @"brightcove-id"];
  if(!brightcove_id) return nil;
  
  return _.join(@"/movies/trailer?brightcove_id=", brightcove_id);
}

/** -- memoizedViews ------------------------------------------------------------------ **/

-(void)resetMemoizedViews
{
  [self instance_variable_set: @selector(schedules_by_movie_id) withValue:nil];
  [self instance_variable_set: @selector(schedules_by_theater_id) withValue:nil];
}

-(ChairView*) schedules_by_movie_id_
{
  return [ self.schedules viewWithMap:nil
                             andGroup:^id(NSDictionary *value, id key) { return [value objectForKey:@"movie_id"]; }
                            andReduce:^id(NSArray *values, id key) { return _.hash("group", values); }
  ];
}

-(ChairView*) schedules_by_movie_id
{
  return [self memoized: @selector(schedules_by_movie_id)
          usingSelector: @selector(schedules_by_movie_id_)];
}

-(ChairView*) schedules_by_theater_id_
{
  return [ self.schedules viewWithMap:nil
                             andGroup:^id(NSDictionary *value, id key) { return [value objectForKey:@"theater_id"]; }
                            andReduce:^id(NSArray *values, id key) { return _.hash("group", values); }
  ];
}

-(ChairView*) schedules_by_theater_id
{
  return [self memoized: @selector(schedules_by_theater_id) 
          usingSelector: @selector(schedules_by_theater_id_)];
}

/** -------------------------------------------------------------------- **/

-(NSArray*) theaterIdsByMovieId: (NSString*)movie_id
{
  ChairView* schedules_by_movie_id = [self schedules_by_movie_id];
  [schedules_by_movie_id update];

  NSArray* schedules = [[schedules_by_movie_id get: movie_id] objectForKey:@"group"];
  NSArray* theater_ids = [schedules pluck: @"theater_id"];

  return theater_ids.uniq.sort;
}

-(NSArray*) movieIdsByTheaterId: (NSString*)theater_id
{
  ChairView* schedules_by_theater_id = [self schedules_by_theater_id];
  
  NSArray* schedules = [[schedules_by_theater_id get: theater_id] objectForKey:@"group"];
  NSArray* movie_ids = [schedules pluck: @"movie_id"];
  
  return movie_ids.uniq.sort;
}

-(NSArray*) schedulesByMovieId: (NSString*)movie_id
{
  return [[[self schedules_by_movie_id] get: movie_id] objectForKey:@"group"];
}

-(NSArray*) schedulesByTheaterId: (NSString*)theater_id
{
  ChairView* view = [self schedules_by_theater_id];
  NSDictionary* group = [view get: theater_id];
  
  return [group objectForKey:@"group"];
}


-(NSArray*) schedulesByMovieId: (NSString*)movie_id andTheaterId: (NSString*)theater_id
{
  NSArray* schedules = [self schedulesByTheaterId: theater_id];
  
  NSMutableArray* array = [NSMutableArray array];
  for(NSDictionary* schedule in schedules) {
    NSNumber* schedule_movie_id = [schedule objectForKey:@"movie_id"];
    if([movie_id isEqual:schedule_movie_id]) 
      [array addObject:schedule];
  }
  
  return array;
}

@end
