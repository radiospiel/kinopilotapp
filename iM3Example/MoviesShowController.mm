//
//  MoviesShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"
#import "AppDelegate.h"

@implementation MoviesShowController

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSString* bodyURL = _.join(@"/theaters/list/movie_id=", [self.model objectForKey:@"_uid" ]);
  [self setBodyController: [app viewControllerForURL:bodyURL ] withTitle: @"Kinos"];
  
  // Show full info on a tap on tap on imageView and description
  NSString* fullInfoURL = [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/full"];

  [self.view onTapOpen: fullInfoURL ];
}  

- (NSString*)descriptionAsHTML
{
  NSDictionary* model = self.model;

  NSString* title =           [model objectForKey:@"title"];
  NSNumber* runtime =         [model objectForKey:@"runtime"];
  NSString* genre =           [[model objectForKey:@"genres"] objectAtIndex:0];
  NSNumber* production_year = [model objectForKey:@"production-year"];

  NSMutableArray* parts = [NSMutableArray array];
  [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title]];

  if(genre || production_year || runtime) {
    NSMutableArray* p = [NSMutableArray array];
    if(genre) [p addObject: genre];
    if(production_year) [p addObject: production_year];
    if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
    
    [parts addObject: @"<p>"];
    [parts addObject: [p componentsJoinedByString:@", "]];
    [parts addObject: @"</p>"];
  }

  return [parts componentsJoinedByString:@""];
}

-(NSArray*)actions
{
  NSMutableArray* actions = _.array();
  
  NSString* imdb = [self.model objectForKey:@"IMDB"];
  imdb = _.join(@"http://imdb.de/?q=", [self.model objectForKey: @"title"]);
  
  if(actions.count < 2 && imdb) {
    [actions addObject: _.array(@"IMDB", imdb)];
  }

  return actions;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
