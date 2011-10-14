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

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.imageView.clipsToBounds = YES;
}

-(void)setUrl: (NSString *)url
{
  [super setUrl: url];

  [url matches:@"/movies/show/(.*)"];
  DLOG($1);
  
  self.model = [app.chairDB.movies get: $1];
}

-(void)setModel: (NSDictionary*)movie
{  
  DLOG(movie);

  [super setModel: movie];

  NSString* bodyURL = _.join(@"/theaters/list/movie_id=", [movie objectForKey: @"_uid"]);
  [self setBodyController: [app.router controllerForURL: bodyURL] withTitle: @"Kinos"];
  
  // Show full info on a tap on tap on imageView and description
  [self.imageView onTapOpen:  
          [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/images"] ];
  
  // -- set views

  NSString* title =           [movie objectForKey:@"title"];
  NSNumber* runtime =         [movie objectForKey:@"runtime"];
  NSArray* genres =           [movie objectForKey:@"genres"];
  NSNumber* production_year = [movie objectForKey:@"production-year"];

  // -- set actions

  {
    NSMutableArray* actions = _.array();
    
    // add full info URL
    [actions addObject: _.array(@"Mehr...", 
                                [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/full"]
                                )];
    
    // add imdb URL
    NSString* imdbURL = _.join(@"imdb:///find?q=", title.urlEscape);
    if(![app canOpen:imdbURL])
      imdbURL = _.join(@"http://imdb.de/?q=", title.urlEscape);
    
    [actions addObject: _.array(@"IMDB", imdbURL)];
    
    self.actions = actions;
  }

  // -- set desription
  {
    NSMutableArray* parts = [NSMutableArray array];
    [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title]];
    
    if(genres.first || production_year || runtime) {
      NSMutableArray* p = [NSMutableArray array];
      if(genres.first) [p addObject: genres.first];
      if(production_year) [p addObject: production_year];
      if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
      
      [parts addObject: @"<p>"];
      [parts addObject: [p componentsJoinedByString:@", "]];
      [parts addObject: @"</p>"];
    }
    
    self.htmlDescription = [parts componentsJoinedByString:@""];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
