//
//  M3.m
//  M3
//
//  Created by Enrico Thierbach on 04.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"

@implementation M3

+(void)open: (NSString*)url
{
  id app = [[UIApplication sharedApplication]delegate];
  [app performSelector:@selector(open:) withObject: url];
}

@end
