#import "AppDelegate.h"
#import "GTMSqlite+M3Additions.h"

#if 0
#define REMOTE_URL  @"http://kinopilotupdates2.heroku.com/db/images,berlin"
#else
#define REMOTE_URL      @"http://localhost:3000/db/images,berlin"
#define REMOTE_SQL_URL  @"http://localhost:3000/db/images,berlin.sql"
#endif

// #define DB_PATH     @"$documents/chairdb/berlin.json"
#define DB_PATH     @"$documents/chairdb/kinopilot"

@interface ChairDatabase(Private)

-(void)resetMemoizedViews;

@end

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

-(BOOL)loadLocalCopy
{
  if(![M3 fileExists: DB_PATH]) return NO;

  {
    Benchmark(_.join("Loading database from ", DB_PATH));
    [self load: DB_PATH];
  }  

  [self updateCompleted];

  return YES;
}

-(BOOL)loadRemoteURL
{
#if 1
  {
    // NSString* dbPath = [M3 expandPath: @"$documents/kinopilot.sqlite3"];
    NSString* dbPath = @":memory:";
    
    M3SqliteDatabase* db = [M3SqliteDatabase databaseWithPath:dbPath
                                              withCFAdditions:NO 
                                                         utf8:YES 
                                                    errorCode:0];
    
    [db synchronousMode:NO];

    NSArray* entries = [M3 readJSON: REMOTE_SQL_URL];
    if(![entries isKindOfClass: [NSArray class]])
      _.raise("Cannot read file", REMOTE_SQL_URL);
    
    Benchmark(_.join("Importing database from ", REMOTE_SQL_URL));
  
    [db importDump:entries];
  }
#endif
  
  {
    Benchmark(_.join("Loading database from ", REMOTE_URL));
    [self import: REMOTE_URL];
  }

  [self updateCompleted];

  {
    Benchmark(_.join("Saving database to ", DB_PATH));
    [self save: DB_PATH];
  }

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

-(void)updateIfNeeded
{
  if(![self isLoaded]) {
    if([self loadLocalCopy]) return;
    if([self loadRemoteURL]) return;
  }
  else {
    // TODO: check for updates
  }
}

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

-(SEL)adjustSelectorForType: (NSString*) typeName
{
  NSString* selectorName = [NSString stringWithFormat: @"adjust%@:", typeName.camelizeWord];
  
  SEL selector = NSSelectorFromString(selectorName);
  if(![self respondsToSelector: selector])
    return nil;

  return selector;
}

-(NSDictionary*)objectForKey: (id)key andType: (NSString*) type
{
  ChairTable* table = [self tableForName: type];
  NSDictionary* model = [table get: key];

  if(model) {
    SEL adjustSelector = [self adjustSelectorForType: type];
    if(adjustSelector) {
      model = [NSMutableDictionary dictionaryWithDictionary:model];
      [self performSelector:adjustSelector withObject:model];
    }
  }

  return model;
}

-(NSDictionary*) adjustMovies:(NSDictionary*)movie
{
  if([movie objectForKey:@"image"])
    return movie;

  NSMutableDictionary* adjusted = [NSMutableDictionary dictionaryWithDictionary:movie];
  
  NSArray* images = [movie objectForKey:@"images"];
  images = [images selectUsingBlock:^BOOL(id obj) {
    return [obj isKindOfClass:[NSDictionary class]];
  }];

  if(images.count > 0) {
    NSArray* thumbnails = [images mapUsingBlock:^id(NSDictionary* imageHash) {
      return [imageHash objectForKey:@"thumbnail"]; 
    }];
    
    [adjusted setValue: thumbnails.first  forKey: @"image"];
    [adjusted setValue: thumbnails        forKey: @"thumbnails"];
  }
  
  return adjusted;
}

-(NSDictionary*) adjustTheaters:(NSDictionary*)theater
{
  return theater;
}

-(NSDictionary*) adjustModel:(NSDictionary*)model
{
  NSString* typeName = [model objectForKey:@"_type"];
  if([typeName isEqualToString:@"theaters"])
    return [self adjustTheaters:model];
  
  if([typeName isEqualToString:@"movies"])
    return [self adjustMovies:model];
  
  return model;
}

-(NSDictionary*)modelWithURL: (NSString*)url
{
  if(![url matches: @"^/([^/]+)/[^/]+/(.*)"])
    return [NSDictionary dictionary];

  NSDictionary* model = [self objectForKey: $2 andType: $1];
  return [self adjustModel:model];
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
