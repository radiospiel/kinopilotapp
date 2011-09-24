//
//  MoviesFullController.m
//  M3
//
//  Created by Enrico Thierbach on 24.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesFullController.h"

@implementation MoviesFullController

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

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view from its nib.

  NSDictionary* model = self.model;
  
  titleLabel.text = [model objectForKey:@"title"];
  imageView.imageURL = [model objectForKey:@"image"];
  
  NSString* body = [model objectForKey:@"description"];
  NSString* html = [NSString stringWithFormat: @"<html><body>%@</body></html>", body];

  [detailWebView loadHTMLString: body baseURL: [NSURL URLWithString:@"/"]];
  [detailWebView setOpaque:NO]; 
  detailWebView.backgroundColor = [UIColor clearColor];
  
  [bodyWebView loadHTMLString: html baseURL: [NSURL URLWithString:@"/"]];
  [bodyWebView setOpaque:NO]; 
  bodyWebView.backgroundColor = [UIColor clearColor];

  // Close this view on a tap
  UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissModalViewController)] autorelease];
  [self.view addGestureRecognizer:recognizer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSString*)title
{
  return nil;
}


-(BOOL) shouldOpenModally
{
  return YES;
}

@end
