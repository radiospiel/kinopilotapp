//
//  NSString(M3Extensions).h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

@interface NSString(M3Extensions)

-(BOOL)startsWith: (NSString*) other;
-(NSString*)camelizeWord;
-(NSNumber*)to_number;

@end
