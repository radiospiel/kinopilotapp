@class M3ETestResults;

@interface M3ETest: NSObject {
  M3ETestResults* results_;
  NSString* name_;
};

@property (nonatomic,assign,readonly) NSString* name;

-(void)run;

+(void)runAll;

+(void) do_assert: (BOOL)expr 
         asString: (const char*) exprAsString
           inFile: (const char*) file
           atLine: (int)line;

@end

#define m3assert(expr) [ M3ETest do_assert: expr asString: #expr inFile: __FILE__ atLine: __LINE__]
