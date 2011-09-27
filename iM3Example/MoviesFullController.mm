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
 * MovieRatingCell: This cell shows the community rating
 */

@interface MovieRatingCell: M3TableViewCell
@end

@implementation MovieRatingCell

+(CGFloat)fixedHeight
  { return 50; }

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

+(CGFloat)fixedHeight
  { return 50; }

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];
  
  NSArray* theaterIds = [app.chairDB theaterIdsByMovieId: [theModel objectForKey: @"_uid"]];

  NSArray* theaters = [[app.chairDB.theaters valuesWithKeys:theaterIds] pluck: @"name"].uniq.sort;

  self.imageView.image = [UIImage imageNamed: @"arrowright.png"];
  
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

+(CGFloat)fixedHeight
{ 
  return 0; 
}

- (CGFloat)wantsHeight
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
