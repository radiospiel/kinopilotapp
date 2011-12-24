//
//  UIView+M3Extensions.h
//  M3
//
//  Created by Enrico Thierbach on 24.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (M3Extensions)

@property (nonatomic,retain) UIColor* borderColor;
@property (nonatomic,assign) float borderWidth;

@end

@interface UIView (M3URLOpener)

-(void)onTapOpen: (NSString*)url;

@end
