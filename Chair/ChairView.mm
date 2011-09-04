//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"
#import "ChairDynamicView.h"

@implementation ChairView

@synthesize revision = revision_;

- (id) init {
  self = [ super init ];
  if(!self) return nil;
  
  revision_ = 0;
  source_view_ = nil;
  source_revision_ = 0;
  
  return self;
}

/**
  Update this view.
  
  Make sure that the view is up-to-date. For dependant views this checks wether
  or not the source view has been updated, and updates this view accordingly.
  
  Note: you should not have to call this method yourself; this method should be
  called automatically whenever necessary. 
*/
- (void) update {
  if(!source_view_) return;
  if(source_revision_ && source_revision_ == source_view_.revision) return;

  [self do_update ];
  source_revision_ = source_view_.revision;
}

- (void) do_update {
}

- (void) each: (void (^)(NSDictionary* value, id key)) iterator
          min: (id)min
          max: (id)max
 excludingEnd: (BOOL)excludingEnd;
{
  [ self update ];
}

- (void) each: (void (^)(NSDictionary* value, id key)) iterator;
{
  [ self each: iterator min: nil max: nil excludingEnd: nil ];
}

- (NSDictionary*) get: (id)key
{
  NSDictionary* __block r = nil;
   
  [ self each: ^(NSDictionary* value, id key) { r = value; }
          min: key max: key excludingEnd: NO ];
  
  return r;
}

/**
 returns the number of entries in the view.
 */
- (NSUInteger) count {
  NSUInteger __block r = 0;
  [ self each: ^(NSDictionary* value, id key) { r++; } ];
  return r;
}

/**
 returns the number of entries matchingng options in the view.
 */
- (NSUInteger) countFrom: (id)min
                      to: (id)max
            excludingEnd: (BOOL)excludingEnd;
{
  NSUInteger __block r = 0;
  [ self each: ^(NSDictionary* value, id key) { r++; } min: min max: max excludingEnd: excludingEnd ];
  return r;
}

-(NSArray*) keys {
  NSMutableArray* keys = [ NSMutableArray array ];
  
  [ self each: ^(NSDictionary* value, id key) { [keys addObject: key ]; } ];
  return keys;
}

-(NSArray*) values {
  NSMutableArray* values = [ NSMutableArray array ];
  
  [ self each: ^(NSDictionary* value, id key) { [values addObject: value ]; } ];
  return values;
}

@end


@implementation ChairView(Dynamic)

+ (ChairView*) viewWithView: (ChairView*)view
                     andMap: (MapCallback) map_func
                  andReduce: (ReduceCallback) reduce_func;
{
  return [ ChairDynamicView viewWithView: view
                                  andMap: map_func
                               andReduce: reduce_func ];
}

+ (ChairView*) viewWithView: (ChairView*)view
                     andMap: (SimpleMapCallback) map_func          // change value
                   andGroup: (SimpleMapCallback) group_func        // change key
                  andReduce: (SimpleReduceCallback) reduce_func;  // reduce function, can be a name 
{
  return [ ChairDynamicView viewWithView: view
                                  andMap: map_func        // change value
                                andGroup: group_func      // change key
                               andReduce: reduce_func ];
}

@end
