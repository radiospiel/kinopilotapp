#if TARGET_OS_IPHONE 

#import "M3.h"
#import "Chair.h"

#define app [[UIApplication sharedApplication] delegate]

@implementation UIViewController(Model)

+(id)modelForURL: (NSString*)url
{
  if([url matches: @"^/movies/view/(.*)"]) {
    NSNumber* uid = [$1 to_number];
    
    // 
    ChairTable* movies = [[app chairDB] tableForName:@"movies"];
    NSDictionary* movie = [movies get: uid];
    movie = [NSMutableDictionary dictionaryWithDictionary:movie];
    
    [movie setValue:[movie valueForKey:@"url"] forKey:@"action0"];
    
    NSArray* images = [movie valueForKey:@"images"];
    if(images) {
      NSArray* first_image = [images objectAtIndex:0];
      if(first_image) {
        [movie setValue:[first_image valueForKey:@"thumbnail"] forKey:@"image"];
      }
    }
    
    return movie; 
  }
  
  return [NSDictionary dictionary];
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

#endif
