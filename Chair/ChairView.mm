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
@synthesize source_view = source_view_;

- (id) init {
  self = [ super init ];
  if(!self) return nil;
  
  self.revision = 0;
  self.source_view = nil;
  source_revision_ = 0;
  
  dependant_objects_ = [[[ NSMutableArray alloc ]init] retain];
  
  return self;
}

-(void)dealloc 
{
  NSLog(@"ChairView dealloc: %ld", (long)self);

  [dependant_objects_ release];
  
  self.revision = 0;
  self.source_view = nil;

  [super dealloc];
}

-(void) addDependantObject: (id) object;
{
  [ dependant_objects_ addObject: object ];
}

-(NSString*) description
{
  return [NSString stringWithFormat:  @"<%@: %ld dependants%>", 
                                      NSStringFromClass ([self class]), 
                                      dependant_objects_.count];
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
  
  return [r autorelease];
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
