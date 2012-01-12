//
//  ShareMovieController.h
//  M3
//
//  Created by Enrico Thierbach on 12.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ShareController.h"

#define TEASER_LENGTH 200

@interface ShareMovieController : ShareController

@property (nonatomic,retain) NSDictionary* movie;

@end

@implementation ShareMovieController

@synthesize movie;

-(void)setUrl:(NSString*)url
{
  [super setUrl:url];
  
  NSDictionary* params = url.to_url.params;
  self.movie = [app.sqliteDB.movies get: [params objectForKey: @"movie_id"]];
}

-(void)dealloc
{
  self.movie = nil;
  [super dealloc];
}

// get a teaser string for the movie

-(NSString*)teaser
{
  NSString* description = [self.movie objectForKey:@"description"];
  if(!description) return nil;
  
  NSArray* sentences = [description componentsSeparatedByString:@". "];
  sentences = [sentences mapUsingBlock:^id(NSString* sentence) {
    return [sentence stringByAppendingString:@"."];
  }];
  
  NSMutableString* teaser = [NSMutableString stringWithCapacity: TEASER_LENGTH + 100];
  
  for(NSString* sentence in sentences) {
    [teaser appendFormat:@" %@", sentence];
    if(teaser.length > TEASER_LENGTH) return teaser;
  }
  
  return description;
}

// get a teaser string for the movie, as HTML, potentially a link added.

-(NSString*)teaserAsHtml
{
  NSString* description = [self.movie objectForKey:@"description"];
  if(!description) return nil;
  
  NSString* teaser = [self teaser ];
  NSString* url = [self.movie objectForKey:@"url"];
  
  if(!url || teaser.length > description.length - 15) 
    return teaser.htmlEscape;
  
  return [teaser.htmlEscape stringByAppendingFormat:@"... <a href='%@'>Mehr auf moviepilot.de</a>", url];
}

-(NSDictionary*)interpolationContext
{
  return [NSDictionary dictionaryWithObjectsAndKeys:
          self.movie,            @"movie",       
          [self teaserAsHtml],   @"htmlTeaser",      
          nil 
          ];
}

-(void)shareViaEmail
{
  [ app composeEmailWithTemplateFile: @"$app/share_movie_email.html"
                           andValues: [self interpolationContext] 
   ];
}

@end
