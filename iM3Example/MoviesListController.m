//
//  MoviesListController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesListController.h"

@implementation MoviesListController

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

-(void)dealloc
{
  // [segmentedControl_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

-(void)addSegment:(NSString*)label
{
  [segmentedControl_ insertSegmentWithTitle: label
                                    atIndex: 1000     // Add this to the end
                                   animated: NO];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  
  // Do any additional setup after loading the view from its nib.
  segmentedControl_ = [[UISegmentedControl alloc]init];
  segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;
  // segmentedControl_.apportionsSegmentWidthsByContent = YES;
  
  [self addSegment: @"one"];
  [self addSegment: @"two"];
//  [self addSegment: @"three"];
//  [self addSegment: @"four"];
  
  self.navigationItem.titleView = segmentedControl_;
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
