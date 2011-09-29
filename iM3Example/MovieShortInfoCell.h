/*
 * MovieShortInfoCell: This cell shows the movie's image and a short 
 * description of the movie.
 */

#import "M3TableViewCell.h"

@class TTTAttributedLabel;

@interface MovieShortInfoCell: M3TableViewCell {
  TTTAttributedLabel* htmlView;
}

@end
