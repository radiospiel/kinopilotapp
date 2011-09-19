//
//  NSString(M3Extensions).h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

@interface NSObject(Ivars)

-(id)ivar: (SEL)name;
-(void)ivar_set: (SEL)name withValue: (id)value;

-(id)memoized: (SEL)name usingBlock:(id (^)())block;

@end
