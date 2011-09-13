//
//  AppDelegate+Nib.m
//  M3
//
//  Created by Enrico Thierbach on 13.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#include "Underscore.hh"

@implementation AppDelegate(Nib)

-(UIViewController*)loadWithNibName: (NSString*)nibName andKlass:(Class)klass
{
  return [[ klass alloc]initWithNibName:nibName bundle:nil];
}

-(id) loadFromNib: (NSString*) name ofClass: (Class)expectedklass
{
  Class klass = NSClassFromString(name);
  UIViewController* r;
  if ([self isIPhone])
    r = [ self loadWithNibName: _.join(name, @"_iPhone") andKlass: klass ];
  else
    r = [ self loadWithNibName: _.join(name, @"_iPad") andKlass: klass ];
  
  if(!r)
    r = [ self loadWithNibName: name andKlass: klass ];
  
  if([r isKindOfClass:expectedklass])
    return [r autorelease];
  
  [r release];
  @throw _.join("Cannot load ", name, " of class ", [klass class]);
}

-(UIView*) loadViewFromNib: (NSString*) name
{
  return [self loadFromNib:name ofClass:[UIView class]];
}

-(UIViewController*)loadControllerFromNib: (NSString*) name
{
  return [self loadFromNib:name ofClass:[UIViewController class]];
}


@end
