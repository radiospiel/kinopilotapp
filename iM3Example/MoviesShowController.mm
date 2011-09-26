//
//  MoviesShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesShowController.h"
#import "AppDelegate.h"

@implementation MoviesShowController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSString* bodyURL = _.join(@"/theaters/list/movie_id=", [self.model objectForKey:@"_uid" ]);
  [self setBodyController: [app viewControllerForURL:bodyURL ] withTitle: @"Kinos"];
  
  // Show full info on a tap on tap on imageView and description
  UITapGestureRecognizer *recognizer;
  recognizer = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFullInfo)] autorelease];
  [self.imageView addGestureRecognizer:recognizer];
  self.imageView.userInteractionEnabled = YES;

  recognizer = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openFullInfo)] autorelease];
//  [self.description addGestureRecognizer:recognizer];
}

-(void) openFullInfo
{
  dlog << "==> openFullInfo";
  
  NSString* url = [self.url stringByReplacingOccurrencesOfString:@"/movies/show" withString:@"/movies/full"];
  [app open: url];
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

@end
