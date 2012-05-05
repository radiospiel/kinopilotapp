//
//  MoviesImagesController.m
//  M3
//
//  Created by Enrico Thierbach on 02.10.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "MoviesImagesController.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

#define PAGE_CONTROL_HEIGHT 24

@interface MoviesImagesView: UIView<UIScrollViewDelegate> {
  UIPageControl *pageControl;
  UIScrollView  *scrollView;
}

@property (nonatomic,retain)          NSMutableArray* pageViews;
@property (assign,nonatomic,readonly) UIButton* closeButton;

@end

@implementation MoviesImagesView

@synthesize pageViews, closeButton;

-(id)initWithFrame: (CGRect)frame
{
  self = [super initWithFrame: frame];
  
  self.pageViews = [NSMutableArray array];

  scrollView = [[UIScrollView alloc]init];
  scrollView.pagingEnabled = YES;
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.bounces = NO;
  scrollView.directionalLockEnabled = YES;
  scrollView.delegate = self;
  [self addSubview:[scrollView autorelease]];
  
  pageControl = [[UIPageControl alloc]init];
  pageControl.backgroundColor = [UIColor colorWithName:@"#60606080"];
  pageControl.layer.borderColor = [UIColor colorWithName:@"#ccc"].CGColor;
  pageControl.layer.borderWidth = 2.0f;
  pageControl.layer.cornerRadius = 11;
  pageControl.userInteractionEnabled = NO;
  [self addSubview:[pageControl autorelease]];
  
  closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0]; // this has a alpha of 0. 
  [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal]; 
  [self addSubview:closeButton];

  return self;
}

-(void)dealloc
{
  self.pageViews = nil;
  [super dealloc];
}

-(void)layoutPageControl
{
  pageControl.hidden = pageControl.numberOfPages < 2;
  
  CGSize viewSz = self.frame.size;
  
  int w = pageControl.numberOfPages * 18 + 46;
  int h = PAGE_CONTROL_HEIGHT;
  
  int x = (viewSz.width - w) / 2;
  int y = viewSz.height - 60;
  
  pageControl.frame = CGRectMake(x, y, w, h);
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  CGSize viewSz = self.frame.size;
  int w = viewSz.width, h = viewSz.height;
  
  // --- Layout pages.

  // Fetch currentPage: the modifications on scrollView.frame results
  // in changing pageControl.currentPage; we need the currentPage
  // as it is set now.
  int currentPage = pageControl.currentPage;

  for(int pageNo=0; pageNo < pageViews.count; ++pageNo) {
    UIView* pageView = [pageViews objectAtIndex: pageNo];
    pageView.frame = CGRectMake(w * pageNo, 0, w, h);
  }
  
  // --- Layout scrollView: the scrollView covers the entire view; its 
  // contents is large enough to hold all pages, where each page is (w x h); 
  // and the content offset points to the current page.
  scrollView.frame = CGRectMake(0,0,w,h);
  scrollView.contentSize = CGSizeMake(w * pageViews.count, h);
  scrollView.contentOffset = CGPointMake(w * currentPage, 0);

  // --- Layout closeButton.
  closeButton.frame = CGRectMake(w-50, 10, 50, 50);
  
  // --- Layout pager
  [self layoutPageControl];
}

-(UIView*)viewForPage: (int)pageNo withImage: (UIImage*)image
{
  // set the content size.
  CGSize viewSz = scrollView.frame.size; 
  int w = viewSz.width, h = viewSz.height;

  scrollView.contentSize = CGSizeMake(w * (pageNo+1), h);
  
  // The view for the new page
  UIView* pageView = [[UIView alloc]initWithFrame:CGRectMake(w * pageNo, 0, w, h)];
  
  // The view in the new page.
  UIImageView* imageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, w, h)];
  imageView.autoresizingMask = (UIViewAutoresizingNone                  |
                                UIViewAutoresizingFlexibleLeftMargin    |
                                UIViewAutoresizingFlexibleWidth         |
                                UIViewAutoresizingFlexibleRightMargin   |
                                UIViewAutoresizingFlexibleTopMargin     |
                                UIViewAutoresizingFlexibleHeight        |
                                UIViewAutoresizingFlexibleBottomMargin);

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
  
  UIView* pageView = [self viewForPage:pageNo withImage:image];
  [scrollView addSubview:pageView];
  [pageViews addObject:pageView];
  
  pageControl.numberOfPages = pageNo+1;
  [self layoutPageControl];
}

#pragma mark --- scrollView delegate

-(UIView*)page: (int)pageNo
{
  if(pageNo < 0 || pageNo >= self.pageViews.count) return nil;
  return [self.pageViews objectAtIndex:pageNo];
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
  
  // A possible optimization would be to unload the pages that are no longer visible
}

@end

@implementation MoviesImagesController

-(BOOL)isFullscreen
{
  return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

#pragma mark - Low memory management

-(void)loadView
{
  MoviesImagesView* moviesImagesView = [[MoviesImagesView alloc]initWithFrame: CGRectMake(0, 0, 320, 460)];
  [moviesImagesView.closeButton addTarget:self 
                                   action:@selector(popNavigationController) 
                         forControlEvents:UIControlEventTouchUpInside];

  self.view = moviesImagesView;
}

-(NSString*)title
{
  return nil;
}

//-(void)setTabBarHidden: (BOOL)hide
//{
//  UITabBarController* tbc = self.tabBarController;
//  
//  // find the tab bars content view.
//	UIView *contentView = [tbc.view.subviews.first isKindOfClass:[UITabBar class]] ?
//    tbc.view.subviews.second :
//  	tbc.view.subviews.first;
//  
//  CGRect targetFrame = tbc.view.bounds;
//
//  if(!hide) {
//    targetFrame.size.height -= tbc.tabBar.frame.size.height;
//  }
//  
//  contentView.frame = targetFrame;
//  tbc.tabBar.hidden = hide;
//}

-(void)popNavigationController
{
  [SVProgressHUD dismiss]; // just in case...
  [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray*)imageURLs
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"]; 

  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  NSArray* images = [movie objectForKey:@"images"];
  if(images) return images;
  
  NSString* image = [movie objectForKey:@"image"];
  if(image) return [NSArray arrayWithObject: image];
  
  return nil;
}

- (void)reloadURL
{
  NSArray* imageURLs = [self imageURLs];
  if(!imageURLs) return;
  
  M3CachedFactory* factory = [UIImage cachedImagesWithURL]; 
  
  CGSize imageSize = CGSizeMake(480, 460);
  
  for(NSString* url in imageURLs) {
    [factory buildAsync:[M3 imageURL: url forSize: imageSize]
             withTarget:self.view 
            andSelector:@selector(addImage:)];
  }

  [SVProgressHUD show];
}

@end
