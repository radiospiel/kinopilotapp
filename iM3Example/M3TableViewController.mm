//
//  M3TableViewController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3TableViewController.h"
#import "AppDelegate.h"

@implementation M3TableViewController

-(void)dealloc
{
  [segmentedControl_ release];
  [segmentURLs_ release];
  
  [super dealloc];
}

#pragma mark - View lifecycle

-(void)initializeSegmentedControl
{
  // Do any additional setup after loading the view from its nib.
  if(!segmentedControl_) {
    segmentedControl_ = [[UISegmentedControl alloc]init];
    segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl_ addTarget:self
                          action:@selector(activateSegment:)
                forControlEvents:UIControlEventValueChanged];
  }
  if(!segmentURLs_)
    segmentURLs_ = [[NSMutableArray alloc]init];
}

/* add a segment to the segmentedControl_ */

-(void)addSegment:(NSString*)label withURL: (NSString*)url
{
  [self initializeSegmentedControl];
  
  [segmentedControl_ insertSegmentWithTitle: label
                                    atIndex: segmentedControl_.numberOfSegments
                                   animated: NO];  
  
  segmentedControl_.frame = CGRectMake(0, 0, segmentedControl_.numberOfSegments*30, 32);

  [segmentURLs_ addObject: url];
}

-(void)activateSegment:(UIGestureRecognizer *)segmentedControl
{
  dlog << "activateSegment: " << [segmentedControl_ selectedSegmentIndex];
  // open URL.
}

-(void) showSegmentedControl
{
  [segmentedControl_ setSelectedSegmentIndex:0];
  
  #if 0
    self.navigationItem.titleView = segmentedControl_;  
  #else
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView: segmentedControl_];
  #endif
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  M3TableViewCell* cell = (M3TableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
  return [cell wantsHeightForWidth: 320 ];
}

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [M3TableViewCell class];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Class klass = [self tableView:tableView cellClassForRowAtIndexPath: indexPath];
  NSString* klassName = NSStringFromClass(klass);
  
  // get a reusable or create a new table cell
  M3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: klassName];
  if (!cell) {
    cell = [[[klass alloc]init]autorelease];
  }
  
  id key = [self.keys objectAtIndex: indexPath.row];
  
  cell.model = [self modelWithKey: key];
  cell.tableViewController = self;

  return cell;
}

/*
 * This method returns a list of keys suitable for identifying each entry within the table view.
 */
- (NSArray*)keys;
{
  return nil;
}

/*
 * This method returns the model identified by the passed in key. If cells for this 
 * key do not need any model, it is fine just to return nil here.
 *
 * The default implementation returns the controller's model.
 */
-(NSDictionary*)modelWithKey: (id)key
{
  return self.model;
}

/*
 * This method returns a URL for the specified key. 
 *
 * If the user taps a cell, the app delegate will be asked to open
 * the URL returned by this method for the cell's key.
 *
 * The default implementation returns nil.
 */
-(NSString*)urlWithKey: (id)key
{
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.keys.count;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
  id key = [self.keys objectAtIndex: indexPath.row];
  [app open: [self urlWithKey: key]];

  [self performSelector:@selector(deselectRowOnTableView:) withObject:tableView afterDelay: 1.0];
}

- (void)deselectRowOnTableView: (UITableView *)tableView
{
  [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
@end

