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

@synthesize bodyView, imageView, descriptionView=description;

-(void)dealloc
{
  // dlog << "Dealloc " << _.ptr(self);

  [bodyController_ release];
  bodyController_ = nil;
  
  [self releaseM3Properties];
  
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (NSString*)descriptionAsHTML
{
  return @"<p>Please add a descriptionAsHTML implementation!</p>";
}

-(NSArray*)actions
{
  return _.array(_.array("Google", "http://google.com"));
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Do any additional setup after loading the view from its nib.
  if(!self.model) return;
  
  //
  // --- set image
  
  imageView.imageURL = [self.model objectForKey:@"image"];

  // -- set actions ---------------------------------------------------
  
  NSArray* actions = [self actions];
  for(int i=0; i<2; ++i) {
    UIButton* actionButton = i == 0 ? action0 : action1;
    if(i >= actions.count) {
      [actionButton setHidden:YES];
      continue;
    }

    NSArray* action = [actions objectAtIndex:i];
    
    [actionButton setHidden:NO];
    [actionButton setActionURL: action.second andTitle:action.first];
  }

  // --- set description ---------------------------------------------------
  description.numberOfLines = actions.count ? 4 : 5;
  description.text = [NSAttributedString attributedStringWithSimpleMarkup: [self descriptionAsHTML]];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  dlog << "Releasing bodyController_ " << bodyController_;
  
  [bodyController_ release];
  bodyController_ = nil;
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

#pragma mark - Body Controller

-(void)setBodyController: (UIViewController*)controller withTitle: (NSString*)title
{
  [controller retain];
  [bodyController_ release];
  bodyController_ = controller;

  [self.bodyView addSubview: controller.view];
  CGSize sz = self.bodyView.frame.size;
  
  controller.view.frame = CGRectMake(0, 0, sz.width, sz.height);
}

@end
