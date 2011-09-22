//
//  MoviesListController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesListController.h"
#import "AppDelegate.h"

#define app ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@implementation MoviesListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

-(void)dealloc
{
  [super dealloc];
}

#pragma mark - View lifecycle

-(void)addSegment:(NSString*)label withURL: (NSString*)url
{
  [segmentedControl_ insertSegmentWithTitle: label
                                    atIndex: segmentedControl_.numberOfSegments
                                   animated: NO];  

  [segmentURLs_ addObject: url];
  
  if(segmentedControl_.numberOfSegments == 1) {
    [segmentedControl_ setSelectedSegmentIndex:0];
  }
}

-(void)activateSegment:(UIGestureRecognizer *)segmentedControl
{
  dlog << "activateSegment: " << [segmentedControl_ selectedSegmentIndex];
  // open URL.
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view from its nib.
  segmentedControl_ = [[UISegmentedControl alloc]init];
  segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;

  [segmentedControl_ addTarget:self
                        action:@selector(activateSegment:)
              forControlEvents:UIControlEventValueChanged];
              
  segmentURLs_ = [[NSMutableArray alloc]init];

  [self addSegment: @"all" withURL: @"/movies/list/all"];
  [self addSegment: @"new" withURL: @"/movies/list/new"];
  [self addSegment: @"hot" withURL: @"/movies/list/hot"];
  [self addSegment: @"fav" withURL: @"/movies/list/fav"];
  [self addSegment: @"art" withURL: @"/movies/list/fav"];
  
  segmentedControl_.frame = CGRectMake(0,0,160,32);
  
#if 0
  self.navigationItem.titleView = segmentedControl_;  
#else
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView: segmentedControl_];
#endif
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSArray*)chairKeys
{
  return [self memoized:@selector(chairKeys) usingBlock:^{
    return app.chairDB.movies.keys;
  }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  // get a reusable or create a new table cell
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }

  // fill in table cell
  NSInteger row = indexPath.row;
  id key = [[self chairKeys]objectAtIndex:row];
  NSDictionary* movie = [app.chairDB.movies get: key];
  
  cell.textLabel.text = [ movie objectForKey: @"title"]; // [NSString stringWithFormat:@"%d", indexPath.row];
  cell.detailTextLabel.text = [ movie objectForKey: @"title"];  

  NSArray* images = [movie valueForKey:@"images"];
  if([images.first isKindOfClass:[NSDictionary class]]) {
    cell.imageView.imageURL = [images.first objectForKey:@"thumbnail"]; 
  }

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [ app.chairDB.movies count];
}

@end
