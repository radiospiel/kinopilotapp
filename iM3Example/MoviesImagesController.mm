//
//  MoviesImagesController.m
//  M3
//
//  Created by Enrico Thierbach on 02.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesImagesController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface MoviesImagesController (PrivateMethods)
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end


@implementation MoviesImagesController

@synthesize imageUrls = imageUrls_, pageViews = pageViews_;

-(id)init
{
  self = [super initWithNibName:nil bundle:nil];

  return self;
}

-(BOOL)isFullscreen
{
  return YES;
}

-(void)dealloc
{
  self.imageUrls = nil;
  self.pageViews = nil;
  
  [super dealloc];
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

#define PAGE_CONTROL_HEIGHT 24

-(void)layoutPageControl
{
  int x, y, w, h;
  
  w = pageControl.numberOfPages * 18 + 46;
  h = PAGE_CONTROL_HEIGHT;
  
  x = (320 - w) / 2;
  y = 400;
  
  pageControl.frame = CGRectMake(x, y, w, h);
}

-(void)popNavigationController
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
  if(!scrollView) {
    scrollView = [[[UIScrollView alloc]initWithFrame:CGRectMake(0,0,320,480)]autorelease];
    [self.view addSubview:scrollView];

    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.bounces = NO;
    scrollView.directionalLockEnabled = YES;
  }
  
  if(!pageControl) {
    pageControl = [[[UIPageControl alloc]initWithFrame:CGRectMake(30, 100, 300, 100)]autorelease];
    [self.view addSubview:pageControl];

    [self layoutPageControl];
    
    pageControl.backgroundColor = [UIColor colorWithName:@"#60606080"];
    pageControl.layer.borderColor = [UIColor colorWithName:@"#ccc"].CGColor;
    pageControl.layer.borderWidth = 2.0f;
    pageControl.layer.cornerRadius = 11;
    pageControl.userInteractionEnabled = NO;
  }
  
  if(!closeButton) {
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:@"x" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(270, 10, PAGE_CONTROL_HEIGHT, PAGE_CONTROL_HEIGHT);
    closeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    // closeButton.backgroundColor = [UIColor blackColor];
    closeButton.backgroundColor = [UIColor colorWithName:@"#60606080"];

    CALayer *layer = closeButton.layer;
    //    layer.backgroundColor = [[UIColor colorWithName:@"#60606080"] CGColor];
    // layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.borderColor = [UIColor colorWithName:@"#ccc"].CGColor;
    layer.cornerRadius = 11;
    layer.borderWidth = 2.0f;

    [self.view addSubview:closeButton];
    [closeButton addTarget:self action:@selector(popNavigationController) forControlEvents:UIControlEventTouchUpInside];
  }

  //  [self setTabBarHidden:YES];

  // --- get image URLs from movie object

  [self.url matches:@"/movies/images/(.*)"];
  NSString* movie_id = $1;
  
  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  
  NSArray* images = [movie objectForKey:@"images"];
  
  NSArray* fullsize_urls = [images pluck: @"fullsize"];
  // NSArray* thumbnail_urls = [images pluck: @"thumbnail"];
  
  self.imageUrls = fullsize_urls;
  
  // --- fill the pageViews array with NSNull placeholders.

  self.pageViews = [fullsize_urls mapUsingBlock:^id(id obj) {
    return [NSNull null];
  }];

  // --- set up scrollview size
  
  CGSize contentSize = CGSizeMake(scrollView.frame.size.width * self.pageViews.count, scrollView.frame.size.height);
  scrollView.contentSize = contentSize;
  
  // --- wire up scrollview and pager
  
  pageControl.numberOfPages = self.pageViews.count;
  [self layoutPageControl];
  
  // --- load pages
  
  [self loadScrollViewWithPage:0]; // load first page
  [self loadScrollViewWithPage:1]; // preload second page

  // --- hide the tabbar

  // [self setTabBarHidden: YES];
}

#define DX 5
#define DY 5

-(UIImageView*)viewForPage:(int)page
{
  if (page < 0 || page >= self.pageViews.count)
    return nil;
  
  return [self.pageViews objectAtIndex:page];
}

- (void)loadScrollViewWithPage:(int)page
{
  if (page < 0 || page >= self.pageViews.count)
    return;

  // replace the placeholder in the oageViews array.
  UIView* placeholder = [self.pageViews objectAtIndex:page];
  if(![placeholder isKindOfClass:[NSNull class]]) return;

  CGRect frame = scrollView.frame;
  frame.origin.x = frame.size.width * page + DX;
  frame.origin.y = DY;
  frame.size.width -= 2*DX;
  frame.size.height -= 2*DY;
  
  UIImageView* imageView = [[[UIImageView alloc]initWithFrame: frame]autorelease];
  
  // imageView.image = [UIImage imageNamed:@"no_poster.png"];
  NSLog(@"imageURL: %@", [self.imageUrls objectAtIndex:page]);
  imageView.imageURL = [self.imageUrls objectAtIndex:page];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.clipsToBounds = YES;

  [self.pageViews replaceObjectAtIndex:page withObject:imageView];

  [scrollView addSubview:imageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{  
  // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
  // which a scroll event generated from the user hitting the page control triggers updates from
  // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
  if (pageControlUsed)
  {
    // do nothing - the scroll was initiated from the page control, not the user dragging
    return;
  }
	
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = scrollView.frame.size.width;
  int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

  if(pageControl.currentPage != page) {
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
  }
  
//  double distance_from_center = fabs(pageWidth / 2 - (scrollView.contentOffset.x - page * pageWidth));
//  double relative_distance = (distance_from_center < 30) ? 0 : distance_from_center / (pageWidth / 2);
//  
//  //
//  [self viewForPage:page - 1].alpha = relative_distance;
//  [self viewForPage:page].alpha = 1 - relative_distance;
//  [self viewForPage:page + 1].alpha = relative_distance;

  // Note: A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
  int page = pageControl.currentPage;
	
  // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];
  
	// update the scroll view to the appropriate page
  CGRect frame = scrollView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;
  [scrollView scrollRectToVisible:frame animated:YES];
  
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
  pageControlUsed = YES;
}

@end
