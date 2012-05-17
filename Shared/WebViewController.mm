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

-(void)reload
{
  if(!self.url) return;

  if(!webView) {
    webView = [[UIWebView alloc]init];
    [self.view coverWithSubview: webView];
  }

  // Create a NSURLRequest object and load it in the webView.
  NSURLRequest *request = [NSURLRequest requestWithURL:self.url.to_url];
  [webView loadRequest:request];
}

// If the view gets unloaded, then the webview gets unloaded as well,
// which makes the webView instance variable a dangling pointer.
-(void)viewDidUnload
{
  webView = nil;
}

-(void)setUrl:(NSString *)url
{
  [super setUrl:url];
  [self reload];
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
