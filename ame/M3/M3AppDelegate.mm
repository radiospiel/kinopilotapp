//
//  AppDelegate.m
//  iM3Example
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#if TARGET_OS_IPHONE 

#import "M3AppDelegate.h"
#import "UIViewController+M3Extensions.h"

// for network status
#include <netdb.h>
#include <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "iRate.h"

M3AppDelegate* app;

@interface M3AppDelegate

@implementation M3AppDelegate

-(id)init
{
  self = [super init];
  return self;
}

@end

#endif
