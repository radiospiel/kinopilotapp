//
//  MoviesFullController.m
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"
#import "AppDelegate.h"
#import "M3.h"

#import "TTTAttributedLabel/TTTAttributedLabel.h"

@interface MoviesShowControllerDataSource: M3TableViewDataSource
@end

@implementation MoviesShowControllerDataSource

-(id)init
{
  self = [super init];
  [self addSection: _.array(@"MovieShortInfoCell", @"MovieTrailerCell", 
                            @"MovieInCinemasCell", @"MovieRatingCell", 
                            @"MovieDescriptionCell")];
  
  return self;
}

-(id) cellClassForKey: (id)key
{ 
  return key; 
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
  self.movie = [app.sqliteDB.movies get: movie_id];

  self.dataSource = [[[MoviesShowControllerDataSource alloc]init]autorelease];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

@end
