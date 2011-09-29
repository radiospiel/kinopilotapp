#import "M3TableViewController.h"

/*
 * The M3TableViewProfileCell adds support for a "star" image, which is wired 
 * up with the chairDB "stars" table.
 */
@interface M3TableViewProfileCell: M3TableViewCell {
  UIImageView* starView_;
};

-(void)setStarred: (BOOL)starred;
-(void)setText: (NSString*)text;
-(void)setDetailText: (NSString*)description;
-(void)setImageURL: (NSString*)imageURL;

@end
