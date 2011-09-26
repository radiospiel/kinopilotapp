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
  @"MovieRatingCell",
  @"MovieInCinemasCell",
  @"MovieDescriptionCell"
};

@interface M3CustomCell: UITableViewCell {
  NSDictionary* model_;
}

@property (nonatomic,retain) NSDictionary* model;

-(CGFloat)recommendedHeight;

@end

@implementation M3CustomCell

-(NSDictionary*)model
  { return model_; }

-(id)initWithStyle:(UITableViewCellStyle)style
{
  self = [super initWithStyle:style 
              reuseIdentifier:nil];

  self.textLabel.font = [UIFont systemFontOfSize:13];
  self.textLabel.numberOfLines = 0;

  return self;
}

-(id)init
{
  return [self initWithStyle:UITableViewCellStyleDefault];
}

-(void)setModel:(NSDictionary*)model
{
  [model_ release];
  model_ = [model retain];
}

-(void)dealloc
{
  [model_ release];
  [super dealloc];
}

- (CGFloat)recommendedHeight
  { return 40.0f; }

@end

/*
 * MovieShortInfoCell: This cell shows the movie's image and a short 
 * description of the movie.
 */

@interface MovieShortInfoCell: M3CustomCell {
  TTTAttributedLabel* htmlView;
}

@end

@implementation MovieShortInfoCell

-(id) init {
  self = [super init];
  if(!self) return nil;

  htmlView = [[[TTTAttributedLabel alloc]init]autorelease];
  [self addSubview:htmlView];

  return self;
}

-(NSString*)shortInfoASHTML
{
  NSDictionary* model = self.model;
  
  NSNumber* runtime =         [model objectForKey:@"runtime"];
  NSString* genre =           [[model objectForKey:@"genres"] objectAtIndex:0];
  NSNumber* production_year = [model objectForKey:@"production-year"];
  NSArray* actors =           [model objectForKey:@"actors"];
  NSArray* directors =        [model objectForKey:@"directors"];
  // NSString* original_title =  [model objectForKey:@"original-title"];
  // NSString* average-community-rating: 56,  
  // NSString* cinema_start_date = [self.model objectForKey: @"cinema-start-date"]; // e.g. "2011-08-25T00:00:00+02:00"

  NSMutableArray* parts = [NSMutableArray array];

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
  
  if(directors) {
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

- (CGFloat)recommendedHeight
{
  CGFloat heightByHTMLView = [self htmlViewSize].height + 15;
  CGFloat heightByImage = 120;
  
  return heightByImage >= heightByHTMLView ? heightByImage : heightByHTMLView;
}

@end

/*
 * MovieRatingCell: This cell shows the community rating
 */

@interface MovieRatingCell: M3CustomCell
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

@interface MovieInCinemasCell: M3CustomCell
@end

@implementation MovieInCinemasCell

-(void)setModel: (NSDictionary*)theModel
{
  [super setModel:theModel];
  
  self.textLabel.text = @"In cinemas right now.";
}

@end

/*
 * MovieDescriptionCell: This cell shows a description of the movie.
 */

@interface MovieDescriptionCell: M3CustomCell {
  TTTAttributedLabel* htmlView;
}

@end

@implementation MovieDescriptionCell

-(id) init {
  self = [super init];
  if(!self) return nil;

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

- (CGFloat)recommendedHeight
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  dlog << "viewDidLoad";
  
  // self.tableView.separatorColor = [UIColor clearColor];
  // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return sizeof(columns)/sizeof(columns[0]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString* cellClass = columns[indexPath.row];
  
  Class klass = NSClassFromString(cellClass);
  
  M3CustomCell* cell = [[[klass alloc]init] autorelease];
  cell.model = self.model;
  return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  M3CustomCell* cell = (M3CustomCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
  return [cell recommendedHeight];
}

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
