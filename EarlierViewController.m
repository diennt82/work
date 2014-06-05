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
#import "PublicDefine.h"
#import "UIColor+Hubble.h"

@interface EarlierViewController ()

@property (nonatomic) BOOL isDidLoad;
@property (nonatomic, assign) id parentVC;

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
    
    if (self)
    {
        self.camChannel = camChannel;
    }
    
    return self;
}

- (id)initWithParentVC: (id)parentVC camChannel: (CamChannel *)camChannel
{
    self = [super init];
    
    if (self)
    {
        self.parentVC = parentVC;
        self.camChannel = camChannel;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([_camChannel.profile isNotAvailable])
    {
        self.navigationItem.hidesBackButton = YES;
        self.navigationController.navigationBarHidden = NO;
        UIBarButtonItem *earlierBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Earlier"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:nil
                                                                        action:nil];
        [earlierBarBtn setTitleTextAttributes:@{
                                                NSFontAttributeName: [UIFont fontWithName:PN_SEMIBOLD_FONT size:17.0],
                                                NSForegroundColorAttributeName: [UIColor barItemSelectedColor]
                                                } forState:UIControlStateNormal];
        earlierBarBtn.enabled = NO;
        self.navigationItem.rightBarButtonItem = earlierBarBtn;
        [self addHubbleLogo_Back];
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
    }
    
    self.timelineVC = [[TimelineViewController alloc] init];
    [_timelineVC setTitle:@"Timeline"];
    
    NSArray *viewControllers;
    
    if (CUE_RELEASE_FLAG)
    {
        viewControllers = @[_timelineVC];
    }
    else
    {
        SavedEventViewController *savedViewController = [[SavedEventViewController alloc] initWithNibName:@"SavedEventViewController" bundle:nil];
        [savedViewController setTitle:@"Saved"];
        viewControllers = @[_timelineVC, savedViewController];
    }
    
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
            self.timelineVC.navVC = self.navigationController;
        }
        else
        {
            self.timelineVC.navVC = _nav;
            self.timelineVC.timelineVCDelegate = self.parentVC;
        }
        
        self.isDidLoad = TRUE;
        [_timelineVC loadEvents:_camChannel];
        
        self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(5, 0, 64, 0);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.timelineVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }
    
    NSLog(@"EarlierVC - view: %@, timeline: %@, timelineContentSize: %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.timelineVC.view.frame), NSStringFromUIEdgeInsets(self.timelineVC.tableView.contentInset));
}

#pragma mark - Methods

-(void)addHubbleLogo_Back
{
    UIImage *image = [UIImage imageNamed:@"Hubble_back_text"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(goBackToHubbleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    [barButtonItem release];
}

- (void)goBackToHubbleMenu: (id)sender
{
    NSLog(@"%s retain:%d", __FUNCTION__, self.retainCount);
    
    if (_tabBarController)
    {
        _tabBarController.delegate = nil;
    }
    
    if (_timelineVC)
    {
        _timelineVC.timelineVCDelegate = nil;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s retain:%d", __FUNCTION__, self.retainCount);
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && index == 0)
    {
        self.timelineVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }
}


@end
