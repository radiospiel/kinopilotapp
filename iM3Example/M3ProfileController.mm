//
//  MovieController.m
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3ProfileController.h"

@implementation M3ProfileController

@synthesize imageView = imageView_;
@synthesize htmlDescription = htmlDescription_;

-(id)init
{
  self = [super init];
  NSLog(@"init ok.");
  NSLog(@"self is: %@", self);


  // IBOutlet UIImageView* imageView_;
  // IBOutlet TTTAttributedLabel* descriptionView_;
  // IBOutlet UIButton* actionButton0_;
  // IBOutlet UIButton* actionButton1_;

  // IBOutlet UIView* bodyView_;
  
  // UIViewController* bodyController_;

  // NSArray* actions_;
  // NSString* htmlDescription_;


  return self;
}

-(void)dealloc
{
  self.htmlDescription = nil;
  
  [bodyController_ release];
  bodyController_ = nil;
  
  [self releaseM3Properties];

  [super dealloc];
}

-(UIView*) headerView
{
  return nil;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
    
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)setUrl:(NSString *)url
{
  [super setUrl:url];
}

// -- set actions ---------------------------------------------------

-(NSArray*)actions
{
  return actions_;
}

-(void)setActions: (NSArray*)actions
{
  [actions retain];
  [actions_ release];
  actions_ = actions;

  for(int i=0; i<2; ++i) {
    UIButton* actionButton = i == 0 ? actionButton0_ : actionButton1_;
    if(i >= actions.count) {
      [actionButton setHidden:YES];
      continue;
    }
    
    NSArray* action = [actions objectAtIndex:i];
    
    [actionButton setHidden:NO];
    [actionButton setActionURL: action.second andTitle:action.first];
  }
}

-(NSString*)htmlDescription
{
  return htmlDescription_;
}

-(void)setHtmlDescription: (NSString*)htmlDescription
{
  [htmlDescription retain];
  [htmlDescription_ release];
  htmlDescription_ = htmlDescription;
  
  descriptionView_.numberOfLines = self.actions.count ? 4 : 5;
  descriptionView_.text = [NSAttributedString attributedStringWithSimpleMarkup: htmlDescription];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
  // 
  //   // Return YES for supported orientations
  // if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
  //     return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  // } else {
  //     return YES;
  // }
}

-(void)viewDidLoad
{
  self.url = self.url;
  [super viewDidLoad];
}

#pragma mark - Body Controller

-(void)setBodyController: (UIViewController*)controller withTitle: (NSString*)title
{
  [controller retain];
  [bodyController_ release];
  bodyController_ = controller;

  [bodyView_ addSubview: controller.view];
  CGSize sz = bodyView_.frame.size;
  
  controller.view.frame = CGRectMake(0, 0, sz.width, sz.height);
}

@end
