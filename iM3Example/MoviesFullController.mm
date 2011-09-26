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

static NSString* columns[] = {
  @"MovieShortInfoCell",
  @"MovieInCinemasCell",
  @"MovieRatingCell",
  @"M3TableViewAdCell",
  @"MovieDescriptionCell"
};

@class MoviesFullController;

/*
 * MovieShortInfoCell: This cell shows the movie's image and a short 
 * description of the movie.
 */

@interface MovieShortInfoCell: M3TableViewCell {
  TTTAttributedLabel* htmlView;
}

@end

@implementation MovieShortInfoCell

-(id) init {
  self = [super init];
  if(!self) return nil;

  self.selectionStyle = UITableViewCellSelectionStyleNone;

  htmlView = [[[TTTAttributedLabel alloc]init]autorelease];
  [self addSubview:htmlView];

  return self;
}

-(NSString*)shortInfoASHTML
{
  NSDictionary* model = self.model;
  
  NSString* title =           [model objectForKey:@"title"];
  NSNumber* runtime =         [model objectForKey:@"runtime"];
  NSString* genre =           [[model objectForKey:@"genres"] objectAtIndex:0];
  NSNumber* production_year = [model objectForKey:@"production-year"];
  NSArray* actors =           [model objectForKey:@"actors"];
  NSArray* directors =        [model objectForKey:@"directors"];
  // NSString* original_title =  [model objectForKey:@"original-title"];
  // NSString* average-community-rating: 56,  
  // NSString* cinema_start_date = [self.model objectForKey: @"cinema-start-date"]; // e.g. "2011-08-25T00:00:00+02:00"

  NSMutableArray* parts = [NSMutableArray array];

  [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2>", title]];

  if(genre || production_year || runtime) {
    NSMutableArray* p = [NSMutableArray array];
    if(genre) [p addObject: genre];
    if(production_year) [p addObject: production_year];
    if(runtime) [p addObject: [NSString stringWithFormat:@"%@ min", runtime]];
    
    [parts addObject: [p componentsJoinedByString:@", "]];
    [parts addObject:@""];
  }

  if(directors) {
    NSMutableArray* p = [NSMutableArray array];
    [p addObject: @"<b>Regie:</b> "];
    [p addObject: [directors componentsJoinedByString:@", "]];
    [parts addObject: [p componentsJoinedByString:@""]];
  }
  
  if(actors) {
    NSMutableArray* p = [NSMutableArray array];
    [p addObject: @"<b>Darsteller:</b> "];
    [p addObject: [actors componentsJoinedByString:@", "]];

    [parts addObject: [p componentsJoinedByString:@""]];
  }

  [parts addObject:@""];
  return [parts componentsJoinedByString:@"<br/>"];
}

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];
  
  self.imageView.imageURL = [theModel objectForKey:@"image"];
  self.textLabel.text = @" ";
    
  NSString* html = [self shortInfoASHTML];
  htmlView.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(220, 1000)];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  self.imageView.frame = CGRectMake(10, 10, 70, 100);
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(90, 7, sz.width, sz.height);
}

- (CGFloat)wantsHeightForWidth: (CGFloat)width
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 15;
  CGFloat heightByImage = 120;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end

/*
 * MovieRatingCell: This cell shows the community rating
 */

@interface MovieRatingCell: M3TableViewCell
@end

@implementation MovieRatingCell

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];

  self.textLabel.text = @"Community Rating:";
}

@end

/*
 * MovieInCinemasCell: This cell shows in which cinemaes the movie runs.
 */

@interface MovieInCinemasCell: M3TableViewCell
@end

@implementation MovieInCinemasCell

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];
  
  NSArray* theaterIds = [app.chairDB theaterIdsByMovieId: [theModel objectForKey: @"_uid"]];

  NSMutableArray* theaters = [NSMutableArray array];
  for(id theater_id in theaterIds) {
    NSDictionary* theater = [app.chairDB.theaters get: theater_id];
    [theaters addObject: [theater objectForKey:@"name"]];
  }
  
  NSArray* sorted = [[theaters uniq] sortedArrayUsingSelector:@selector(compare:)];
  self.textLabel.text = [NSString stringWithFormat: @"In %d Kinos: %@", 
                         theaterIds.count, 
                         [sorted componentsJoinedByString: @", "]];
}

@end

/*
 * MovieDescriptionCell: This cell shows a description of the movie.
 */

@interface MovieDescriptionCell: M3TableViewCell {
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

-(NSString*)descriptionAsHTML
{
  NSDictionary* model = self.model;
  
  NSString* description = [model objectForKey:@"description"];
  return description;
}

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];
  
  self.textLabel.text = @" ";
  
  NSString* html = [self descriptionAsHTML];
  htmlView.text = [NSAttributedString attributedStringWithSimpleMarkup: html];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(300, 1000)];
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(10, 5, sz.width, sz.height);
}

- (CGFloat)wantsHeightForWidth: (CGFloat)width
{
  return [self htmlViewSize].height + 15;
}

@end

@implementation MoviesFullController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
      // Custom initialization
  }
  return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return sizeof(columns)/sizeof(columns[0]);
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString* className = columns[indexPath.row];
  return NSClassFromString(className);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
