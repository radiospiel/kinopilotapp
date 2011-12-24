//
//  M3Rotator.m
//  M3
//
//  Created by Enrico Thierbach on 24.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"

#define ROTATION_INTERVAL 2.5

@interface M3Rotator()

@property (nonatomic,retain) NSTimer* timer;
@property (nonatomic,retain) UIView* viewOnTop;
@property (nonatomic,retain) UIView* viewBelowTop;
@property (nonatomic,assign) NSUInteger currentIndex;

@end

@implementation M3Rotator

@synthesize timer, viewOnTop, viewBelowTop, delegate, currentIndex;

-(id)initWithFrame: (CGRect)frame
{
  self = [super initWithFrame: frame];
  
  self.currentIndex = -1;
  
  return self;
}

-(void)dealloc
{
  [self stop];
  
  [self.timer invalidate]; 
  self.timer = nil;
  self.viewOnTop = nil;
  self.viewBelowTop = nil;
  self.delegate = nil;
  
  [super dealloc];
}

-(void)stackOnTop: (UIView*)view
{
  view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  view.clipsToBounds = YES;
  [view layoutSubviews];
  
  [viewBelowTop removeFromSuperview];
  viewBelowTop = viewOnTop;
  [self addSubview: view];
  
  viewOnTop = view;
  
  viewOnTop.alpha = 0.0;
  viewBelowTop.alpha = 1.0;
  // 
  // 
  [UIView animateWithDuration:0.3
                   animations:^{ viewOnTop.alpha = 1.0; viewBelowTop.alpha = 0.0; }
                   completion:^(BOOL finished) { }
   ];
}

-(void)showNext
{
  currentIndex = (currentIndex + 1) % [delegate numberOfViewsInRotator: self];
  UIView* view = [delegate rotator: self viewForItemAtIndex: currentIndex];
  [self stackOnTop: view];
}

-(void)showPrev
{
  currentIndex = (currentIndex + 1) % [delegate numberOfViewsInRotator: self];
  UIView* view = [delegate rotator: self viewForItemAtIndex: currentIndex];
  [self stackOnTop: view];
}

-(void)stop
{
  [self.timer invalidate]; 
  self.timer = nil;
}

-(void)start
{
  [self showNext];
  
  self.timer = [NSTimer timerWithTimeInterval: ROTATION_INTERVAL
                                       target: self
                                     selector: @selector(showNext)
                                     userInfo: nil
                                      repeats: YES];
  
  [[NSRunLoop mainRunLoop] addTimer:self.timer 
                            forMode:NSDefaultRunLoopMode];
}

@end
