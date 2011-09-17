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
#import "NSArray+Globbing.h"
#import "NSString+Regexp.h"

#import "M3MemoryManagement.h"

#import "M3+Comparison.h"
#import "M3+Crypto.h"
#import "M3+Events.h"
#import "M3+FileIO.h"
#import "M3+Filenames.h"
#import "M3+JSON.h"
#import "M3+Inflector.h"

#import "M3StopWatch.h"
#import "M3Exception.h"
#import "M3Etest.h"
#import "M3EventCenter.h"

#import "M3Http.h"
#import "M3Data.h"

#ifdef __cplusplus
#import "underscore.hh"
#endif

