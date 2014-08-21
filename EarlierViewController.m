//
//  EarlierViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "EarlierViewController.h"
#import "MHTabBarController.h"
#import "UIColor+Hubble.h"
#import "PublicDefine.h"
#import "define.h"

@interface EarlierViewController () <MHTabBarControllerDelegate>

@property (nonatomic, strong) UIControl *backCover;
@property (nonatomic, strong) MHTabBarController *tabBarController;
@property (nonatomic, weak) UIViewController *parentVC;
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

- (id)initWithParentVC:(UIViewController *)parentVC camChannel:(CamChannel *)camChannel
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
    
    self.timelineVC = [[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
    _timelineVC.title = LocStr(@"Timeline");
    
    if ( [_parentVC conformsToProtocol:@protocol(TimelineVCDelegate)] ) {
        _timelineVC.timelineVCDelegate = (id<TimelineVCDelegate>)_parentVC;
    }
    _timelineVC.parentVC = _parentVC;

    _tabBarController = [[MHTabBarController alloc] init];
	_tabBarController.delegate = self;
	_tabBarController.viewControllers = @[_timelineVC];
    
    [self.view addSubview:_tabBarController.view];
    
    //load event for timeline
    if ([self.camChannel.profile isNotAvailable]) {
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _tabBarController.hidesBottomBarWhenPushed = YES;
    }
    else {
        if ( [_parentVC conformsToProtocol:@protocol(TimelineVCDelegate)] ) {
            _timelineVC.timelineVCDelegate = (id<TimelineVCDelegate>)_parentVC;
        }
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
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Private Methods

- (void)goBackToHubble:(id)sender
{
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
