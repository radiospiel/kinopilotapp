typedef void (^EventCallback)(NSNotification*);

@interface NSObject(M3Events)

-(void) on: (NSString*) event
    notify: (id) reveicer
      with: (SEL)selector;

-(void) on: (NSString*) event
      call: (EventCallback) callback;

- (void) emit: (NSString*) event;
- (void) emit: (NSString*) event withParameter: (id) parameter;

@end
