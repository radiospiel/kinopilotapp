//
//  Chair.h - the simplistic MapReduce database for iOS
//
//  Created by Enrico Thierbach on 19.08.11.
//  Copyright (c) 2011 Enrico Thierbach. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M3.h"

@class ChairDatabase;

@interface Chair 

/**

returns the _uid for this record. This is the entry with key @"_uid".
If the record does not have a key, this method will calculate a key.

*/
 
+(NSString*)uid: (NSDictionary*) record;


+(NSUInteger)indexForObject: (id)anObject 
                    inArray: (NSMutableArray*) sortedArray;

+(void)insertObject: (id)anObject 
          intoArray: (NSMutableArray*) sortedArray;

+(void)removeObject: (id)anObject 
          fromArray: (NSMutableArray*) sortedArray;

+(NSRange) rangeInArray: (NSMutableArray*) array
                    min: (id)min 
                    max: (id)max 
           excludingEnd: (BOOL) excludingEnd;

+(void) sortArray: (NSMutableArray*) array;
           
@end

@interface Chair(DefaultDatabase)

+ (ChairDatabase*) db;

+ (ChairDatabase*) import: (NSString*) path;

+ (ChairDatabase*) load: (NSString*) path;
+ (ChairDatabase*) save: (NSString*) path;

@end

#import "ChairDatabase.h"
#import "ChairDictionary.h"
#import "ChairTable.h"
#import "ChairView.h"
