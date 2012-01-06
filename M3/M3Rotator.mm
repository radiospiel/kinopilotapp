//
//  M3Rotator.m
//  M3
//
//  Created by Enrico Thierbach on 24.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"

#define ROTATION_INTERVAL 2.5

@interface M3Rotator()

@property (nonatomic,retain) UIView* viewOnTop;
@property (nonatomic,retain) UIView* viewBelowTop;
@property (nonatomic,assign) NSUInteger currentIndex;

@end

@implementation M3Rotator

@synthesize viewOnTop, viewBelowTop, delegate, currentIndex;

-(id)initWithFrame: (CGRect)frame
{
  self = [super initWithFrame: frame];
  
  self.currentIndex = -1;
  
  UITapGestureRecognizer* recognizer = 
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
  [self addGestureRecognizer: [recognizer autorelease]];

  return self;
}

-(void)dealloc
{
  self.viewOnTop = nil;
  self.viewBelowTop = nil;
  self.delegate = nil;
  
  [super dealloc];
}

-(void)stackOnTop: (UIView*)view
{
  view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  view.clipsToBounds = YES;
  [view layoutSubviews];
  
  [viewBelowTop removeFromSuperview];
  viewBelowTop = viewOnTop;
  [self addSubview: view];
  
  viewOnTop = view;
  
  viewOnTop.alpha = 0.0;
  viewBelowTop.alpha = 1.0;
  // 
  // 
  [UIView animateWithDuration:0.3
                   animations:^{ viewOnTop.alpha = 1.0; viewBelowTop.alpha = 0.0; }
                   completion:^(BOOL finished) { }
   ];
}

-(void)advance: (int)step
{
  NSUInteger numberOfViewsInRotator = [delegate numberOfViewsInRotator: self];
  if(numberOfViewsInRotator <= 1) return;
  
  currentIndex = (numberOfViewsInRotator + currentIndex + step) % numberOfViewsInRotator;
  UIView* view = [delegate rotator: self viewForItemAtIndex: currentIndex];
  [self stackOnTop: view];
}

-(void)showNext
{
  [self advance: 1];
}

-(void)showPrev
{
  [self advance: -1];
}

-(void)start
{
  NSUInteger numberOfViewsInRotator = [delegate numberOfViewsInRotator: self];

  // set current index
  currentIndex = numberOfViewsInRotator > 1 ? rand() % numberOfViewsInRotator : 0;
  
  [self showNext];
  
  [M3Timer timerWithTimeInterval: ROTATION_INTERVAL
                          target: self
                        selector: @selector(showNext)
                        userInfo: nil
                         repeats: YES];
}

-(void)handleTap:(UITapGestureRecognizer *)sender 
{
  id del = delegate;
  
  if(![del respondsToSelector:@selector(rotator:activatedIndex:)])
    return;

  [delegate rotator:self activatedIndex: currentIndex];
}


@end

// -- Image rotor -------------------------------------------------------

@interface M3ImageRotator()<M3RotatorDelegate>

@property (nonatomic,retain) UIImageView* backgroundImageView;

- (UIImageView *)imageViewWithImage:(UIImage*)image;

@end

@implementation M3ImageRotator

@synthesize imageURLs, backgroundImageView;

-(id)initWithFrame: (CGRect)frame
{
  self = [super initWithFrame: frame];
  self.delegate = self;
  
  UIImage* no_poster = [UIImage imageNamed:@"no_poster.png"];
  self.backgroundImageView = [self imageViewWithImage: no_poster];
  [self addSubview:backgroundImageView];
  
  return self;
}

-(NSArray*)imageURLs
{
  return imageURLs;
}

-(void)setImageURLs:(NSArray *)urls
{
  NSMutableArray* array = [[NSMutableArray alloc]init];
  imageURLs = array;

  M3CachedFactory* factory = [UIImage cachedImagesWithURL];
  
  for(NSString* url in urls) {
    NSString* urlForSize = [M3 imageURL:url forSize: self.frame.size];

    [factory buildAsync:urlForSize
           withCallback:^(UIImage* image, BOOL didExist) {
             if(self.backgroundImageView) {
               [self.backgroundImageView removeFromSuperview];
               self.backgroundImageView = nil;
             }

             [array addObject: url];
           }];
  }
}

- (NSUInteger)numberOfViewsInRotator: (M3Rotator*)rotator
{
  return imageURLs.count == 0 ? 1 : imageURLs.count;
}

- (UIImageView *)imageViewWithImage:(UIImage*)image;
{
  CGSize sz = self.frame.size;
  
  UIImageView* imageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, sz.width, sz.height)];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.clipsToBounds = YES;
  imageView.image = image;
  
  return [imageView autorelease];
}

- (UIView *)rotator:(M3Rotator*)rotator viewForItemAtIndex:(NSUInteger)index;
{
  UIImage* image = nil;
  
  if(imageURLs.count > index) {
    M3CachedFactory* factory = [UIImage cachedImagesWithURL];
    image = [factory build: [imageURLs objectAtIndex:index]];
  }
  
  if(!image)
    image = [UIImage imageNamed:@"no_poster.png"];

  return [self imageViewWithImage: image];
}

-(void)dealloc
{
  self.imageURLs = nil;
  self.backgroundImageView = nil;
  
  [super dealloc];
}

@end
