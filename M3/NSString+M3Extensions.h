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

@property (readonly,nonatomic,retain) NSString* cdata;
-(NSString*)cdata;

@property (readonly,nonatomic,retain) NSDate* to_date;
-(NSDate*)to_date;

@property (readonly,nonatomic,retain) NSString* htmlEscape;
-(NSString*)htmlEscape;

@property (readonly,nonatomic,retain) NSString* htmlUnescape;
-(NSString*)htmlUnescape;

@property (readonly,nonatomic,retain) NSString* urlEscape;
-(NSString*)urlEscape;

@property (readonly,nonatomic,retain) NSString* urlUnescape;
-(NSString*)urlUnescape;

@property (readonly,nonatomic,retain) NSURL* to_url;
-(NSURL*)to_url;

@end
