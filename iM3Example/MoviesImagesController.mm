//
//  MoviesImagesController.m
//  M3
//
//  Created by Enrico Thierbach on 02.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesImagesController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface MoviesImagesController (PrivateMethods)
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void)layoutPageControl;
@end

@implementation MoviesImagesController

@synthesize pages = pages_;

-(id)init
{
  self = [super initWithNibName:nil bundle:nil];

  // [app.chairDB on: @selector(updated) notify:self with:@selector(reload)];
  
  return self;
}

-(BOOL)isFullscreen
{
  return YES;
}

-(void)dealloc
{
  self.pages = nil;
  [super dealloc];
}

#pragma mark - Low memory management

- (void)viewDidLoad
{
  self.pages = [NSMutableArray array];

  CGSize viewSize = self.view.frame.size;
  CGRect frame = CGRectMake(0,0,viewSize.width,viewSize.height);

  scrollView = [[[UIScrollView alloc]initWithFrame:frame]autorelease];
  [self.view addSubview:scrollView];
  
  scrollView.delegate = self;
  scrollView.pagingEnabled = YES;
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.bounces = NO;
  scrollView.directionalLockEnabled = YES;

  pageControl = [[[UIPageControl alloc]initWithFrame:CGRectMake(30, 100, 300, 100)]autorelease];
  [self.view addSubview:pageControl];
  
  [self layoutPageControl];
  
  pageControl.backgroundColor = [UIColor colorWithName:@"#60606080"];
  pageControl.layer.borderColor = [UIColor colorWithName:@"#ccc"].CGColor;
  pageControl.layer.borderWidth = 2.0f;
  pageControl.layer.cornerRadius = 11;
  pageControl.userInteractionEnabled = NO;
  
  closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  closeButton.frame = CGRectMake(270, 10, 50, 50);
  closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0]; // this has a alpha of 0. 
  [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal]; 
  
  [self.view addSubview:closeButton];
  [closeButton addTarget:self action:@selector(popNavigationController) forControlEvents:UIControlEventTouchUpInside];

  [super viewDidLoad];
}

- (void)viewDidUnload
{
  self.pages = nil;
  [super viewDidLoad];
}

#define PAGE_CONTROL_HEIGHT 24

-(void)layoutPageControl
{
  pageControl.hidden = pageControl.numberOfPages < 2;
    
  int w = pageControl.numberOfPages * 18 + 46;
  int h = PAGE_CONTROL_HEIGHT;
  
  int x = (320 - w) / 2;
  int y = 400;
  
  pageControl.frame = CGRectMake(x, y, w, h);
}

//
-(NSString*)title
{
  return nil;
}

-(void)setTabBarHidden: (BOOL)hide
{
  UITabBarController* tbc = self.tabBarController;
  
  // find the tab bars content view.
	UIView *contentView = [tbc.view.subviews.first isKindOfClass:[UITabBar class]] ?
    tbc.view.subviews.second :
  	tbc.view.subviews.first;
  
  CGRect targetFrame = tbc.view.bounds;

  if(!hide) {
    targetFrame.size.height -= tbc.tabBar.frame.size.height;
  }
  
  contentView.frame = targetFrame;
  tbc.tabBar.hidden = hide;
}

-(void)popNavigationController
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(UIView*)viewForPage: (int)pageNo withImage: (UIImage*)image
{
  // set the content size.
  CGSize viewSz = scrollView.frame.size; 
  scrollView.contentSize = CGSizeMake(viewSz.width * (pageNo+1), viewSz.height);

  // The view for the new page
  UIView* pageView = [[UIView alloc]initWithFrame:CGRectMake(viewSz.width * pageNo,0,viewSz.width, viewSz.height)];

  // The view in the new page.
  CGRect frame = CGRectMake(0, 0, viewSz.width, viewSz.height);
  
  UIImageView* imageView = [[UIImageView alloc]initWithFrame: frame];
  imageView.image = image;
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.clipsToBounds = YES;

  [pageView addSubview: [imageView autorelease]];
  return [pageView autorelease];
}

-(void)addImage:(UIImage*)image
{
  // The number of the page to be added. Note: pages are 0-based.
  int pageNo = pageControl.numberOfPages;
  
  if(pageNo == 0) 
    [SVProgressHUD dismiss];
  
  UIView* page = [self viewForPage:pageNo withImage:image];
  [scrollView addSubview:page];
  [self.pages addObject:page];

  pageControl.numberOfPages = pageNo+1;
  [self layoutPageControl];
}

- (void)reloadURL
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"]; 

  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  NSArray* images = [movie objectForKey:@"images"];
  
  M3CachedFactory* factory = [UIImage cachedImagesWithURL]; 
  
  for(NSString* url in images) {
    [factory buildAsync:[M3 imageURL: url forSize: self.view.frame.size]
             withTarget:self 
            andSelector:@selector(addImage:)];
  }

  [SVProgressHUD show];
}

-(UIView*)page: (int)pageNo
{
  if(pageNo < 0 || pageNo >= self.pages.count) return nil;
  return [self.pages objectAtIndex:pageNo];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{  
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = scrollView.frame.size.width;
  int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

  pageControl.currentPage = page;

  //
  // smooth blending of next/previous page.
  double distance_from_center = fabs((scrollView.contentOffset.x - page * pageWidth));
  double relative_distance = distance_from_center / (pageWidth / 2);
  
  //
  [self page: page-1].alpha = relative_distance;
  [self page: page].alpha = 1;
  [self page: page+1].alpha = relative_distance;

  // Note: A possible optimization would be to unload the pages
  // that are no longer visible
}

#if 0

// If we had an active pageControl, we would want to determine whether
// or not a scrollViewDidScroll: event originates in a user action or
// in te pageView's changePage: handler.

// At the begin of scroll dragging, reset the boolean used when scrolls 
// originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls 
// originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
  int page = pageControl.currentPage;
  
	// update the scroll view to the appropriate page
  CGRect frame = scrollView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;
  [scrollView scrollRectToVisible:frame animated:YES];
  
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
  pageControlUsed = YES;
}

#endif

@end
