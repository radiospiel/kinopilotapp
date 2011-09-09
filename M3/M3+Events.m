#import "M3.h"

@implementation NSObject(M3Events)

-(void) on: (SEL)event
    notify: (id) reveicer
      with: (SEL)selector;
{
  [[M3EventCenter defaultCenter]connect:self event:event to:reveicer selector:selector];
}

- (void) emit: (SEL)event;
{
  [[M3EventCenter defaultCenter] emit:event ];
}

- (id) sender
{
  return [[M3EventCenter defaultCenter] sender ];
}

@end
