#import <Foundation/Foundation.h>

@interface NSArray (Globbing)

+ (NSArray*) arrayWithFilesMatchingPattern: (NSString*) pattern
                               inDirectory: (NSString*) directory;

@end

@interface NSArray (M3Extensions)

@property (readonly,nonatomic,retain) id first;
@property (readonly,nonatomic,retain) id last;

-(id) first;
-(id) second;
-(id) last;

@property (readonly,nonatomic,retain) NSArray* uniq;

-(NSArray*) uniq;


/** 
  This method assumes the array is an array of dictionaries. It then fetches 
  all objects at key \a attributeName of all entries, and returns it as an array.

  Not-existing entries will be skipped.
*/

-(NSArray*) pluck: (NSString*)attributeName;

-(NSMutableArray*) mapUsingSelector: (SEL)selector;
-(NSMutableArray*) mapUsingBlock: (id (^)(id obj))block;

-(NSMutableDictionary*)groupUsingKey: (id)key;
-(NSMutableDictionary*)groupUsingSelector: (SEL)selector;
-(NSMutableDictionary*)groupUsingBlock: (id (^)(id obj))block;

#pragma mark NSArray Sorting

@property (readonly,nonatomic,retain) NSArray* sort;

-(NSArray*) sort;

-(NSArray*) sortBySelector: (SEL)selector;
-(NSArray*) sortByBlock: (id (^)(id obj))block;
-(NSArray*) sortByKey: (id) key;

@end

@interface NSDictionary (M3Extensions)

@property (readonly,nonatomic,retain) NSArray* to_array;

-(NSArray*)to_array;

@end
