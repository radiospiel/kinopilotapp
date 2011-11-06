//
//  M3TableViewController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3TableViewController.h"

@implementation M3TableViewController

-(id)init
{
  self = [super init];
  
  
  return self;
}

-(void)dealloc
{
  self.dataSource = nil;

  [segmentedControl_ release];
  [segmentedControlParams_ release];
  
  [self releaseM3Properties];

  [super dealloc];
}

-(void)viewDidLoad
{
  // dlog << "viewDidLoad: " << _.ptr(self) << (self.isViewLoaded ? " Loaded" : " Not loaded");

  [super viewDidLoad];

  // As M3TableViewController inherits from UITableViewController, the 
  // tableView is initialed with a newly created UITableView. Its dataSource
  // property is set to the controller - this is not what we'll use here,
  // so we nil it to be on the safe side.
  self.tableView.dataSource = nil;

  [self reload];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
}


#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  // If we are running in the simulator and it's the DEBUG target
  // then simulate a memory warning. 
    
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), 
                                       (CFStringRef)@"UISimulatedMemoryWarningNotification", 
                                       NULL, NULL, true);
}

#endif
#endif

-(M3TableViewDataSource*) dataSource
{ 
  M3AssertKindOf(self.tableView, UITableView);
  M3AssertKindOf([self.tableView dataSource], M3TableViewDataSource);
  
  return dataSource_;
}

-(void) setDataSource: (M3TableViewDataSource*)dataSource
{ 
  if(dataSource == dataSource_) return;

  // Note: an UITableView's dataSource is not retained by itself.
  [dataSource retain];
  [dataSource_ release];
  dataSource_ = dataSource;
  dataSource_.controller = self;
  
  if(self.isViewLoaded) {
    [self.tableView setDataSource: dataSource_]; 
    [self.tableView reloadData];
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
  M3TableViewCell* cell = (M3TableViewCell*)[self.dataSource tableView:tableView 
                                                 cellForRowAtIndexPath:indexPath];

  [cell selectedCell];

  [self performSelector:@selector(deselectRowOnTableView:) withObject:tableView afterDelay: 0.1];
}

- (void)deselectRowOnTableView: (UITableView *)tableView
{
  [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Segemented Control

// The M3TableViewController supports a segmented control, which is embedded 
// into the controllers navigation item (i.e. in the place of the right
// button).
//
// Each segment has a label (string or image), a title to display in the
// navigation item whenever it is selected, and a filter expression
// which will be send via setFilter: to the current controller. 
//
-(void)initializeSegmentedControl
{
  // Do any additional setup after loading the view from its nib.
  if(segmentedControl_) return;
  
  segmentedControl_ = [[UISegmentedControl alloc]init];
  segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;

  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView: segmentedControl_]autorelease];

  [segmentedControl_ addTarget:self
                        action:@selector(activeSegmentChanged:)
              forControlEvents:UIControlEventValueChanged];


  segmentedControlParams_ = [[NSMutableArray alloc]init];
  // 
  // if(!self.navigationItem) return;
  //  
  // UIView* titleView = self.navigationItem.titleView;
  // DLOG( NSStringFromCGRect(titleView.frame));
}

/* add a segment to the segmentedControl_ */

-(void)addSegment:(NSString*)label withFilter: (id)filter andTitle: (NSString*)title
{
  [self initializeSegmentedControl];
  
  [segmentedControl_ insertSegmentWithTitle: label
                                    atIndex: segmentedControl_.numberOfSegments
                                   animated: NO];  
  
  segmentedControl_.frame = CGRectMake(0, 0, segmentedControl_.numberOfSegments*45, 32);

  [segmentedControlParams_ addObject: _.hash(@"filter", filter, @"title", title)];
}

-(void) setFilter:(id)filter
{
  dlog << "Remember to implement " << [self class ] << "#setFilter: " << filter;
}

-(void) activateSegment:(NSUInteger)segmentNo
{
  [segmentedControl_ setSelectedSegmentIndex:segmentNo];
  
  NSDictionary* params = [segmentedControlParams_ objectAtIndex:segmentNo];
  NSString* title = [params objectForKey: @"title"];
  if(title) self.navigationItem.title = title;

  [self setFilter: [params objectForKey: @"filter"]];
}

-(void)activeSegmentChanged:(UIGestureRecognizer *)segmentedControl
{
  [self activateSegment: [segmentedControl_ selectedSegmentIndex]];
}

-(NSString*)title
{
  if(segmentedControl_) {
    NSUInteger idx = [segmentedControl_ selectedSegmentIndex];
    NSDictionary* params = [segmentedControlParams_ objectAtIndex:idx];
    return [params objectForKey: @"title"];
  }

  return [super title];
}

#pragma mark - Actions

#define ACTIONS_BUTTON_HEIGHT 33

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.dataSource.sections objectAtIndex: sectionNo];
  NSDictionary* actions = [section.second objectForKey:@"actions"];
  return actions ? ACTIONS_BUTTON_HEIGHT : 33;
}


- (UIView *)tableView:(UITableView *)tableView 
            viewForHeaderInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.dataSource.sections objectAtIndex: sectionNo];
  NSDictionary* actions = [section.second objectForKey:@"actions"];
  if(!actions) return nil;
  
  // 
  // add a button "section", i.e. a line of button(s)
  
  UIView* headerView = [[[UIView alloc]init]autorelease];
  headerView.frame = CGRectMake(0, 0, 320, ACTIONS_BUTTON_HEIGHT);

  int btnWidth = (300 - (actions.count - 1) * 20) / actions.count;
  int x = 10;
  
  for(NSArray* action in actions) {
    UIButton* btn = [UIButton actionButtonWithURL:action.second
                                         andTitle:action.first];
  
    btn.frame = CGRectMake(x, 5, btnWidth, ACTIONS_BUTTON_HEIGHT - 5);
    x += btnWidth + 20;
    [headerView addSubview: btn];
  }
  
  return headerView;
}

@end
