//
//  NSNumber(M3Extensions).h
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

@interface NSNumber(M3Extensions)

@property (readonly,nonatomic) int to_i;
@property (readonly,nonatomic) NSDate* to_date;
@property (readonly,nonatomic) NSDate* to_day;
@property (readonly,nonatomic) NSNumber* to_number;

@end
