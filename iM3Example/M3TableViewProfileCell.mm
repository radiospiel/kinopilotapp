#import "M3TableViewProfileCell.h"
#import <QuartzCore/QuartzCore.h>
#import "M3.h"

@implementation M3TableViewProfileCell

-(id)init {
  self = [super initWithStyle:UITableViewCellStyleSubtitle];
  
  if(self) {
    // self.selectionStyle = UITableViewCellSelectionStyleNone;

    // set basic layout for textLabel and detailTextLabel. 
    // They are identical for all instances.
    self.textLabel.font = [UIFont boldSystemFontOfSize:14];

    self.detailTextLabel.font = [UIFont systemFontOfSize:11];
    self.detailTextLabel.textColor = [UIColor colorWithName: @"#333"];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];

    self.detailTextLabel.numberOfLines = 2;
  }
  return self;
}

-(BOOL)features: (SEL)what
{
  if(what == @selector(star))
    return YES;

  if(what == @selector(tag))
    return nil != [self.model objectForKey:@"tags"];

  if(what == @selector(image))
    return YES;
  
  return NO;
}

- (void)tappedStar:(UITapGestureRecognizer *)sender {     
  NSLog(@"tappedStar");
  if (sender.state == UIGestureRecognizerStateEnded) { // handling code     
  } 
}

- (CGFloat)wantsHeightForWidth: (CGFloat)width
{ 
  return 51.0f; 
}

-(NSString*)detailText
{
  return [self.model objectForKey: @"description"];
}

/*
 * fill in table cell from values in model. This does create any needed 
 * subviews (for stars and tags), and sets the subviews' content, but does 
 * not adjust the layout, as this is done in layoutSubviews below. 
 */
-(void)setModel: (NSDictionary*)model
{
  [super setModel:model];
  
  // --- create/show/hide starView_, tagLabel_, imageView
  
  if(!starView_ && [self features: @selector(star)]) {
    starView_ = [[[UIImageView alloc]init]autorelease];
    [[self contentView] addSubview: starView_];
    
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedStar:)] autorelease];
    starView_.userInteractionEnabled = YES;
    [starView_ addGestureRecognizer:recognizer];
  }
  [starView_ setHidden: !([self features: @selector(star)])];

  if(!tagLabel_ && [self features: @selector(tag)]) {
    tagLabel_ = [[[UILabel alloc]init]autorelease];
    tagLabel_.font = [UIFont boldSystemFontOfSize: 9];
    tagLabel_.textColor = [UIColor colorWithName: @"#fff"];
    tagLabel_.backgroundColor = [UIColor colorWithName: @"#f60"];
    tagLabel_.layer.cornerRadius = 3;
    
    [[self contentView] addSubview: tagLabel_];
  }

  [self.imageView setHidden: !([self features: @selector(image)])];
  
  // --- set star
  
  if([self features: @selector(star)]) {
    starView_.image = [UIImage imageNamed: @"star.png"]; 
  }
  
  // --- set image
  
  self.imageView.image = [UIImage imageNamed:@"no_poster.png"];
  self.imageView.imageURL = [self.model objectForKey:@"image"];
  
  // --- set labels
  
  self.textLabel.text = [model objectForKey: @"title"];
                               
  // --- set tags

  if([self features: @selector(tag)]) {
    NSString* tags = [model objectForKey:@"tags"];
    if(tags)
      tagLabel_.text = _.join(@" ", tags, @" ");
    else
      tagLabel_.text = nil;
  }
}

- (void) layoutSubviews
{
  [super layoutSubviews];

  self.detailTextLabel.text = [self detailText];

  //
  // left positions for img, and for texts (label and description)
  int left = 0;
  if([self features:@selector(star)]) {
    starView_.frame = CGRectMake(7, 17, 16, 16);
    left = 27;
  }

  if([self features:@selector(image)]) {
    left += 3;
    self.imageView.frame = CGRectMake(left, 4, 33, 43);
    left += 33;
  }

  left += 4;
  self.detailTextLabel.frame = CGRectMake(left, 17, 290 - left, 32);
  [self.detailTextLabel setTopAlignedText: [self detailText]]; // (NSString*)text;

  //
  // the remaining width is 320 - left. We reserve some space for the index.
  if([self features:@selector(tag)]) {
    CGSize tagSize = [tagLabel_.text sizeWithFont:tagLabel_.font];
    int width = (int) (0.5 + tagSize.width);
    
    tagLabel_.frame = CGRectMake(left-1, 3, width, 14);
    left += width;
    self.textLabel.frame = CGRectMake(left+2, 2, 290-left, 16);
  }
  else {
    self.textLabel.frame = CGRectMake(left, 2, 290-left, 16);
  }
}

@end
