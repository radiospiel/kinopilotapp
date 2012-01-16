//
//  MovieActionController.m
//  M3
//
//  Created by Enrico Thierbach on 13.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "M3ActionSheetController.h"

@interface MovieActionsController : M3ActionSheetController

@end

@implementation MovieActionsController

-(void)setUrl: (NSString*)urlString
{
  [super setUrl: urlString];
  
  NSURL* url = urlString.to_url;
  
  NSString* movie_id = [url param: @"movie_id"];

  NSDictionary* movie = [app.sqliteDB.movies get: movie_id ];

  self.title = [ movie objectForKey: @"title"];

  [self addAction:@"Twitter"  withURL: _.join(@"/share/movie/twitter?movie_id=", movie_id)];
  [self addAction:@"Facebook" withURL: _.join(@"/share/movie/facebook?movie_id=", movie_id)];
  [self addAction:@"Email"    withURL: _.join(@"/share/movie/email?movie_id=", movie_id)];
}
@end
