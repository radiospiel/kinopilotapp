//
//  ShareScheduleController.h
//  M3
//
//  Created by Enrico Thierbach on 12.01.12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ShareController.h"

#define TEASER_LENGTH 200

@interface ShareScheduleController : ShareController

@property (nonatomic,retain) NSDictionary* movie;
@property (nonatomic,retain) NSDictionary* theater;
@property (nonatomic,retain) NSDictionary* schedule;

@end

@implementation ShareScheduleController

@synthesize movie, theater, schedule;

-(void)setUrl:(NSString*)url
{
  [super setUrl:url];
  
  NSDictionary* params = url.to_url.params;

  self.schedule = [app.sqliteDB.schedules get: [params objectForKey: @"schedule_id"]];
  self.theater = [app.sqliteDB.theaters get: [self.schedule objectForKey:@"theater_id"]];
  self.movie = [app.sqliteDB.movies get: [self.schedule objectForKey:@"movie_id"]];
}

-(void)dealloc
{
  self.movie = self.theater = self.schedule = nil;
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
  NSNumber* time = [self.schedule objectForKey: @"time"];

  return [NSDictionary dictionaryWithObjectsAndKeys:
            self.movie,                                         @"movie",       
            self.theater,                                       @"theater",     
            [time.to_date stringWithFormat: @"dd. MMM HH:mm"],  @"nice_time",   
            [self teaserAsHtml],                                @"htmlTeaser",      
            nil 
          ];
}

-(void)shareViaEmail
{
  [ app composeEmailWithTemplateFile: @"$app/share_schedule_email.html"
                           andValues: [self interpolationContext] 
  ];
}

-(void)shareViaCalendar
{
  NSNumber* runtime = [self.movie objectForKey: @"runtime"];
  NSTimeInterval runtimeInSecs = runtime ? runtime.to_i * 60 : 90 * 60;

  NSNumber* startTime = [self.schedule objectForKey: @"time"];
  
  BOOL fSuccess = [self addCalendarEvent: [self.movie objectForKey:@"title"]
                            withLocation: [self.theater objectForKey:@"name"]
                            andStartDate: startTime.to_date
                             andDuration: runtimeInSecs + 30 * 60
                   ];

  if (fSuccess) {
    [app alertMessage: @"Die Aufführung wurde in Deinen Kalender eingetragen"];
  }
  else {
    [app alertMessage: @"Die Aufführung konnte nicht in Deinen Kalender eingetragen werden."];
  }
}


-(NSString*)shortMessage
{
  NSNumber* time = [self.schedule objectForKey: @"time"];
  
  return [ NSString stringWithFormat: @"%@: %@, im %@", 
                                      [self.movie objectForKey: @"title"],
                                      [time.to_date stringWithFormat: @"dd. MMM HH:mm"],
                                      [self.theater objectForKey: @"name"]
          ];
}

-(void)shareViaTwitter
{
  [app sendTweet: [self shortMessage]
         withURL: [self.movie objectForKey:@"url"] 
        andImage: nil
  ];
}

-(void)shareViaFacebook
{
  [app sendToFacebook: [self teaserForMovie: self.movie]
            withTitle: [self shortMessage]
          andImageURL: [self.movie objectForKey:@"thumbnail"]
               andURL: [self.movie objectForKey:@"url"]
  ];
}

@end
