//
//  MoviesListController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesListController.h"
#import "M3TableViewProfileCell.h"
#import "M3TableViewAdCell.h"

@implementation M3ListViewController: M3TableViewController

-(void)dealloc
{
  [keys_ release];
  [super dealloc];
}

-(NSArray*)keys
{
  if(!keys_) {
    NSMutableArray* keys = [[NSMutableArray alloc]init];

    int probability = -1;
    
    for(id key in app.chairDB.movies.keys) {
      // The likelyhood of an ad view increments with each inserted row.
      if(rand() % 12 < probability) {
        NSLog(@"add ad");
        [keys addObject: [NSNull null]];
        probability = -1;
      }

      probability++;
      
      [keys addObject: key];
    }
    
    keys_ = keys;
  }

  return keys_;
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  NSArray* keys = [self keys];
  id key = [keys objectAtIndex: indexPath.row];
  
  if([key isKindOfClass:[NSNull class]])
    return [M3TableViewAdCell class];
  
  return [M3TableViewProfileCell class];
}

@end

@implementation MoviesListController


-(NSDictionary*)modelWithKey:(id)key
{ 
  if(!key) return nil;
  if([key isKindOfClass: [NSNull class]]) return nil;

  return [app.chairDB objectForKey: key andType: @"movies"]; 
}

// get url for indexPath
-(NSString*)urlWithKey: (id)key
{ 
  if(!key) return nil;
  if([key isKindOfClass: [NSNull class]]) return nil;
  
  return _.join(@"/movies/show/", key); 
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view from its nib.
  [self addSegment: @"all" withURL: @"/movies/list/all"];
  [self addSegment: @"new" withURL: @"/movies/list/new"];
  [self addSegment: @"hot" withURL: @"/movies/list/hot"];
  [self addSegment: @"fav" withURL: @"/movies/list/fav"];
  [self addSegment: @"art" withURL: @"/movies/list/fav"];
  
  [self showSegmentedControl];
}

@end
