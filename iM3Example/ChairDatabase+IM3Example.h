@interface ChairDatabase(IM3Example)

@property (nonatomic,retain,readonly) ChairTable* stats;
@property (nonatomic,retain,readonly) ChairTable* movies;
@property (nonatomic,retain,readonly) ChairTable* theaters;
@property (nonatomic,retain,readonly) ChairTable* schedules;

@property (nonatomic,retain,readonly) ChairView* schedules_by_theater_id;

-(NSDictionary*)modelWithURL: (NSString*)url;
-(NSDictionary*)objectForKey: (id)key andType: (NSString*) type;

-(NSArray*) theaterIdsByMovieId: (NSString*)movieID;
-(NSArray*) movieIdsByTheaterId: (NSString*)theaterID;

-(NSArray*) schedulesByMovieId: (NSString*)movieID;
-(NSArray*) schedulesByTheaterId: (NSString*)theaterID;
-(NSArray*) schedulesByMovieId: (NSString*)movieID andTheaterId: (NSString*)theaterID;

-(NSDictionary*) adjustMovies:(NSDictionary*)movie;
-(NSDictionary*) adjustTheaters:(NSDictionary*)theater;

-(void)updateIfNeeded;

@end
