#import "AppDelegate.h"

@implementation ChairDatabase(IM3Example)

-(ChairTable*) movies
{
  return [self tableForName:@"movies"];
}

-(ChairTable*) theaters
{
  return [self tableForName:@"theaters"];
}

-(ChairTable*) schedules
{
  return [self tableForName:@"schedules"];
}


@end
