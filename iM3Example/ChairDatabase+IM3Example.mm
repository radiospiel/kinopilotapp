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

@end
