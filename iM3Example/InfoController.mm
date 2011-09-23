//
//  InfoController.m
//  M3
//
//  Created by Enrico Thierbach on 23.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import "InfoController.h"


@implementation InfoController

-(id)init
{
  self = [super initWithStyle: UITableViewStyleGrouped];
  if(self) {
    
  }
  
  return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  infoSection_ = [[app.config objectForKey: @"info"]retain];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
 
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return infoSection_.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNo
{
  NSDictionary* section = [infoSection_ objectAtIndex:sectionNo];
  return [section objectForKey:@"header"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionNo
{
  NSDictionary* section = [infoSection_ objectAtIndex:sectionNo];
  return [section objectForKey:@"footer"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionNo
{
  NSDictionary* section = [infoSection_ objectAtIndex:sectionNo];
  
  // NSString* title = [section objectForKey:@"title"];
  // NSString* header = [section objectForKey:@"header"];
  // NSString* footer = [section objectForKey:@"footer"];
  NSArray* content = [section objectForKey:@"content"];
  
  return content.count;
}

-(NSArray*)contentRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary* section = [infoSection_ objectAtIndex: indexPath.section];
  
  id row = [[section objectForKey:@"content"]objectAtIndex:indexPath.row];
  
  if([row isKindOfClass:[NSString class]])
    return [NSArray arrayWithObject:row];

  return row;
}

-(UIFont*) regularFont 
{
  return [UIFont systemFontOfSize:13];
}

-(NSString*)resolveCustomValue: (NSString*)name
{
  SEL selector = NSSelectorFromString(name);
  if(![self respondsToSelector: selector]) 
    return name;
  
  return [self performSelector:selector];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  
  NSArray* row = [self contentRowAtIndexPath: indexPath];
  
  switch(row.count) {
    case 2:
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
      cell.textLabel.text = row.first;
      cell.textLabel.textColor = [UIColor colorWithName: @"#000"];
      cell.detailTextLabel.text = [self resolveCustomValue: row.last];
      cell.detailTextLabel.font = [self regularFont];
      cell.detailTextLabel.textColor = [UIColor colorWithName: @"#385487"];
      break;
    case 1:
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
      cell.textLabel.text = row.first;
      cell.textLabel.font = [self regularFont];
      cell.textLabel.numberOfLines = 0;
      cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
      cell.textLabel.textAlignment = UITextAlignmentCenter;
      break;
  }
  
  // Configure the cell...

  return cell;
}

-(NSString*)title
{
  return [app.config objectForKey: @"name"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* row = [self contentRowAtIndexPath: indexPath];
  if(row.count == 2)
    return 35;
  
  NSString* text = row.first;

  CGSize stringSize = [text sizeWithFont:[self regularFont]
                       constrainedToSize:CGSizeMake(260, 9999) 
                           lineBreakMode:UILineBreakModeWordWrap ];

  return stringSize.height + 10;
}

// --- Custom values ---------

-(NSString*) updated_at
{
  return @"updated_at";
}

-(NSString*) theaters_count
{
  return [NSString stringWithFormat: @"%d", app.chairDB.theaters.count];
}

-(NSString*) movies_count
{
  return [NSString stringWithFormat: @"%d", app.chairDB.movies.count];
}

-(NSString*) schedules_count
{
  return [NSString stringWithFormat: @"%d", app.chairDB.schedules.count];
}

-(NSString*) build_at
{
  return [NSString stringWithFormat: @"%s %s", __DATE__, __TIME__];
}

@end
