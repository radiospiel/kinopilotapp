#include "QSStrings.m"
#include "M3.h"

@implementation M3(Base64)

+(NSData*) decodeBase64WithString: (NSString*)encoded
{
  return [QSStrings decodeBase64WithString: encoded];
}

+(NSString*) encodeBase64WithData: (NSData*)unencoded
{
  return [QSStrings encodeBase64WithData: unencoded];
}

@end
