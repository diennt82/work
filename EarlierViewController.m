//
//  EarlierViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import "EarlierViewController.h"
#import "SavedEventViewController.h"
#import "MHTabBarController.h"
#import "UIColor+Hubble.h"
#import "PublicDefine.h"
#import "define.h"

@interface EarlierViewController () <MHTabBarControllerDelegate>

@property (nonatomic, retain) UIControl *backCover;
@property (nonatomic, assign) MHTabBarController *tabBarController;
@property (nonatomic, assign) id parentVC;
@property (nonatomic) BOOL isDidLoad;

@end

@implementation EarlierViewController

#pragma mark - Initialization methods

- (id)initWithCamChannel:(CamChannel *)camChannel
{
    self = [super init];
    if (self) {
        self.camChannel = camChannel;
    }
    return self;
}

- (id)initWithParentVC:(id)parentVC camChannel:(CamChannel *)camChannel
{
    self = [super init];
    if (self) {
        self.parentVC = parentVC;
        self.camChannel = camChannel;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([_camChannel.profile isNotAvailable]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    self.timelineVC = [[TimelineViewController alloc] init];
    [_timelineVC setTitle:@"Timeline"];
    
    NSArray *viewControllers;
    if (CUE_RELEASE_FLAG) {
        viewControllers = @[_timelineVC];
    }
    else {
        SavedEventViewController *savedViewController = [[SavedEventViewController alloc] initWithNibName:@"SavedEventViewController" bundle:nil];
        [savedViewController setTitle:@"Saved"];
        viewControllers = @[_timelineVC, savedViewController];
    }

    [_timelineVC release];
    
    _tabBarController = [[MHTabBarController alloc] init];
	_tabBarController.delegate = self;
	_tabBarController.viewControllers = viewControllers;
    
    [self.view addSubview:_tabBarController.view];
    
    //load event for timeline
    if ([self.camChannel.profile isNotAvailable]) {
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.timelineVC.navVC = self.navigationController;
        _tabBarController.hidesBottomBarWhenPushed = YES;
    }
    else {
        self.timelineVC.navVC = _nav;
        self.timelineVC.timelineVCDelegate = self.parentVC;
    }
    
    [_timelineVC loadEvents:_camChannel];
    
    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(5, 0, 64, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.timelineVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }
    
    NSLog(@"EarlierVC - view: %@, timeline: %@, timelineContentSize: %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.timelineVC.view.frame), NSStringFromUIEdgeInsets(self.timelineVC.tableView.contentInset));
    
    if ( [_camChannel.profile isNotAvailable] && !_backCover ) {
        // Cover the back button so we can overide the default back action
        self.backCover = [[UIControl alloc] initWithFrame:CGRectMake( 0, 0, 100, 44)]; // Width setup for @"Cameras"
        
        [_backCover addTarget:self action:@selector(goBackToHubble:) forControlEvents:UIControlEventTouchUpInside];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        [navBar addSubview:_backCover];
        [_backCover release];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)dealloc
{
    NSLog(@"%s retain:%d", __FUNCTION__, self.retainCount);
    [_timelineVC release];
    [_tabBarController release];
    [_backCover release];
    [super dealloc];
}

#pragma mark - Private Methods

- (void)goBackToHubble:(id)sender
{
    NSLog(@"%s retain:%d", __FUNCTION__, self.retainCount);
    
    if (_tabBarController) {
        _tabBarController.delegate = nil;
    }
    
    if (_timelineVC) {
        _timelineVC.timelineVCDelegate = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && index == 0) {
        self.timelineVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    }
}

@end
