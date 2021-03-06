#import "M3TableView/M3TableViewController.h"

/*
 * The M3ListViewControllerSlightly modified section headers for lists: this saves a few pixels per section.
 */

@interface M3ListViewController: M3TableViewController<UISearchBarDelegate> {
  NSString* filterText_;
  M3TableViewDataSource *originalDataSource_;
}

@property (nonatomic,retain) NSString* filterText;
@property (nonatomic,retain) NSString* searchText;
@property (nonatomic,retain) M3TableViewDataSource *originalDataSource;

-(void)setSearchBarEnabled: (BOOL)searchBarEnabled;

@end
