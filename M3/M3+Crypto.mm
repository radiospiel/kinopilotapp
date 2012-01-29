#import "M3.h"

#import <CommonCrypto/CommonDigest.h>

@implementation M3 (MD5)

+ (NSString*) md5: (NSString*) input 
{
  const char* str = [input UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, (unsigned int) strlen(str), result);
  
  NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
  for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
    [ret appendFormat:@"%02x",result[i]];
  }
  return ret;
}

@end
