#import "M3ListViewController.h"
#import "M3TableViewAdCell.h"
#import "M3TableViewProfileCell.h"

@implementation M3ListViewController: M3TableViewController

- (Class) tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  id key = [self.keys objectAtIndex: indexPath.row];
  
  if([key isKindOfClass:[NSNull class]])
    return [M3TableViewAdCell class];
  
  return [M3TableViewProfileCell class];
}

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

@end
