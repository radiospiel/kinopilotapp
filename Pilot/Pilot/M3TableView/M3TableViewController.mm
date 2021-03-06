//
//  M3TableViewController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "M3TableViewController.h"

@implementation M3TableViewController

@synthesize topBannerView;

-(id)init
{
  self = [super init];
  self.clearsSelectionOnViewWillAppear = NO;

  return self;
}

-(void)dealloc
{
  self.dataSource = nil;

  self.topBannerView.delegate = nil; 
  self.topBannerView = nil; 

  [segmentedControl_ release]; segmentedControl_ = nil;
  [segmentedControlParams_ release]; segmentedControlParams_ = nil;
  
  [self releaseM3Properties];

  [super dealloc];
}

-(void)viewDidLoad
{
  [super viewDidLoad];

  // As M3TableViewController inherits from UITableViewController, the 
  // tableView is initialized with a newly created UITableView. Its dataSource
  // property is set to the controller - this is not what we'll use here,
  // so we nil it to be on the safe side. It will be set properly during
  // reload, though.
  self.tableView.dataSource = nil;

  [self reload];
}

-(void)viewDidUnload
{
  self.topBannerView = nil; 
  self.tableView = nil;

  [super viewDidUnload];
}

#if TARGET_IPHONE_SIMULATOR
#if DEBUG
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

-(NSUInteger) supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

-(M3TableViewDataSource*) dataSource
{ 
  M3AssertKindOf(self.tableView, UITableView);
  M3AssertKindOf(self.tableView.dataSource, M3TableViewDataSource);
  
  return dataSource_;
}

-(void)setUrl:(NSString *)url
{
  // Note: the tableview should already exist before setting the URL for the
  // first time. Else a tableview would be created, and the viewDidLoad method
  // (re)loads the data source, sets it into the tableview, after which the 
  // loadURL method loads and sets the data source again; consequently building
  // the data source **twice**. This is only important when setting an URL for 
  // the first time, though.
  // 
  [ self tableView ]; // Make sure the tableView exists.
  
  [super setUrl:url];
  if(!url)
    self.dataSource = nil;
}

-(void) setDataSource: (M3TableViewDataSource*)dataSource
{ 
  if(dataSource == dataSource_) return;

  // Note: an UITableView's dataSource is not retained by itself.
  [dataSource retain];
  [dataSource_ release];
  dataSource_ = dataSource;
  dataSource_.controller = self;

  if(!self.isViewLoaded) return;
  
  [self.tableView setDataSource: dataSource_]; 
  [self.tableView reloadData];
  
  if([dataSource_ isKindOfClass: @"M3TableViewDefaultDataSource".to_class]) {
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
  }
  else {
    self.tableView.separatorColor = [UIColor colorWithName: @"#ddd"];
    self.tableView.scrollEnabled = YES;
    [self.tableView setScrollsToTop:YES];
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

  [cell didSelectCell];

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

/* add a segment to the segmentedControl_ */

-(BOOL)hasSegmentedControl;
{
  return segmentedControl_ != nil;
}

-(void)addSegment:(id)labelOrImage withFilter: (id)filter andTitle: (NSString*)title;
{
  id existingSegmentedControl_ = segmentedControl_;
  
  // Is the segmentedControl_ already initialized? If not, build it, but do not
  // yet wire it to self.
  if(!segmentedControl_) {
    segmentedControl_ = [[UISegmentedControl alloc]init];
    segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView: segmentedControl_]autorelease];

    segmentedControlParams_ = [[NSMutableArray alloc]init];
  }
  
  if([labelOrImage isKindOfClass:[UIImage class]]) {
    [segmentedControl_ insertSegmentWithImage: labelOrImage
                                      atIndex: segmentedControl_.numberOfSegments
                                     animated: NO];
  }
  else {
    [segmentedControl_ insertSegmentWithTitle: labelOrImage
                                      atIndex: segmentedControl_.numberOfSegments
                                     animated: NO];
  }

  [segmentedControlParams_ addObject: _.hash(@"filter", filter, @"title", title)];

  segmentedControl_.frame = CGRectMake(0, 0, segmentedControl_.numberOfSegments*45, 32);

  if(!existingSegmentedControl_) {
    [segmentedControl_ setSelectedSegmentIndex:0];
    [segmentedControl_ addTarget:self
                          action:@selector(activeSegmentChanged:)
                forControlEvents:UIControlEventValueChanged];
  }
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

#define ACTIONS_BUTTON_HEIGHT 29

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.dataSource.sections objectAtIndex: sectionNo];
  NSDictionary* actions = [section.second objectForKey:@"actions"];
  return actions ? 29 : 33;
}


- (UIView *)tableView:(UITableView *)tableView 
            viewForHeaderInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.dataSource.sections objectAtIndex: sectionNo];
  NSArray* actions = [section.second objectForKey:@"actions"];
  if(!actions) return nil;
  
  // 
  // add a button "section", i.e. a line of button(s)
  
  UIView* headerView = [[[UIView alloc]init]autorelease];
  headerView.frame = CGRectMake(0, 0, 320, ACTIONS_BUTTON_HEIGHT);

  NSArray* buttons = [actions mapUsingBlock:^id(NSArray* action) {
    return [UIButton actionButtonWithURL: action.second
                                andTitle: action.first];
    
  }];

  [ UIButton layoutButtons: (NSArray*)buttons 
             	   withWidth: 320 
            	  andPadding: EVEN_PADDING
                 andMargin: 10 ];

  for(UIButton* btn in buttons) {
    [headerView addSubview: btn];
  }
  
  return headerView;
}

@end
