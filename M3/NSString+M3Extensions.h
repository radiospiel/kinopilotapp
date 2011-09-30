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

@property (readonly,nonatomic,retain) NSNumber* to_number;

@property (readonly,nonatomic,retain) NSString* dquote;
-(NSString*)dquote;

@property (readonly,nonatomic,retain) NSString* squote;
-(NSString*)squote;

@property (readonly,nonatomic,retain) NSString* quote;
-(NSString*)quote;

@property (readonly,nonatomic,retain) NSDate* to_date;
-(NSDate*)to_date;

@end
