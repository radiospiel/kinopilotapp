#import "M3AppDelegate.h"
#import "M3ListViewController.h"

@implementation M3ListViewController

-(id)init
{
  self = [super init];
  [app on: @selector(updated) notify:self with:@selector(reload)];
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
  // header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-background-dark-22.png"]];
  header.backgroundColor = UIColor.whiteColor;
  
  UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(7, 0, 308, 22)]autorelease];
  // label.backgroundColor = [UIColor whiteColor];
  // label.opaque = NO;
  // label.textColor = [UIColor whiteColor];
  // label.font = [UIFont boldSystemFontOfSize:15];
  label.lineBreakMode = UILineBreakModeMiddleTruncation;
  label.text = text;

  [header addSubview:label];

  return header;
}

-(void)dealloc
{
  [originalDataSource_ release]; originalDataSource_ = nil;
  [filterText_ release]; filterText_ = nil;

  [super dealloc];
}

#pragma mark - Filtering

@synthesize originalDataSource = originalDataSource_, searchText = searchText_;

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

-(void)setSearchBarEnabled: (BOOL)enabled
{
  // --- create the search bar.
  UISearchBar* searchBar = [[UISearchBar alloc]initWithFrame: CGRectMake(0, 0, 305, 44)];
  searchBar.delegate = self;
  // searchBar.barStyle = UIBarStyleBlackOpaque;
  
  // --- create a navigation bar dummy, which covers the space between pixels 290 and 20.
  UINavigationBar *dummyNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  dummyNavigationBar.barStyle = searchBar.barStyle;
  
  UIView *customTableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  [customTableHeaderView addSubview:[dummyNavigationBar autorelease]];
  [customTableHeaderView addSubview:[searchBar autorelease]];
  self.tableView.tableHeaderView = [customTableHeaderView autorelease];

  // --- hide search bar: user must pull the list down.
  // self.tableView.contentOffset = CGPointMake(0, 44);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  self.searchText = self.filterText;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  self.filterText = searchText;

  if(searchText.length) return;
  
  // The user clicked [X] or otherwise removed the filter text.
  [searchBar performSelector: @selector(resignFirstResponder) 
                  withObject: nil 
                  afterDelay: 0.1];
}

@end
