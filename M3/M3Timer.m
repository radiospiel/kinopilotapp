//
//  M3Timer.m
//  M3
//
//  Created by Enrico Thierbach on 06.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "M3.h"
#import "M3-Internals.h"

// 
// Why do we have M3Timer? See what Apple says on memory management re/NSTimers:
//
// "Perhaps more importantly, a timer also maintains a strong reference to its target. 
// This means that as long as a timer remains valid (and you otherwise properly abide 
// by memory management rules), its target will not be deallocated. As a corollary, 
// this means that it does not make sense for a timer’s target to try to invalidate
// the timer in its dealloc or finalize method—neither method will be invoked as 
// long as the timer is valid."
//
// Therefore we implement a M3Timer, which acts as a target for a NSTimer. 
// It holds a weak reference to the target. If the timer fires, but 
// the target does no longer exists this a) ignores the timer event, 
// and b) invalidates the timer, which would then release the M3Timer.
//

@interface M3Timer()

@property (nonatomic,assign) NSTimer* timer;
@property (nonatomic,retain) MAZeroingWeakRef* refToTarget;
@property (nonatomic,assign) SEL targetSelector;
@property (nonatomic,assign) BOOL targetSelectorTakesParameter;

@end

@implementation M3Timer

@synthesize timer, refToTarget, targetSelector, targetSelectorTakesParameter;

- (M3Timer*)initWithTimeInterval:(NSTimeInterval)seconds 
                          target:(id)target 
                        selector:(SEL)aSelector 
                        userInfo:(id)userInfo 
                         repeats:(BOOL)repeats
{
  self = [super init];

  self.refToTarget = [MAZeroingWeakRef refWithTarget: target];
  self.targetSelector = aSelector;
  self.targetSelectorTakesParameter = [NSStringFromSelector(aSelector) containsString: @":"];

  self.timer = [NSTimer timerWithTimeInterval:seconds 
                                       target:self 
                                     selector:@selector(timerFireMethod:) 
                                     userInfo:userInfo 
                                      repeats:repeats];
  
  [[NSRunLoop mainRunLoop] addTimer:self.timer 
                            forMode:NSDefaultRunLoopMode];
  
  return self;
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
  id target = [self.refToTarget target];
  if(!target) {
    [self.timer invalidate];
    self.timer = nil;
  }
  else if(self.targetSelectorTakesParameter) {
    [target performSelector: self.targetSelector
                 withObject: theTimer];
  }
  else {
    [target performSelector: self.targetSelector];
  }
}

+ (M3Timer*) timerWithTimeInterval:(NSTimeInterval)seconds 
                            target:(id)target 
                          selector:(SEL)aSelector 
                          userInfo:(id)userInfo 
                           repeats:(BOOL)repeats
{
  M3Timer* timer;
  
  timer = [[M3Timer alloc] initWithTimeInterval: seconds 
                                         target: target 
                                       selector: aSelector 
                                       userInfo: userInfo 
                                        repeats: repeats];
  return [timer autorelease];
}

@end
