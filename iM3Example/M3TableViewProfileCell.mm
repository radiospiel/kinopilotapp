#import "M3TableViewProfileCell.h"
#import <QuartzCore/QuartzCore.h>
#import "M3.h"

@implementation M3TableViewProfileCell

// @synthesize imageURL=imageURL_;
@synthesize flagged, flagView, image;

static CGFloat textHeight = 0, detailTextHeight = 0;

+(void)initialize {
  textHeight = [self.stylesheet fontForKey:@"h2"].lineHeight;
  detailTextHeight = [self.stylesheet fontForKey:@"detail"].lineHeight;
}

-(id)init {
  self = [super initWithStyle:UITableViewCellStyleSubtitle];
  self.imageView.hidden = YES;
  return self;
}

-(void)dealloc
{
  self.flagView = nil;
  [super dealloc];
}

+ (CGFloat)fixedHeight
{ 
  return 2 + textHeight + 2 * detailTextHeight + 3;
}

#pragma mark --- starring

-(BOOL)onFlagging: (BOOL)isNowFlagged;
{
  return isNowFlagged;
}

- (void)tappedFlag:(UITapGestureRecognizer *)sender {   
  BOOL newFlagged = [self onFlagging: !self.flagged];
  [self setFlagged: newFlagged];
}

/** return the starView; create if needed. */

-(UIImageView*)flagView
{
  if(flagView) return flagView;
  
  flagView = [[UIImageView alloc]init];
  [self.contentView addSubview: flagView];
  
  flagView.userInteractionEnabled = YES;
  
  UITapGestureRecognizer *recognizer;
  recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self 
                                                      action:@selector(tappedFlag:)];
  [flagView addGestureRecognizer:[recognizer autorelease]];

  return flagView;
}

-(void)setFlagged: (BOOL)newFlagged
{
  if(newFlagged == self.flagged) return;
  
  NSString* flagImage = newFlagged ? @"star.png" : @"unstar.png";
  self.flagView.image = [UIImage imageNamed: flagImage]; 
  flagged = newFlagged;
}

-(void)setText: (NSString*)text
{
  self.textLabel.text = text;
}

-(void)setDetailText: (NSString*)description
{
  self.detailTextLabel.text = description;
}

- (void) layoutSubviews
{
  [super layoutSubviews];
  
  //
  // set colors for text labels 
  self.detailTextLabel.textColor = [UIColor colorWithName: @"#333"];
  self.detailTextLabel.numberOfLines = 2;
  
  //
  // Make detail text label background transparent: detailTextLabel and
  // textLabel are pretty close to each other - this minimize the visible
  // interference between both.
  self.detailTextLabel.backgroundColor = [UIColor clearColor];

  // left positions for img, and for texts (label and description)
  int left = 7;
  if(flagView) {
    flagView.frame = CGRectMake(9, 16, 24, 24);
    left = 44;
  }

  if(self.image) {
    self.imageView.hidden = NO;
    self.imageView.image = self.image; //  [UIImage imageNamed:@"no_poster.png"];
    self.imageView.frame = CGRectMake(left, 4, 36, 47);
    // self.imageView.imageURL = self.imageURL; 
    left += 42;
  }

  //
  // After adding image and starView 320px - \a left pixels remain. 
  // We reserve some space (30px) to not obstruct the index.
  int indexWidth = 25;
  self.textLabel.frame = CGRectMake(left, 2, 320 - indexWidth - left, textHeight);

  // top align text in detailTextLabel.
  
  int numberOfLines = self.detailTextLabel.numberOfLines;
  CGSize maxSize = CGSizeMake(320 - indexWidth - left, 
                      numberOfLines ? numberOfLines * detailTextHeight : 9999);

  CGSize labelSize = [self.detailTextLabel.text sizeWithFont: self.detailTextLabel.font 
                                           constrainedToSize: maxSize
                                               lineBreakMode: self.detailTextLabel.lineBreakMode];
  
  self.detailTextLabel.frame = CGRectMake(left, 1 + textHeight, labelSize.width, labelSize.height);
}

@end
