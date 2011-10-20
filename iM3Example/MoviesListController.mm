//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesListController.h"

/*** A cell for the MoviesListCell *******************************************/

@interface MoviesListCell: M3TableViewProfileCell
@end

@implementation MoviesListCell

-(void)setKey: (id)movie_id
{
  [super setKey:movie_id];
  
  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  movie = [app.chairDB adjustMovies: movie];
  
  [self setStarred:YES];
  [self setImageURL: [movie objectForKey: @"image"]];
  [self setText: [movie objectForKey: @"title"]];

  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys: theater_ids] pluck: @"name"];
  [self setDetailText: [theaters.uniq.sort componentsJoinedByString: @", "]];

  self.url = [NSString stringWithFormat: @"/movies/full/%@", self.key];
}

@end

/*** A cell for the MoviesListCell *******************************************/

/*
 * This cell is either filtered by movie_id and theater_id, or only by the
 * movie_id.
 */
@interface MoviesListFilteredByTheaterCell: M3TableViewProfileCell

@end

@implementation MoviesListFilteredByTheaterCell


-(void)setKey: (NSDictionary*)key
{
  [super setKey:key];
  
  //
  // Example key
  //
  // 
  // {
  //   movie_id: "howiendedthissummer|movies", 
  //   schedules: [
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 16:15:00 +0000>, version: "omu"}, 
  //     {_type: "schedules", ..., time: <__NSDate: 2011-09-25 14:00:00 +0000>, version: "omu"}, 
  //     ...
  //   ]
  // }
  
  NSDictionary* movie = [key joinWith: app.chairDB.movies on: @"movie_id"];
  movie = [app.chairDB adjustMovies: movie];
  
  [self setImageURL: [movie objectForKey: @"image"]];
  [self setText: [movie objectForKey: @"title"]];
  
  NSArray* schedules = [movie objectForKey:@"schedules"];
  schedules = [schedules sortByKey:@"time"];
  
  schedules = [schedules mapUsingBlock:^id(NSDictionary* schedule) {
    NSString* time = [schedule objectForKey:@"time"];
    NSString* timeAsString = [time.to_date stringWithFormat:@"HH:mm"];
    
    return [timeAsString withVersionString: [schedule objectForKey:@"version"]];
  }];
  
  [self setDetailText: [schedules componentsJoinedByString:@", "]];

  self.url = [NSString stringWithFormat: @"/movies/full/%@", [self.key objectForKey: @"movie_id"]];
}

@end

/******************************************************************************/

@implementation MoviesListController

-(id)init
{
  self = [super init];

  [self addSegment: @"new" withFilter: @"new" andTitle: @"Neu im Kino"];
  [self addSegment: @"all" withFilter: @"all" andTitle: @"Alle Filme"];
  [self addSegment: @"art" withFilter: @"art" andTitle: @"Klassiker"];
  // [self addSegment: @"fav" withFilter: @"fav" andTitle: @"Vorgemerkt"];

  [self activateSegment: 0];
  return self;
}

-(void)setFilter:(NSString*)filter
{
  if([self.url matches: @"/movies/list/theater_id=(.*)"])
    return;

  self.url = _.join(@"/movies/list/filter=", filter);
}

-(void)loadFromUrl:(NSString *)url
{
  if(!url)
    self.dataSource = nil;
  else if([self.url matches: @"/movies/list/theater_id=(.*)"])
    self.dataSource = [M3DataSource moviesListFilteredByTheater:$1]; 
  else if([self.url matches: @"/movies/list/filter=(.*)"])
    self.dataSource = [M3DataSource moviesListWithFilter: $1];
  else
    self.dataSource = [M3DataSource moviesListWithFilter: @"new"];
}

@end

