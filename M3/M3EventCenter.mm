#import "M3.h"

#include <map>
#include <set>

typedef std::pair<id,SEL> M3Signal;
typedef std::pair<id,SEL> M3Slot;

class M3SignalsById {
  typedef std::map<id, std::set<M3Signal> > Data;

  std::map<id, std::set<M3Signal> > data;
  
  public:
  
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
      if(!receiver || it->second.first == receiver) {
        SlotsBySignal::iterator target = it++;
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

@implementation M3EventCenter

-(id)init {
  if(!(self = [super init])) return nil;
  
  pimpl_ = new M3EventCenterData();
  return self;
}

-(void)dealloc {
  delete pimpl;
}

-(void)connect: (id)sender    event: (SEL)event 
           to: (id)observer  selector: (SEL)selector
{
  if(!pimpl->isRegistered(sender)) [self __disconnectAutomatically: sender];
  if(!pimpl->isRegistered(observer)) [self __disconnectAutomatically: observer];

  pimpl->connect(sender, event, observer, selector);
}

-(void)disconnect: (id)sender    event: (SEL)event 
              to: (id)observer  selector: (SEL)selector;
{
  pimpl->disconnect(sender, event, observer, selector);
}

-(void)disconnectAll: (id)object;
{
  pimpl->disconnectAll(object);
}

@end
