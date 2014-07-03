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

@property (retain, nonatomic) Account_ViewController *accountVC;

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
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
    [button setBackgroundImage:image forState:UIControlStateSelected];
    [button setBackgroundImage:image forState:UIControlStateDisabled];
    
    [button setShowsTouchWhenHighlighted:NO];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(menuBackAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = barButtonItem;

    
    
    
    
    
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
    cameraBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(selectMenuCamera)];
    settingsBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(selectSettings)];
    accountBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(selectAccountSetting)];
    
    //NSArray *actionButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
    //self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
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
    
//    self.camerasVC.tableView.frame = CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 30);
    self.camerasVC.ibTableListCamera.contentInset = UIEdgeInsetsMake(30, 0, 64, 0);
    
    //UIImage *hubbleBack = [UIImage imageNamed:@"Hubble_logo_back"];
    //[self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithPatternImage:hubbleBack]];

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
        
        
        if (!isOffline &&
            !self.camerasVC.waitingForUpdateData &&
            !_notUpdateCameras)
        {
            self.camerasVC.waitingForUpdateData = TRUE;
            //self.navigationItem.leftBarButtonItem.enabled = NO;
            //[self.navigationItem.rightBarButtonItems[1] setEnabled:NO];
            //[self.navigationItem.rightBarButtonItems[1] setHidden:YES];
            
            @synchronized(self.camerasVC)
            {
                [self performSelectorInBackground:@selector(recreateAccount)
                                       withObject:nil];
            }
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
        self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
        
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
        
        if ([camChannel.profile isFwUpgrading:[NSDate date]])
        {
            NSLog(@"%s FW is upgrading...", __FUNCTION__);
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
            h264PlayerViewController.h264PlayerVCDelegate = self;
            
            NSLog(@"%@, %@", self.parentViewController.description, self.parentViewController.parentViewController);
            
            [self.navigationController pushViewController:h264PlayerViewController animated:YES];
            [h264PlayerViewController release];
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[accountBarButton, cameraBarButton];
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
            !_camerasVC.waitingForUpdateData &&
            !_notUpdateCameras)
        {
            self.camerasVC.waitingForUpdateData = TRUE;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [self.navigationItem.rightBarButtonItems[1] setEnabled:NO];
            [self.camerasVC.ibTableListCamera reloadData];
            [self.camerasVC updateBottomButton];
            [self performSelectorInBackground:@selector(recreateAccount)
                                   withObject:nil];
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
        if ([self rebindCamerasResource] == TRUE)
        {
            [self updateCameraList];
            
            self.camerasVC.camChannels = _cameras;
        }
        
        self.camerasVC.waitingForUpdateData = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.camerasVC.ibTableListCamera reloadData];
            //[self.camerasVC.ibTableListCamera layoutIfNeeded];
             [self.camerasVC updateBottomButton];
        });
       
        NSLog(@"%s", __FUNCTION__);
        
        UIImage *image = [UIImage imageNamed:@"Hubble_logo_back"];
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        
        //init a normal UIButton using that image
        UIButton* button = [[UIButton alloc] initWithFrame:frame];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setShowsTouchWhenHighlighted:YES];
        
        //set the button to handle clicks - this one calls a method called 'downloadClicked'
        [button addTarget:self action:@selector(menuBackAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //finally, create your UIBarButtonItem using that button
        UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        //then set it.  phew.
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
        [barButtonItem release];
        
        if (self.cameras != nil &&
            self.cameras.count > 0)
        {
            [self.navigationItem.rightBarButtonItems[1] setEnabled:YES];
            //[self.navigationItem.rightBarButtonItems[1] setHidden:NO];
            self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }
        else
        {
            self.navigationItem.rightBarButtonItems = @[accountBarButton, cameraBarButton];
        }
    }
    else
    {
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
    [_accountVC release];
    [_settingsVC release];
    [_camerasVC release];
    [super dealloc];
}

@end
