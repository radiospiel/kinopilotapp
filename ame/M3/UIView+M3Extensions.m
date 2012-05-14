//
//  UIView+M3Extensions.m
//  M3
//
//  Created by Enrico Thierbach on 24.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
#import "UIView+M3Extensions.h"

#import <QuartzCore/QuartzCore.h>

/**** some layer properties ******************************************/

@implementation UIView (M3Extensions)

-(UIColor*) borderColor;
{
  CGColorRef cgColor = self.layer.borderColor;
  return [UIColor colorWithCGColor: cgColor];
}

-(void) setBorderColor: (UIColor*) borderColor;
{
  self.layer.borderColor = borderColor.CGColor;
}

-(float) borderWidth
{
  return self.layer.borderWidth;
}

-(void) setBorderWidth: (float)width
{
  self.layer.borderWidth = width;
}

@end

/**** Opening URLs ***************************************************/

@interface M3URLOpener: NSObject
@property (nonatomic,copy) NSString* url;
@end

@implementation M3URLOpener

@synthesize url;

-(id)initWithURL: (NSString*)targetURL
{
  self = [super init];
  self.url = targetURL;
  return self;
}

-(void)dealloc
{
  self.url = nil;
  [super dealloc];
}

-(void)openURL
{
  [M3 open: self.url];
}

@end

@interface M3UITapGestureRecognizer: UITapGestureRecognizer
@property (nonatomic,retain) M3URLOpener* urlOpener;
@end

@implementation M3UITapGestureRecognizer
@synthesize urlOpener;
@end

@implementation UIView(M3URLOpener)

-(void)onTapOpen: (NSString*)url
{
  self.userInteractionEnabled = YES;

  M3URLOpener* target = [[M3URLOpener alloc]initWithURL: url];

  M3UITapGestureRecognizer* recognizer;
  recognizer = [[M3UITapGestureRecognizer alloc]initWithTarget:target 
                                                        action:@selector(openURL)];
  recognizer.urlOpener = [target autorelease];
  [self addGestureRecognizer:[recognizer autorelease]];
}

@end

@implementation UIView (CoverWithSubview)

-(void)coverWithSubview: (UIView*)subView;
{
  CGRect frame = self.frame;
  frame.origin.x = frame.origin.y = 0;

  subView.frame = frame;
  subView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin    |
                              UIViewAutoresizingFlexibleWidth         |
                              UIViewAutoresizingFlexibleRightMargin   |
                              UIViewAutoresizingFlexibleTopMargin     |
                              UIViewAutoresizingFlexibleHeight        |
                              UIViewAutoresizingFlexibleBottomMargin);

  [self addSubview:subView];
}
@end


@implementation UIView (Webview)

-(void)disableScrollingInWebview
{
  for (id subview in self.subviews) {
    if ([[subview class] isSubclassOfClass: [UIScrollView class]])
      ((UIScrollView *)subview).bounces = NO;
  }
}

@end
