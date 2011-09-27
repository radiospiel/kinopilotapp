//
//  TheatersShowController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "TheatersShowController.h"

@implementation TheatersShowController

- (NSString*)descriptionAsHTML
{
  NSDictionary* model = self.model;

  NSString* name = [model objectForKey:@"name"];

  NSMutableArray* parts = [NSMutableArray array];

  [parts addObject: [NSString stringWithFormat: @"<h2><b>%@</b></h2><br/>", name]];

  void (^addEntry)(NSString*, NSString*) = ^(NSString* name, NSString* key) {
    NSString* value = [model objectForKey:key];
    if(!value) return;
  
    [parts addObject: [NSString stringWithFormat: @"<p><b>%@:</b> %@</p>", name, value]]; 
  };
  
  addEntry(@"Adresse", @"address");
  addEntry(@"Fon", @"telephone");
  // addEntry(@"Email", @"email");
  // addEntry(@"Web", @"website");
  
  return [parts componentsJoinedByString:@""];
}

-(NSArray*)actions
{
  NSMutableArray* actions = _.array();

  NSString* fon = [self.model objectForKey:@"telephone"];
  if(actions.count < 2 && fon) {
    [actions addObject: _.array(@"Fon", fon)];
  }
  NSString* email = [self.model objectForKey:@"email"];
  if(actions.count < 2 && email) {
    [actions addObject: _.array(@"Email", email)];
  }
  NSString* web = [self.model objectForKey:@"website"];
  if(actions.count < 2 && web) {
    [actions addObject: _.array(@"Website", web)];
  }
  
  return actions;
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSString* bodyURL = _.join(@"/movies/list/theater_id=", [self.model objectForKey:@"_uid" ]);
  [self setBodyController: [app viewControllerForURL:bodyURL ] withTitle: @"Filme"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
