@interface M3EventCenter: NSObject {
  void* pimpl_;
}

-(void)connect: (id)sender    event: (SEL)event 
            to: (id)observer  selector: (SEL)selector;

-(void)disconnect: (id)sender    event: (SEL)event 
             from: (id)observer  selector: (SEL)selector;

-(void)disconnectAll: (id)object;

-(void)fire: (id)sender event: (SEL)event;

-(void)fire: (id)sender event: (SEL)event withParameter: (id)parameter;

@end

@interface M3EventCenter(DefaultCenter)

+(M3EventCenter*)defaultCenter;

+(void)connect: (id)sender    event: (SEL)event 
            to: (id)observer  selector: (SEL)selector;

+(void)disconnect: (id)sender    event: (SEL)event 
             from: (id)observer  selector: (SEL)selector;

+(void)disconnectAll: (id)object;

+(void)fire: (id)sender event: (SEL)event;
+(void)fire: (id)sender event: (SEL)event withParameter: (id)parameter;

@end

// // registers an object with the event center: if the object gets dealloc'ed, 
// // it will automatically be disconnected. An object will not be registered
// // twice. 
// -(void)register_object:(id)sender;
          


@interface M3EventCenter(Disconnect)

-(void)__disconnectAutomatically:(id)object;

@end
