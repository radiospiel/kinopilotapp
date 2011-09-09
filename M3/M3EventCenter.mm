#import "M3.h"

#include <map>
#include <set>

typedef std::pair<id,SEL> M3Signal;
typedef std::pair<id,SEL> M3Slot;

class M3SignalsById {
  typedef std::map<id, std::set<M3Signal> > Data;

  std::map<id, std::set<M3Signal> > data;
  
  public:

  size_t size() const { return data.size(); }
    
  void insert(id object, const M3Signal& signal) {
    Data::iterator it = data.find(object);
    if(it == data.end()) {
      it = data.insert(std::make_pair(object, std::set<M3Signal>())).first;
    };
    
    it->second.insert(signal);
  }
  
  void erase(id object) {
    Data::iterator it = data.find(object);
    if(it != data.end()) data.erase(it);
  }
  bool has(id object) const {
    Data::const_iterator it = data.find(object);
    return it != data.end();
  }
  
  const std::set<M3Signal>* signalsForId(id object) const {
    Data::const_iterator it = data.find(object);
    if(it == data.end()) return 0;
    const std::set<M3Signal>& r = it->second;
    return &r;
  }
};

//
// The internal data for an event center.
class M3EventCenterData {
  // Internal structure:
  //
  // (a) A multimap holding all sender/event pairs for a certain receiver
  M3SignalsById signals_by_receiver;

  // (b) A multimap holding all sender/event pairs for a certain sender
  M3SignalsById signals_by_sender;
  
  // (c) A multimap holding all observer/selector pairs for a certain sender/event pair
  typedef std::multimap<M3Signal, M3Slot> SlotsBySignal; 
  SlotsBySignal slots_by_signals;

public:
  void fireEvent(id sender, SEL event)
  {
    M3Signal m3signal = std::make_pair(sender, event);
    
    SlotsBySignal::const_iterator it = slots_by_signals.find(m3signal);
    SlotsBySignal::const_iterator end = slots_by_signals.end();
    
    while(it != end && it->first == m3signal) {
      fireSlot(it->second);
      ++it;
    }
  }
  
private:
  
  static void fireSlot(const M3Slot& slot)
  {
    id observer = slot.first;
    SEL selector = slot.second;

    [ observer performSelector: selector ];
  }

  public:
  
  // Adding a connection means
  void connect(id sender, SEL signal, id receiver, SEL slot)
  {
    M3Signal m3signal = std::make_pair(sender, signal);
    M3Slot m3slot = std::make_pair(receiver, slot);

    signals_by_receiver.insert(receiver, m3signal);
    signals_by_sender.insert(sender, m3signal);

    slots_by_signals.insert(std::make_pair(m3signal, m3slot));
  }
  
  //
  // Removing a single connection 
  //
  //   removing [ sobserver, selector ] from (c)
  void disconnect(id sender, SEL signal, id receiver, SEL slot)
  {  
    M3Signal m3signal = std::make_pair(sender, signal);
    M3Slot m3slot = std::make_pair(receiver, slot);
    
    SlotsBySignal::iterator it = slots_by_signals.find(m3signal);
    if(it != slots_by_signals.end())
      slots_by_signals.erase(it);
  }

  //
  // Removing an object
  void disconnectAll(id object) {
    disconnectAllSignalsToReceiver(signals_by_sender.signalsForId(object));
    signals_by_sender.erase(object);
    
    disconnectAllSignalsToReceiver(signals_by_receiver.signalsForId(object), object);
    signals_by_receiver.erase(object);
  }

  NSString* stats() const {
    return [ NSString stringWithFormat: @"signals_by_receiver: %d,signals_by_sender: %d,slots_by_signals: %d", 
      (int) signals_by_receiver.size(), 
      (int) signals_by_sender.size(), 
      (int) slots_by_signals.size()];
  }
private:
  
  void disconnectAllSignalsToReceiver(const std::set<M3Signal>* signals, id receiver = nil)
  {
    if(!signals) return;
    
    std::set<M3Signal>::const_iterator it = signals->begin();
    std::set<M3Signal>::const_iterator end = signals->end();
    while(it != end) {
      disonnectSignalToReceiver(*it, receiver);
      ++it;
    }
  }

  void disonnectSignalToReceiver(const M3Signal& signal, id receiver) {
    SlotsBySignal::iterator it = slots_by_signals.find(signal);
    while(it != slots_by_signals.end() && it->first == signal) {
      SlotsBySignal::iterator target = it++;
      if(!receiver || target->second.first == receiver) {
        slots_by_signals.erase(target);
      }
    }
  }
  
public:
  
  bool isRegistered(id object) {
    return signals_by_sender.has(object) || signals_by_receiver.has(object);
  }
};

#define pimpl ((M3EventCenterData*)pimpl_)

@interface M3EventCenter(Internals)
-(M3EventCenterData*) eventCenterData;
@end

@implementation M3EventCenter(Internals)
-(M3EventCenterData*) eventCenterData {
  return pimpl;
}
@end


@implementation M3EventCenter

-(id)init {
  if(!(self = [super init])) return nil;
  
  pimpl_ = new M3EventCenterData();
  return self;
}

-(void)dealloc {
  delete pimpl;
}

-(void)clear {
  delete pimpl;
  pimpl_ = new M3EventCenterData();
}

-(void)connect: (id)sender    event: (SEL)event 
            to: (id)observer  selector: (SEL)selector
{
  if(!pimpl->isRegistered(sender)) [self __disconnectAutomatically: sender];
  if(!pimpl->isRegistered(observer)) [self __disconnectAutomatically: observer];

  pimpl->connect(sender, event, observer, selector);
}

-(void)disconnect: (id)sender    event: (SEL)event 
             from: (id)observer  selector: (SEL)selector;
{
  pimpl->disconnect(sender, event, observer, selector);
}

-(void)disconnectAll: (id)object;
{
  pimpl->disconnectAll(object);
}

-(void)fire: (id)sender event: (SEL)event 
{
  pimpl->fireEvent(sender, event);
}

@end

/*
 * === Tests ============================================================
 */

@interface TestClass2: NSObject {
  int count_;
}
@property (nonatomic,assign) int count;
@end

@implementation TestClass2
@synthesize count = count_;

-(void)dealloc {
  // NSLog(@"dealloc");
  [super dealloc];
}

-(void)on_ho {
  // NSLog(@"on_ho");
  
  count_ += 1;
}

@end

#undef pimpl

static M3EventCenter *eventCenter = 0;

#define pimpl [eventCenter eventCenterData]

ETest(M3EventCenter)

-(void)setUp {
  eventCenter = [[M3EventCenter alloc]init];
}

-(void)tearDown {
  [eventCenter release];
}

-(void)_testDisconnectOnDealloc {
  id obj1 = [[ TestClass2 alloc ]init];
  id obj2 = [[ TestClass2 alloc ]init];

  assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());

  [ eventCenter connect: obj1 event: @selector(ho) to: obj2 selector: @selector(on_ho)];
  assert_equal("signals_by_receiver: 1,signals_by_sender: 1,slots_by_signals: 1", pimpl->stats());
  
  [obj1 release];
  [obj2 release];

  assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
}

-(void)_testDisconnectOnDeallocWithAutorelease {
  @autoreleasepool {
    id obj1 = [[[ TestClass2 alloc ]init]autorelease];
    id obj2 = [[[ TestClass2 alloc ]init]autorelease];
    
    assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
    
    [ eventCenter connect: obj1 event: @selector(ho) to: obj2 selector: @selector(on_ho)];
    assert_equal("signals_by_receiver: 1,signals_by_sender: 1,slots_by_signals: 1", pimpl->stats());
  }
  
  assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
}

-(void)_testDisconnectMultipleOnDealloc {
  @autoreleasepool {
    id obj1 = [[[ TestClass2 alloc ]init]autorelease];
    id obj2 = [[[ TestClass2 alloc ]init]autorelease];
    id obj3 = [[[ TestClass2 alloc ]init]autorelease];
    
    assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
    
    [ eventCenter connect: obj1 event: @selector(ho) to: obj2 selector: @selector(on_ho)];
    [ eventCenter connect: obj1 event: @selector(ho) to: obj3 selector: @selector(on_ho)];
    
    assert_equal("signals_by_receiver: 2,signals_by_sender: 1,slots_by_signals: 2", pimpl->stats());
  }
  
  assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
}

-(void)testSimpleFireEvent {
  TestClass2* obj1 = [[TestClass2 alloc ]init];
  TestClass2* obj2 = [[TestClass2 alloc ]init];
  
  [ eventCenter connect: obj1 event: @selector(ho) to: obj2 selector: @selector(on_ho)];
  
  [ eventCenter fire: obj1 event: @selector(ho) ];
  [obj2 release];

  [ eventCenter fire: obj1 event: @selector(ho) ];
  assert_equal("signals_by_receiver: 0,signals_by_sender: 1,slots_by_signals: 0", pimpl->stats());
  
  [obj1 release];
}

-(void)testFireEvent {
  @autoreleasepool {
    TestClass2* obj1 = [[[ TestClass2 alloc ]init]autorelease];
    TestClass2* obj2 = [[TestClass2 alloc ]init];
    
    assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
    
    [ eventCenter connect: obj1 event: @selector(ho) to: obj2 selector: @selector(on_ho)];
    
    assert_equal("signals_by_receiver: 1,signals_by_sender: 1,slots_by_signals: 1", pimpl->stats());

    [ eventCenter fire: obj1 event: @selector(ho) ];
    assert_equal(1, obj2.count);

    [ eventCenter fire: obj1 event: @selector(ho) ];
    assert_equal(2, obj2.count);

    // Connecting a second time results in obj2.on_ho being called twice per event
    [ eventCenter connect: obj1 event: @selector(ho) to: obj2 selector: @selector(on_ho)];

    [ eventCenter fire: obj1 event: @selector(ho) ];
    assert_equal(4, obj2.count);
    
    // Build a third object, connect it, fire + check
    TestClass2* obj3 = [[TestClass2 alloc ]init];
    [ eventCenter connect: obj1 event: @selector(ho) to: obj3 selector: @selector(on_ho)];

    [ eventCenter fire: obj1 event: @selector(ho) ];
    assert_equal(6, obj2.count);
    assert_equal(1, obj3.count);

    [ eventCenter fire: obj1 event: @selector(ho) ];
    assert_equal(8, obj2.count);
    assert_equal(2, obj3.count);

    assert_equal("signals_by_receiver: 2,signals_by_sender: 1,slots_by_signals: 3", pimpl->stats());

    [obj2 release];

    assert_equal("signals_by_receiver: 1,signals_by_sender: 1,slots_by_signals: 1", pimpl->stats());

    [ eventCenter fire: obj1 event: @selector(ho) ];
    assert_equal(3, obj3.count);

    [obj3 release];
    [ eventCenter fire: obj1 event: @selector(ho) ];
  }
  
  assert_equal("signals_by_receiver: 0,signals_by_sender: 0,slots_by_signals: 0", pimpl->stats());
}

@end
