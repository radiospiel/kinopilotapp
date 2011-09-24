//
//  M3TableViewController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3TableViewController.h"
#import "AppDelegate.h"

#define app ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@implementation M3TableViewController

@synthesize classForCells = classForCells_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      classForCells_ = [M3ListCell class];
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
  [segmentedControl_ autorelease];
  [segmentURLs_ autorelease];
  
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Class klass = classForCells_;

  // get a reusable or create a new table cell
  M3ListCell *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass(klass)];
  if (!cell)
    cell = [[[klass alloc]init]autorelease];
  
  // Set model in cell.
  id key = [self.keys objectAtIndex: indexPath.row];
  cell.model = [self modelWithKey: key];
  return cell;
}

-(UITableViewCell*)createCell
{
  return [[[M3ListCell alloc] init] autorelease];
}

-(NSDictionary*)modelWithKey: (id)key
{
  _.raise(@"Missing mplementation: M3TableViewController#modelWithKey:");
  return nil;
}

- (NSArray*)keys;
{
  _.raise(@"Missing mplementation: M3TableViewController#keys");
  return nil;
}

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
}
@end

// For animating cell heights:
// http://stackoverflow.com/questions/460014/can-you-animate-a-height-change-on-a-uitableviewcell-when-selected/2063776#2063776
