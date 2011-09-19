//
//  MovieController.m
//  M3
//
//  Created by Enrico Thierbach on 16.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3.h"
#import "ProfileController.h"

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


@implementation ProfileController

@synthesize data = data_, isLandscape = isLandscape_;

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
  if(!data_) return;

  //
  // fill in profile view from data

  headline.text = [ data_ valueForKey: @"title" ];
  
  if([data_ valueForKey:@"img"]) {
    NSData* data = [M3Http requestData: @"GET" 
                                   url: [data_ valueForKey:@"img"] 
                           withOptions: nil];
    imageView.image = [UIImage imageWithData:data];
  }

  [action0 setAction: [data_ valueForKey: @"action0"]];
  [action1 setAction: [data_ valueForKey: @"action1"]];

  BOOL actionsHidden = action0.hidden && action1.hidden;
  if([self isLandscape])
    description.numberOfLines = actionsHidden ? 6 : 5;
  else
    description.numberOfLines = actionsHidden ? 5 : 4;
  
  [description setTopAlignedText: [ data_ valueForKey: @"description" ]];
  // [imageView 
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
