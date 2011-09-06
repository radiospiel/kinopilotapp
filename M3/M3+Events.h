typedef void (^EventCallback)(id sender, id event);

@interface NSObject(M3Events)

-(void) on: (NSString*) event
    notify: (id) reveicer
      with: (SEL)selector;

-(void) on: (NSString*) event
      call: (EventCallback) callback;

- (void) emit: (NSString*) event;
- (void) emit: (NSString*) event withParameter: (id) parameter;

@end

//
//
//- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)notificationSender
//
//NSNotificationCenter
//-(void) respondTo: (NSString*) event
//on: (id) sender
//with: (SEL)selector;
//
//-(void) respondTo: (NSString*) event
//on: (id) sender
//withCallback: (EventCallback) callback;
//
//// - (void) on: (SEL) event call: (void)(callback^)(id sender, id event);
//// - (void) on: (SEL) event call: (id)listener with: (SEL)selector;
//// - (void) on: (SEL) event call: (id)listener with: (SEL)selector andParameter: (id) parameter;
//// // - (void) on: (SEL) event call: (id)listener with: (SEL)selector andEvent: (M3Event*) event;
//
