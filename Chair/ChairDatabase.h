//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChairView;
@class ChairTable;

@interface ChairDatabase: NSObject {
  NSMutableDictionary *tables_; 
}

-(void)import: (NSString*) path_or_url;
-(void)export: (NSString*) path;

-(void)load: (NSString*) path;
-(void)save: (NSString*) path;

-(ChairTable*)tableForName: (NSString*) name;

+ (ChairDatabase*) database;

@end

@interface NSArray(ChairDatabaseAdditions)

-(NSArray*) joinWith: (ChairView*)view on: (NSString*)key; 
-(NSArray*) innerJoinWith: (ChairView*)view on: (NSString*)key; 

@end
