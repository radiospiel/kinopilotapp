//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"

@implementation NSString (IM3ExampleExtensions)

-(NSString*) withVersionString: (NSString*)versionString;
{
  if(!versionString) return self;
  return [self stringByAppendingFormat:@" (%@)", versionString];
}

@end
