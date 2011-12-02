@interface ChairDatabase(IM3Example)

@property (nonatomic,retain,readonly) ChairTable* news;

@property (nonatomic,retain,readonly) ChairTable* stats;
@property (nonatomic,retain,readonly) ChairTable* movies;
@property (nonatomic,retain,readonly) ChairTable* theaters;
@property (nonatomic,retain,readonly) ChairTable* schedules;
@property (nonatomic,retain,readonly) ChairTable* images;

@property (nonatomic,retain,readonly) ChairView* schedules_by_theater_id;

-(NSArray*) theaterIdsByMovieId: (NSString*)movieID;
-(NSArray*) movieIdsByTheaterId: (NSString*)theaterID;

-(NSArray*) schedulesByMovieId: (NSString*)movieID;
-(NSArray*) schedulesByTheaterId: (NSString*)theaterID;
-(NSArray*) schedulesByMovieId: (NSString*)movieID andTheaterId: (NSString*)theaterID;

-(void)updateIfNeeded;
-(void)update;

-(UIImage*)thumbnailForMovie: (NSString*)movie_id;
-(NSString*)trailerURLForMovie: (NSString*)movie_id;

@end

#error 0
