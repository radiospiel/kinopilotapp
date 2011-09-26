#import "M3TableViewController.h"

/*
 * The M3TableViewProfileCell adds support for a "star" image, which is wired 
 * up with the chairDB "stars" table.
 */
@interface M3TableViewProfileCell: M3TableViewCell {
  UIImageView* starView_;
  UILabel* tagLabel_;
};

/*
 * checks if the current cell supports a certain feature.
 */
-(BOOL)features: (SEL)feature;

/*
 * returns the detailText. While title, image, and tags are read straight from the model,
 * the detailText is returned by this method. Subclasses may override detailText to implement
 * semi-dynamic behaviour (i.e. may contain different information depending on, e.g., 
 * controller setting).
 */
-(NSString*)detailText;

@end
