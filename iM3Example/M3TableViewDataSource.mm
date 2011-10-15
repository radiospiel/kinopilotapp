#import "M3.h"

#import "M3TableViewCell.h"
#import "M3TableViewDataSource.h"

@implementation M3TableViewDataSource

@synthesize controller = controller_, sections = sections_;

-(id)init
{
  self = [super init];
  self.sections = [NSMutableArray array];
  return self;
}

-(void)dealloc
{
  self.sections = nil;
  [super dealloc];
}

-(NSString*)inspect
{
  return [NSString stringWithFormat: @"<%@ @ 0x%08x: %d sections>", NSStringFromClass([self class]), self, self.sections.count];
}

-(void)addSection:(NSArray*) keys withOptions: (NSDictionary*) options
{
  M3AssertKindOf(keys, NSArray);
  if(options) M3AssertKindOf(options, NSDictionary);    // Note: options is allowed to be nil.
  
  NSArray* section = [NSArray arrayWithObjects: keys, options, nil];
  [self.sections addObject: section];
}

-(void)prependSection:(NSArray*) keys withOptions: (NSDictionary*) options
{
  M3AssertKindOf(keys, NSArray);
  if(options) M3AssertKindOf(options, NSDictionary);    // Note: options is allowed to be nil.
  
  NSArray* section = [NSArray arrayWithObjects: keys, options, nil];
  [self.sections insertObject:section atIndex:0];
}

#pragma mark - UITableViewDataSource customization

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
  if(self.sections.count < 7) return nil;
  
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

#pragma mark - UITableViewDataSource implementations: cells

- (id)keyForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* section = [self.sections objectAtIndex:indexPath.section]; 
  return [section.first objectAtIndex:indexPath.row];
}

-(Class) cellClassForRowAtIndexPath: (NSIndexPath*)indexPath
{
  id key = [self keyForRowAtIndexPath:indexPath];
  id klass = [self cellClassForKey:key];
  return [klass respondsToSelector: @selector(to_class)] ? [klass to_class] : klass;
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
  cell.key = [self keyForRowAtIndexPath: indexPath];
  
  return cell;
}

@end
