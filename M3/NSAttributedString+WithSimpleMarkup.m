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

#import <CoreText/CoreText.h>

@interface M3AttributedStringBuilder: NSObject<NSXMLParserDelegate> {
  NSMutableAttributedString* attributedString_;
  NSString* fontName;
  int fontSize;
  UIColor* color;
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
  color = nil;
  
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
  NSLog(@"didStartElement %@", elementName);
  
  if([elementName isEqualToString:@"b"])
    self.bold = YES;
  else if([elementName isEqualToString:@"i"])
    self.italic = YES;
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

