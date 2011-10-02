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

-(void)dealloc
{
  [segmentedControl_ release];
  [segmentedControlParams_ release];
  
  [self releaseM3Properties];
  
  [super dealloc];
}

-(M3TableViewDataSource*) dataSource
{ 
  M3AssertKindOf(self.tableView.dataSource, M3TableViewDataSource);
  
  return [self.tableView dataSource];
}

-(void) setDataSource: (M3TableViewDataSource*)dataSource
{ 
  M3AssertKindOf(dataSource, M3TableViewDataSource);
  self.tableView.dataSource = dataSource;
  [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
  M3TableViewCell* cell = (M3TableViewCell*)[self.dataSource tableView:tableView 
                                                 cellForRowAtIndexPath:indexPath];

  NSString* url = [cell urlToOpen];
  if(url)
    [app open: url];

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

@end

/*
 * Slightly modified section headers for lists: this saves a few pixels per section.
 */
@implementation M3TableViewListController

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the button object
  UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)]autorelease];
  header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-background-22.png"]]; 
  
  UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(7, 0, 308, 22)]autorelease];
  label.backgroundColor = [UIColor clearColor];
  label.opaque = NO;
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont boldSystemFontOfSize:15];
  label.lineBreakMode = UILineBreakModeMiddleTruncation;
  label.text = [self.dataSource tableView:tableView titleForHeaderInSection:section];

  [header addSubview:label];

  return header;
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
