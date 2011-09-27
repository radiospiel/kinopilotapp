//
//  MovieController.m
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "M3ProfileController.h"

static NSString* recti(CGRect rect)
{
  return [NSString stringWithFormat: @"(%d,%d+%d+%d)", 
    (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height];
}

@interface UILabel(M3Utilities)

-(void)setTopAlignedText: (NSString*)text;
@end

@implementation UILabel(M3Utilities)

-(void)setTopAlignedText: (NSString*)text
{
  //
  // Get the font's height.
  float lineHeight = [text sizeWithFont:self.font].height;
  
  //
  // The text might not fill the number of lines as set in the label.
  // Calculate the size actually needed, and resize the label accordingly.
  CGSize stringSize = [text sizeWithFont:self.font
                       constrainedToSize:CGSizeMake(self.frame.size.width, lineHeight * self.numberOfLines) 
                           lineBreakMode:self.lineBreakMode];
  
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, stringSize.height);

  // Finally set the text.
  [self setText:text];
}

@end


@implementation UIButton(M3Utilities)

-(void)setAction: (NSString*)label withURL: (NSString*)url
{
  [self setHidden:NO];
  [self setTitle:label forState:UIControlStateNormal];
  [self onTapOpen: url];
}

-(void)setAction: (NSArray*)action
{
  [self setAction: action.first withURL: action.last];
}
@end

@implementation M3ProfileController

@synthesize bodyView, imageView, descriptionView=description;

-(void)dealloc
{
  dlog << "Dealloc " << _.ptr(self);

  [bodyController_ release];
  bodyController_ = nil;
  
  [self releaseM3Properties];
  
  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
  
  [action0 setHidden:YES];
  [action1 setHidden:YES];
  
  switch(actions.count) {
    case 2:   [action1 setAction: [actions objectAtIndex: 1]];
              /* fall thru */
    case 1:   [action0 setAction: [actions objectAtIndex: 0]];
              /* fall thru */
    default:  (void)0;  
  };

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
  // dlog << "bodyView rectangle: " << recti(bodyView.frame);
  // dlog << "controller.view rectangle: " << recti(controller.view.frame);
} 

@end
