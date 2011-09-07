@interface M3StopWatch: NSObject {
  uint64_t started_;
}


-(void)startWatch;
-(uint64_t)nanoSeconds;
-(uint64_t)milliSeconds;
-(double)seconds;

@end
