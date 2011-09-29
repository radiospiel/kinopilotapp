#import "M3TableViewProfileCell.h"
#import <QuartzCore/QuartzCore.h>
#import "M3.h"

@implementation M3TableViewProfileCell

-(id)init {
  self = [super initWithStyle:UITableViewCellStyleSubtitle];

  //
  // set basic layout for textLabel and detailTextLabel. 

  self.textLabel.font = [UIFont boldSystemFontOfSize:14];
  self.detailTextLabel.font = [UIFont systemFontOfSize:11];
  self.detailTextLabel.textColor = [UIColor colorWithName: @"#333"];
  self.detailTextLabel.numberOfLines = 2;
  
  //
  // Make detail text label background transparent: detailTextLabel and
  // textLabel are pretty close to each other - this minimize the visible
  // interference between both.
  self.detailTextLabel.backgroundColor = [UIColor clearColor];

  self.imageView.hidden = YES;

  // self.selectionStyle = UITableViewCellSelectionStyleNone;

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
  return 51.0f; 
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

  
  // Layout everything..

  // left positions for img, and for texts (label and description)
  int left = 0;
  if(starView_) {
    starView_.frame = CGRectMake(7, 17, 16, 16);
    left = 27;
  }

  if(!self.imageView.hidden) {
    left += 3;
    self.imageView.frame = CGRectMake(left, 4, 33, 43);
    left += 33;
  }

  left += 4;
  self.detailTextLabel.frame = CGRectMake(left, 17, 290 - left, 32);

  //
  // the remaining width is 320 - left. We reserve some space for the index.
  self.textLabel.frame = CGRectMake(left, 2, 290-left, 16);
}

@end
