//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "ChairTable.h"

@interface ChairDynamicView: ChairMaterializedView {
  MapCallback     map_function_;
  ReduceCallback  reduce_function_;
}

+(ChairView*) viewWithView: (ChairView*)view_
                    andMap: (MapCallback)map_fun
                 andReduce: (ReduceCallback)reduce_fun;

+(ChairView*) viewWithView: (ChairView*)view
                    andMap: (SimpleMapCallback) map_func     // change value
                  andGroup: (SimpleMapCallback) group_func   // change key
                 andReduce: (SimpleReduceCallback) reduce_func; // reduce function, can be a name 

@end
