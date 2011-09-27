//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "Chair.h"

/**
 A ChairView object
*/

@interface ChairView: NSObject {
  NSUInteger      revision_;
  ChairView*      source_view_;
  NSUInteger      source_revision_;
  
  NSMutableArray* dependant_objects_;
}

-(void) addDependantObject: (id) object;

/**
  The revision number. 
 
  Each change in a view changes the view's revision. That means if the revision 
  number has changed, then a dependant view must erase all cached information
  stemming from that view.
*/
@property (nonatomic,assign) NSUInteger revision;
@property (nonatomic,retain) ChairView* source_view;

- (id) init;

/**
  Update this view.
  
  Make sure that the view is up-to-date. For dependant views this checks wether
  or not the source view has been updated, and updates this view accordingly.
  
  Note: you should not have to call this method yourself; this method will be
  called automatically whenever necessary. 
  
  Derived classes implement the actual updating code in the do_update method.
*/
- (void) update;

/**
  Update this view.
  
  @see update
 */
- (void) do_update;

/**

 returns/yields all entries in the view
 
 The opts parameter may contain these entries:

 - min: a single entry or an array of entries.
 - max: a single entry or an array of range entries.
 - excludingEnd: exclude max value?
 - descending: return results in descending order.
*/
- (void) each: (void (^)(NSDictionary* value, id key)) iterator
          min: (id)min
          max: (id)max
 excludingEnd: (BOOL)excludingEnd;
 
/**
  shortcut to yield all entries in the view.
*/
- (void) each: (void (^)(NSDictionary* value, id key)) iterator;

/**
 gets all values
 */
- (NSArray*) values;

@property (readonly,nonatomic) NSArray* values;

/**
 gets all values matching the key or keys
 */
- (NSArray*) valuesWithKey: (id)key;
- (NSArray*) valuesWithKeys: (NSArray*)keys;

/**
 gets all keys
 */
- (NSArray*) keys;

@property (readonly,nonatomic) NSArray* keys;

/**
 returns the first entry in the view, or nil.
 */
-(NSDictionary*) first;

/**
   gets the first entry matching \a key or nil.
 */
- (NSDictionary*) get: (id)key;

/**
 returns the number of entries matchingng options in the view.
 */
- (NSUInteger) countFrom: (id)min
                      to: (id)max
            excludingEnd: (BOOL)excludingEnd;

/**
  returns the number of entries in the view.
*/
- (NSUInteger) count;

@end

typedef void (^EmitCallback)(NSDictionary* value, id key);
typedef void (^MapCallback)(NSDictionary* value, id key, EmitCallback emit);
typedef void (^ReduceCallback)(NSArray* values, id key, EmitCallback emit);
typedef id   (^SimpleMapCallback)(NSDictionary* value, id key);
typedef NSDictionary* (^SimpleReduceCallback)(NSArray* value, id key);

/**
 A ChairView object
 */

@interface ChairView(Dynamic)

-(ChairView*) viewWithMap: (MapCallback)map_fun
                andReduce: (ReduceCallback)reduce_fun;

-(ChairView*) viewWithMap: (SimpleMapCallback) map_func    // change value
                 andGroup: (SimpleMapCallback) group_func  // change key
                andReduce: (SimpleReduceCallback) reduce_func; // reduce function, can be a name 

@end

@interface Chair(Dynamic)

+ (SimpleMapCallback) groupBy: (NSString*) name;
+ (SimpleReduceCallback) reduceBy: (NSString*) name;

@end
