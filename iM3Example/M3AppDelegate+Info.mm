#import "M3AppDelegate.h"

@implementation M3AppDelegate(AppInfo)

static id infoForKey(NSString *key)
{
  if([key isEqualToString: @"updated_at"]) { 
    NSNumber* updated_at = [app.sqliteDB.settings objectForKey: @"updated_at"]; 
    if(updated_at)
      return [updated_at.to_date stringWithFormat: @"dd.MM.yyyy HH:mm"];
  
    return @"Kinopilot wurde nocht nicht aktualisiert.";
  }
 
  if([key isEqualToString: @"revision"])
    return [app.sqliteDB.settings objectForKey: @"revision"]; 
  
  if([key isEqualToString: @"theaters_count"])
    return app.sqliteDB.theaters.count;
  
  if([key isEqualToString: @"movies_count"])
    return app.sqliteDB.movies.count; 
  
  if([key isEqualToString: @"schedules_count"])
    return app.sqliteDB.schedules.count;
  
  if([key isEqualToString: @"built_at"])
    return [NSString stringWithFormat: @"%s %s", __DATE__, __TIME__]; 
  
  return key;
}

-(NSDictionary*) infoDictionary
{
  NSArray* keys = _.array(@"updated_at", @"revision", @"theaters_count", @"movies_count", @"schedules_count", @"built_at");

  NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
  for(NSString* key in keys) {
    id value = infoForKey(key);
    if(!value) continue;
    
    [dictionary setObject: value forKey: key];
  }
  
  return dictionary;
}

@end
