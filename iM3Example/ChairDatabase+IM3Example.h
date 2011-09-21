@interface ChairDatabase(IM3Example)

@property (nonatomic,retain,readonly) ChairTable* movies;
@property (nonatomic,retain,readonly) ChairTable* theaters;
@property (nonatomic,retain,readonly) ChairTable* schedules;

@end
