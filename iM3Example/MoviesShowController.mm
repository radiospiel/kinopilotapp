//
//  MoviesFullController.m
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"
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
  [section addObject:_.array(@"MoviesShowTrailerCell", movie)];
  [section addObject:_.array(@"MovieInCinemasCell", movie)];
  
  [section addObject:_.array(@"MovieRatingCell", movie)];
  // [section addObject:_.array(@"M3TableViewAdCell", movie)];
  [section addObject:_.array(@"MovieDescriptionCell", movie)];
  
  [self addSection: section withOptions: nil];
  
  return self;
}

-(id) cellClassForKey: (NSArray*)key
{ 
  return key.first; 
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
  return number.to_i <= 0 ? 0 : 44;
}

-(id)init
{
  self = [super init];

  self.textLabel.text = @"moviepilot.de Rating";

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
  if(number.to_i <= 0) return;
  
  ratingBackground_.frame = CGRectMake(180, 13, 96, 16);
  ratingForeground_.frame = CGRectMake(180, 13, (number.to_i * 96 + 50)/100, 16);
  ratingForeground_.contentMode = UIViewContentModeLeft;
  ratingForeground_.clipsToBounds = YES;

  // TODO: make me right aligned
  CGRect labelFrame = self.textLabel.frame;
  
  ratingLabel_.font = [self.stylesheet fontForKey:@"h2"];
  ratingLabel_.frame = CGRectMake(287, labelFrame.origin.y, 46, labelFrame.size.height);
  ratingLabel_.font = self.textLabel.font;
  ratingLabel_.text = [NSString stringWithFormat: @"%.1f", number.to_i / 10.0];
}

@end

@interface MoviesShowTrailerCell: M3TableViewUrlCell
@end

@implementation MoviesShowTrailerCell

-(void)setKey: (id)key
{
  [super setKey:key];
  
  NSDictionary* movie = [self.key objectAtIndex:1];
  M3AssertKindOf(movie, NSDictionary);
    
  self.textLabel.text = @"Show Trailer";
  self.url = _.join(@"/movies/trailer?movie_id=", [movie objectForKey:@"_uid"]);
}

@end

/*
 * MovieInCinemasCell: This cell shows in which cinemaes the movie runs.
 */

@interface MovieInCinemasCell: MovieInfoCell
@end

@implementation MovieInCinemasCell

-(CGFloat)wantsHeight
{ 
  return 44;
}

-(void)setKey: (id)key
{
  [super setKey: key];
  
  // --- fill in cell.
  
  NSString* movie_id = [self.movie objectForKey: @"_uid"];
  NSArray* theater_ids = [app.chairDB theaterIdsByMovieId: movie_id];
  
  if(!theater_ids.count) {
    self.textLabel.text = @"Für diesen Film liegen uns keine Termine vor.";
    self.textLabel.font = [UIFont italicSystemFontOfSize:13];
    self.textLabel.textColor = [UIColor colorWithName:@"#999"];
  }
  else {
    NSString* label = nil;
    
    if(theater_ids.count == 1) {
      NSDictionary* theater = [app.chairDB.theaters get: theater_ids.first];
      label = [NSString stringWithFormat: @"Zur Zeit im %@", [theater objectForKey:@"name"]];
    }
    else {
      label = [NSString stringWithFormat: @"Zur Zeit in %d Kinos", theater_ids.count];
    }
    
    self.textLabel.font = [UIFont boldSystemFontOfSize:14];
    self.textLabel.text = label;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  // --- set URL
  switch(theater_ids.count) {
    case 0:   self.url = nil;
    case 1:   self.url = _.join(@"/schedules/list?movie_id=", movie_id, "&theater_id=", theater_ids.first); break;
    default:  self.url = _.join(@"/theaters/list?movie_id=", movie_id); break;
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

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:14] forKey:@"p"];
}

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
  
  htmlView.text = [NSAttributedString attributedStringWithMarkup: html 
                                                   forStylesheet: self.stylesheet];
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

@implementation MoviesShowController

-(NSString*)title 
{
  return @"Details";
}

-(void)loadFromUrl:(NSString *)url
{
  NSString* movie_id = [url.to_url param: @"movie_id"];
  self.dataSource = [[[MoviesFullControllerDataSource alloc]initWithMovieId: movie_id]autorelease];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

@end
