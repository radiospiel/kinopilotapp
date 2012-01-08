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

@property (nonatomic,retain) UIView* viewOnTop;
@property (nonatomic,retain) UIView* viewBelowTop;
@property (nonatomic,assign) NSUInteger currentIndex;

@end

@implementation M3Rotator

@synthesize viewOnTop, viewBelowTop, delegate, currentIndex;

-(id)initWithFrame: (CGRect)frame
{
  self = [super initWithFrame: frame];
  
  self.currentIndex = -1;
  
  UITapGestureRecognizer* recognizer = 
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
  [self addGestureRecognizer: [recognizer autorelease]];

  return self;
}

+(M3Rotator*)rotatorWithFrame: (CGRect)frame
{
  M3Rotator* rotator = [[M3Rotator alloc] initWithFrame:frame];
  return [rotator autorelease];
}

-(void)dealloc
{
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
  
  [self.viewBelowTop removeFromSuperview];
  self.viewBelowTop = viewOnTop;
  [self addSubview: view];
  
  self.viewOnTop = view;
  
  self.viewOnTop.alpha = 0.0;
  self.viewBelowTop.alpha = 1.0;
  // 
  // 
  [UIView animateWithDuration:0.3
                   animations:^{ self.viewOnTop.alpha = 1.0; self.viewBelowTop.alpha = 0.0; }
                   completion:^(BOOL finished) { }
   ];
}

-(void)advance: (int)step
{
  NSUInteger numberOfViewsInRotator = [delegate numberOfViewsInRotator: self];
  if(numberOfViewsInRotator <= 1) return;
  
  currentIndex = (numberOfViewsInRotator + currentIndex + step) % numberOfViewsInRotator;
  UIView* view = [delegate rotator: self viewForItemAtIndex: currentIndex];
  [self stackOnTop: view];
}

-(void)showNext
{
  [self advance: 1];
}

-(void)showPrev
{
  [self advance: -1];
}

-(void)start
{
  NSUInteger numberOfViewsInRotator = [delegate numberOfViewsInRotator: self];

  // set current index
  currentIndex = numberOfViewsInRotator > 1 ? rand() % numberOfViewsInRotator : 0;
  
  [self showNext];
  
  [M3Timer timerWithTimeInterval: ROTATION_INTERVAL
                          target: self
                        selector: @selector(showNext)
                        userInfo: nil
                         repeats: YES];
}

-(void)handleTap:(UITapGestureRecognizer *)sender 
{
  id del = delegate;
  
  if(![del respondsToSelector:@selector(rotator:activatedIndex:)])
    return;

  [delegate rotator:self activatedIndex: currentIndex];
}


@end
