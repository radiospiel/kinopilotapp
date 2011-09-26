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

@interface TheatersListCell: M3TableViewProfileCell

/*
 * checks if the current cell supports a certain feature.
 */
-(BOOL)features: (SEL)feature;

@end

@implementation TheatersListCell

-(BOOL)features: (SEL)feature;
{
  if(feature == @selector(image))
    return NO;
  
  return [super features: feature];
}

@end

@implementation TheatersListController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [TheatersListCell class];
}

-(NSArray*)keys
{
  return app.chairDB.theaters.keys;
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
