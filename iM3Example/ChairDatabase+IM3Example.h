@interface ChairDatabase(IM3Example)

@property (nonatomic,retain,readonly) ChairTable* movies;
@property (nonatomic,retain,readonly) ChairTable* theaters;
@property (nonatomic,retain,readonly) ChairTable* schedules;

-(NSDictionary*)modelWithURL: (NSString*)url;
-(NSDictionary*)objectForKey: (id)key andType: (NSString*) type;

-(NSArray*) theaterIdsByMovieId: (NSString*)movieID;
-(NSArray*) movieIdsByTheaterId: (NSString*)theaterID;

-(NSArray*) schedulesByMovieId: (NSString*)movieID;
-(NSArray*) schedulesByTheaterId: (NSString*)theaterID;
-(NSArray*) schedulesByMovieId: (NSString*)movieID andTheaterId: (NSString*)theaterID;

-(void) adjustMovies:(NSMutableDictionary*)movie;
-(void) adjustTheaters:(NSMutableDictionary*)theater;

@end
