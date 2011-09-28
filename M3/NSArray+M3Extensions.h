#import <Foundation/Foundation.h>

@interface NSArray (Globbing)

+ (NSArray*) arrayWithFilesMatchingPattern: (NSString*) pattern
                               inDirectory: (NSString*) directory;

@end

@interface NSArray (M3Extensions)

@property (readonly,nonatomic,retain) id first;
@property (readonly,nonatomic,retain) id last;

-(id) first;
-(id) last;

@property (readonly,nonatomic,retain) NSArray* uniq;

-(NSArray*) uniq;

@property (readonly,nonatomic,retain) NSArray* sort;

-(NSArray*) sort;

/** 
  This method assumes the array is an array of dictionaries. It then fetches 
  all objects at key \a attributeName of all entries, and returns it as an array.

  Not-existing entries will be skipped.
*/

-(NSArray*) pluck: (NSString*)attributeName;

-(NSArray*) mapUsingSelector: (SEL)selector;
-(NSArray*) mapUsingBlock: (id (^)(id obj))block;

-(NSMutableDictionary*)groupUsingSelector: (SEL)selector;
-(NSMutableDictionary*)groupUsingBlock: (id (^)(id obj))block;

-(NSArray*) sortBySelector: (SEL)selector;
-(NSArray*) sortByBlock: (id (^)(id obj))block;
-(NSArray*) sortByKey: (id) key;

@end
