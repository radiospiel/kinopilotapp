//
//  UIView+M3Stylesheets.m
//  M3
//
//  Created by Enrico Thierbach on 02.11.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
#import "UIView+M3Stylesheets.h"

// A simple stylesheet

@implementation M3Stylesheet

@synthesize styles = styles_;

static NSDictionary* defaultStyles()
{
  NSMutableDictionary* d = [NSMutableDictionary dictionary];
  
  [d setObject: [UIFont boldSystemFontOfSize:17] forKey:@"font-h1"];
  [d setObject: [UIFont systemFontOfSize:14] forKey:@"font-h2"];
  [d setObject: [UIFont systemFontOfSize:13] forKey:@"font-details"];
  [d setObject: [UIFont systemFontOfSize:15] forKey:@"font-p"];
  
  return d;
}

+(M3Stylesheet*)stylesheetWithDictionary: (NSDictionary*)dictionary
{
  M3Stylesheet* stylesheet = [[M3Stylesheet alloc]init];
  [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [stylesheet setObject:obj forKey:key];
  }];
  
  return [stylesheet autorelease];
}

-(id) init
{
  self = [super init];
  self.styles = [NSMutableDictionary dictionary];
  return self;
}

-(void)dealloc
{
  self.styles = nil;
  [super dealloc];
}

-(id)objectForKey: (NSString*)key
{
  return [self.styles objectForKey:key];
}

-(void)setObject: (id) object forKey: (NSString*)key
{
  [self.styles setObject:object forKey:key];
}

-(UIFont*)fontForKey: (NSString*)key
{
  key = _.join(@"font-", key); 
  
  UIFont* font = [self objectForKey:key];
  if(!font)
    font = [self objectForKey:@"font"];
  
  if(!font)
    font = [UIFont systemFontOfSize:13];
  
  M3AssertKindOf(font, UIFont);
  return font;
}

-(void)setFont: (UIFont*) font forKey: (NSString*)key
{
  M3AssertKindOf(font, UIFont);
  
  key = _.join(@"font-", key); 
  [self setObject:font forKey:key];
}

@end


@implementation UIView (M3Stylesheets)

+(M3Stylesheet*) stylesheet
{
  Class klass = [self class];
  M3Stylesheet* stylesheet = [klass memoized:@selector(stylesheet) usingBlock:^id{
    
    M3Stylesheet* stylesheet = nil;
    
    // get the stylesheet from the superclass.
    Class superklass = [klass superclass];
    if([superklass respondsToSelector:@selector(stylesheet)]) {
      stylesheet = [superklass performSelector: @selector(stylesheet)];
    }
    
    return [M3Stylesheet stylesheetWithDictionary: stylesheet.styles];
  }];
  
  return stylesheet;
}

-(M3Stylesheet*) stylesheet
{
  return [[self class] stylesheet];
}

@end

