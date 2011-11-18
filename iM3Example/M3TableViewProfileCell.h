#import "M3TableViewController.h"

/*
 * The M3TableViewProfileCell adds support for a "star" image, which is wired 
 * up with the chairDB "stars" table.
 */
@interface M3TableViewProfileCell: M3TableViewCell {
  UIImageView* starView_;
  // NSString* imageURL_;
  UIImage* image_;
};

// @property (nonatomic,copy) NSString* imageURL;
@property (nonatomic,retain) UIImage* image;

-(void)setStarred: (BOOL)starred;
-(void)setText: (NSString*)text;
-(void)setDetailText: (NSString*)description;

@end
