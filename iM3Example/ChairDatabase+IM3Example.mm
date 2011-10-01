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

-(NSArray*) theaterIdsByMovieId: (NSString*)movie_id
{
  ChairView* schedules_by_movie_id = [self schedules_by_movie_id];
  
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
  return [[[self schedules_by_theater_id] get: theater_id] objectForKey:@"group"];
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
