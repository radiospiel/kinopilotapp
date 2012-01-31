#import "M3.h"

#import "M3TableViewCell.h"
#import "M3TableViewDataSource.h"

@implementation M3TableViewDataSource

@synthesize controller = controller_, 
              sections = sections_, 
             cellClass = cellClass_;

-(id)initWithCellClass:(id)cellClass
{
  self = [super init];

  if(self) {
    self.sections = [NSMutableArray array];
    cellClass_ = [cellClass retain];
  }
  
  return self;
}

-(id)init
{
  return [self initWithCellClass:nil];
}

-(void)dealloc
{
  self.sections = nil;
  
  [cellClass_ release]; cellClass_ = nil;

  [super dealloc];
}

-(NSString*)inspect
{
  return [NSString stringWithFormat: @"<%@ @ 0x%08x: %d sections>", NSStringFromClass([self class]), self, self.sections.count];
}

-(void)addSection:(NSArray*) keys
{
  [self addSection: keys withOptions: nil];
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

-(void)insertKey:(id)key 
         atIndex:(int)index
     intoSection:(int)sectionIndex
{
  NSArray* section = [self.sections objectAtIndex:sectionIndex];
  
  // make sure the keys are, in fact, mutable.
  NSMutableArray* keys = section.first;
  if(![keys isKindOfClass:[NSMutableArray class]])
    keys = [NSMutableArray arrayWithArray:keys];
  
  [keys insertObject:key atIndex:index];

  NSArray* newSection = [NSArray arrayWithObjects:keys, section.second, nil];
  [self.sections replaceObjectAtIndex: sectionIndex 
                           withObject: newSection]; 
}


#pragma mark - Filtering

- (BOOL)stringItem: (NSString*)item 
     matchesFilter: (NSString*)filter
{
  return [[item uppercaseString] containsString: [filter uppercaseString]];
}

- (BOOL)dictionaryItem: (NSDictionary*)item 
         matchesFilter: (NSString*)filter
{
  NSString* itemText = [item objectForKey:@"filter"];
  if(!itemText) itemText = [item objectForKey:@"title"];
  if(!itemText) itemText = [item objectForKey:@"name"];
  if(!itemText) itemText = [item objectForKey:@"label"];

  return [self stringItem:itemText matchesFilter:filter];
}

- (BOOL)item: (id)item matchesFilter: (NSString*)filter
{
  if([item isKindOfClass:[NSString class]]) 
    return [self stringItem:item matchesFilter:filter];
  if([item isKindOfClass:[NSDictionary class]]) 
    return [self dictionaryItem:item matchesFilter:filter];
  
  return NO;
}

- (NSArray*)section: (NSArray*)section filteredWith: (NSString*)filter
{
  NSArray* keys = section.first;

  keys = [ keys selectUsingBlock:^BOOL(id item) {
    return [self item: item matchesFilter: filter];
  }];
  
  if(keys.count == 0) return nil;
  
  // Build a filtered section *without* the original section's options:
  // we do not want headers or footers here.
  return [NSArray arrayWithObject: keys];
}

- (M3TableViewDataSource*)dataSourceByFilteringWith: (NSString*)filterText;
{
  if(!filterText.length) return [[self retain]autorelease];

  M3AssertNotNil(self.cellClass);

  M3TableViewDataSource* dataSource = [[M3TableViewDataSource alloc]initWithCellClass:self.cellClass];
  
  for(NSArray* section in self.sections) {
    section = [self section: section filteredWith:filterText];
    if(section)
      [dataSource.sections addObject:section];
  }
  
  return [dataSource autorelease];
}

#pragma mark - UITableViewDataSource customization

-(Class) cellClassForKey: (id)key
{
  if([key isEqual: @"M3TableViewAdCell"])
    return @"M3TableViewAdCell".to_class;
  
  if(cellClass_)
    return cellClass_;
  
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
  NSArray* first = section.first;
  return [first count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNo
{
  if(self.sections.count <= sectionNo) return nil;
  
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
  
  [cell setTableViewController: self.controller];
  
  cell.indexPath = indexPath;
  cell.key = [self keyForRowAtIndexPath: indexPath];
  
  return cell;
}

@end

#pragma mark -- default data source

@interface M3TableViewDefaultDataSource: M3TableViewDataSource
@end

@implementation M3TableViewDefaultDataSource

-(id)cellClassForKey: (id)key
{ 
  return key; 
}

@end

@implementation M3TableViewDataSource(defaultDataSource)

+(M3TableViewDataSource*)dataSourceWithSection: (NSArray*)section;
{
  M3TableViewDataSource* dataSource = [[M3TableViewDefaultDataSource alloc]init];
  [dataSource addSection: section];
  return [dataSource autorelease];
}

@end
