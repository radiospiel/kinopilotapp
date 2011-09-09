//
//  iM3Tests.m
//  iM3Tests
//
//  Created by Enrico Thierbach on 09.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "iM3Tests.h"

#import "M3.h"
#import "M3+JSON.h"

/* Test helper macros */

@implementation iM3Tests

- (void) test_etest 
{
  [ M3ETest runAll ];
}

@end
