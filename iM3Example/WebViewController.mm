//
//  WebViewController.m
//  M3
//
//  Created by Enrico Thierbach on 14.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "WebViewController.h"

#include "Underscore.hh"

@implementation WebViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.

  dlog << "viewDidLoad, url is " << self.url;
  if(!self.url) return;

  NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url.to_url];   // URL Requst Object
  [webView loadRequest:requestObj];                               // Load the request in the UIWebView.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
    // Return YES for supported orientations
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSString*)title
{
  return nil;
}

@end
