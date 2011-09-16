typedef void (^EventCallback)(NSNotification*);

@interface NSObject(M3Events)

-(void) on: (SEL)event
    notify: (id) reveicer
      with: (SEL)selector;

- (void) emit: (SEL)event;
- (void) emit: (SEL)event withParameter: (id)parameter;

@end
