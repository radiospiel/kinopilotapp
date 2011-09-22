//
//  MoviesListController.m
//  M3
//
//  Created by Enrico Thierbach on 22.09.11.
//  Copyright (c) 2011 n/a. All rights reserved.
//

#import "MoviesListController.h"
#import "AppDelegate.h"

@interface MoviesListCell: UITableViewCell
@end

@implementation  MoviesListCell

- (void) layoutSubviews
{   
  [super layoutSubviews];
  self.imageView.frame = CGRectMake(3, 4, 33, 42); // your positioning here
}

@end


#define app ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@implementation MoviesListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
  [super dealloc];
}

#pragma mark - View lifecycle

-(void)addSegment:(NSString*)label withURL: (NSString*)url
{
  [segmentedControl_ insertSegmentWithTitle: label
                                    atIndex: segmentedControl_.numberOfSegments
                                   animated: NO];  

  [segmentURLs_ addObject: url];
  
  if(segmentedControl_.numberOfSegments == 1) {
    [segmentedControl_ setSelectedSegmentIndex:0];
  }
}

-(void)activateSegment:(UIGestureRecognizer *)segmentedControl
{
  dlog << "activateSegment: " << [segmentedControl_ selectedSegmentIndex];
  // open URL.
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Do any additional setup after loading the view from its nib.
  segmentedControl_ = [[UISegmentedControl alloc]init];
  segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;

  [segmentedControl_ addTarget:self
                        action:@selector(activateSegment:)
              forControlEvents:UIControlEventValueChanged];
              
  segmentURLs_ = [[NSMutableArray alloc]init];

  [self addSegment: @"all" withURL: @"/movies/list/all"];
  [self addSegment: @"new" withURL: @"/movies/list/new"];
  [self addSegment: @"hot" withURL: @"/movies/list/hot"];
  [self addSegment: @"fav" withURL: @"/movies/list/fav"];
  [self addSegment: @"art" withURL: @"/movies/list/fav"];
  
  segmentedControl_.frame = CGRectMake(0,0,160,32);
  
#if 0
  self.navigationItem.titleView = segmentedControl_;  
#else
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView: segmentedControl_];
#endif
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(id)keyForRow: (NSInteger)row
{
  NSArray* keys = [self memoized:@selector(chairKeys) usingBlock:^{
    return app.chairDB.movies.keys;
  }];
 
  return [keys objectAtIndex:row]; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  // get a reusable or create a new table cell
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[[MoviesListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  // fill in table cell
  NSString* key = [self keyForRow:indexPath.row];
  NSDictionary* movie = [app.chairDB.movies get: key];
  
  cell.textLabel.text = [ movie objectForKey: @"title"]; // [NSString stringWithFormat:@"%d", indexPath.row];
  cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
  cell.detailTextLabel.text = [ movie objectForKey: @"title"];  
  cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
  cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];

  cell.imageView.image = [UIImage imageNamed:@"no_poster.png"];
  
  NSArray* images = [movie valueForKey:@"images"];
  if([images.first isKindOfClass:[NSDictionary class]]) {
    cell.imageView.imageURL = [images.first objectForKey:@"thumbnail"]; 
  }
  
  
  return cell;
}

-(NSString*)title
{
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [ app.chairDB.movies count];
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
  dlog << "Clicked row " << indexPath.row;
  NSString* url = _.join(@"/movies/show/", [self keyForRow: indexPath.row]);
  [app open: url];
}
@end

/* The previous layout is as follows: */

#if 0

//
// 
// Parameters:
//    title
//    subtitle
//    image
//
//
//    TA    IMG   LABEL 
//   STAR   IMG   DESCRIPTION
//   S  R   IMG   TAGS

App.Partials.listing = function(rec, options) {
  var className = "listing";
  
  //
  // left positions for img, and for texts (label and description)
  var left = 0;
  if(options && options.stars) {
    className += "_stars";
    if(!rec.img) {
      rec.img = "img/no_poster.png"
    } 
  }
  
  if(rec.img) className += "_img";
  if(rec.tags) className += "_tags";
  
  var row = Titanium.UI.createTableViewRow({
  className: className,
  height: 50
  });
  
  if(options && options.stars) {
    var star_img = App.is_starred(rec) ? 'img/star.png' : 'img/unstar.png';
    var star_img_view = App.imageView({image:star_img,
    width:16, height:16,
    left:7, top:17
    });
    
    row.add(star_img_view);
    left = 30;
    
    row.update_star = function(is_starred) {
      star_img_view.image = is_starred ? 'img/star.png' : 'img/unstar.png';
    };
  }
  
  if(rec.hasOwnProperty("img")) {
    left += 3;
    
    row.add(App.imageView({image:rec.img || "img/no_poster.png", 
    width:33, height:42,
    left:left, top:4
    }));
    
    left += 33;
  }
  
  if(rec.tags) {
    row.add(Titanium.UI.createLabel({
    text: " " + rec.tags + " ",
    font: Font.bold(9),
    color: "#fff",
    borderRadius: 3,
    backgroundColor: "#f60",
    textAlign:'center',
    top:4, 
    left: left + 3,
    width: 30,
    height: 14
    }));
  }
  
  left += 4;
  var label = Titanium.UI.createLabel({
  text: rec.title || rec.name,
  font: Font.bold(14),
  width: 290 - left,
  textAlign:'left',
  top:3, 
  left:left + (rec.tags ? 32 : 0), height:16
  });
  row.add(label);
  
  row.search = rec.title || rec.name;
  
  var description = rec.subtitle || rec.teaser || rec.address;
  var limited_description = String.truncate(description, 2);
  
  row.add(Titanium.UI.createLabel({
  text: limited_description,
  font: Font.normal(11),
  color: "#333",
  textAlign:'left',
  top:18, 
  left: left,
  width: 290 - left,
  height: limited_description === description ? 'auto' : 32
  }));
  
  return row;  
};
#endif

// For animating cell heights:
// http://stackoverflow.com/questions/460014/can-you-animate-a-height-change-on-a-uitableviewcell-when-selected/2063776#2063776
