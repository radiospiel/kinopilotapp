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

- (void)viewDidLoad
{
  // --- get image URLs from movie object

  [self.url matches:@"/movies/images/(.*)"];
  NSString* movie_id = $1;
  
  NSDictionary* movie = [app.chairDB.movies get: movie_id];
  
  NSArray* images = [movie objectForKey:@"images"];
  
  NSArray* fullsize_urls = [images pluck: @"fullsize"];
  NSArray* thumbnail_urls = [images pluck: @"thumbnail"];
  
  self.imageUrls = fullsize_urls;
  
  // --- fill the pageViews array with NSNull placeholders.

  self.pageViews = [fullsize_urls mapUsingBlock:^id(id obj) {
    return [NSNull null];
  }];

  // --- wire up scrollview and pager
  
  CGRect frame = scrollView.frame;
  
  scrollView.pagingEnabled = YES;
  scrollView.contentSize = CGSizeMake(frame.size.width * self.pageViews.count, frame.size.height);
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.directionalLockEnabled = YES;
  scrollView.delegate = self;
  
  pageControl.numberOfPages = thumbnail_urls.count;
  pageControl.currentPage = 0;
  
  frame = pageControl.frame;
  frame.size.width = pageControl.numberOfPages * 18 + 46;
  frame.origin.x = (320 - frame.size.width)/2;
  frame.size.height = 24;
  pageControl.frame = frame;
  
  pageControl.backgroundColor = [UIColor colorWithName:@"#60606080"];
  pageControl.layer.borderColor = [UIColor colorWithName:@"#ccc"].CGColor;
  pageControl.layer.borderWidth = 2.0f;
  pageControl.layer.cornerRadius = 11;
  pageControl.userInteractionEnabled = NO;
  
  // --- load pages
  
  [self loadScrollViewWithPage:0]; // load first page
  [self loadScrollViewWithPage:1]; // preload second page

  // --- hide the tabbar

  // [self setTabBarHidden: YES];
}

- (void)dealloc
{
  [scrollView release];
  [pageControl release];
  
  self.pageViews = nil;
  self.imageUrls = nil;
  
  [super dealloc];
}

- (void)loadScrollViewWithPage:(int)page
{
  if (page < 0 || page >= self.pageViews.count)
    return;

  // replace the placeholder in the oageViews array.
  UIView* placeholder = [self.pageViews objectAtIndex:page];
  if(![placeholder isKindOfClass:[NSNull class]]) return;

  CGRect frame = scrollView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;

  UIImageView* imageView = [[UIImageView alloc]initWithFrame: frame];
  
  imageView.image = [UIImage imageNamed:@"no_poster.png"];
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

  if(pageControl.currentPage == page) return;
  
  pageControl.hidden = YES;
//  
//  if(pageControl.currentPage != page) {
//    pageControl.currentPage = page;
//    pageControl.alpha = 1;
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                       pageControl.alpha = 0;
//                     }];
//  }
  
  // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];
  
  // A possible optimization would be to unload the views+controllers which are no longer visible
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
