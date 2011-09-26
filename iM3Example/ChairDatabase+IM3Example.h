@interface ChairDatabase(IM3Example)

@property (nonatomic,retain,readonly) ChairTable* movies;
@property (nonatomic,retain,readonly) ChairTable* theaters;
@property (nonatomic,retain,readonly) ChairTable* schedules;

-(NSDictionary*)modelWithURL: (NSString*)url;
-(NSDictionary*)objectForKey: (id)key andType: (NSString*) type;

-(NSArray*) theaterIdsByMovieId: (NSNumber*)movieID;
-(NSArray*) movieIdsByTheaterId: (NSNumber*)theaterID;

@end
