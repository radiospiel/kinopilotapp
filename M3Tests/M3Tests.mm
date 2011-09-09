//
//  M3Tests.m
//  M3Tests
//
//  Created by Enrico Thierbach on 04.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
#import "M3+JSON.h"
#import "Underscore.hh"
#import "M3Tests.h"

/* Test helper macros */

@implementation M3Tests

- (void) test_etest 
{
  [ M3ETest runAll ];
}

@end
