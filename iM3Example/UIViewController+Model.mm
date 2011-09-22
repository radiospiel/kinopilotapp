#import "AppDelegate.h"
#import "Chair.h"


#define app ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define addr(ptr) [ NSString stringWithFormat: @"0x%08x", ptr]

@implementation UIViewController(Model)

+(id)modelForURL: (NSString*)url
{
  @autoreleasepool {
    
  if([url matches: @"^/movies/show/(.*)"]) {
    NSNumber* uid = [$1 to_number];
    
    NSDictionary* movie = [app.chairDB.movies get: uid];
    dlog << "movie is at " << addr(movie);
    
    movie = [[NSMutableDictionary alloc] initWithDictionary: movie];
    dlog << "copied movie is at " << addr(movie);
    
    [movie setValue:[movie valueForKey:@"url"] forKey:@"action0"];
    
    NSArray* images = [movie valueForKey:@"images"];
    if(images.first)
      [movie setValue:[images.first valueForKey:@"thumbnail"] forKey:@"image"];
    
    return movie; 
  }
  
  if([url matches: @"^/movies/list(/(.*))?"]) {
    return app.chairDB.movies;
  }
  
  return [NSDictionary dictionary];
  }
}

-(NSDictionary*) model 
{
  if(!self.url) return nil;
 
  return [self memoized:@selector(model) usingBlock:^(){
    return [UIViewController modelForURL: self.url];
  }];
}

-(NSString*) url {
  return [ self instance_variable_get: @selector(url) ];
};

-(void) setUrl: (NSString*)url {
  [ self instance_variable_set: @selector(url) withValue: url ];
};

-(NSString*) title {
  // Use any pre-set title
  NSString* title = [ self instance_variable_get: @selector(title) ];
  if(title) return title;
  
  // Do we have a model? Use a @"title" or @"label" property in that case.
  NSDictionary* model = self.model;
  if([model isKindOfClass:[NSDictionary class]]) {
    title = [model objectForKey:@"title"];
    if(title) return title;
    
    title = [model objectForKey:@"label"];
    if(title) return title;
  }

  // Use the class name as a title -- mostly for development purposes.
  return NSStringFromClass([self class]);
};

-(void) setTitle: (NSString*)title {
  [ self instance_variable_set: @selector(title) withValue: title ];
};

@end
