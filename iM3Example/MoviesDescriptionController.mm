#import "AppBase.h"

@interface MoviesDescriptionController : UIViewController {
  UIButton* closeButton;
  UIView* label;
}

@property (nonatomic,readonly) NSDictionary* movie;

@end

@implementation MoviesDescriptionController

-(BOOL)isFullscreen
{
  return YES;
}

-(void)loadView
{
  [super loadView];
  
  closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  closeButton.frame = CGRectMake(320-50, 10, 50, 50);
  closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0]; // this has a alpha of 0. 
  [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal]; 
  
  [closeButton addTarget:self 
                  action:@selector(popNavigationController) 
        forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:closeButton];
}

-(NSString*)title
{
  [self.movie objectForKey: @"title"];
  return nil;
}

-(void)popNavigationController
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(NSDictionary*) movie
{
  NSString* movie_id = [self.url.to_url param: @"movie_id"]; 
  return [app.sqliteDB.movies get: movie_id];
}

-(UIView*)descriptionView
{
  TTTAttributedLabel* view = [[[TTTAttributedLabel alloc]initWithFrame: CGRectMake(30,0,260,480)]autorelease];
  view.numberOfLines = 0;
  view.backgroundColor = [UIColor colorWithName: @"#000"];
  
  NSString* description = [self.movie objectForKey:@"description"];
  NSString* markup = _.join(@"<p><b>Beschreibung: </b>", description.cdata, @"</p><br />");
  markup = _.join(@"<color name='#fff'>", markup, @"</color>");

  view.text = [NSAttributedString attributedStringWithMarkup: markup 
                                               forStylesheet: nil];
  return view;
}

- (void)reloadURL
{
  [label removeFromSuperview];
  label = [self descriptionView];  
  [self.view addSubview: label];
  [self.view bringSubviewToFront: closeButton];
}

@end
