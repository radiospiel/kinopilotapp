//
//  AppDelegate+Nib.m
//  M3
//
//  Created by Enrico Thierbach on 13.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#include "Underscore.hh"


static id loadInstance(Class klass, NSString* nibName)
{
  if([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"])
    return [[ klass alloc]initWithNibName:nibName bundle:nil];

  return nil;
}

@implementation AppDelegate(Nib)

-(id)loadInstanceOfClass: (Class)klass fromNib: (NSString*) nibName
{
  UIViewController* r;
  if ([self isIPhone])
    r = loadInstance(klass, _.join(nibName, @"_iPhone"));
  else
    r = loadInstance(klass, _.join(nibName, @"_iPad"));
  
  if(!r)
    r = loadInstance(klass, nibName);

  if(!r)
    _.raise("Cannot load ", klass, " object from NIB ", nibName);

  return [r autorelease];
}


@end
