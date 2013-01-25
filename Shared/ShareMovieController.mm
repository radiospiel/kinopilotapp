//
//  ShareMovieController.h
//  M3
//
//  Created by Enrico Thierbach on 12.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ShareController.h"

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

#define TEASER_LENGTH 200

// get a teaser string for the movie, as HTML, potentially a link added.

-(NSString*)teaserAsHtml
{
  NSString* description = [self.movie objectForKey:@"description"];
  if(!description) return nil;
  
  NSString* teaser = [self teaserForMovie: self.movie];
  NSString* escapedTeaser = teaser.htmlEscape;
  
  NSString* url = [self.movie objectForKey:@"url"];
  
  if(url && (teaser.length < description.length - 15)) {
    if(app.isKinopilot)
      escapedTeaser = [escapedTeaser stringByAppendingFormat:@"... <a href='%@'>Mehr auf moviepilot.de</a>", url];
    else
      escapedTeaser = [escapedTeaser stringByAppendingFormat:@"... <a href='%@'>Weiterlesen</a>", url];
  } 

  return escapedTeaser;
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
  [ app composeEmailWithTemplateFile: @"$config/share_movie_email.html"
                           andValues: [self interpolationContext] 
   ];
}

-(void)shareViatwer
{
  NSString* tweet = [NSString stringWithFormat: @"%@: %@", 
                     [self.movie objectForKey:@"title"], 
                     [self.movie objectForKey:@"url"]];

  [app sendTweet: tweet
         withURL: [self.movie objectForKey:@"url"] // [self.movie objectForKey:@"url"] 
        andImage: [self.movie objectForKey:@"thumbnail"]];
}

@end
