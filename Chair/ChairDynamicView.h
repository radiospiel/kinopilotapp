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

@property (retain,nonatomic) MapCallback map_function;
@property (retain,nonatomic) ReduceCallback reduce_function;

@end
