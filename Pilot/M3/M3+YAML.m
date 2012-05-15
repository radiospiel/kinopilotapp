//
//  M3+YAML.m
//  Pilot
//
//  Created by Enrico Thierbach on 15.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "M3+YAML.h"
#import "../vendor/YAML.framework/YAMLSerialization.h"

@implementation M3 (YAML)

+ (id) parseYAMLData:(NSData *)data;
{
  NSError* error = nil;

  id r = [YAMLSerialization YAMLWithData: data
                                 options: kYAMLReadOptionMutableContainersAndLeaves 
                                   error: &error];
  
  [M3Exception raiseOnError: error];
  return r;
}

+ (id) parseYAML: (NSString*) string;
{
  return [self parseYAMLData: [string dataUsingEncoding:NSUTF8StringEncoding]];
}


+ (id) readYAML: (NSString*) path;
{
  return [self parseYAMLData: [M3 readDataFromPath:path]];
}


+ (NSString*) toYAML: (id) obj;
{
  NSError* error = nil;
  NSData* data = [YAMLSerialization dataFromYAML: obj
                                         options: kYAMLWriteOptionSingleDocument
                                           error: &error];
  
  NSString* r = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return [r autorelease];
}


+ (void) writeYAMLFile: (NSString*) path object: (id) object;
{
  NSError* error = nil;
  NSData* data = [YAMLSerialization dataFromYAML: object
                                         options: kYAMLWriteOptionSingleDocument
                                           error: &error];
  
  path = [M3 expandPath: path];
  [M3 writeData: data toPath: path];
}

@end
