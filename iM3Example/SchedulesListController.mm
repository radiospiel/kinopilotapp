#import "SchedulesListController.h"
#import "AppDelegate.h"

@implementation SchedulesListController

-(NSDictionary*)parameters
{
  NSDictionary* parameters = nil;
  
  if([self.url matches: @"/schedules/list\\?theater_id=(.*)&movie_id=(.*)"]) 
    parameters = _.hash(@"theater_id", $1, @"movie_id", $2);
  else if([self.url matches: @"/schedules/list\\?movie_id=(.*)&theater_id=(.*)"]) 
    parameters = _.hash(@"movie_id", $1, @"theater_id", $2);
  
  return parameters;
}

-(NSString*)title
{
  return nil;
}

-(NSDictionary*)theater
{
  return [app.chairDB.theaters get: self.theater_id];
}

-(NSString*)theater_id
{
  NSString* theater_id = [[self parameters] objectForKey: @"theater_id"];
  
  DLOG(theater_id);
  
  return theater_id;
}

-(NSDictionary*)movie
{
  return [app.chairDB.movies get: self.movie_id];
}

-(NSString*)movie_id
{
  return [[self parameters] objectForKey: @"movie_id"];
}

-(UIView*) headerView
{
  NSDictionary* theater = self.theater;
  NSDictionary* movie = self.movie;
  
  M3ProfileView* pv = [[[M3ProfileView alloc]init]autorelease];
  
  // -- set descriptions
  
  {
    NSMutableString* html = [NSMutableString string];
    
    NSString* name = [theater objectForKey:@"name"];
    NSString* title = [movie objectForKey:@"title"];
    
    [html appendFormat:@"<h2><b>%@</b>, im <b>%@</b></h2>", title.cdata, name.cdata];
    
    NSString* address = [theater objectForKey:@"address"];
    if(address)
      [html appendFormat: @"<p>%@</p>", address.cdata]; 
    
    [pv setHtmlDescription:html];
  }
  
  // -- set actions
  
  {
    NSMutableArray* actions = _.array();
    
    NSString* address = [theater objectForKey:@"address"];
    
    if(address)
      [actions addObject: _.array(@"Fahrinfo", _.join(@"fahrinfo-berlin://connection?to=", address.urlEscape))];
    
    NSString* fon = [theater objectForKey:@"telephone"];
    if(fon)
      [actions addObject: _.array(@"Fon", _.join(@"tel://", fon.urlEscape))];
    
    NSString* web = [theater objectForKey:@"website"];
    if(web)
      [actions addObject: _.array(@"Website", web)];
    
    [pv setActions: actions];
  }
  
  // -- add a map view
  
  {
    NSArray* latlong = [theater objectForKey:@"latlong"];
    [pv setCoordinate: CLLocationCoordinate2DMake([latlong.first floatValue], [latlong.second floatValue])];
  }  
  
  NSString* url = _.join(@"/map/show?theater_id=", [theater objectForKey:@"_uid" ]);
  
  [pv setProfileURL:url];
  
  // --- adjust size
  
  pv.frame = CGRectMake(0, 0, 320, [pv wantsHeight]);
  return pv;
}

-(void)loadFromUrl:(NSString *)url
{
  self.dataSource = nil;

  // if(!url)
  //   self.dataSource = nil;
  // else if([self.url matches: @"/movies/list\\?theater_id=(.*)"])
  //   self.dataSource = [M3DataSource moviesListFilteredByTheater:$1]; 
  // else if([self.url matches: @"/movies/list\\?filter=(.*)"])
  //   self.dataSource = [M3DataSource moviesListWithFilter: $1];
  // else
  //   self.dataSource = [M3DataSource moviesListWithFilter: @"new"];
  
  self.tableView.tableHeaderView = [self headerView];
}

@end
