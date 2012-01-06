//
//  NSString(M3Extensions).h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

@interface NSString(M3Extensions)

-(BOOL)startsWith: (NSString*) other;
-(BOOL)containsString: (NSString*)aString;
-(NSUInteger)indexOfString: (NSString*)aString;

-(NSString*)camelizeWord;

@property (readonly,nonatomic,retain) NSNumber* to_number;
@property (readonly,nonatomic,retain) NSString* dquote;
@property (readonly,nonatomic,retain) NSString* squote;
@property (readonly,nonatomic,retain) NSString* quote;
@property (readonly,nonatomic,retain) NSString* cdata;
@property (readonly,nonatomic,retain) NSDate* to_date;
@property (readonly,nonatomic,retain) NSString* htmlEscape;
@property (readonly,nonatomic,retain) NSString* htmlUnescape;
@property (readonly,nonatomic,retain) NSString* urlEscape;
@property (readonly,nonatomic,retain) NSString* urlUnescape;
@property (readonly,nonatomic,assign) SEL to_sym;
@property (readonly,nonatomic,assign) Class to_class;

@end
