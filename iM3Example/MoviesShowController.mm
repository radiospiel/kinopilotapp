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

-(id) cellClassForKey: (NSArray*)key
{ 
  return key; 
}

@end

@implementation MoviesShowController

-(NSString*)title 
{
  return @"Details";
}

-(void)loadFromUrl:(NSString *)url
{
  self.dataSource = [[[MoviesShowControllerDataSource alloc]init]autorelease];
}

-(NSDictionary*)movie
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"];
  return [app.sqliteDB.movies get: movie_id];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

@end
