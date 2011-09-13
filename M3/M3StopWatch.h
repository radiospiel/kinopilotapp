typedef void (^M3StopWatchCallback)(void);

@interface M3StopWatch: NSObject {
  uint64_t started_;
}

-(void)startWatch;
-(uint64_t)nanoSeconds;
-(int)milliSeconds;
-(double)seconds;

+(M3StopWatch*) stopWatch;

+(double) measure: (M3StopWatchCallback) callback;
+(double) measure: (M3StopWatchCallback) callback withMessage: (NSString*)msg;

@end
