#import "M3TableViewProfileCell.h"
#import <QuartzCore/QuartzCore.h>
#import "M3.h"
#import "AppDelegate.h"

@implementation M3TableViewProfileCell

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
  [starView_ release];
  [super dealloc];
}

//- (void)tappedStar:(UITapGestureRecognizer *)sender {     
//  NSLog(@"tappedStar");
//  if (sender.state == UIGestureRecognizerStateEnded) { // handling code     
//  } 
//}

+ (CGFloat)fixedHeight
{ 
  return 2 + textHeight + 2 * detailTextHeight + 3;
}

-(void)setStarred: (BOOL)starred
{
  if(!starView_) {
    starView_ = [[UIImageView alloc]init];
    [self.contentView  addSubview: starView_];
    
    // UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedStar:)] autorelease];
    // starView_.userInteractionEnabled = YES;
    // [starView_ addGestureRecognizer:recognizer];
  }

  NSString* starImage = starred ? @"star.png" : @"unstar.png";
  
  M3AssertKindOf(starView_, UIImageView);
  
  starView_.image = [UIImage imageNamed: starImage]; 
}

-(void)setText: (NSString*)text
{
  self.textLabel.text = text;
}

-(void)setDetailText: (NSString*)description
{
  self.detailTextLabel.text = description;
}

-(void)setImageURL: (NSString*)imageURL
{
  self.imageView.hidden = NO;
  self.imageView.image = [UIImage imageNamed:@"no_poster.png"];
  self.imageView.imageURL = imageURL; 
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
  if(starView_) {
    starView_.frame = CGRectMake(7, 20, 16, 16);
    left = 27;
  }

  if(!self.imageView.hidden) {
    self.imageView.frame = CGRectMake(left, 4, 36, 47);
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
