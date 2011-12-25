//
//  EmptyListCell.m
//  M3
//
//  Created by Enrico Thierbach on 04.12.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "M3AppDelegate.h"
#import "M3TableViewCell.h"
#import "TTTAttributedLabel.h"

@interface EmptyListCell : M3TableViewCell

@property (nonatomic,retain) TTTAttributedLabel* htmlView;

@end

@implementation EmptyListCell

@synthesize htmlView;

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:32] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:15] forKey:@"p"];
}

-(id) init {
  self = [super init];

  self.selectionStyle = UITableViewCellSelectionStyleNone;

  self.htmlView = [[TTTAttributedLabel alloc]init];
  [self addSubview:self.htmlView]; 

  // Disable scrolling in WebView
  //
  //  for (id subview in webView.subviews) {
  //    if ([[subview class] isSubclassOfClass: [UIScrollView class]])
  //      ((UIScrollView *)subview).bounces = NO;
  //  }

  return self;
}

-(NSString*)markup
{
  NSString* tmpl = @"<h2><b>Hoppla!</b></h2>"
                    "<p>Für Deine Auswahl liegen keine oder noch keine Informationen vor. "
                       "Die Daten der Kinopilot-App aktualisieren sich selbständig. "
                       "Du kannst aber eine Aktualisierung auch von Hand veranlassen.</p>"
                    "<p></p>"
                    "<p>Zeitpunkt des letzten Update: {{updated_at}}.</p>";
  
  return [M3 interpolateString: tmpl 
                    withValues: app.infoDictionary];
}

-(void)setKey: (id)key
{
  [super setKey:key];
  
  self.textLabel.text = @" ";
  
  // NSString *html = @"<html><head><title>The Meaning of Life</title></head><body><p>...really is <b>42</b>!</p></body></html>";  
  // [webView loadHTMLString: [self markup] 
  //                baseURL: nil]; 

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
  self.htmlView.frame = CGRectMake(14, 7, sz.width, sz.height);
//  webView.frame = CGRectMake(14, 7, sz.width, sz.height);
//  webView.backgroundColor = [UIColor clearColor];
//  
//  webView.userInteractionEnabled = NO;
}

- (CGFloat)wantsHeight
{
  return [self htmlViewSize].height + 14;
}

@end

@interface EmptyListUpdateActionCell : M3TableViewCell {
  UIButton* button;
}
@end

@implementation EmptyListUpdateActionCell

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
