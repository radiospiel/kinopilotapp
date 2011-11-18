@interface M3(Base64)

+(NSData*) decodeBase64WithString: (NSString*)encoded;
+(NSString*) encodeBase64WithData: (NSData*)unencoded;

@end

