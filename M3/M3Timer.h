//
//  M3Timer.h
//  M3
//
//  Created by Enrico Thierbach on 06.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3Timer: NSObject

+ (M3Timer*) timerWithTimeInterval:(NSTimeInterval)seconds 
                           target:(id)target 
                         selector:(SEL)aSelector 
                         userInfo:(id)userInfo 
                          repeats:(BOOL)repeats;

@end
