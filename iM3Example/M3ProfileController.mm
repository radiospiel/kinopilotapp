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

-(void)setAction: (NSString*)label
{
  if(!label)
    [self setHidden:YES];
  else
    [self setTitle:label forState:UIControlStateNormal];
}

@end


@implementation M3ProfileController

@synthesize bodyView, imageView;

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


- (void)handleTap:(UITapGestureRecognizer *)sender {     
  NSLog(@"handleTap");
  // if (sender.state == UIGestureRecognizerStateEnded)     {         // handling code     
  // } 
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Do any additional setup after loading the view from its nib.
  if(!self.model) return;
  
  //
  // fill in profile view from data

  headline.text = [ self.model valueForKey: @"title" ];
  dlog << "Loaded movie " << headline.text;
  
  imageView.imageURL = [self.model valueForKey:@"image"];

  [action0 setAction: [self.model valueForKey: @"action0"]];
  [action1 setAction: [self.model valueForKey: @"action1"]];

  BOOL actionsHidden = action0.hidden && action1.hidden;
  description.numberOfLines = actionsHidden ? 5 : 4;
  
  [description setTopAlignedText: [ self.model valueForKey: @"description" ]];
  // [imageView 
  
  UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)] autorelease];
  description.userInteractionEnabled = YES;
  [description addGestureRecognizer:recognizer];
  NSLog(@"*** Attached UITapGestureRecognizer");
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
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
  [bodyController_ release];
  bodyController_ = [controller retain];

  subHeader.text = title;
  
  [self.bodyView addSubview: controller.view];
  CGSize sz = self.bodyView.frame.size;
  
  controller.view.frame = CGRectMake(0, 0, sz.width, sz.height);
  // dlog << "bodyView rectangle: " << recti(bodyView.frame);
  // dlog << "controller.view rectangle: " << recti(controller.view.frame);
} 

@end
