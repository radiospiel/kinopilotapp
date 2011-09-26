//
//  TheatersListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3TableViewProfileCell.h"
#import "TheatersListController.h"

/*** A cell for the TheatersListController ***************************************************/

@interface TheatersListCell: M3TableViewProfileCell

-(BOOL)features: (SEL)feature;

@end

@implementation TheatersListCell

-(BOOL)features: (SEL)feature;
{
  if(feature == @selector(image))
    return NO;
  
  return [super features: feature];
}

-(NSString*)detailText {
  return @"detailText"; // [self.model objectForKey: @"description"];
}

@end

/*** The TheatersListController ***************************************************/

@implementation TheatersListController

-(void)setUrl:(NSString*)url
{
  [super setUrl: url];
  
  if([self.url matches: @"/theaters/list/movie_id=(.*)"])
    self.keys = [app.chairDB theaterIdsByMovieId: $1.to_number];
  else
    self.keys = app.chairDB.theaters.keys;
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [TheatersListCell class];
}

-(NSDictionary*)modelWithKey:(id)key
{ 
  return [app.chairDB objectForKey: key andType: @"theaters"]; 
}

// get url for indexPath
-(NSString*)urlWithKey: (id)key
{
  return _.join(@"/theaters/show/", key);
}

@end
