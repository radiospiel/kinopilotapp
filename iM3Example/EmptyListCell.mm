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

@interface StaticListCell: M3TableViewCell
@property (nonatomic,retain) TTTAttributedLabel* htmlView;
@property (nonatomic,retain) NSString* theTemplate;

-(StaticListCell*)initWithTemplate:(NSString*)aTemplate;
@end

@implementation StaticListCell

@synthesize htmlView, theTemplate;

+(void)initialize
{
  M3Stylesheet* stylesheet = [self stylesheet];
  [stylesheet setFont: [UIFont systemFontOfSize:32] forKey:@"h2"];
  [stylesheet setFont: [UIFont systemFontOfSize:15] forKey:@"p"];
}

-(id) initWithTemplate: (NSString*)aTemplate {
  self = [super init];
  
  self.theTemplate = aTemplate;
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  htmlView = [[TTTAttributedLabel alloc]init];
  [self addSubview:htmlView]; 

  // Disable scrolling in WebView
  //
  //  for (id subview in webView.subviews) {
  //    if ([[subview class] isSubclassOfClass: [UIScrollView class]])
  //      ((UIScrollView *)subview).bounces = NO;
  //  }

  return self;
}

-(void)dealloc
{
  self.theTemplate = nil;
  [super dealloc];
}

-(NSString*)markup
{
  return [M3 interpolateString: self.theTemplate 
                    withValues: app.infoDictionary];
}

-(void)setKey: (id)key
{
  [super setKey:key];
  
  self.textLabel.text = @" ";

  htmlView.numberOfLines = 0;
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
}

- (CGFloat)wantsHeight
{
  return [self htmlViewSize].height + 14;
}

@end

@interface EmptyListActionCell : M3TableViewCell {
  UIButton* button;
}
@end

@implementation EmptyListActionCell

-(id) initWithURL: (NSString*)url andTitle: (NSString*)title {
  self = [super init];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  button = [UIButton actionButtonWithURL: url 
                                andTitle: title];

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

/** specific implementations**/

@interface EmptyListCell: StaticListCell
@end

@implementation EmptyListCell

-(id)init {
  NSString* tmpl = @"<h2><b>Hoppla!</b></h2>"
  "<p>Für Deine Auswahl liegen keine oder noch keine Informationen vor. "
  "Die Daten der Kinopilot-App aktualisieren sich selbständig. "
  "Du kannst aber eine Aktualisierung auch von Hand veranlassen.</p>"
  "<p></p>"
  "<p>Zeitpunkt des letzten Update: {{updated_at}}.</p>";
  
  return [super initWithTemplate: tmpl];
}
@end

@interface EmptyListUpdateActionCell: EmptyListActionCell
@end

@implementation EmptyListUpdateActionCell

-(id)init 
{
  return [super initWithURL:@"/action/update" andTitle:@"Aktualisieren!"];
}
@end

@interface NoFavsCell: StaticListCell
@end

@implementation NoFavsCell

-(id)init {
  NSString* tmpl = @"<h2><b>Lieblingskinos?</b></h2>"
  "<p></p>"
  "<p>Hier siehst Du immer alle Deine Lieblingskinos. Um ein Kino vorzumerken, aktiviere den Stern in der Kinoübersicht.</p>"
  "<p></p>";
  
  return [super initWithTemplate: tmpl];
}
@end

