//
//  M3TableViewController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3TableViewController.h"
#import "M3TableViewAdCell.h"

@implementation M3TableViewController

@synthesize keys=keys_;

-(void)dealloc
{
  dlog << "Dealloc " << _.ptr(self);
  
  [segmentedControl_ release];
  [segmentURLs_ release];
  self.keys = nil;
  
  [self releaseM3Properties];
  [self releaseRequestedBannerViews];
  
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
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView: segmentedControl_]autorelease];
  #endif
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
  if (!cell)
    cell = [[[klass alloc]init]autorelease];

  cell.tableViewController = self;
  cell.indexPath = indexPath;

  id key = [self.keys objectAtIndex: indexPath.row];
  cell.key = key;
  cell.model = [self modelWithKey: key];

  return cell;
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
