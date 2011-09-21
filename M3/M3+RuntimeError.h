@interface RuntimeError: NSException {
  NSArray* backtrace_;
  NSString* message_;
};

-(id)initWithMessage: (NSString*)theMessage;

@property(retain,nonatomic,readonly) NSArray* backtrace;
@property(retain,nonatomic,readonly) NSString* message;

@end
