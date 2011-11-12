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

@property (nonatomic,retain) NSIndexPath* indexPath;
@property (nonatomic,retain) NSString* url;
@property (nonatomic,retain) id key;

/*
 * The designated initialiser
 */
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

-(void)didSelectCell;

@end

/*
 * M3TableViewUrlCell: This cell links a label to an URL.
 */

@interface M3TableViewUrlCell: M3TableViewCell
@end

/*
 * M3TableViewHtmlCell: This cell shows a HTML description
 */

@class TTTAttributedLabel;
@interface M3TableViewHtmlCell: M3TableViewCell {
  TTTAttributedLabel* htmlView;
}

-(void)setHtml: (NSString*)html;

@end
