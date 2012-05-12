//
//  M3Inflector.h
//  M3
//
//  Created by Enrico Thierbach on 15.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3(Image)

/**
 * converts the source image URL into the image URL to actually fetch the image
 */
+(NSString*)imageURL: (NSString*) url forSize: (CGSize)size;

@end
