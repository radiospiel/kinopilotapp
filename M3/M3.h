#import <Foundation/Foundation.h>

/* Sync NDEBUG setting w/DEBUG setting. NDEBUG is C standard, while DEBUG is Apple's Objective-C standard. */

#ifdef DEBUG
#undef NDEBUG
#else
#define NDEBUG
#endif

/* The M3 namespace */
@interface M3: NSObject
@end

#import "NSString+M3Extensions.h"
#import "NSArray+M3Extensions.h"
#import "NSDate+M3Extensions.h"
#import "NSString+Regexp.h"
#import "NSObject+Ivars.h"

#import "M3MemoryManagement.h"

#import "M3+Caller.h"
#import "M3+Comparison.h"
#import "M3+Crypto.h"

#import "M3+Events.h"
#import "M3+FileIO.h"
#import "M3+Filenames.h"
#import "M3+JSON.h"
#import "M3+Inflector.h"
#import "M3+Inspect.h"
#import "M3+RuntimeError.h"

#import "M3StopWatch.h"
#import "M3Exception.h"
#import "M3Etest.h"
#import "M3EventCenter.h"

#import "M3Http.h"


#ifdef __cplusplus
#import "underscore.hh"
#endif

/* iOS additions */
#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#import "UIImageView+Http.h"
#import "UIColor+M3Extensions.h"

#endif


#define M3AssertKindOf(var, type) NSCParameterAssert([var isKindOfClass: [type class]])

#import "NSAttributedString+WithSimpleMarkup.h"
