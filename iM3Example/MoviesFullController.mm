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
  [section addObject:_.array(@"MovieInCinemasCell", movie)];
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
  { return [self.key last]; }

@end

/*
 * MovieRatingCell: This cell shows the community rating
 */

@interface MovieRatingCell: MovieInfoCell
@end

@implementation MovieRatingCell

+(CGFloat)fixedHeight
  { return 50; }

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  self.textLabel.text = @"Community Rating:";
}

@end

/*
 * MovieInCinemasCell: This cell shows in which cinemaes the movie runs.
 */

@interface MovieInCinemasCell: MovieInfoCell
@end

@implementation MovieInCinemasCell

+(CGFloat)fixedHeight
  { return 50; }

-(void)setKey: (NSArray*)class_and_movie
{
  [super setKey:class_and_movie];
  M3AssertKindOf(self.movie, NSDictionary);

  self.imageView.image = [UIImage imageNamed: @"arrowright.png"];
  
  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: [self.movie objectForKey: @"_uid"]];
  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys:theater_ids] pluck: @"name"].uniq.sort;
  
  self.textLabel.numberOfLines = 2;
  
  switch(theaters.count) {
    case 0:
      self.textLabel.text = @"Für diesen Film liegen zur Zeit keine Aufführungen vor.";
      break;
    case 1:
      self.textLabel.text = [NSString stringWithFormat: @"Zur Zeit im %@", theaters.first];
      break;
    default:
      self.textLabel.text = [NSString stringWithFormat: @"Zur Zeit in %d Kinos: %@", theaters.count, [theaters componentsJoinedByString: @", "]];
      break;
  }
}

-(NSString*)urlToOpen
{
  self.imageView.image = [UIImage imageNamed: @"arrowright.png"];

  id movie_id = [self.movie objectForKey: @"_uid"];
  
  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  switch(theater_ids.count) {
    case 0:   return nil;
    case 1:   return [NSString stringWithFormat: @"/theaters/show/%@", theater_ids.first];
    default:  return [NSString stringWithFormat: @"/movies/show/%@", movie_id];
  }
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

-(void)setUrl:(NSString *)url
{
  [super setUrl:url];
  
  if([url matches:@"/movies/full/(.*)"])
    self.dataSource = [[MoviesFullControllerDataSource alloc]initWithMovieId: $1];
}
@end
