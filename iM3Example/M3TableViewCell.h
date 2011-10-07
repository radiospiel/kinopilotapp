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
  M3TableViewController* tableViewController_;

  id key_;
  NSIndexPath* indexPath_;
  NSString* url_;
}

@property (nonatomic,assign) M3TableViewController* tableViewController;

@property (nonatomic,retain) id key;
@property (nonatomic,retain) NSIndexPath* indexPath;
@property (nonatomic,retain) NSString* url;

-(id)initWithStyle:(UITableViewCellStyle)style;

/*
 * Returns the height needed for this specific cell.
 */
-(CGFloat) wantsHeight;

/*
 * If all cells of this class need the same height override this method
 * to return that height. This heavily speeds up loading of larger tables.
 *
 * The default implementation just returns 0.
 */
+(CGFloat) fixedHeight;

-(void)selectedCell;

@end
