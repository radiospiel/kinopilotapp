#import "M3TableViewController.h"

/**
 
 A profile cell.
 
 Implements title, description, an optional image, and an optional "star".

*/

@interface M3TableViewProfileCell: M3TableViewCell {
};

@property (nonatomic,retain) UIImage* image;
@property (nonatomic,retain) UIImageView* flagView;
@property (nonatomic,assign) BOOL flagged;

-(void)setText: (NSString*)text;
-(void)setDetailText: (NSString*)description;

/** 
  callback when the user toggles the flag.
 
  return the new flagging status.
*/
-(BOOL)onFlagging: (BOOL)isNowFlagged;

@end
