//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3ListViewController.h"

/*

 ## Movie List
 
 - /movies/list?filter=<filter> show a list of movies matching the filter 
   criteria. A click on a movie shows a Theater List showing that movie, 
   under /theaters/list?movie_id=<movie_id>
 
 - /movies/list?theater_id=<theater_id> show a list of movies playing in 
   the specific theater, grouped by day. The header view contains a theater 
   short info cell, which, amongst others, contains a link to a map 
   highlighting the  theater, i.e. /map/show?theater_id=<theater_id>
 
   A click on a movie shows all play times of the movie in the theater, 
   under /schedules/list?theater_id=<theater_id>&movie_id=<movie_id>

*/
@interface MoviesListController: M3ListViewController

@property (readonly) NSString* theater_id;
@property (readonly) NSDictionary* theater;

@end
