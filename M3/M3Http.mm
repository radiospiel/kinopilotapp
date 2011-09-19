//
//  M3Http.m
//  M3
//
//  Created by Enrico Thierbach on 12.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"

@implementation M3Http

// NSURLResponse's encoding is an IANA string. This method uses CF utilities
// to convert it via a CFStringEncoding then a NSStringEncoding.
static NSStringEncoding nsEncodingByIANAName(NSString* iana) 
{
  NSString* encoding_name = iana;
  if (!encoding_name) return NSUTF8StringEncoding;
  
  CFStringEncoding cf_encoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef) encoding_name);
  if (cf_encoding != kCFStringEncodingInvalidId)
    return CFStringConvertEncodingToNSStringEncoding(cf_encoding);
  
  return NSUTF8StringEncoding;
}


+(NSURLRequest*) getRequest: (NSString*) verb 
                        url: (NSString*) url 
                withOptions: (NSDictionary*) options
{
  dlog(2) << verb << " " << url;

  NSURL* ns_url = [NSURL URLWithString: url];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ns_url ];
  request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
  request.timeoutInterval = 60.0;
  request.HTTPMethod = verb;

  return request;
}


+ (NSData*) requestData: (NSString*) verb
                    url: (NSString*) url 
            withOptions: (NSDictionary*) options
{
  Benchmark(_.join(verb, " ", url));

  NSURLRequest* request = [self getRequest:verb
                                       url:url
                               withOptions:options];
  
  NSError* error;
  NSData* data = [ NSURLConnection sendSynchronousRequest: request 
                                        returningResponse: 0
                                                    error: &error ];
  
  if(!data) @throw @"RuntimeError"; //  [ ETRuntimeError raise: error ];

  return data;
}

+ (NSString*) uncachedRequest: (NSString*) verb
                          url: (NSString*) url 
                  withOptions: (NSDictionary*) options 
{
  Benchmark(_.join(verb, " ", url));

  NSURLRequest* request = [self getRequest:verb
                                       url:url
                               withOptions:options];
  
  NSError* error;
  NSURLResponse *response;
  
  NSData* data = [ NSURLConnection sendSynchronousRequest: request 
                                        returningResponse: &response 
                                                    error: &error ];
  
  if(!data) @throw @"RuntimeError"; //  [ ETRuntimeError raise: error ];
  
  NSStringEncoding encoding = nsEncodingByIANAName(response.textEncodingName);
  
  return [[ [NSString alloc] initWithData: data
                                 encoding: encoding ] autorelease];
}

// retunrs a default cache
+(NSCache*)cache
{
  static NSCache* cache_ = 0;
  if(!cache_) cache_ = [[NSCache alloc]init];
  return cache_;
}

+ (NSString*) cachedRequest: (NSString*) verb
                        url: (NSString*) url 
                withOptions: (NSDictionary*) options 
{
  NSArray* key = [NSArray arrayWithObjects: verb, url, options, nil];
  NSString* result = [[self cache]objectForKey:key];
  if(result) return result;
  
  result = [self uncachedRequest:verb url:url withOptions:options];
  [[self cache]setObject:result forKey:key];
  return result;
}

+ (NSString*) request: (NSString*) verb
                  url: (NSString*) url 
          withOptions: (NSDictionary*) options;
{
  return [self cachedRequest:verb url: url withOptions:options];
}

+ (NSString*) get: (NSString*) url withOptions: (NSDictionary*) options {
  return [ self request: @"GET" url: url withOptions: options ];
}

+ (NSString*) get: (NSString*) url {
  return [ self request: @"GET" url: url withOptions: nil ];
}

// --- Async loader ------------------------------------------------------------
//
//// get an URL with options
//+ (id) asyncGet: (NSString*) url withOptions: (NSDictionary*) options
//{
//  [M3Http get: url withOptions: options];
//}
////
//// get an URL
//+ (id) asyncGet: (NSString*) url
//{
//  [M3Http get: url withOptions: options];
//}

@end

ETest(M3Http)

-(void)test_get
{
  NSString* data = [M3Http get: @"http://www.google.com"];
  assert_true([data matches: @"<title>Google<\\/title>"]);
}

-(void)test_caching
{
  NSString* url = @"http://www.google.com";

  double t1 = [ M3StopWatch measure:^() { [M3Http get: url]; } ];
  double t2 = [ M3StopWatch measure:^() { [M3Http get: url]; } ];

  assert_true(t1 > t2);
}


@end
