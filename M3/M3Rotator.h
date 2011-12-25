//
//  M3Rotator.h
//  M3
//
//  Created by Enrico Thierbach on 24.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

// --- The M3Rotator ----------------------------------------------------------

@class M3Rotator;
@protocol M3RotatorDelegate

- (NSUInteger)numberOfViewsInRotator: (M3Rotator*)rotator;
- (UIView *)rotator:(M3Rotator*)rotator viewForItemAtIndex:(NSUInteger)index;

@optional

- (void)rotator:(M3Rotator*)rotator activatedIndex:(NSUInteger)index;

@end

@interface M3Rotator: UIView

@property (nonatomic, assign) id<M3RotatorDelegate> delegate;

-(void)start;
-(void)stop;

@end

@interface M3ImageRotator: M3Rotator

@property (nonatomic, retain) NSArray* imageURLs;

@end
