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
 * Gets the section name for this key. 
 */
-(NSString*)sectionForKey: (id)key
{
  return [[[key description] substringToIndex:1] uppercaseString];
}

-(void)setKeys:(NSArray*)keys
{
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
    
  self.sections = sections; 
  [super setKeys: keys];
}

-(BOOL)showsIndex
{
  if(self.keys.count < 25) return NO;
  if(self.sections.count < 7) return NO;

  return YES;
}

/*
 * returns an array of index titles for this table view. Returns nil
 * to disable the index.
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  if(![self showsIndex]) return nil;
  
  NSMutableArray* array = _.array();
  
  for(NSArray* section in self.sections) {
    NSString* indexLabel = [section objectAtIndex:0];
    [array addObject:indexLabel];
  }
  
  return array;
}

/*
 * returns the number of the section for the section index title at position
 * \a index (in the array returned by sectionIndexTitlesForTableView:)
 */
- (NSInteger) tableView:(UITableView *)tableView 
     sectionForSectionIndexTitle:(NSString *)title 
                atIndex:(NSInteger)index 
{
  //
  // As we have a 1:1 relation ship between index titles and sections
  // we can just return the index position here.
    
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

  return entries.count;
}

@end



