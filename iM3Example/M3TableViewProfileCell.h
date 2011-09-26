#import "M3TableViewController.h"

@interface M3TableViewProfileCell: M3TableViewCell {
  UIImageView* starView_;
  UILabel* tagLabel_;
};

/*
 * checks if the current cell supports a certain feature.
 */
-(BOOL)features: (SEL)feature;

@end
