//
//  NSAttributedString+WithSimpleMarkup.h
//  M3
//
//  Created by Enrico Thierbach on 26.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (WithSimpleMarkup)

+ (NSAttributedString*)attributedStringWithSimpleMarkup:(NSString *)html;

@end

@interface NSString (WithSimpleMarkup)

@property (nonatomic,readonly) NSAttributedString* to_attributed_string;
- (NSAttributedString*)to_attributed_string;

@end
