//
//  MoviesFullController.h
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"

@interface MoviesShowControllerDataSource: M3TableViewDataSource
@end

@implementation MoviesShowControllerDataSource

-(id)initWithMovieId: (id)movie_id
{
  self = [super init];
  
  [self addCellOfClass: @"MovieActionsCell"     withKey: movie_id];
  [self addCellOfClass: @"MovieInCinemasCell"   withKey: movie_id];
  [self addCellOfClass: @"MovieRatingCell"      withKey: movie_id];
  // [self addCellOfClass: @"MovieAffiliateCell"   withKey: movie_id];
  [self addCellOfClass: @"MovieTrailerCell"     withKey: movie_id];
  [self addCellOfClass: @"MoviePersonsCell"     withKey: movie_id];
  [self addCellOfClass: @"MovieDescriptionCell" withKey: movie_id];
  
  return self;
}

-(id) cellClassForKey: (NSArray*)key
{ 
  return key.first; 
}

@end

@implementation MoviesShowController

@synthesize movie=movie_;

-(NSString*)title 
{
  return @"Details";
}

-(void)reloadURL
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"];

  [self setRightButtonWithSystemItem: UIBarButtonSystemItemAction
                                 url: _.join(@"/movie/actions?movie_id=", movie_id)];
  
  self.movie = [app.sqliteDB.movies get: movie_id];

  self.dataSource = [[[MoviesShowControllerDataSource alloc]initWithMovieId: movie_id]autorelease];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

@end
