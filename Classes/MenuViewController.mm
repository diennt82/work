//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/16/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define DISABLE_VIEW_RELEASE_FLAG 0

#import "MenuViewController.h"
#import "Account_ViewController.h"
#import "H264PlayerViewController.h"
#import "UserAccount.h"
#import "EarlierViewController.h"

@interface MenuViewController () <H264PlayerVCDelegate, UserAccountDelegate>
{
    UIBarButtonItem *cameraBarButton;
    UIBarButtonItem *settingsBarButton;
    UIBarButtonItem *accountBarButton;
}

@property (assign, nonatomic) Account_ViewController *accountVC;

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
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"back"]]];
    
    /*UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back"];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithImage:hubbleBack
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(menuBackAction:)];
    [backBarBtn setTintColor:[UIColor colorWithPatternImage:hubbleBack]];
    
    self.navigationItem.leftBarButtonItem = backBarBtn;
     */
    UIImage *image = [UIImage imageNamed:@"Hubble_logo_back"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    [button setShowsTouchWhenHighlighted:NO];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(menuBackAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button release];
    
    self.navigationItem.leftBarButtonItem = barButtonItem;

    [barButtonItem release];
    
    
    
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.camerasVC = [[CamerasViewController alloc]initWithNibName:@"CamerasViewController_ipad" bundle:nil delegate:self.menuDelegate parentVC:self];
    }
    else
    {
        self.camerasVC = [[CamerasViewController alloc]initWithNibName:@"CamerasViewController" bundle:nil delegate:self.menuDelegate parentVC:self];
    }
    
    
    if (_cameras)
    {
        self.camerasVC.camChannels = self.cameras;
    }

#if DISABLE_VIEW_RELEASE_FLAG
    self.accountVC = [[Account_ViewController alloc] init];
    
    NSLog(@"viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.mdelegate);
    
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    
    self.viewControllers = [NSArray arrayWithObjects:nav, nav2, nil];
    
    [nav release];
    [nav2 release];
#else
    [self.view addSubview:_camerasVC.view];
    
    _settingsVC = [[SettingsViewController alloc] init];
    _settingsVC.parentVC = self;
    [self.view addSubview:_settingsVC.view];
    
    
    self.accountVC = [[Account_ViewController alloc] init];
    self.accountVC.parentVC = self;
    
    NSLog(@"MenuVC - viewDidLoad: %p, %p", self.menuDelegate, self.accountVC.parentVC);
    
    [self.view addSubview:self.accountVC.view];
    cameraBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"camera", nil, [NSBundle mainBundle], @"Camera", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(selectMenuCamera)];
    settingsBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"settings", nil, [NSBundle mainBundle], @"Settings", nil)
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(selectSettings)];
    accountBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"account",nil, [NSBundle mainBundle],
                                                                                                @"Account", nil)
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(selectAccountSetting)];
    
    //NSArray *actionButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
    self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
    //[self.navigationItem.rightBarButtonItems[1] setEnabled:NO];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
#endif
}

- (void)resetFontTextNormalBarButton
{
    [cameraBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont regular18Font], NSFontAttributeName,  [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [settingsBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont regular18Font], NSFontAttributeName,  [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [accountBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont regular18Font], NSFontAttributeName,  [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
}
- (void)selectMenuCamera
{
    [_camerasVC.view removeFromSuperview];
    [self resetFontTextNormalBarButton];
    [cameraBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont bold18Font], NSFontAttributeName,  [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.view addSubview:_camerasVC.view];
}
- (void)selectSettings
{
    [_settingsVC.view removeFromSuperview];
    [self resetFontTextNormalBarButton];
    [settingsBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont bold18Font], NSFontAttributeName,  [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    _settingsVC.parentVC = self;
    [self.view addSubview:_settingsVC.view];
}
- (void)selectAccountSetting
{
    [self.accountVC.view removeFromSuperview];
    [self.view addSubview:self.accountVC.view];
    [self resetFontTextNormalBarButton];
    [accountBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont bold18Font], NSFontAttributeName,  [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.accountVC.parentVC = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"";
    [self selectMenuCamera];
    self.camerasVC.ibTableListCamera.contentInset = UIEdgeInsetsMake(30, 0, 64, 0);
    
    [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:EVENT_DELETED_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (!_isFirttime) //revert
    {
        self.isFirttime = TRUE;
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [self menuBackAction:nil];
        });
       
        [self removeNavigationBarBottomLine];
    }
    else
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:_OfflineMode] &&
            !_notUpdateCameras)
        {
            if (!_camerasVC.waitingForUpdateData)
            {
                self.camerasVC.waitingForUpdateData = TRUE;
                
                for (CamChannel *ch in _camerasVC.camChannels) {
                    ch.profile.hasUpdateLocalStatus = NO;
                }
                
                @synchronized(self.camerasVC)
                {
                    [self performSelectorInBackground:@selector(recreateAccount)
                                           withObject:nil];
                }
            }
            else
            {
                NSLog(@"%s Loading is going on...", __FUNCTION__);
            }
            
            [self.camerasVC.ibTableListCamera reloadData];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_camerasVC)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:_camerasVC
                                                 selector:@selector(updateCameraInfo_delay)
                                                   object:nil];
    }
    
    [super viewWillDisappear:animated];
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
    NSLog(@"%s cameras:%p", __FUNCTION__, _cameras);
    
    if (self.cameras != nil &&
        self.cameras.count > 0)
    {
        //self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
        
        CamChannel *camChannel = nil;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *regID = [userDefaults stringForKey:REG_ID];
        
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
            [userDefaults setObject:camChannel.profile.registrationID forKey:REG_ID];
        }
        
        if ([camChannel.profile isFwUpgrading:[NSDate date]] ||
            !camChannel.profile.hasUpdateLocalStatus)
        {
            NSLog(@"%s FW is upgrading... or updating:%d", __FUNCTION__, !camChannel.profile.hasUpdateLocalStatus);
            return;
        }
        
        if ([camChannel.profile isNotAvailable])
        {
            if([camChannel.profile isSharedCam])
            {
                NSLog(@"MenuVC - menuBackAction - Selected camera is NOT available & is SHARED_CAM");
            }
            else
            {
                // Show Earlier view
                [userDefaults setObject:camChannel.profile.mac_address forKey:CAM_IN_VEW];
                [userDefaults synchronize];
                
                EarlierViewController *earlierVC = [[EarlierViewController alloc] initWithCamChannel:camChannel];
                [self.navigationController pushViewController:earlierVC animated:YES];
                [earlierVC release];
            }
        }
        else
        {
            [CameraAlert clearAllAlertForCamera:camChannel.profile.mac_address];
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            [userDefaults setObject:camChannel.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
            
            H264PlayerViewController *h264PlayerViewController = [[H264PlayerViewController alloc] init];
            
            h264PlayerViewController.selectedChannel = camChannel;
            //h264PlayerViewController.h264PlayerVCDelegate = self;

    
            [self.navigationController pushViewController:h264PlayerViewController animated:NO];
            [h264PlayerViewController release];
        }
    }
    else
    {
        //self.navigationItem.rightBarButtonItems = @[accountBarButton, cameraBarButton];
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

- (void)refreshCameraList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    
    NSLog(@"%s isOffline:%d, waitingForUpdateData:%d, _notUpdateCameras:%d",
          __FUNCTION__, isOffline, _camerasVC.waitingForUpdateData, _notUpdateCameras);
   
    @synchronized(self.camerasVC)
    {
        if (!isOffline &&
            !_notUpdateCameras)
        {
            if (!_camerasVC.waitingForUpdateData)
            {
                self.camerasVC.waitingForUpdateData = TRUE;
                self.navigationItem.leftBarButtonItem.enabled = NO;
                
                for (CamChannel *ch in _camerasVC.camChannels) {
                    ch.profile.hasUpdateLocalStatus = NO;
                }
                
                [self.camerasVC.ibTableListCamera reloadData];
                [self.camerasVC updateBottomButton];
                [self performSelectorInBackground:@selector(recreateAccount)
                                       withObject:nil];
            }
            else
            {
                NSLog(@"%s Loading is going on...", __FUNCTION__);
            }
        }
    }
}
#pragma mark - Update Camera list

- (void)recreateAccount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username   = [userDefaults stringForKey:@"PortalUsername"];
    NSString *apiKey     = [userDefaults stringForKey:@"PortalApiKey"];
    
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
    if (self.isViewLoaded && self.view.window)
    {
        if (success)
        {
            self.camerasVC.isRetrying = FALSE;
            
            if ([self rebindCamerasResource] == TRUE)
            {
                [self updateCameraList];
                
                self.camerasVC.camChannels = _cameras;
            }
            
            self.camerasVC.waitingForUpdateData = NO;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.camerasVC.ibTableListCamera reloadData];
                [self.camerasVC updateBottomButton];
                
                NSLog(@"%s", __FUNCTION__);
            });
        }
        else
        {
            self.camerasVC.waitingForUpdateData = NO;
            
            if (!camProfiles)
            {
                // Forcing refresh here!
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!_camerasVC.isRetrying)
                    {
                        self.camerasVC.isRetrying = TRUE;
                        [_camerasVC.ibTableListCamera reloadData];
                    }
                    
                    Reachability *reachability = [Reachability reachabilityForInternetConnection];
                    [reachability startNotifier];
                    
                    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
                    
                    if (networkStatus == NotReachable)
                    {
                        [self performSelector:@selector(refreshCameraList) withObject:nil afterDelay:2];
                    }
                    else
                    {
                        [self refreshCameraList];
                    }
                });
                //[self performSelectorOnMainThread:@selector(refreshCameraList) withObject:nil waitUntilDone:NO];
            }
            else
            {
                if (_camerasVC.isRetrying)
                {
                    self.camerasVC.isRetrying = FALSE;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.camerasVC.ibTableListCamera reloadData];
                    });
                }
               
                NSLog(@"%s Error:%@", __FUNCTION__, camProfiles);
            }
        }
    }
    else
    {
        //self.camerasVC.waitingForUpdateData = NO;
        NSLog(@"%s view is invisible. Do nothing!", __FUNCTION__);
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
            ch.profile.hasUpdateLocalStatus = YES;
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

- (void)removeSubviews
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_accountVC)
    {
        // Dismiss account view's subviews.
        [_accountVC dismissViewControllerAnimated:NO completion:^{}];
        
        [_accountVC.view removeFromSuperview];
    }
    
    if (_settingsVC)
    {
        [_settingsVC.view removeFromSuperview];
    }
    
    if (_camerasVC)
    {
        [_camerasVC.view removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_cameras release];
    [_accountVC release];
    [_settingsVC release];
    [_camerasVC release];
    [super dealloc];
}

@end
