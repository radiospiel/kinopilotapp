//
//  WebViewController.h
//  M3
//
//  Created by Enrico Thierbach on 14.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//


#import "M3ViewController.h"

@interface WebViewController : M3ViewController {
  IBOutlet UIWebView* webView;
}

-(void)loadUrl: (NSString*)url;

@end
