//
//  EmptyListCell.m
//  M3
//
//  Created by Enrico Thierbach on 04.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "AppDelegate.h"

@interface EmptyListCell : M3TableViewCell {
  TTTAttributedLabel* htmlView;
}
@end

@implementation EmptyListCell

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:22] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:15] forKey:@"p"];
}

-(id) init {
  self = [super init];
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  htmlView = [[[TTTAttributedLabel alloc] init] autorelease];
  [self addSubview: htmlView];
  
  return self;
}

-(NSString*)markup
{
  return 
     @"<h2><b>Hoppla!</b></h2>"
     "<p>Für diese Auswahl liegen zur Zeit keine Informationen vor.</p>"
      "<p>kinopilot wurde zuletzt aktualisiert am {{updated_at}}.</p>";
}

-(void)setKey: (id)key
{
  [super setKey:key];
  
  self.textLabel.text = @" ";
  
  htmlView.text = [NSAttributedString attributedStringWithMarkup: [self markup] 
                                                   forStylesheet: self.stylesheet];
}

-(CGSize)htmlViewSize
{
  return [htmlView sizeThatFits: CGSizeMake(292, 1000)];
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize sz = [self htmlViewSize];
  htmlView.frame = CGRectMake(14, 7, sz.width, sz.height);
}

- (CGFloat)wantsHeight
{
  return [self htmlViewSize].height + 14;
}

@end

@interface UpdateActionListCell : M3TableViewCell {
  UIButton* button;
}
@end

@implementation UpdateActionListCell

-(id) init {
  self = [super init];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  button = [UIButton actionButtonWithURL:@"/action/update" andTitle:@"Aktualisieren!"];
  [self addSubview: button];
  
  return self;
}

-(CGFloat)wantsHeight
{
  return 44;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect buttonFrame = button.frame;
  buttonFrame.origin.x = (320 - buttonFrame.size.width)/2;
  buttonFrame.origin.y = 7;
  button.frame = buttonFrame;
}

@end
