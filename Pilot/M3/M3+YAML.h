//
//  M3+YAML.h
//  Pilot
//
//  Created by Enrico Thierbach on 15.05.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "M3.h"

@interface M3 (YAML)

+ (id) parseYAML: (NSString*) data;
+ (id) parseYAMLData:(NSData *)data;

+ (NSString*) toYAML: (id) obj;

+ (id) readYAML: (NSString*) path;
+ (void) writeYAMLFile: (NSString*) path object: (id) object;

@end
