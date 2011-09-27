//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"
#import "ChairDynamicView.h"

@implementation ChairDynamicView

@synthesize map_function = map_function_;
@synthesize reduce_function = reduce_function_;

-(id) initWithView: (ChairView*)view_
            andMap: (MapCallback)map_fun
         andReduce: (ReduceCallback)reduce_fun {
  self = [super init];
  if(!self) return nil;
  
  source_view_ = view_;
  self.map_function = [[map_fun copy]autorelease];
  self.reduce_function = [[reduce_fun copy]autorelease];

  [source_view_ addDependantObject: self];
  return self;
}

-(void)dealloc
{
  LOG_DEALLOC;
  
  self.map_function = nil;
  self.reduce_function = nil;
  
  [super dealloc];
}

// --------------------------------------------------------------------

- (ChairMultiDictionary*) createUpdatedDictionary {
  /*
   * === map stage =================================================== 
   */
  ChairMultiDictionary* mapped = [[ChairMultiDictionary alloc] init]; 
  
  if(map_function_) {
    EmitCallback emit = ^(id value, id key) {
      [mapped addObject:value forKey: key];
    };
    
    [source_view_ each:^(NSDictionary* value, id key) {
      map_function_(value, key, emit);
    }];
  }

  if(!reduce_function_) return mapped;
  
  /*
   * === reduce stage =================================================== 
   */
  ChairMultiDictionary* reduced = [[ChairMultiDictionary alloc] init];
  EmitCallback emit = ^(NSDictionary* value, id key) {
    [reduced addObject:value forKey: key];
  };
    
  [mapped eachArray: ^(NSArray *values, id key) { reduce_function_(values, key, emit); } 
                min: nil
                max: nil
       excludingEnd: NO
   ];  
  
  [mapped release];
  return reduced;
}

- (void) do_update {
  self.dictionary = [self createUpdatedDictionary];
}

@end

@implementation ChairView(Dynamic)

-(ChairView*) viewWithMap: (MapCallback)map_fun
                andReduce: (ReduceCallback)reduce_fun
{
  ChairView* r = [[ChairDynamicView alloc] initWithView: self
                                                 andMap: map_fun
                                              andReduce: reduce_fun];
  return [r autorelease];
}

-(ChairView*) viewWithMap: (SimpleMapCallback) map_func    // change value
                 andGroup: (SimpleMapCallback) group_func  // change key
                andReduce: (SimpleReduceCallback) reduce_func // reduce function, can be a name 
{
  if(!map_func) map_func = ^(NSDictionary* value, id key) { return value; };
  if(!group_func) group_func = ^(NSDictionary* value, id key) { return key; };

  map_func = AUTORELEASE([map_func copy]);
  group_func = AUTORELEASE([group_func copy]);
  
  MapCallback map_fun = ^(NSDictionary* value, id key, EmitCallback emit) {
                          value = map_func(value, key);
                          if(!value) return;

                          key = group_func(value, key);
                          if(!key) return;

                          emit(value, key);
                        };

  map_fun = AUTORELEASE([map_fun copy]);

  ReduceCallback reduce_fun = nil;
  if(reduce_func) {
    reduce_func = AUTORELEASE([reduce_func copy]);
    
    reduce_fun = ^(NSArray* values, id key, EmitCallback emit) {
                   id value = reduce_func(values, key);
                   if(value) emit(value, key);
    };
  };
  
  ChairView* r = [[ChairDynamicView alloc] initWithView: self
                                                 andMap: map_fun
                                              andReduce: reduce_fun];

  return [r autorelease];
}

@end
