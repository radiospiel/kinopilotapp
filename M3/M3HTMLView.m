#import <UIKit/UIKit.h>
#import "M3.h"

#define USE_NSATTRIBUTED_STRING 0
#define USE_WEBVIEW             0
#define USE_TTTATTRIBUTED_LABEL 1

/* NSAttributedString implementation */

#define ALLOW_IPHONE_SPECIAL_CASES 1
#define DT_USE_THREAD_SAFE_INITIALIZATION


#if USE_WEBVIEW

@implementation M3(AttributedText)

+(UIView*) createHTMLView: (NSString*)html;
{
  UIWebView* webView = [[UIWebView alloc]init];
  [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"/"]];  
  
  return webView;
}

@end

#endif

#if USE_NSATTRIBUTED_STRING

// --- import attributed string code -----------------------------------------

#import "NSAttributedString/Classes/CGUtils.h"
#import "NSAttributedString/Classes/CGUtils.m"
#import "NSAttributedString/Classes/DTAttributedTextCell.h"
#import "NSAttributedString/Classes/DTAttributedTextCell.m"
#import "NSAttributedString/Classes/DTAttributedTextContentView.h"
#import "NSAttributedString/Classes/DTAttributedTextContentView.m"
#import "NSAttributedString/Classes/DTAttributedTextView.h"
#import "NSAttributedString/Classes/DTAttributedTextView.m"
#import "NSAttributedString/Classes/DTCSSListStyle.h"
#import "NSAttributedString/Classes/DTCSSListStyle.m"
#import "NSAttributedString/Classes/DTCSSStylesheet.h"
#import "NSAttributedString/Classes/DTCSSStylesheet.m"
#import "NSAttributedString/Classes/DTCache.h"
#import "NSAttributedString/Classes/DTCache.m"
#import "NSAttributedString/Classes/DTCoreTextFontCollection.h"
#import "NSAttributedString/Classes/DTCoreTextFontCollection.m"
#import "NSAttributedString/Classes/DTCoreTextFontDescriptor.h"
#import "NSAttributedString/Classes/DTCoreTextFontDescriptor.m"
#import "NSAttributedString/Classes/DTCoreTextGlyphRun.h"
#import "NSAttributedString/Classes/DTCoreTextGlyphRun.m"
#import "NSAttributedString/Classes/DTCoreTextLayoutFrame.h"
#import "NSAttributedString/Classes/DTCoreTextLayoutFrame.m"
#import "NSAttributedString/Classes/DTCoreTextLayoutLine.h"
#import "NSAttributedString/Classes/DTCoreTextLayoutLine.m"
#import "NSAttributedString/Classes/DTCoreTextLayouter.h"
#import "NSAttributedString/Classes/DTCoreTextLayouter.m"
#import "NSAttributedString/Classes/DTCoreTextParagraphStyle.h"
#import "NSAttributedString/Classes/DTCoreTextParagraphStyle.m"
#import "NSAttributedString/Classes/DTHTMLElement.h"
#import "NSAttributedString/Classes/DTHTMLElement.m"
// #import "NSAttributedString/Classes/DTLazyImageView.h"
// #import "NSAttributedString/Classes/DTLazyImageView.m"
#import "NSAttributedString/Classes/DTLinkButton.h"
#import "NSAttributedString/Classes/DTLinkButton.m"
#import "NSAttributedString/Classes/DTRangedAttribute.h"
#import "NSAttributedString/Classes/DTRangedAttribute.m"
#import "NSAttributedString/Classes/DTRangedAttributesOptimizer.h"
#import "NSAttributedString/Classes/DTRangedAttributesOptimizer.m"
#import "NSAttributedString/Classes/DTTextAttachment.h"
#import "NSAttributedString/Classes/DTTextAttachment.m"
#import "NSAttributedString/Classes/DTWebVideoView.h"
#import "NSAttributedString/Classes/DTWebVideoView.m"

// #import "NSAttributedString/Classes/DemoAppDelegate.h"
// #import "NSAttributedString/Classes/DemoAppDelegate.m"
// #import "NSAttributedString/Classes/DemoSnippetsViewController.h"
// #import "NSAttributedString/Classes/DemoSnippetsViewController.m"
// #import "NSAttributedString/Classes/DemoTextViewController.h"
// #import "NSAttributedString/Classes/DemoTextViewController.m"

// #import "NSAttributedString/Classes/NSAttributedString+DTWebArchive.h"
// #import "NSAttributedString/Classes/NSAttributedString+DTWebArchive.m"

#import "NSAttributedString/Classes/NSAttributedString+HTML.h"
#import "NSAttributedString/Classes/NSAttributedString+HTML.m"

// #import "NSAttributedString/Classes/NSAttributedStringHTMLTest.h"
// #import "NSAttributedString/Classes/NSAttributedStringHTMLTest.m"

#import "NSAttributedString/Classes/NSAttributedStringRunDelegates.h"
#import "NSAttributedString/Classes/NSAttributedStringRunDelegates.m"
#import "NSAttributedString/Classes/NSCharacterSet+HTML.h"
#import "NSAttributedString/Classes/NSCharacterSet+HTML.m"
#import "NSAttributedString/Classes/NSData+Base64.h"
#import "NSAttributedString/Classes/NSData+Base64.m"
#import "NSAttributedString/Classes/NSMutableAttributedString+HTML.h"
#import "NSAttributedString/Classes/NSMutableAttributedString+HTML.m"
#import "NSAttributedString/Classes/NSScanner+HTML.h"
#import "NSAttributedString/Classes/NSScanner+HTML.m"
#import "NSAttributedString/Classes/NSString+HTML.h"
#import "NSAttributedString/Classes/NSString+HTML.m"
#import "NSAttributedString/Classes/NSString+UTF8Cleaner.h"
#import "NSAttributedString/Classes/NSString+UTF8Cleaner.m"
// #import "NSAttributedString/Classes/NSStringHTMLTest.h"
// #import "NSAttributedString/Classes/NSStringHTMLTest.m"
#import "NSAttributedString/Classes/NSURL+HTML.h"
#import "NSAttributedString/Classes/NSURL+HTML.m"
#import "NSAttributedString/Classes/UIColor+HTML.h"
#import "NSAttributedString/Classes/UIColor+HTML.m"
// #import "NSAttributedString/Classes/UIColorHTMLTest.h"
// #import "NSAttributedString/Classes/UIColorHTMLTest.m"
#import "NSAttributedString/Classes/UIDevice+DTVersion.h"
#import "NSAttributedString/Classes/UIDevice+DTVersion.m"

// ---------------------------------------------------------------------------

#import "M3.h"

@interface DTAttributedTextContentView(M3Additions)
@end

@implementation DTAttributedTextContentView(M3Additions)

-(void)setHTML:(NSString*)html
{
  NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
  NSAttributedString* htmlString;
  htmlString = [NSAttributedString attributedStringWithHTML:data 
                                                    options:nil]; // (NSDictionary *)options;

  [self setAttributedString:htmlString];
}

@end

@implementation M3(AttributedText)

+(UIView*) createHTMLView: (NSString*)html;
{
  UIView* view = [[DTAttributedTextContentView alloc]init];
  [view setHTML: html];

  return view;
}

@end

#endif

#if USE_TTTATTRIBUTED_LABEL

#define DT_USE_THREAD_SAFE_INITIALIZATION

//#import "NSAttributedString/Classes/NSString+HTML.h"
//#import "NSAttributedString/Classes/NSString+HTML.m"

#import "NSAttributedString/Classes/CGUtils.h"
#import "NSAttributedString/Classes/CGUtils.m"

#import "NSAttributedString/Classes/DTCSSListStyle.h"
#import "NSAttributedString/Classes/DTCSSListStyle.m"
#import "NSAttributedString/Classes/DTCSSStylesheet.h"
#import "NSAttributedString/Classes/DTCSSStylesheet.m"
// #import "NSAttributedString/Classes/DTCache.h"
// #import "NSAttributedString/Classes/DTCache.m"
// #import "NSAttributedString/Classes/DTCoreTextFontCollection.h"
// #import "NSAttributedString/Classes/DTCoreTextFontCollection.m"
#import "NSAttributedString/Classes/DTCoreTextFontDescriptor.h"
#import "NSAttributedString/Classes/DTCoreTextFontDescriptor.m"
// #import "NSAttributedString/Classes/DTCoreTextGlyphRun.h"
// #import "NSAttributedString/Classes/DTCoreTextGlyphRun.m"
// #import "NSAttributedString/Classes/DTCoreTextLayoutFrame.h"
// #import "NSAttributedString/Classes/DTCoreTextLayoutFrame.m"
// #import "NSAttributedString/Classes/DTCoreTextLayoutLine.h"
// #import "NSAttributedString/Classes/DTCoreTextLayoutLine.m"
// #import "NSAttributedString/Classes/DTCoreTextLayouter.h"
// #import "NSAttributedString/Classes/DTCoreTextLayouter.m"
#import "NSAttributedString/Classes/DTCoreTextParagraphStyle.h"
#import "NSAttributedString/Classes/DTCoreTextParagraphStyle.m"
#import "NSAttributedString/Classes/DTHTMLElement.h"
#import "NSAttributedString/Classes/DTHTMLElement.m"
// #import "NSAttributedString/Classes/DTLazyImageView.h"
// #import "NSAttributedString/Classes/DTLazyImageView.m"
// #import "NSAttributedString/Classes/DTLinkButton.h"
// #import "NSAttributedString/Classes/DTLinkButton.m"
// #import "NSAttributedString/Classes/DTRangedAttribute.h"
// #import "NSAttributedString/Classes/DTRangedAttribute.m"
// #import "NSAttributedString/Classes/DTRangedAttributesOptimizer.h"
// #import "NSAttributedString/Classes/DTRangedAttributesOptimizer.m"
#import "NSAttributedString/Classes/DTTextAttachment.h"
#import "NSAttributedString/Classes/DTTextAttachment.m"

#import "NSAttributedString/Classes/NSAttributedStringRunDelegates.h"
#import "NSAttributedString/Classes/NSAttributedStringRunDelegates.m"

#import "NSAttributedString/Classes/NSAttributedString+HTML.h"
#import "NSAttributedString/Classes/NSAttributedString+HTML.m"
#import "NSAttributedString/Classes/NSScanner+HTML.h"
#import "NSAttributedString/Classes/NSScanner+HTML.m"
#import "NSAttributedString/Classes/NSString+HTML.h"
#import "NSAttributedString/Classes/NSString+HTML.m"
#import "NSAttributedString/Classes/NSString+UTF8Cleaner.h"
#import "NSAttributedString/Classes/NSString+UTF8Cleaner.m"

#import "TTTAttributedLabel/TTTAttributedLabel.h"
#import "TTTAttributedLabel/TTTAttributedLabel.m"

@implementation M3(AttributedText)

+(UIView*) createHTMLView: (NSString*)html;
{
  NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
  NSAttributedString* htmlString;
  htmlString = [NSAttributedString attributedStringWithHTML:data 
                                                    options:nil]; // (NSDictionary *)options;
  
  TTTAttributedLabel* view = [[TTTAttributedLabel alloc]init];
  [view setText: htmlString];
  // view se
  // [self setAttributedString:htmlString];

  
  //  UIView* view = [[DTAttributedTextContentView alloc]init];
  //  [view setHTML: html];
  
  return view;
}

@end


#endif

