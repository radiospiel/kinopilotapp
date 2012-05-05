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

@interface MoviesImagesView: UIView<UIScrollViewDelegate> 

@property (nonatomic,retain) NSMutableArray *pages;

@property (assign,nonatomic,readonly) UIScrollView  *scrollView;
@property (assign,nonatomic,readonly) UIPageControl *pageControl;
@property (assign,nonatomic,readonly) UIButton      *closeButton;

@end

@implementation MoviesImagesView

@synthesize scrollView, pageControl, closeButton, pages;

-(id)initWithFrame: (CGRect)frame
{
  self = [super initWithFrame: frame];
  
  self.pages = [NSMutableArray array];

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
  closeButton.frame = CGRectMake(270, 10, 50, 50);
  closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0]; // this has a alpha of 0. 
  [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal]; 
  
  [self addSubview:closeButton];


  return self;
}

-(void)dealloc
{
  self.pages = nil;
  [super dealloc];
}

-(void)layoutPageControl
{
  pageControl.hidden = pageControl.numberOfPages < 2;
  
  int w = pageControl.numberOfPages * 18 + 46;
  int h = PAGE_CONTROL_HEIGHT;
  
  int x = (320 - w) / 2;
  int y = 400;
  
  pageControl.frame = CGRectMake(x, y, w, h);
}

-(void)layoutSubviews
{
  dlog << "layoutSubviews";
  [super layoutSubviews];
  
  CGSize viewSize = self.frame.size;
  CGRect frame = CGRectMake(0,0,viewSize.width,viewSize.height);
  scrollView.frame = frame;
  pageControl.frame = CGRectMake(30, 100, 300, 100);

  [self layoutPageControl];
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
  [pages addObject:page];
  
  pageControl.numberOfPages = pageNo+1;
  [self layoutPageControl];
}

#pragma mark --- scrollView delegate

-(UIView*)page: (int)pageNo
{
  if(pageNo < 0 || pageNo >= pages.count) return nil;
  return [pages objectAtIndex:pageNo];
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


@end

@interface MoviesImagesController (PrivateMethods)
- (void)scrollViewDidScroll:(UIScrollView *)sender;
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

- (void)viewDidLoad
{
  NSLog(@"**** viewDidLoad: ***********************");
  
  [super viewDidLoad];
}

//
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
  dlog << "popNavigationController";
  
  [SVProgressHUD dismiss]; // just in case...
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadURL
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"]; 

  NSDictionary* movie = [app.sqliteDB.movies get: movie_id];
  NSArray* images = [movie objectForKey:@"images"];
  if(!images) {
    NSString* image = [movie objectForKey:@"image"];
    if(image) {
      images = [NSMutableArray arrayWithObject: image];
    }
  }
  
  if(!images) return;
  
  M3CachedFactory* factory = [UIImage cachedImagesWithURL]; 
  
  for(NSString* url in images) {
    [factory buildAsync:[M3 imageURL: url forSize: self.view.frame.size]
             withTarget:self.view 
            andSelector:@selector(addImage:)];
  }

  [SVProgressHUD show];
}

@end
