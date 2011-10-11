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
  self = [super init];
  if(!self) return nil;
  
  self.revision = 0;
  self.source_view = nil;
  source_revision_ = 0;
  
  dependant_objects_ = [[NSMutableArray alloc]init];
  
  return self;
}

-(void)dealloc 
{
  [dependant_objects_ release];
  
  self.revision = 0;
  self.source_view = nil;

  [super dealloc];
}

-(void) addDependantObject: (id) object;
{
  [dependant_objects_ addObject: object];
}

-(NSString*) description
{
  return [NSString stringWithFormat: @"<%@: %ld dependants>", NSStringFromClass([self class]), dependant_objects_.count];
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
  if(source_revision_ == source_view_.revision) return;

  [self do_update];
  source_revision_ = source_view_.revision;
}

-(BOOL)isDirty
{
  if(!source_view_) return NO;
  if(source_revision_ == source_view_.revision) return NO;

  return YES;
}

- (void) do_update {
}

- (void) each: (void (^)(NSDictionary* value, id key)) iterator
          min: (id)min
          max: (id)max
 excludingEnd: (BOOL)excludingEnd;
{
  [self update];
}

- (void) each: (void (^)(NSDictionary* value, id key)) iterator;
{
  [self each: iterator min: nil max: nil excludingEnd: NO];
}

/** get first, all, all matching values. Get all keys. */

-(NSDictionary*) first;
{
  NSArray* keys = [self keys];
  if([keys count] == 0) return nil;
  return [self get:keys.first];
}

-(NSArray*) keys {
  NSMutableArray* keys = [NSMutableArray array];
  id __block lastKey = nil;
  
  [self each: ^(NSDictionary* value, id key) { 
    if(!lastKey || _.compare(lastKey, key))
      [keys addObject: key]; 
    }];
  
  return keys;
}

- (NSArray*) valuesWithKeys: (NSArray*)keys
{
  NSMutableArray* array = [NSMutableArray array];

  for(id key in keys) {
    [self each:^(NSDictionary *value, id key) { [array addObject:value]; } 
           min: key max: key excludingEnd: NO];
  }

  return array;
}

- (NSArray*) valuesWithKey: (id)key
{
  NSMutableArray* array = [NSMutableArray array];
  
  [self each:^(NSDictionary *value, id key) { [array addObject:value]; } 
         min: key max: key excludingEnd: NO];
  
  return array;
  
}

- (NSArray*) values
{
  return [self valuesWithKey: nil];
}

/** Get an entry off the dictionary. */

- (NSDictionary*) get: (id)key
{
  NSDictionary* __block r = nil;

  [self each: ^(NSDictionary* value, id key) { r = value; }
          min: key max: key excludingEnd: NO];
  
  return r;
}

/** returns the number of entries in the view. */

- (NSUInteger) count {
  NSUInteger __block r = 0;
  [self each: ^(NSDictionary* value, id key) { r++; }];
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
  [self each: ^(NSDictionary* value, id key) { r++; } min: min max: max excludingEnd: excludingEnd];
  return r;
}

@end
