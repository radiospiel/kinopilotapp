//
//  Chair.m
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import "ChairView.h"

@class  ChairDictionary;

@interface ChairMaterializedView: ChairView {
  ChairDictionary* dictionary_;
}

@property (nonatomic,retain) ChairDictionary* dictionary;

@end

/**
 
 A ChairTable is a view which has own storage: it keeps all entries
 
*/

@interface ChairTable: ChairMaterializedView<NSCoding> {
  NSString* name_;
}

@property (nonatomic,retain) NSString* name;

-(id) initWithName: (NSString*)name;

-(id) upsert: (NSDictionary*)record;
-(id) upsert: (NSDictionary*)record withKey: (NSString*)key;

+(ChairTable*) tableWithFile: (NSString*)file;

-(void) saveToFile: (NSString*) path;

@end
