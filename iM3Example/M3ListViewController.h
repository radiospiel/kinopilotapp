#import "M3TableViewController.h"

@interface M3ListViewController: M3TableViewController {
  NSArray* sections_;
}

@property (retain,nonatomic) NSArray* sections;

/*
 * Gets the section label for this 
 */
-(NSString*)sectionForKey: (id)key;

-(BOOL)showsIndex;

@end
