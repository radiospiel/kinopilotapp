//
//  M3TableViewController.h
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M3TableViewCell.h"

/*
 * A M3TableViewController to work with M3TableViewCells. It adds an 
 * additional segmented control, which allows for filtering the 
 * table view. 
 */

@interface M3TableViewController : UITableViewController {
  Class classForCells_;
  UISegmentedControl* segmentedControl_;
  NSMutableArray* segmentURLs_;
}

// returns an array of keys for this table.
- (NSArray*)keys;

// returns the model for a specific key
-(NSDictionary*)modelWithKey:(id)key;

/*
 * returns the URL for a specific key.
 *
 * If a row is tapped, and this method returns an URL for the row's key,
 * the app delegate will be asked to open that URL.
 */
-(NSString*)urlWithKey:(id)key;

/*
 * returns the class of the table view cell at position indexPath
 */
- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)addSegment:(NSString*)label withURL: (NSString*)url;
-(void)showSegmentedControl;

@end


