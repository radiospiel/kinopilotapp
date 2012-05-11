//
//  MovieList.h
//  M3
//
//  Created by Enrico Thierbach on 14.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

@interface M3DataSource: NSObject
@end

@class M3TableViewDataSource;

@interface M3DataSource(M3Lists)

+(M3TableViewDataSource*)moviesListWithFilter: (NSString*)filter;
+(M3TableViewDataSource*)moviesCalendar;
+(M3TableViewDataSource*)moviesListFilteredByTheater:(id)theater_id;

+(M3TableViewDataSource*)theatersListWithFilter: (NSString*)filter;
+(M3TableViewDataSource*)theatersListFilteredByMovie:(id)movie_id;

+(M3TableViewDataSource*)schedulesByTheater: (NSString*)theater_id 
                                   andMovie: (NSString*)movie_id
                                      onDay: (NSDate*)day; 
 
+(M3TableViewDataSource*)locationsListWithFilter: (NSString*)filter;

@end
