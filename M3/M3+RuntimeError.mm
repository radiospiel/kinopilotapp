#import "M3.h"

#include <execinfo.h>

@implementation RuntimeError

@synthesize backtrace=backtrace_, message=message_;

-(id)initWithMessage:(NSString*)theMessage
{
  self = [super initWithName:NSStringFromClass([self class]) reason:theMessage userInfo:nil];
  if(!self) return nil;

  // collect backtrace information
  backtrace_ = [[M3 callersWithLimit: 15]retain];
  message_ = [theMessage retain];
  
  return self;
}

+(RuntimeError*)errorWithMessage: (NSString*)theMessage;
{
  return [[[RuntimeError alloc]initWithMessage: theMessage]autorelease];
}


-(void)dealloc
{
  [message_ release];
  [backtrace_ release];
  
  [super dealloc];
}
     
@end
