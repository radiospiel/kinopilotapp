//
//  M3TableViewController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface M3TableViewController : UITableViewController {
  Class classForCells_;
  UISegmentedControl* segmentedControl_;
  NSMutableArray* segmentURLs_;
}

@property (assign,nonatomic) Class classForCells;

// returns an array of keys for this table.
- (NSArray*)keys;

// returns the model for a specific key
-(NSDictionary*)modelWithKey:(id)key;

// returns the URL for a specific key
-(NSString*)urlWithKey:(id)key;

-(void)addSegment:(NSString*)label withURL: (NSString*)url;
-(void)showSegmentedControl;

@end
