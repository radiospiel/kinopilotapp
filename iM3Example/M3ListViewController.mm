#import "AppDelegate.h"
#import "M3ListViewController.h"

@implementation M3ListViewController

-(id)init
{
  self = [super init];

  [app.chairDB on: @selector(updated) notify:self with:@selector(reload)];
  [app on: @selector(resumed) notify:self with:@selector(reload)];
  
  self.clearsSelectionOnViewWillAppear = NO;
  
  return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  NSString* text = [self.dataSource tableView:tableView titleForHeaderInSection:section];
  if(!text) return 0;
	return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSString* text = [self.dataSource tableView:tableView titleForHeaderInSection:section];
  if(!text) return nil;
  
  UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)]autorelease];
  header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-background-dark-22.png"]]; 
  
  UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(7, 0, 308, 22)]autorelease];
  label.backgroundColor = [UIColor clearColor];
  label.opaque = NO;
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont boldSystemFontOfSize:15];
  label.lineBreakMode = UILineBreakModeMiddleTruncation;
  label.text = text;

  [header addSubview:label];

  return header;
}

-(void)dealloc
{
  [originalDataSource_ release]; 
  [filterText_ release]; 

  [super dealloc];
}

#pragma mark - Filtering

@synthesize originalDataSource = originalDataSource_;


-(void)updateFilteredDataSource
{
  M3TableViewDataSource* dataSource = [self.originalDataSource dataSourceByFilteringWith:self.filterText];
  [super setDataSource: dataSource];
}


-(void)setDataSource:(M3TableViewDataSource *)dataSource
{
  if(self.originalDataSource == dataSource) return;

  [filterText_ release];
  filterText_ = nil;

  self.originalDataSource = dataSource;
  [self updateFilteredDataSource];
}

-(NSString*) filterText
{
  return filterText_;
}

-(void)setFilterText:(NSString *)filterText
{
  if(filterText.length == 0) filterText = nil;
  
  [filterText retain];
  [filterText_ release];
  filterText_ = filterText;

  [self updateFilteredDataSource];
}

#pragma mark - Search Bar

-(UISearchBar*)searchBar
{
  UISearchBar* searchBar = [[UISearchBar alloc]initWithFrame: CGRectMake(0, 0, 290, 44)];
  [searchBar setBarStyle:UIBarStyleBlackOpaque];
  //searchBar.showsCancelButton = YES;
  // bar 
  searchBar.delegate = self;
  return [searchBar autorelease];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  self.filterText = searchText;
}

// - (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
//   // letUserSelectRow = NO;
//   // self.tableView.scrollEnabled = NO;
  
//   // TODO: disable or hide index
  
//   //Add the done button.
// //  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
// //                                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
// //                                             target:self action:@selector(doneSearching_Clicked:)] autorelease];
// }

//- (void) doneSearching_Clicked:(UIBarButtonItem *)sender {
//  
//}

//- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//  if(searchMode_) return nil;
//  return indexPath;
//}

@end
