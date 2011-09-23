@interface M3ListCell: UITableViewCell {
  UIImageView* starView_;
  UILabel* tagLabel_;
  NSDictionary* model_;
};

@property (nonatomic,retain) NSDictionary* model;

/*
 * checks if the current cell supports a certain feature.
 */
-(BOOL)features: (SEL)feature;

@end
