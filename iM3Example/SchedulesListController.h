//
//  SchedulesListController.h
//
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3ListViewController.h"

/*

 ## Schedules List
 
 - **`/schedules/list?theater_id=<theater_id>&movie_id=<movie_id>`** show a list 
   of play times for a given theater and movie combination. The header 
   cell contains a description a la "&lt;movie title&gt; in &lt;theater name&gt;".
   Below is a list of schedules, grouped by day. Clicking on a schedule opens a
   schedule (modal) view, which allows to share the schedule, 
   under *`/schedules/show?schedule_id=<schedule_id>`*

*/
@interface SchedulesListController: M3ListViewController

@property (readonly) NSString* theater_id;
@property (readonly) NSDictionary* theater;

@property (readonly) NSString* movie_id;
@property (readonly) NSDictionary* movie;

@end
