@class M3TableViewController;

/*
 * A table view cell.
 *
 * A M3TableViewCell retains its own copies of key and data, and has a weak link
 * to the owning controller.
 *
 * The M3TableViewCell
 */
@interface M3TableViewCell: UITableViewCell {
  id key_;
  NSDictionary* model_;
  M3TableViewController* tableViewController_;
}

@property (nonatomic,retain) id key;
@property (nonatomic,retain) NSDictionary* model;
@property (nonatomic,assign) M3TableViewController* tableViewController;

-(id)initWithStyle:(UITableViewCellStyle)style;

// returns the height this implementation wants.
-(CGFloat) wantsHeightForWidth: (CGFloat)width;

@end
