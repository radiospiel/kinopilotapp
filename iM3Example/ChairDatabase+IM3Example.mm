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
  NSArray* images = [movie valueForKey:@"images"];
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



-(NSArray*) theaterIdsByMovieId: (NSNumber*)movieID
{
  // -- SQL pseudo code ----------------------------------------
  //
  // SELECT * FROM schedules WHERE movie_id=$1
  // INNER JOIN theaters ON theaters.uid = schedules.theater_id
  // ORDER BY theaters.name
  
  NSMutableArray* m_array = [NSMutableArray array];
  
  [self.schedules each:^(NSDictionary *value, id key) {
    if(![movieID isEqual:[value objectForKey:@"movie_id"]]) return;
    [m_array addObject: [value objectForKey:@"theater_id"]];
  }];

  NSArray* array = [m_array uniq];
  return [array sortedArrayUsingSelector:@selector(compare:)];
  
  // == or just
  //  
  // ChairView* schedules_by_movie_id = app.chairDB.schedules;
  //  
  // [schedules_by_movie_id each:^(NSDictionary *value, id key) {
  //    // <#code#>
  // } 
  //                         min:this_movies_id 
  //                         max:this_movies_id 
  //                excludingEnd:NO];
}

-(NSArray*) movieIdsByTheaterId: (NSNumber*)theaterID
{
  NSMutableArray* m_array = [NSMutableArray array];
  
  [self.schedules each:^(NSDictionary *value, id key) {
    if(![theaterID isEqual:[value objectForKey:@"theater_id"]]) return;
    [m_array addObject: [value objectForKey:@"movie_id"]];
  }];
  
  NSArray* array = [m_array uniq];
  return [array sortedArrayUsingSelector:@selector(compare:)];
  
  // == or just
  //  
  // ChairView* schedules_by_movie_id = app.chairDB.schedules;
  //  
  // [schedules_by_movie_id each:^(NSDictionary *value, id key) {
  //    // <#code#>
  // } 
  //                         min:this_movies_id 
  //                         max:this_movies_id 
  //                excludingEnd:NO];
}



@end
