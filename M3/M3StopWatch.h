@interface M3StopWatch: NSObject {
  uint64_t started_;
}


-(void)startWatch;
-(uint64_t)nanoSeconds;
-(int)milliSeconds;
-(double)seconds;

@end
