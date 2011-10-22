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
  dlog << "viewDidLoad: " << _.ptr(self) << (self.isViewLoaded ? " Loaded" : " Not loaded");

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

#define ACTIONS_BUTTON_HEIGHT 49

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




#if 0 

/*
 * iAd banners
 */

static NSString *kADBannerContentSizePortrait = nil;
static NSString *kADBannerContentSizeLandscape = nil;

static BOOL initialiseADBannerConstants() {
  Class cls = NSClassFromString(@"ADBannerView");
  if (!cls) return NO;

  if (&ADBannerContentSizeIdentifierPortrait != nil)
    kADBannerContentSizePortrait = ADBannerContentSizeIdentifierPortrait;
  else
    kADBannerContentSizePortrait = ADBannerContentSizeIdentifier320x50;

  if (&ADBannerContentSizeIdentifierLandscape != nil)
    kADBannerContentSizeLandscape = ADBannerContentSizeIdentifierLandscape;
  else
    kADBannerContentSizeLandscape = ADBannerContentSizeIdentifier480x32;

  return YES;
}

@implementation M3TableViewController(iAd)

-(void)releaseRequestedBannerViews
{
  if(!requestedAdBanners_) return;
  
  for(id key in requestedAdBanners_) {
    ADBannerView* bannerView = [requestedAdBanners_ objectForKey: key];
    bannerView.delegate = nil;
    [bannerView release];
  }
}

-(NSMutableDictionary*)requestedBannerViews
{
  if(!requestedAdBanners_) {
    static BOOL initialisedADBannerConstants = initialiseADBannerConstants();
    (void)initialisedADBannerConstants;
    
    requestedAdBanners_ = [[NSMutableDictionary alloc]init];
  }

  return requestedAdBanners_;
}

/*
 * request an ad banner on indexPath.
 */
-(void)requestAdBannerAtIndexPath: (NSIndexPath*)indexPath
{
  Class classAdBannerView = NSClassFromString(@"ADBannerView");
  if (!classAdBannerView) return;

  if([self adBannerAtIndexPath: indexPath]) return;

  ADBannerView* adView = [[[classAdBannerView alloc]initWithFrame:CGRectZero] autorelease];
  [adView setRequiredContentSizeIdentifiers:[NSSet setWithObject: kADBannerContentSizePortrait ]];
  [adView setCurrentContentSizeIdentifier: kADBannerContentSizePortrait];            
  // [adView setFrame:CGRectOffset([bannerView_ frame], 0, 50)];
  [adView setDelegate:self];

  NSMutableDictionary* requestedBannerViews = [self requestedBannerViews];
  [requestedBannerViews setObject: adView forKey: indexPath];
}

/*
 * a banner was properly loaded -> reload the AdCell at the cell's indexPath. 
 */
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
  NSIndexPath* indexPath = [[self requestedBannerViews]allKeysForObject:banner].first;
  if(!indexPath) return;
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject: indexPath]
                        withRowAnimation:UITableViewRowAnimationFade];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  // dlog << @"*** Did not receive a banner " << error;
}

-(UIView*) adBannerAtIndexPath: (NSIndexPath*)indexPath
{
  return [[self requestedBannerViews]objectForKey: indexPath];
}

@end

#endif
