#import "M3.h"

@implementation M3EventCenter(DefaultCenter)

+(M3EventCenter*) defaultCenter
{
  static M3EventCenter* defaultCenter = 0;

	@synchronized([self class])
	{
    if(!defaultCenter)
      defaultCenter = [[self alloc]init];
    
    return defaultCenter;
  }
}

+(void)connect: (id)sender    event: (SEL)event 
            to: (id)observer  selector: (SEL)selector
{
  [[self defaultCenter] connect: sender event: event to: observer selector: selector];
}

+(void)disconnect: (id)sender    event: (SEL)event 
               to: (id)observer  selector: (SEL)selector;
{
  [[self defaultCenter] disconnect: sender event: event to: observer selector: selector];
}

+(void)disconnectAll: (id)object;
{
  [[self defaultCenter] disconnectAll: object];
}

@end
