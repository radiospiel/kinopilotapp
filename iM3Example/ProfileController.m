//
//  MovieController.m
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "ProfileController.h"

@interface UILabel(M3Utilities)

-(void)setTopAlignedText: (NSString*)text;
@end

@implementation UILabel(M3Utilities)

-(void)setTopAlignedText: (NSString*)text
{
  CGSize stringSize = [text sizeWithFont:self.font
                       constrainedToSize:self.frame.size 
                           lineBreakMode:self.lineBreakMode];
  
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, stringSize.width, stringSize.height);
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


@implementation ProfileController

@synthesize data = data_, isHorizontal = isHorizontal_;

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

  NSLog(@"viewDidLoad: data is %@", data_);
  
  // Do any additional setup after loading the view from its nib.
  if(data_) {
    [action0 setAction: [data_ valueForKey: @"action0"]];
    [action1 setAction: [data_ valueForKey: @"action1"]];

    BOOL actionsHidden = action0.hidden && action1.hidden;
    if([self isHorizontal])
      description.numberOfLines = actionsHidden ? 5 : 3;
    else
      description.numberOfLines = actionsHidden ? 6 : 5;
      
    [headline setTopAlignedText: [ data_ valueForKey: @"title" ]];
    [description setTopAlignedText: [ data_ valueForKey: @"description" ]];
  }
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
  // 
  //   // Return YES for supported orientations
  // if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
  //     return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  // } else {
  //     return YES;
  // }
}

@end
