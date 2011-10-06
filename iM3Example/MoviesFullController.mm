//
//  MoviesFullController.m
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesFullController.h"
#import "AppDelegate.h"
#import "M3.h"

#import "TTTAttributedLabel/TTTAttributedLabel.h"

@interface MoviesFullControllerDataSource: M3TableViewDataSource
@end

@implementation MoviesFullControllerDataSource

-(id)initWithMovieId: (id)movie_id
{
  self = [super init];
  if(!self) return nil;

  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  movie = [app.chairDB adjustMovies:movie];

  M3AssertKindOf(movie, NSDictionary);
  
  NSMutableArray* section = [NSMutableArray array];
  
  [section addObject:_.array(@"MovieShortInfoCell", movie)];
  [section addObject:_.array(@"MovieNotInCinemasCell", movie)];
  [section addObject:_.array(@"MovieRatingCell", movie)];
  [section addObject:_.array(@"M3TableViewAdCell", movie)];
  [section addObject:_.array(@"MovieDescriptionCell", movie)];
  
  [self addSection: section withOptions: nil];
  
  return self;
}

-(Class) cellClassForKey: (NSArray*)key
{
  NSString* className = key.first;
  return NSClassFromString(className);
}

@end

@interface MovieInfoCell: M3TableViewCell

@property (nonatomic,readonly) NSDictionary* movie;

@end

@implementation MovieInfoCell

-(NSDictionary*)movie
{ 
  NSDictionary* movie = [self.key objectAtIndex:1];
  M3AssertKindOf(movie, NSDictionary);

  return movie;
}

@end

/*
 * MovieRatingCell: This cell shows the community rating
 */

@interface MovieRatingCell: MovieInfoCell {
  UIImageView* ratingBackground_;
  UIImageView* ratingForeground_;
  UILabel*     ratingLabel_;
}
@end

@implementation MovieRatingCell

-(CGFloat)wantsHeight
{
  NSNumber* number = [self.movie objectForKey: @"average-community-rating"];
  int rating = [number intValue];
  
  return rating < 0.01 ? 0 : 30;
}

-(id)init
{
  self = [super init];
  if(self) {
    ratingBackground_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unstars.png"]];
    [self addSubview: [ratingBackground_ autorelease]];

    ratingForeground_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stars.png"]];
    [self addSubview: [ratingForeground_ autorelease]];
  
    ratingLabel_ = [[UILabel alloc]init];
    [self addSubview: [ratingLabel_ autorelease]];

    self.clipsToBounds = YES;
  }
  return self;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  // Get rating: this is a number between 0 and 100.
  NSNumber* number = [self.movie objectForKey: @"average-community-rating"];
  int rating = [number intValue];

  if(rating < 0.01) return;
  
  self.textLabel.text = @"moviepilot.de Rating:";

  ratingBackground_.frame = CGRectMake(150, 6, 96, 16);
  ratingForeground_.frame = CGRectMake(150, 6, (rating * 96 + 50)/100, 16);
  ratingForeground_.contentMode = UIViewContentModeLeft;
  ratingForeground_.clipsToBounds = YES;

  CGRect labelFrame = self.textLabel.frame;
  
  ratingLabel_.frame = CGRectMake(260, labelFrame.origin.y, 96, labelFrame.size.height);
  ratingLabel_.font = self.textLabel.font;
  ratingLabel_.text = [NSString stringWithFormat: @"%.1f", rating / 10.0];
}

@end

/*
 * MovieNotInCinemasCell: This cell shows in which cinemaes the movie runs.
 */

@interface MovieNotInCinemasCell: MovieInfoCell
@end

@implementation MovieNotInCinemasCell

-(CGFloat)wantsHeight
{ 
  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: [self.movie objectForKey: @"_uid"]];
  return theater_ids.count > 0 ? 0 : 30; 
}

-(id)init
{
  self = [super init];
  
  self.textLabel.text = @"Für diesen Film liegen uns keine Termine vor.";
  self.textLabel.font = [UIFont italicSystemFontOfSize:13];
  self.textLabel.textColor = [UIColor colorWithName:@"#999"];

  return self;
}
@end


/*
 * MovieDescriptionCell: This cell shows a description of the movie.
 */

@interface MovieDescriptionCell: MovieInfoCell {
  TTTAttributedLabel* htmlView;
}

@end

@implementation MovieDescriptionCell

-(id) init {
  self = [super init];
  if(!self) return nil;

  self.selectionStyle = UITableViewCellSelectionStyleNone;

  htmlView = [[[TTTAttributedLabel alloc]init]autorelease];
  [self addSubview:htmlView];

  return self;
}

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  
  self.textLabel.text = @" ";
  
  NSString* description = [self.movie objectForKey:@"description"];
  NSString* html = _.join(@"<p><b>Beschreibung: </b>", description.cdata, @"</p><br />");

  htmlView.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
}

-(CGSize)htmlViewSize
  { return [htmlView sizeThatFits: CGSizeMake(300, 1000)]; }

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(10, 5, sz.width, sz.height);
}

- (CGFloat)wantsHeight
  { return [self htmlViewSize].height + 15; }

@end

@implementation MoviesFullController

// set right button
-(void)setRightButton: (NSString*)movie_id
{
  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  
  switch(theater_ids.count) {
    case 0:
      break;
    case 1: 
      [self setRightButtonWithTitle: @"1 Kino"
                                url: _.join(@"/theaters/show/", theater_ids.first) ];
      break;
    default: 
      [self setRightButtonWithTitle: [NSString stringWithFormat: @"%d Kinos", theater_ids.count]
                                url: _.join(@"/movies/show/", movie_id) ];
  }
}

-(NSString*)title 
{
  return @"Details";
}

-(void)setUrl:(NSString *)url
{
  [super setUrl:url];
  
  if([url matches:@"/movies/full/(.*)"]) {
    NSString* movie_id = $1;
    id dataSource = [[MoviesFullControllerDataSource alloc]initWithMovieId: movie_id];
    self.dataSource = [dataSource autorelease];
    [self setRightButton:movie_id];
  }
}
@end
