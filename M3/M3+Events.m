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
  [[M3EventCenter defaultCenter] fire: self event: event ];
}

- (void) emit: (SEL)event withParameter: (id)parameter;
{
  [[M3EventCenter defaultCenter] fire: self event: event withParameter: parameter ];
}

- (id) sender
{
  return [[M3EventCenter defaultCenter] sender ];
}

@end
