#import <Foundation/Foundation.h>
#import "NSArray+M3Extensions.h"
#include <glob.h>
#include "Underscore.hh"

@implementation NSArray (Globbing)

/* 
 * This is from https://gist.github.com/293959
 * Thanks, bkyle!
 */

+ (NSArray*) arrayWithFilesMatchingPattern: (NSString*) pattern 
                                inDirectory: (NSString*) directory 
{
  NSMutableArray* files = [NSMutableArray array];
  glob_t gt;

  NSString* globPathComponent = [NSString stringWithFormat: @"/%@", pattern];
  NSString* expandedDirectory = [directory stringByExpandingTildeInPath];
  const char* fullPattern = [[expandedDirectory stringByAppendingPathComponent: globPathComponent] UTF8String];
  
  if (glob(fullPattern, 0, NULL, &gt) == 0) {
    NSFileManager* fileman = [NSFileManager defaultManager];
    for (int i=0; i<gt.gl_matchc; i++) {
      size_t len = strlen(gt.gl_pathv[i]);
      NSString* filename = [fileman stringWithFileSystemRepresentation: gt.gl_pathv[i] length: len];
      [files addObject: filename];
    }
  }
  globfree(&gt);
  return [NSArray arrayWithArray: files];
}

@end

@implementation NSArray (M3Extensions)

-(id) first
{
  if(self.count < 1) return nil;
  return [self objectAtIndex: 0];
}

-(id) second
{
  if(self.count < 2) return nil;
  return [self objectAtIndex: 1];
}

-(id) last
{
  if(self.count < 1) return nil;
  return [self objectAtIndex: (self.count - 1)];
}

-(NSArray*) uniq
{
  return [[NSSet setWithArray: self] allObjects];                   
}

-(NSMutableArray*) pluck: (NSString*)attributeName
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count];
  for(NSDictionary* entry in self) {
    M3AssertKindOf(entry, NSDictionary);
    
    id object = [entry objectForKey: attributeName];
    if(object) 
      [array addObject: object];
  }
  
  return array;
}

/**
 * sorting
 */

static NSComparisonResult underscore_compare(id a, id b, void* p) {
  return _.compare(a, b);
}

-(NSArray*) sort
{
  return [self sortedArrayUsingSelector:@selector(compare:)];
}

-(NSArray*) sortBySelector: (SEL)selector
{
  return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    id val1 = [obj1 performSelector: selector];
    id val2 = [obj2 performSelector: selector];
    return [val1 compare:val2];
  }];
}

-(NSArray*) sortByBlock: (id (^)(id obj))block
{
  return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    id val1 = block(obj1);
    id val2 = block(obj2);
    return [val1 compare:val2];
  }];
}

-(NSArray*) sortByKey: (id) key
{
  return [self sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
    id val1 = [obj1 objectForKey: key];
    id val2 = [obj2 objectForKey: key];
    return [val1 compare:val2];
  }];
}

-(NSMutableArray*) mapUsingSelector: (SEL)selector
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count];
  for(NSDictionary* entry in self) {
    id object = [entry performSelector: selector];
    if(object) 
      [array addObject: object];
  }
  
  return array;
}

-(NSMutableArray*) mapUsingBlock: (id (^)(id obj))block
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count];
  for(NSDictionary* entry in self) {
    id object = block(entry);
    if(object) 
      [array addObject: object];
  }
  
  return array;
}

-(NSMutableDictionary*)groupUsingKey: (id)key
{
  NSMutableDictionary* groupedHash = [NSMutableDictionary dictionary];
  
  for(NSDictionary* object in self) {
    id keyValue = [object objectForKey: key];

    NSMutableArray* group = [groupedHash objectForKey:keyValue];
    if(!group) {
      group = [NSMutableArray array];
      [groupedHash setObject: group forKey:keyValue];
    }
    
    [group addObject:object];
  }
  
  return groupedHash;
}

-(NSMutableDictionary*)groupUsingBlock: (id (^)(id obj))block
{
  NSMutableDictionary* groupedHash = [NSMutableDictionary dictionary];
  
  for(id object in self) {
    id key = block(object);
    
    NSMutableArray* group = [groupedHash objectForKey:key];
    if(!group) {
      group = [NSMutableArray array];
      [groupedHash setObject: group forKey:key];
    }
    
    [group addObject:object];
  }
  
  return groupedHash;
}

-(NSMutableDictionary*)groupUsingSelector: (SEL)selector
{
  NSMutableDictionary* groupedHash = [NSMutableDictionary dictionary];
  
  for(id object in self) {
    id key = [object performSelector: selector];
    
    NSMutableArray* group = [groupedHash objectForKey:key];
    if(!group) {
      group = [NSMutableArray array];
      [groupedHash setObject: group forKey:key];
    }
    
    [group addObject:object];
  }
  
  return groupedHash;
}

-(NSMutableArray*) rejectUsingSelector: (SEL)selector
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count / 4];
  for(NSDictionary* entry in self) {
    if(![entry performSelector: selector]) [array addObject: entry];
  }
  
  return array;
}

-(NSMutableArray*) rejectUsingBlock: (BOOL (^)(id obj))block
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count / 4];
  for(NSDictionary* entry in self) {
    if(!block(entry)) 
      [array addObject: entry];
  }
  
  return array;
}

-(NSMutableArray*) selectUsingSelector: (SEL)selector
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count / 4];
  for(NSDictionary* entry in self) {
    if([entry performSelector: selector]) 
      [array addObject: entry];
  }
  
  return array;
}

-(NSMutableArray*) selectUsingBlock: (BOOL (^)(id obj))block
{
  NSMutableArray* array = [NSMutableArray arrayWithCapacity: self.count / 4];
  for(NSDictionary* entry in self) {
    if(block(entry)) 
      [array addObject: entry];
  }
  
  return array;
}

@end

@implementation NSDictionary(M3Extensions)

-(NSArray*)to_array
{
  NSMutableArray* array = [NSMutableArray array];
  
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [array addObject:[NSArray arrayWithObjects:key, obj, nil]];
  }];
  
  return array;
}

@end
