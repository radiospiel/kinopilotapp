//
//  NSString+M3Extensions.mm
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//
#import "M3.h"

@implementation NSString(M3Extensions)

-(BOOL)startsWith: (NSString*) other
{
  if(!other) return NO;
  if([self length] < [other length]) return NO;

  NSString* me = [self substringToIndex: other.length];
  return [me isEqualToString: other];
}

@end
