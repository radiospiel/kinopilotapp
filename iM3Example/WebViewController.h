//
//  WebViewController.h
//  M3
//
//  Created by Enrico Thierbach on 14.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController {
  IBOutlet UIWebView* webView;
}

-(void)loadUrl: (NSString*)url;

@end
