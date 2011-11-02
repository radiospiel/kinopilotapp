//
//  UIView+M3Stylesheets.h
//  M3
//
//  Created by Enrico Thierbach on 02.11.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// A simple stylesheet object

@interface M3Stylesheet: NSObject

@property (nonatomic,retain) NSMutableDictionary* styles;

-(id)objectForKey: (NSString*)key;
-(void)setObject: (id) object forKey: (NSString*)key;

-(void) setFont: (UIFont*) font 
         forKey: (NSString*)key;

-(UIFont*) fontForKey: (NSString*)key;

+(M3Stylesheet*)stylesheetWithDictionary: (NSDictionary*)dictionary;

@end


/*
 * Custom stylesheets on UIViewControllers.
 */
@interface UIView(M3Stylesheets)

+(M3Stylesheet*) stylesheet;

@property (nonatomic,assign,readonly) M3Stylesheet* stylesheet;

@end

