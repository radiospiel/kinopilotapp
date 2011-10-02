//
//  MoviesShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"
#import "AppDelegate.h"

@interface MoviesShowController (Private)

@property (nonatomic,readonly) NSString* fullInfoURL;
@end

@implementation MoviesShowController (Private)

-(NSString*)fullInfoURL
{
  return [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/full"];
}

-(NSString*)imagesURL
{
  return [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/images"];
}

@end

@implementation MoviesShowController

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSString* bodyURL = _.join(@"/theaters/list/movie_id=", [self.model objectForKey:@"_uid" ]);
  [self setBodyController: [app viewControllerForURL:bodyURL ] withTitle: @"Kinos"];

  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.imageView.clipsToBounds = YES;
  
  // Show full info on a tap on tap on imageView and description
  [self.imageView onTapOpen: self.imagesURL ];
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

  // add full info URL
  [actions addObject: _.array(@"Mehr...", self.fullInfoURL)];

  // add imdb URL
  NSString* title = [self.model objectForKey: @"title"];
  NSString* imdbURL = _.join(@"imdb:///find?q=", title.urlEscape);
  if(![app canOpen:imdbURL])
    imdbURL = _.join(@"http://imdb.de/?q=", title.urlEscape);

  [actions addObject: _.array(@"IMDB", imdbURL)];

  return actions;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
