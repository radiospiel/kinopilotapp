#import "M3AppDelegate.h"

#import "M3TableViewCell.h"
#import "M3TableViewDataSource.h"

@implementation M3TableViewDataSource


// [LEGACY] is this a "c-" or "m-" index key? 
// The theater_id is "c-<sortkey>", and the first character of the sortkey
// "makes sense" for the index: this should be the first relevant 
// letter from the movie title.
static NSString* legacyIndexKey(NSDictionary* dict) 
{
  id objId = [dict objectForKey:@"_id"];
  if(!objId) objId = [dict objectForKey:@"id"];
  NSString* index_key = [objId description];
  
  if([[index_key substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"-"])
    return [index_key substringFromIndex:2];
  
  return index_key;
}

// returns the sortkey in a dictionary.
+(NSString*) indexKey: (NSDictionary*) dict 
{
  NSString* indexKey = [dict objectForKey:@"sortkey"];
  
  if(![indexKey isKindOfClass:[NSString class]])
    indexKey = legacyIndexKey(dict);
  
  indexKey = [[indexKey substringToIndex:1] uppercaseString];
  
  if([indexKey compare:@"A"] == NSOrderedAscending || [@"Z" compare: indexKey] == NSOrderedAscending)
    return @"#";
  
  return indexKey;
}

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

-(void)addFallbackSectionIfNeeded: (NSString*)cells
{
  if(self.sections.count > 0) return;
  
  [self addSection: [cells componentsSeparatedByString:@","]];
}

-(void)addFallbackSectionIfNeeded
{
  [self addFallbackSectionIfNeeded: @"EmptyListCell,EmptyListUpdateActionCell"];
}

-(void)addSection:(NSArray*) keys
{
  [self addSection: keys withOptions: nil];
}

-(void)addSection:(NSArray*) keys withOptions: (NSDictionary*) options
{
  M3AssertKindOf(keys, NSArray);
  if(options) M3AssertKindOf(options, NSDictionary);    // Note: options is allowed to be nil.
  
  if(!keys) keys = [NSArray array];
  NSArray* section = [NSArray arrayWithObjects: keys, options, nil];
  [self.sections addObject: section];
}

-(NSString*)groupLabelForKey: (id)key
{
  return [key description];
}

-(id)groupKeyForRecord: (NSDictionary*)record
{
  M3AssertKindOf(record, NSDictionary);
  
  return [record objectForKey:@"group_key"];
}

-(void)addRecords:(NSArray*) records
{
  [self addRecords:records withGroupingThreshold: 10];
}

-(void)addRecords:(NSArray*) records withGroupingThreshold: (int)groupThreshold
{
  if(records.count < groupThreshold || ![self groupKeyForRecord: records.first]) {
    [self addSection: records];
    return;
  }
  
  // The following groups the records by their respective groupKeys.
  // It is stable; i.e. group keys appear in the final result in the
  // order in which they appeared in the records input.
  
  NSMutableArray* groupKeys = [NSMutableArray array];
  NSMutableDictionary* grouped = [NSMutableDictionary dictionary];
  for(NSDictionary* record in records) {
    id groupKey = [self groupKeyForRecord: record];
    NSMutableArray* group = [grouped objectForKey:groupKey];
    if(group) {
      [group addObject:record];
      continue;
    }
    
    group = [NSMutableArray arrayWithObject: record];
    [grouped setObject:group forKey:groupKey];
    [groupKeys addObject:groupKey];
  }
  
  // Build groups according to the groupKeys array.
  for(id groupKey in groupKeys) {
    NSArray* recordsInGroup = [grouped objectForKey:groupKey];
    NSString* groupLabel = [self groupLabelForKey: groupKey];
    
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    [options setObject: groupLabel forKey:@"header"];

    if(groupLabel.length == 1) {
      [options setObject: groupLabel forKey:@"index"];
    }
    
    [self addSection: recordsInGroup
         withOptions: options];
  }
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

-(void)prependCellOfClass: (id)klass
                  withKey: (id)key;
{
  NSArray* entry = [NSArray arrayWithObjects: klass, key, nil];
  [self prependSection:[NSArray arrayWithObject: entry] 
           withOptions:nil];
}

-(void)addCellOfClass: (id)klass
              withKey: (id)key;
{
  NSArray* entry = [NSArray arrayWithObjects: klass, key, nil];
  [self addSection:[NSArray arrayWithObject: entry]
       withOptions:nil];
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

-(Class) cellValueForKey: (id)key
{
  if([key isKindOfClass:[NSArray class]])
    return [key objectAtIndex:1];
  
  return key;
}

-(Class) cellClassForKey: (id)key
{
  if([key isKindOfClass:[NSString class]]) {
    Class klass = [key to_class];
    if(klass) return klass;
  }

  if([key isKindOfClass:[NSArray class]]) {
    NSArray* ary = (NSArray*)key;
    if([ary.first isKindOfClass:[NSString class]]) {
      Class klass = [ary.first to_class];
      if(klass) return klass;
    }
  }

  if(cellClass_)
    return cellClass_;
  
  return [M3TableViewCell class];
}

-(Class)loadCellClassForKey: (id)key
{
  Class klass = [self cellClassForKey:key];
  if([klass respondsToSelector: @selector(to_class)])
    return [klass to_class];
  
  return klass;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id key = [self keyForRowAtIndexPath:indexPath];
  Class klass = [self loadCellClassForKey:key];
  
  CGFloat height = [klass fixedHeight]; 
  if(height) return height;
  
  M3TableViewCell* cell = (M3TableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
  return [cell wantsHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id key = [self keyForRowAtIndexPath: indexPath];
  Class klass = [self loadCellClassForKey: key];
  NSString* klassName = NSStringFromClass(klass);
  
  // get a reusable or create a new table cell
  M3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: klassName];
  if (!cell) {
    cell = [[[klass alloc]init]autorelease];
    M3AssertKindOf(cell, M3TableViewCell);
  }
  
  [cell setTableViewController: self.controller];
  
  cell.indexPath = indexPath;
  cell.key = [self cellValueForKey: key];
  
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
