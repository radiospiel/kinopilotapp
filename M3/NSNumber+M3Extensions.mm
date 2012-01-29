//
//  NSString(M3Extensions).h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"

@implementation NSNumber(M3Extensions)

-(int) to_i
{
  return [self intValue];
}

-(NSDate*)to_date
{
  return [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
}

-(NSDate*)to_day
{
  return self.to_date.to_day;
}

@end
