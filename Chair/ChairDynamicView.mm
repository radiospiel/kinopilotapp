//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"
#import "ChairDynamicView.h"

@implementation ChairDynamicView

-(id) initWithView: (ChairView*)view_
            andMap: (MapCallback)map_fun
         andReduce: (ReduceCallback)reduce_fun {
  self = [ super init ];
  if(!self) return nil;
  
  source_view_ = view_;
  map_function_ = map_fun;
  reduce_function_ = reduce_fun;

  return self;
}

+(ChairDynamicView*) viewWithView: (ChairView*)view_
                           andMap: (MapCallback)map_fun
                        andReduce: (ReduceCallback)reduce_fun
{
  ChairDynamicView* view = [[ ChairDynamicView alloc ] initWithView: view_
                                                             andMap: map_fun
                                                          andReduce: reduce_fun ];

  return AUTORELEASE(view);
}

+ (ChairView*) viewWithView: (ChairView*)view
                     andMap: (SimpleMapCallback) map_func    // change value
                   andGroup: (SimpleMapCallback) group_func  // change key
                  andReduce: (SimpleReduceCallback) reduce_func // reduce function, can be a name 
{
  if(!map_func) map_func = ^(NSDictionary* value, id key) { return value; };
  if(!group_func) group_func = ^(NSDictionary* value, id key) { return key; };

  MapCallback map_fun = ^(NSDictionary* value, id key, EmitCallback emit) {
                          value = map_func(value, key);
                          if(!value) return;

                          key = group_func(value, key);
                          if(!key) return;

                          emit(value, key);
                        };

  ReduceCallback reduce_fun = nil;
  if(reduce_func) {
    reduce_fun = ^(NSArray* values, id key, EmitCallback emit) {
                   id value = reduce_func(values, key);
                   // NSLog(@"reduced %@: %@ to %@", key, values, value);
                   if(value) emit(value, key);
    };
  };
  
  return [ ChairView viewWithView: view
                           andMap: map_fun
                        andReduce: reduce_fun ];
}

// --------------------------------------------------------------------

- (void) do_update {
  ChairMultiDictionary* stage1 = [ ChairMultiDictionary dictionary ]; 
  EmitCallback emit; 
  
  // --- map stage ------------------------------------------------

  emit = ^(id value, id key) {
    [stage1 addObject:value forKey: key ];
  };

  [ source_view_ each:^(NSDictionary* value, id key) {
    map_function_(value, key, emit);
  } ];

  if(!reduce_function_) {
    self.dictionary = stage1;
    return;
  }
  
  // --- reduce stage ------------------------------------------------

  ChairDictionary* stage2 = [ ChairDictionary dictionary ];
  emit = ^(NSDictionary* value, id key) {
    [stage2 setObject:value forKey: key ];
  };
  
  [ stage1 eachArray: ^(NSArray *values, id key) {
                        reduce_function_(values, key, emit);
                      } 
                 min: nil
                 max: nil
        excludingEnd: NO
   ];

  self.dictionary = stage2;
}

@end
