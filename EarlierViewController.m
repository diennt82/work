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
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [[NSBundle mainBundle] loadNibNamed:@"EarlierViewController_iPad"
//                                      owner:self
//                                    options:nil];
//    }
    
    self.timelineVC = [[TimelineViewController alloc] init];
    
    //NSLog(@"%@, %@", timelineVC.camChannel, _camChannel);
    
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_timelineVC];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:[[SavedEventViewController alloc] init]];
    
    self.viewControllers = [NSArray arrayWithObjects:_timelineVC, nav1, nil];
    
    UITabBarItem *timelineItem = [self.tabBar.items objectAtIndex:0];
    [timelineItem setImage:[UIImage imageNamed:@"camera.png"]];
    
    UITabBarItem *savedItem = [self.tabBar.items objectAtIndex:1];
    [savedItem setImage:[UIImage imageNamed:@"general"]];
 
    
    //[nav release];
    [nav1 release];
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"EarlierViewController: %@", NSStringFromCGRect(self.view.frame));
    
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
            self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(84, 0, 44, 0);
        } else
        {
            self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(84, 0, 64, 0);
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
    [super dealloc];
}

@end
