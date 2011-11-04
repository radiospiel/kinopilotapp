//
//  NSAttributedString+WithSimpleMarkup.h
//  M3
//
//  Created by Enrico Thierbach on 26.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@class M3Stylesheet;

@interface NSAttributedString (WithSimpleMarkup)

+ (NSAttributedString*)attributedStringWithMarkup: (NSString *)html
                                    forStylesheet: (M3Stylesheet*)stylesheet;

@end
