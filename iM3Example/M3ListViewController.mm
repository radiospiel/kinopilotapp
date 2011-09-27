#import "M3ListViewController.h"
#import "M3TableViewAdCell.h"
#import "M3TableViewProfileCell.h"
#import "Underscore.hh"

@implementation M3ListViewController: M3TableViewController

@synthesize sections = sections_;
// 
// - (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
// {
//   id key = [self.keys objectAtIndex: indexPath.row];
//   
//   if([key isKindOfClass:[NSNull class]])
//     return [M3TableViewAdCell class];
//   
//   return [M3TableViewProfileCell class];
// }

#if 0 
-(void)setKeys:(NSArray*)keys
{
  // --- Mixin iAds ------------------------------------------------------------
 
  NSMutableArray* keysWithAds = [[NSMutableArray alloc]init];
  
  int probability = -1;
  
  for(id key in keys) {
    // The likelyhood of an ad view increments with each inserted row.
    if(rand() % 12 < probability) {
      [keysWithAds addObject: [NSNull null]];
      probability = -2000;
    }
    
    probability++;
    
    [keysWithAds addObject: key];
  }
  
  dlog << @"added " << (keysWithAds.count - keys.count) << " ads amongst " << keys.count << " entries";
  
  [super keysWithAds];
}

#endif


/*
 * Gets the section label for this 
 */
-(NSString*)sectionForKey: (id)key
{
  return [[[key description] substringToIndex:1] uppercaseString];
  //  return [[key description]substringToIndex:2];
}

-(NSMutableArray* )sectionsWithKeys: (NSArray*)keys
{
  Benchmark(@"sectionsWithKeys");
  
  NSMutableArray* sections = [NSMutableArray array];
  NSString* previousSection = nil;
  
  for(id key in keys) {
    NSString* section = [self sectionForKey:key];
    if(![previousSection isEqualToString:section]) {
      previousSection = section;
      NSMutableArray* entries = [NSMutableArray array];
      [sections addObject: [NSMutableArray arrayWithObjects: section, section, entries, nil]];
    }

    NSMutableArray* entries = [sections.last objectAtIndex:2];
    [entries addObject: key];
  }
  
  return sections; 
}

-(void)setKeys:(NSArray*)keys
{
  [super keys];
  self.sections = [self sectionsWithKeys:keys];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  NSMutableArray* array = _.array();
  
  for(NSArray* section in self.sections) {
    NSString* indexLabel = [section objectAtIndex:0];
    [array addObject:indexLabel];
  }
  
  return array;
}

- (NSInteger) tableView:(UITableView *)tableView 
     sectionForSectionIndexTitle:(NSString *)title 
                atIndex:(NSInteger)index {
  
  return index;
}

- (NSString *)tableView:(UITableView *)tableView 
      titleForHeaderInSection:(NSInteger)sectionNo 
{
  NSArray* section = [self.sections objectAtIndex:sectionNo];
  return [section objectAtIndex:1];
}

- (id)keyForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger sectionNo = indexPath.section;
  NSArray* section = [self.sections objectAtIndex:sectionNo];
  NSArray* entries = [section objectAtIndex:2];

  return [entries objectAtIndex: indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionNo
{
  NSArray* section = [self.sections objectAtIndex:sectionNo];
  NSArray* entries = [section objectAtIndex:2];

  dlog << "numberOfRowsInSection " << sectionNo << " returns " << entries.count;
  return entries.count;
}

@end



