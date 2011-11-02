#import "AppDelegate.h"
#import "M3ListViewController.h"

@implementation M3ListViewController

-(id)init
{
  self = [super init];

  [app.chairDB on: @selector(updated) notify:self with:@selector(reload)];
  [app on: @selector(resumed) notify:self with:@selector(reload)];
  
  return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  NSString* text = [self.dataSource tableView:tableView titleForHeaderInSection:section];
  if(!text) return 0;
	return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSString* text = [self.dataSource tableView:tableView titleForHeaderInSection:section];
  if(!text) return nil;
  
  UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)]autorelease];
  header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-background-dark-22.png"]]; 
  
  UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(7, 0, 308, 22)]autorelease];
  label.backgroundColor = [UIColor clearColor];
  label.opaque = NO;
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont boldSystemFontOfSize:15];
  label.lineBreakMode = UILineBreakModeMiddleTruncation;
  label.text = text;

  [header addSubview:label];

  return header;
}

@end
