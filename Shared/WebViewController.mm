//
//  WebViewController.m
//  M3
//
//  Created by Enrico Thierbach on 14.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppBase.h"
#import "WebViewController.h"

@implementation WebViewController

#pragma mark - View lifecycle

-(void)loadView
{
  [super loadView];
  
  webView = [[UIWebView alloc]init];
  [self.view coverWithSubview: webView];
}

-(void)reload
{
  if(!self.url) return;

  // Create a NSURLRequest object and load it in the webView.
  NSURLRequest *request = [NSURLRequest requestWithURL:self.url.to_url];
  [webView loadRequest:request];                               
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

-(NSString*)title
{
  return nil;
}

@end
