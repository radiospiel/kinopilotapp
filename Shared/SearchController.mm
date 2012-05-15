//
//  SearchController.h
//  M3
//
//  Created by Enrico Thierbach on 02.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"

@interface SearchController: M3ListViewController

@end

@implementation SearchController

-(NSString*)title
{
  return @"Suche...";
}

-(void)reloadURL
{
  [self setSearchBarEnabled:YES];
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
