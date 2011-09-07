@class M3ETestResults;

@interface M3ETest: NSObject {
  M3ETestResults* results_;
  NSString* name_;
};

-(void)run;

@end
