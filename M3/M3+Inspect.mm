#include "M3.h"
#include <vis.h>

/* === NSObject ==================================================== */

@implementation NSObject(Inspect)

-(NSString*)inspect
{ 
  return [NSString stringWithFormat: @"<%@: %@>", [self class], [self description]]; 
}

@end

/* === NSNumber ==================================================== */

@implementation NSNumber(Inspect)

-(NSString*)inspect
{ 
  return [self description]; 
}

@end

/* === NSString ==================================================== */

@implementation NSString(Inspect)

-(NSString*)inspect
{ 
  const char *UTF8Input = [self UTF8String];
  char *UTF8Output = (char*) [[NSMutableData dataWithLength:strlen(UTF8Input) * 4 + 3 /* Worst case */] mutableBytes];
  char ch, *och = UTF8Output;
  *och++ = '"';
  
  while ((ch = *UTF8Input++)) {
    if (ch == '\'' || ch == '\'' || ch == '\\' || ch == '"')
    {
      *och++ = '\\';
      *och++ = ch;
    }
    else if (isascii(ch))
      och = vis(och, ch, VIS_NL | VIS_TAB | VIS_CSTYLE, *UTF8Input);
    else
      och += sprintf(och, "\\%03hho", ch);
  }

  *och++ = '"';

  return [NSString stringWithUTF8String:UTF8Output];
}

@end

/* === NSArray ===================================================== */

@implementation NSArray(Inspect)

-(NSString*)inspect
{ 
  NSMutableArray* parts = [NSMutableArray arrayWithCapacity: self.count];
  
  for(id part in self) {
    [parts addObject: [part inspect]];
  }
  
  return [NSString stringWithFormat: @"[%@]", [parts componentsJoinedByString: @", "]];
}

@end

/* === NSDictionary ================================================ */

static NSInteger key_sort(id key1, id key2, void* _)
{
  return [[key1 description] compare:[key2 description]];
}
       
@implementation NSDictionary(Inspect)

-(NSString*)inspect
{ 
  NSArray* keys = [[self allKeys] sortedArrayUsingFunction: key_sort context:0];
  
  NSMutableArray* parts = [NSMutableArray arrayWithCapacity: self.count];
  
  for(id key in keys) {
    NSString* part = [NSString stringWithFormat: @"%@: %@", key, [[self objectForKey: key] inspect]];
    [parts addObject: part];
  }
  
  return [NSString stringWithFormat: @"{%@}", [parts componentsJoinedByString: @", "]];
}

@end

/* === NSThread ============================================ */

@implementation NSThread(Inspect)

-(NSString*)inspect
{
  return [NSString stringWithFormat: @"<NSThread 0x%08x>", self ];
}
@end

/* === inspect ETests ============================================== */

ETest(Inspect)

-(void)test_inspect
{
  assert_equal([NSNumber numberWithInteger: 1].inspect, @"1");
  assert_equal([NSNumber numberWithInteger: -1].inspect, @"-1");

  assert_equal(@"abc".inspect, @"\"abc\"");

  assert_equal(_.array(1, 2).inspect, @"[1, 2]");

  assert_equal(_.hash("a", 1, "b", 2).inspect, @"{a: 1, b: 2}");
  assert_equal(_.hash("a", "a", "b", 2).inspect, @"{a: \"a\", b: 2}");
}
@end
