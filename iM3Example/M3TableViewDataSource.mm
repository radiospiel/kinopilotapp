#import "M3.h"

#import "M3TableViewCell.h"
#import "M3TableViewDataSource.h"

@implementation M3TableViewDataSource

@synthesize controller = controller_;

-(id)init
{
  self = [super init];
  if(!self) return nil;
  
  return self;
}

-(void)dealloc
{
  self.sections = nil;
  [super dealloc];
}

-(NSMutableArray*)sections
{
  return sections_;
}

-(void)setSections:(NSMutableArray *)sections
{
  for(NSArray* section in sections) {
    NSCParameterAssert(section.count == 4);
    M3AssertKindOf([section objectAtIndex: 0], NSString);
    M3AssertKindOf([section objectAtIndex: 1], NSString);
    M3AssertKindOf([section objectAtIndex: 2], NSString);
    M3AssertKindOf([section objectAtIndex: 3], NSArray);
  }

  [sections retain];
  [sections_ release];
  sections_ = sections;
}

-(void)addSection:(NSArray*) keys
       withHeader:(NSString*)header
        andFooter:(NSString*)footer
    andIndexTitle:(NSString*)indexTitle
{
  M3AssertKindOf(keys, NSArray);
  
  if(!sections_)
    self.sections = [NSMutableArray array];
    
  [sections_ addObject: [NSArray arrayWithObjects: header, footer, indexTitle, [keys copy], nil]];
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
  return [[section objectAtIndex:3] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.sections objectAtIndex:sectionNo]; 
  return [section objectAtIndex:0];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.sections objectAtIndex:sectionNo]; 
  return [section objectAtIndex:1];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  return [sections_ mapUsingBlock:^id(NSArray* section) {
    return [section objectAtIndex:2];
  }];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  return index;
}

#pragma mark - UITableViewDataSource implementations: cells */

- (id)keyForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray* section = [self.sections objectAtIndex:indexPath.section]; 
  NSArray* keys = [section objectAtIndex:3];
  return [keys objectAtIndex:indexPath.row];
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
  if(height)
    return height;
  
  M3TableViewCell* cell = (M3TableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
  return [cell wantsHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Class klass = [self cellClassForRowAtIndexPath: indexPath];
  NSString* klassName = NSStringFromClass(klass);
  
  // get a reusable or create a new table cell
  M3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: klassName];
  if (!cell)
    cell = [[[klass alloc]init]autorelease];
  
  cell.tableViewController = self.controller;
  cell.indexPath = indexPath;
  
  id key = [self keyForRowAtIndexPath: indexPath ];
  cell.key = key;
  cell.model = [self modelWithKey: key];
  
  return cell;
}

@end
