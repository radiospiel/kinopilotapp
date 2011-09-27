//
//  NSAttributedString+WithSimpleMarkup.m
//  M3
//
//  Created by Enrico Thierbach on 26.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

//
// Here is a bit on attributed strings:
//
// http://iphonedevelopment.blogspot.com/2011/03/attributed-strings-in-ios.html
//

#import "M3.h"
#import "NSAttributedString+WithSimpleMarkup.h"

#if TARGET_OS_IPHONE 
#import <CoreText/CoreText.h>
#endif

@interface M3AttributedStringBuilder: NSObject<NSXMLParserDelegate> {
  NSMutableAttributedString* attributedString_;
  NSString* fontName;
  int fontSize;
  // UIColor* color;
  BOOL bold;
  BOOL italic;
};

// returns an autoreleased instance of the attributedString.
-(NSMutableAttributedString*)attributedString;

@property (retain,nonatomic) NSString* fontName;
@property (assign,nonatomic) int fontSize;
// @property (retain,nonatomic) UIColor* color;
@property (getter=isBold,assign,nonatomic) BOOL bold;
@property (getter=isItalic,assign,nonatomic) BOOL italic;

@end

@implementation M3AttributedStringBuilder

@synthesize fontName, fontSize, /* color, */ bold, italic;

-(id)init
{
  self = [super init];
  attributedString_ = [[NSMutableAttributedString alloc]init];
  
  fontName = @"Helvetica";
  fontSize = 13;
  // color = nil;
  
  return self;
}

-(void)dealloc
{
  [attributedString_ release];
  [super dealloc];
}

-(NSMutableAttributedString*)attributedString
{
  return attributedString_;
}

-(CTFontRef) createFontRef
{
  // A list of font names is available here
  // http://sree.cc/iphone/some-ios-fonts-available-for-iphone-apps
  
  NSMutableArray* parts = [NSMutableArray array];
  [parts addObject: @"Helvetica"];
  
  if(self.bold || self.italic)
    [parts addObject: @"-"];
   
  if(self.bold)
    [parts addObject: @"Bold"];

  if(self.italic)
    [parts addObject: @"Oblique"];


  NSString* name = [parts componentsJoinedByString:@""];
  
  return CTFontCreateWithName((CFStringRef)name, fontSize, NULL);
}

- (void)add:(NSString*)string
{
  // -- create string ----------------------------
  
  CFMutableAttributedStringRef attrString;
  attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
  CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), (CFStringRef)string);
  
  // -- set color ----------------------------

  //  if(color != nil) {
  //    CFAttributedStringSetAttribute(attrString, 
  //      CFRangeMake(0, CFAttributedStringGetLength(attrString)), 
  //      kCTForegroundColorAttributeName, color.CGColor);
  //  }
  
  // -- set font ----------------------------

  CTFontRef theFont = [self createFontRef];
  CFAttributedStringSetAttribute(attrString,
    CFRangeMake(0, CFAttributedStringGetLength(attrString)), 
    kCTFontAttributeName, theFont);
  CFRelease(theFont);

  // -- set paragraph style ----------------------------
  
  CTTextAlignment alignment = kCTNaturalTextAlignment;
  CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment};
  CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
  CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);    
  CFRelease(paragraphStyle);

  // --- append the attributedString -------------------
  
  NSMutableAttributedString *nsAttrString = (NSMutableAttributedString *)attrString;
  [attributedString_ appendAttributedString: nsAttrString];
  [nsAttrString autorelease];
}

- (void)parser:(NSXMLParser *)parser 
    didStartElement:(NSString *)elementName 
       namespaceURI:(NSString *)namespaceURI 
      qualifiedName:(NSString *)qualifiedName 
         attributes:(NSDictionary *)attributeDict
{
  if([elementName isEqualToString:@"b"])
    self.bold = YES;
  else if([elementName isEqualToString:@"i"])
    self.italic = YES;
  else if([elementName isEqualToString:@"h1"])
    self.fontSize = 18;
  else if([elementName isEqualToString:@"h2"])
    self.fontSize = 15;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  if([elementName isEqualToString:@"p"])
    [self add: @"\n"];
  else if([elementName isEqualToString:@"br"])
    [self add: @"\n"];
  else if([elementName isEqualToString:@"b"])
    self.bold = NO;
  else if([elementName isEqualToString:@"i"])
    self.italic = NO;
  else if([elementName isEqualToString:@"h1"]) {
    self.fontSize = 13;
    [self add: @"\n"];
  }
  else if([elementName isEqualToString:@"h2"]) {
    self.fontSize = 13;
    [self add: @"\n"];
  }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)data
{
  NSString* string = [[NSString alloc]initWithData: data encoding:NSUTF8StringEncoding];
  [self add: string];
  [string release];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  [self add: string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
  [self add: [parseError description]];
}
@end


@implementation NSAttributedString (WithSimpleMarkup)

+ (NSAttributedString*)attributedStringWithSimpleMarkup:(NSString *)html 
{
  html = [html stringByReplacingOccurrencesOfString:@"\n\n" withString:@"<br /><br />"];
  
  NSString* format = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<!DOCTYPE addresses SYSTEM \"addresses.dtd\">\n"
    "<body>%@</body>\n";
    
  html = [NSString stringWithFormat: format, html];
    
  NSData* xmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
  NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
    
  M3AttributedStringBuilder* builder = [[M3AttributedStringBuilder alloc]init];
  [parser setDelegate:builder];

  // [parser setShouldResolveExternalEntities:NO];
  [parser parse]; // if not successful, delegate is informed of error
  [parser release];
    
  NSAttributedString* r = [[builder attributedString]retain];
  [builder release];
  
  return [r autorelease];
}

@end

#if 0

/* === A font list =========================================================== */

REGISTER_FONTNAME("Arial", @"ArialMT");
REGISTER_FONTNAME("Arial,bold", @"Arial-BoldMT");
REGISTER_FONTNAME("Arial,bold,italic", @"Arial-BoldItalicMT");
REGISTER_FONTNAME("Arial,italic", @"Arial-ItalicMT");
REGISTER_FONTNAME("Baskerville", @"Baskerville");
REGISTER_FONTNAME("Baskerville,bold", @"Baskerville-SemiBold");
REGISTER_FONTNAME("Baskerville,bold,italic", @"Baskerville-SemiBoldItalic");
REGISTER_FONTNAME("Baskerville,italic", @"Baskerville-Italic");
REGISTER_FONTNAME("Cochin", @"Cochin");
REGISTER_FONTNAME("Cochin,bold", @"Cochin-Bold");
REGISTER_FONTNAME("Cochin,bold,italic", @"Cochin-BoldItalic");
REGISTER_FONTNAME("Cochin,italic", @"Cochin-Italic");
REGISTER_FONTNAME("Courier", @"Courier");
REGISTER_FONTNAME("Courier,bold", @"Courier-Bold");
REGISTER_FONTNAME("Courier,bold,italic", @"Courier-BoldOblique");
REGISTER_FONTNAME("Courier,italic", @"Courier-Oblique");
REGISTER_FONTNAME("Courier New", @"CourierNewPSMT");
REGISTER_FONTNAME("Courier New,bold", @"CourierNewPS-BoldMT");
REGISTER_FONTNAME("Courier New,bold,italic", @"CourierNewPS-BoldItalicMT");
REGISTER_FONTNAME("Courier New,italic", @"CourierNewPS-ItalicMT");
REGISTER_FONTNAME("Georgia", @"Georgia");
REGISTER_FONTNAME("Georgia,bold", @"Georgia-Bold");
REGISTER_FONTNAME("Georgia,bold,italic", @"Georgia-BoldItalic");
REGISTER_FONTNAME("Georgia,italic", @"Georgia-Italic");
REGISTER_FONTNAME("Gill Sans", @"GillSans");
REGISTER_FONTNAME("Gill Sans,bold", @"GillSans-Bold");
REGISTER_FONTNAME("Gill Sans,bold,italic", @"GillSans-BoldItalic");
REGISTER_FONTNAME("Gill Sans,italic", @"GillSans-Italic");
REGISTER_FONTNAME("Helvetica", @"Helvetica");
REGISTER_FONTNAME("Helvetica,bold", @"Helvetica-Bold");
REGISTER_FONTNAME("Helvetica,bold,italic", @"Helvetica-BoldOblique");
REGISTER_FONTNAME("Helvetica,italic", @"Helvetica-Oblique");
REGISTER_FONTNAME("Helvetica Neue", @"HelveticaNeue");
REGISTER_FONTNAME("Helvetica Neue,bold", @"HelveticaNeue-Bold");
REGISTER_FONTNAME("Helvetica Neue,bold,italic", @"HelveticaNeue-BoldItalic");
REGISTER_FONTNAME("Helvetica Neue,italic", @"HelveticaNeue-Italic");
REGISTER_FONTNAME("Hoefler Text", @"HoeflerText-Regular");
REGISTER_FONTNAME("Hoefler Text,bold", @"HoeflerText-Black");
REGISTER_FONTNAME("Hoefler Text,bold,italic", @"HoeflerText-BlackItalic");
REGISTER_FONTNAME("Hoefler Text,italic", @"HoeflerText-Italic");
REGISTER_FONTNAME("Optima", @"Optima-Regular");
REGISTER_FONTNAME("Optima,bold", @"Optima-Bold");
REGISTER_FONTNAME("Optima,bold,italic", @"Optima-BoldItalic");
REGISTER_FONTNAME("Optima,italic", @"Optima-Italic");
REGISTER_FONTNAME("Palatino", @"Palatino-Roman");
REGISTER_FONTNAME("Palatino,bold", @"Palatino-Bold");
REGISTER_FONTNAME("Palatino,bold,italic", @"Palatino-BoldItalic");
REGISTER_FONTNAME("Palatino,italic", @"Palatino-Italic");
REGISTER_FONTNAME("Times New Roman", @"TimesNewRomanPSMT");
REGISTER_FONTNAME("Times New Roman,bold", @"TimesNewRomanPS-BoldMT");
REGISTER_FONTNAME("Times New Roman,bold,italic", @"TimesNewRomanPS-BoldItalicMT");
REGISTER_FONTNAME("Times New Roman,italic", @"TimesNewRomanPS-ItalicMT");
REGISTER_FONTNAME("Trebuchet MS", @"TrebuchetMS");
REGISTER_FONTNAME("Trebuchet MS,bold", @"TrebuchetMS-Bold");
REGISTER_FONTNAME("Trebuchet MS,bold,italic", @"Trebuchet-BoldItalic");
REGISTER_FONTNAME("Trebuchet MS,italic", @"TrebuchetMS-Italic");
REGISTER_FONTNAME("Verdana", @"Verdana");
REGISTER_FONTNAME("Verdana,bold", @"Verdana-Bold");
REGISTER_FONTNAME("Verdana,bold,italic", @"Verdana-BoldItalic");
REGISTER_FONTNAME("Verdana,italic", @"Verdana-Italic");

#endif
