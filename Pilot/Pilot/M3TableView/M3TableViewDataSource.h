@class M3TableViewController;
@class M3TableViewCell;

/*
 * The M3TableViewDataSource is a (mainly) static data source for 
 * UITableViews.
 *
 * The table view data is organized into sections, where
 * each section is defined by header, footer, indexTitle, and
 * an array of object keys.
 */
@interface M3TableViewDataSource : NSObject<UITableViewDataSource> {
  NSMutableArray* sections_;
  M3TableViewController* controller_;
  id cellClass_;
}

@property (retain,nonatomic) NSMutableArray* sections;
@property (assign,nonatomic) M3TableViewController* controller;
@property (readonly,nonatomic) id cellClass;

+(NSString*) indexKey: (NSDictionary*) dict;

-(id)initWithCellClass: (id)cellClass;

-(void)prependCellOfClass: (id)klass
                  withKey: (id)key;

-(void)addCellOfClass: (id)klass
              withKey: (id)key;

/** 
 * Adds a section to the receiving data source.
 */
-(void)addSection: (NSArray*) keys withOptions: (NSDictionary*)options;
-(void)addSection: (NSArray*) keys;

/**
 * Adds an array of records to this data source.
 */
-(void)addRecords: (NSArray*) records;

-(NSString*)groupLabelForKey: (id)key;
-(id)groupKeyForRecord: (NSDictionary*)record;

/**
 * Adds an array of fallback entries to this data source.
 */
-(void)addFallbackSectionIfNeeded;
-(void)addFallbackSectionIfNeeded: (NSString*)cells;

/** 
 * Prepends a section to the receiving data source.
 */
-(void)prependSection: (NSArray*) keys withOptions: (NSDictionary*)options;

-(void)insertKey:(id)key 
         atIndex:(int)index
     intoSection:(int)sectionIndex;

/** 
 * Returns the class for the cell with the given key. Keys are whatever
 * is put into the section.
 *
 * The default implementation returns M3TableViewCell.
 */
-(Class) cellClassForKey: (id)key;

/**
 * returns the height the cell at indexPath would need.
 */
- (CGFloat)         tableView:(UITableView *)tableView
      heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * returns the height the cell at indexPath would need.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 * return filtered data source
 */
- (M3TableViewDataSource*)dataSourceByFilteringWith: (NSString*)filterText;

@end

@interface M3TableViewDataSource(defaultDataSource)

+(M3TableViewDataSource*)dataSourceWithSection: (NSArray*)section;

@end

