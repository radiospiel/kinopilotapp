//
//  SearchController.m
//  M3
//
//  Created by Enrico Thierbach on 02.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "SearchController.h"

#import "AppDelegate.h"
#import "MoviesListController.h"
#import "M3ProfileView.h"
#import "M3DataSource.h"

@implementation SearchController

-(id)init
{
  self = [super init];
  
  return self;
}

-(NSString*)title
{
  return @"Suche...";
}

-(void)loadFromUrl:(NSString *)url
{
  self.tableView.tableHeaderView = [self searchBar];
  // self.dataSource = [M3DataSource moviesListFilteredByTheater:[params objectForKey: @"theater_id"]]; 
}

-(void)setFilterText: (NSString*)filterText
{
  dlog << "filterText: " << filterText;
  [super setFilterText: filterText];
}

-(void)setSearchText: (NSString*)searchText
{
  dlog << "searchText: " << searchText;
}
@end
