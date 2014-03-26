//
//  EarlierViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "EarlierViewController.h"
#import "SavedEventViewController.h"
#import "define.h"

@interface EarlierViewController ()

@property (nonatomic) BOOL isDidLoad;

@end

@implementation EarlierViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCamChannel: (CamChannel *)camChannel
{
    self = [super init];
    
    self.camChannel = camChannel;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    self.timelineVC = [[TimelineViewController alloc] init];
    SavedEventViewController *savedViewController = [[SavedEventViewController alloc] initWithNibName:@"SavedEventViewController" bundle:nil];
    [_timelineVC setTitle:@"Timeline"];
    [savedViewController setTitle:@"Saved"];
    NSArray *viewControllers = @[_timelineVC, savedViewController];
   
    
    _tabBarController = [[MHTabBarController alloc] init];
    
	_tabBarController.delegate = self;
	_tabBarController.viewControllers = viewControllers;
    
    [self.view addSubview:_tabBarController.view];
    
    //load event for timeline
    if (_isDidLoad == FALSE)
    {
        if ([self.camChannel.profile isNotAvailable])
        {
            self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
        self.isDidLoad = TRUE;
        [_timelineVC loadEvents:_camChannel];
        self.timelineVC.navVC = _nav;
        if ((isiPhone4 || isiPhone5))
        {
            self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(5, 0, 44, 0);
        } else
        {
            self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(5, 0, 64, 0);
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_timelineVC release];
    [_tabBarController release];
    [super dealloc];
}


#pragma mark - Custom tab bar delegate
- (BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
	NSLog(@"mh_tabBarController %@ shouldSelectViewController %@ at index %u", tabBarController, viewController, index);
    
	// Uncomment this to prevent "Tab 3" from being selected.
	//return (index != 2);
    
	return YES;
}

- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
	NSLog(@"mh_tabBarController %@ didSelectViewController %@ at index %u", tabBarController, viewController, index);
}


@end
