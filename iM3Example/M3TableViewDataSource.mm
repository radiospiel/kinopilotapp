#import "M3.h"

#import "M3TableViewCell.h"
#import "M3TableViewDataSource.h"

@implementation M3TableViewDataSource

@synthesize controller = controller_, sections = sections_;

-(id)init
{
  self = [super init];
  self.sections = [[NSMutableArray alloc]init];
  return self;
}

-(void)dealloc
{
  self.sections = nil;
  [super dealloc];
}

-(void)addSection:(NSArray*) keys withOptions: (NSDictionary*) options
{
  M3AssertKindOf(keys, NSArray);
  if(options) M3AssertKindOf(options, NSDictionary);    // Note: options is allowed to be nil.
  
  NSArray* section = [NSArray arrayWithObjects: keys, options, nil];
  [self.sections addObject: section];
}

#pragma mark - UITableViewDataSource customization

-(id)modelWithKey:(id)key
{
  return key;
}

-(Class) cellClassForKey: (id)key
{
  return [M3TableViewCell class];
}

#pragma mark - UITableViewDataSource implementations: sections, indices

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.sections objectAtIndex:sectionNo]; 
  return [section.first count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.sections objectAtIndex:sectionNo]; 
  return [section.second objectForKey:@"header"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.sections objectAtIndex:sectionNo]; 
  return [section.second objectForKey:@"footer"];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  return [self.sections mapUsingBlock:^id(NSArray* section) {
    return [section.second objectForKey: @"index"];
  }];
}

- (NSInteger)tableView:(UITableView *)tableView 
    sectionForSectionIndexTitle:(NSString *)title 
               atIndex:(NSInteger)index
{
  return index;
}

#pragma mark - UITableViewDataSource implementations: cells */

- (id)keyForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* section = [self.sections objectAtIndex:indexPath.section]; 
  return [section.first objectAtIndex:indexPath.row];
}

-(Class) cellClassForRowAtIndexPath: (NSIndexPath*)indexPath
{
  id key = [self keyForRowAtIndexPath:indexPath];
  return [self cellClassForKey:key];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Class klass = [self cellClassForRowAtIndexPath: indexPath];
  
  CGFloat height = [klass fixedHeight]; 
  if(height) return height;
  
  M3TableViewCell* cell = (M3TableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
  return [cell wantsHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Class klass = [self cellClassForRowAtIndexPath: indexPath];
  NSString* klassName = NSStringFromClass(klass);
  
  // get a reusable or create a new table cell
  M3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: klassName];
  if (!cell) {
    cell = [[[klass alloc]init]autorelease];
    M3AssertKindOf(cell, M3TableViewCell);
  }
  
  cell.tableViewController = self.controller;
  cell.indexPath = indexPath;
  
  id key = [self keyForRowAtIndexPath: indexPath ];
  cell.key = key;
  cell.model = [self modelWithKey: key];
  
  return cell;
}

@end
