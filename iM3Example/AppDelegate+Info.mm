#import "AppDelegate.h"

@interface AppInfo: NSObject
@end

// --- Custom values ---------

@implementation AppInfo

+(NSString*) updated_at
{ 
  NSDictionary* stats = app.chairDB.stats.first;
  NSNumber* updated_at = [stats objectForKey: @"updated_at"]; 
  return [updated_at.to_date stringWithFormat: @"dd.MM.yyyy HH:mm"];
}

+(NSString*) theaters_count
  { return [NSString stringWithFormat: @"%d", app.chairDB.theaters.count]; }

+(NSString*) movies_count
  { return [NSString stringWithFormat: @"%d", app.chairDB.movies.count]; }

+(NSString*) schedules_count
  { return [NSString stringWithFormat: @"%d", app.chairDB.schedules.count]; }

+(NSString*) built_at
  { return [NSString stringWithFormat: @"%s %s", __DATE__, __TIME__]; }

@end

@implementation AppDelegate(Info)

-(NSString*)infoForKey: (NSString*)name
{
  SEL selector = NSSelectorFromString(name);
  if(![AppInfo respondsToSelector: selector]) 
    return name;
  
  return [AppInfo performSelector:selector];
}

@end
