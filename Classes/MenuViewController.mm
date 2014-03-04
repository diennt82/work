//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define DISABLE_VIEW_RELEASE_FLAG 0

#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "Account_ViewController.h"
#import "H264PlayerViewController.h"
#import "UserAccount.h"

@interface MenuViewController () <H264PlayerVCDelegate, UserAccountDelegate>

@property (retain, nonatomic) Account_ViewController *accountVC;
@property (nonatomic) BOOL isFirttime;
@property (nonatomic, retain) NSMutableArray *restoredProfiles;
@property (nonatomic, retain) NSMutableArray *arrayChannel;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Menu";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
     withConnDelegate:(id<ConnectionMethodDelegate> ) caller
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuDelegate = caller;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = NO;
    
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back"];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(menuBackAction:)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.camerasVC = [[CamerasViewController alloc] initWithStyle:nil
                                                         delegate:self.menuDelegate
                                                         parentVC:self];
    //self.camerasVC.camChannels = self.cameras;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_camerasVC];
    
    //[self.navigationController initWithRootViewController:camerasVC];
#if DISABLE_VIEW_RELEASE_FLAG
    self.accountVC = [[Account_ViewController alloc] init];
    
    NSLog(@"viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.mdelegate);
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav2, nil];
    
    [nav release];
    [nav2 release];
#else
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    settingsVC.parentVC = self;
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    self.accountVC = [[Account_ViewController alloc] init];
    
    NSLog(@"viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.mdelegate);
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav1, nav2, nil];
    
    UITabBarItem *camItem = [self.tabBar.items objectAtIndex:0];
    [camItem setImage:[UIImage imageNamed:@"camera.png"]];
    
    UITabBarItem *settingsItem = [self.tabBar.items objectAtIndex:1];
    [settingsItem setImage:[UIImage imageNamed:@"general"]];

    UITabBarItem *accountItem = [self.tabBar.items objectAtIndex:2];
    [accountItem setImage:[UIImage imageNamed:@"account_icon.png"]];
    
    [nav release];
    [nav2 release];
    [settingsVC release];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back"];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    self.accountVC.mdelegate = self.menuDelegate;
    self.title = @"Cameras";
    self.navigationItem.title = @"Cameras";

    if (!_isFirttime) //revert
    {
        self.isFirttime = TRUE;
        
        [self menuBackAction:nil];
        [self removeNavigationBarBottomLine];
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
        
        if (!isOffline)
        {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.camerasVC.waitingForUpdateData = TRUE;
            [self.camerasVC.tableView reloadData];
            [self performSelectorInBackground:@selector(recreateAccount)
                                   withObject:nil];
        }
    }
}

- (void)removeNavigationBarBottomLine
{
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
    {
        for (UIView *childView in parentView.subviews)
        {
            if ([childView isKindOfClass:[UIImageView class]] &&
                childView.bounds.size.height <= 1)
            {
                [childView removeFromSuperview];
                return;
            }
        }
    }
}

- (void)menuBackAction: (id)sender
{
    // Back to Player view. What is camera selected? 0?
    
    if (self.cameras != nil &&
        self.cameras.count > 0)
    {
        CamChannel *camChannel = nil;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *regID = [userDefaults stringForKey:@"REG_ID"];
        
        for (CamChannel *ch in _cameras)
        {
            if ([ch.profile.registrationID isEqualToString:regID])
            {
                camChannel = ch;
                break;
            }
        }
        
        if (camChannel == nil)
        {
            camChannel = (CamChannel *)[self.cameras objectAtIndex:0];
            [userDefaults setObject:camChannel.profile.registrationID forKey:@"REG_ID"];
        }
        
        if ([camChannel.profile isNotAvailable] &&
            [camChannel.profile isSharedCam])
        {
            self.navigationItem.leftBarButtonItem.enabled = YES;
            return;
        }
        
        [CameraAlert clearAllAlertForCamera:camChannel.profile.mac_address];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [userDefaults setObject:camChannel.profile.mac_address forKey:CAM_IN_VEW];
        [userDefaults synchronize];
        
        H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
        
        h264PlayerViewController.selectedChannel = camChannel;
        h264PlayerViewController.h264PlayerVCDelegate = self;
        
        NSLog(@"%@, %@", self.parentViewController.description, self.parentViewController.parentViewController);

        [self.navigationController pushViewController:h264PlayerViewController animated:YES];
        [h264PlayerViewController release];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = NO;
    }
}

- (void)stopStreamFinished:(CamChannel *)camChannel
{
    if (self.cameras != nil &&
        self.cameras.count > 0)
    {
        for (CamChannel *obj in _cameras)
        {
            if ([obj.profile.mac_address isEqualToString:camChannel.profile.mac_address])
            {
                obj.waitingForStreamerToClose = NO;
            }
            else
            {
                NSLog(@"%@ ->waitingForClose: %d", obj.profile.name, obj.waitingForStreamerToClose);
            }
        }
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.title = item.title;
}

#pragma mark - Update Camera list

- (void)recreateAccount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username  = [userDefaults stringForKey:@"PortalUsername"];
    NSString *apiKey    = [userDefaults stringForKey:@"PortalApiKey"];
    UserAccount *account = [[UserAccount alloc] initWithUser:username
                                                    password:nil
                                                      apiKey:apiKey
                                                    listener:self];
    [account readCameraListAndUpdate];
    
    [account release];
}

#pragma mark - UserAccount delegate

- (void)finishStoreCameraListData:(NSMutableArray *)camProfiles success:(BOOL)success
{
    if ([self rebindCamerasResource] == TRUE)
    {
        [self updateCameraList];
        
        self.camerasVC.camChannels = _cameras;
    }
    
    self.camerasVC.waitingForUpdateData = NO;
    [self.camerasVC.tableView performSelectorInBackground:@selector(reloadData)
                                               withObject:nil];
    if (self.cameras != nil &&
        self.cameras.count > 0)
    {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (void)updateCameraList
{
    NSMutableArray *validChannels = [[NSMutableArray alloc] init];
    
    for (int i = _arrayChannel.count - 1 ; i > -1; i--)
	{
		CamChannel * ch = [_arrayChannel objectAtIndex:i];
		
        if (ch.profile != nil)
        {
			[validChannels addObject:[_arrayChannel objectAtIndex:i]];
        }
	}
    
	self.cameras = validChannels;
    
    [validChannels release];
}

- (BOOL)rebindCamerasResource
{
    BOOL restore_successful = [self restoreConfigData];
    
    if (restore_successful == YES)
    {
        for (int i = 0; i< [_arrayChannel count]; i++)
        {
            CamChannel* ch = (CamChannel*) [_arrayChannel objectAtIndex:i];
            
            if ( ch.profile != nil)
            {
                for (int j = 0; j < _restoredProfiles.count; j++)
                {
                    CamProfile * cp = (CamProfile *) [_restoredProfiles objectAtIndex:j];
                    
                    if ( !cp.isSelected)
                    {
                        //Re-bind camera - channel
                        [ch setCamProfile:cp];
                        cp.isSelected = TRUE;
                        [cp setChannel:ch];
                        break;
                    }
                }
            }
            else {
                
                //NSLog(@"channel profile = nil");
            }
        }
    }
    
    return restore_successful;
}

- (BOOL) restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
    
	if ([savedData restore_session_data] ==TRUE)
	{
		//NSLog(@"restored data done");
		self.arrayChannel = savedData.channels;
		self.restoredProfiles = savedData.configured_cams;
	}
    
    [savedData release];
    
	return TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_accountVC release];
    [super dealloc];
}

@end
