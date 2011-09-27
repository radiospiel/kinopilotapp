#import "AppDelegate.h"

@implementation ChairDatabase(IM3Example)

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

-(void) adjustMovies:(NSMutableDictionary*)movie
{
  NSArray* images = [movie objectForKey:@"images"];
  if([images.first isKindOfClass:[NSDictionary class]]) {
    [movie setValue: [images.first objectForKey:@"thumbnail"] forKey: @"image"];
  }
}

-(void) adjustTheaters:(NSMutableDictionary*)theater
{
  [theater setObject: [theater objectForKey:@"name"]    forKey: @"title"];
  [theater setObject: [theater objectForKey:@"address"] forKey: @"description"];
}

-(NSDictionary*)modelWithURL: (NSString*)url
{
  if([url matches: @"^/([^/]+)/[^/]+/(.*)"])
    return [self objectForKey: $2.to_number andType: $1];
  
  return [NSDictionary dictionary];
}

-(ChairView*) schedules_by_movie_id_
{
  return [ self.schedules viewWithMap:nil
                             andGroup:^id(NSDictionary *value, id key) { return [value objectForKey:@"movie_id"]; }
                            andReduce:^id(NSArray *values, id key) { return _.hash("group", values); }
  ];
}

-(ChairView*) schedules_by_theater_id_
{
  return [ self.schedules viewWithMap:nil
                             andGroup:^id(NSDictionary *value, id key) { return [value objectForKey:@"theater_id"]; }
                            andReduce:^id(NSArray *values, id key) { return _.hash("group", values); }
  ];
}

-(ChairView*) schedules_by_movie_id
{
  return [self memoized: @selector(schedules_by_movie_id) 
          usingSelector: @selector(schedules_by_movie_id_)];
}

-(ChairView*) schedules_by_theater_id
{
  return [self memoized: @selector(schedules_by_theater_id) usingSelector: @selector(schedules_by_theater_id_)];
}

-(NSArray*) theaterIdsByMovieId: (NSNumber*)movie_id
{
  ChairView* schedules_by_movie_id = [self schedules_by_movie_id];
  
  NSArray* schedules = [[schedules_by_movie_id get: movie_id] objectForKey:@"group"];
  NSArray* theater_ids = [schedules pluck: @"theater_id"];

  return theater_ids.uniq.sort;
}

-(NSArray*) movieIdsByTheaterId: (NSNumber*)theater_id
{
  ChairView* schedules_by_theater_id = [self schedules_by_theater_id];
  
  NSArray* schedules = [[schedules_by_theater_id get: theater_id] objectForKey:@"group"];
  NSArray* movie_ids = [schedules pluck: @"movie_id"];
  
  return movie_ids.uniq.sort;
}


-(NSArray*) schedulesByMovieId: (NSNumber*)movie_id andTheaterId: (NSNumber*)theater_id
{
  ChairView* schedules_by_theater_id = [self schedules_by_theater_id];
  
  NSArray* schedules = [[schedules_by_theater_id get: theater_id] objectForKey:@"group"];
  
  NSMutableArray* array = [NSMutableArray array];
  for(NSDictionary* schedule in schedules) {
    NSNumber* schedule_movie_id = [schedule objectForKey:@"movie_id"];
    if([movie_id isEqual:schedule_movie_id]) 
      [array addObject:schedule];
  }
  
  return array;
}

@end
