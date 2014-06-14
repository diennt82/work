//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created on 12/16/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

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

@property (nonatomic, retain) Account_ViewController *accountVC;
@property (nonatomic, retain) NSMutableArray *restoredProfiles;
@property (nonatomic, retain) NSMutableArray *arrayChannel;

@end

@implementation MenuViewController

#pragma mark - Initialization methods

- (id)initWithNibName:(NSString *)nibNameOrNil withConnDelegate:(id<ConnectionMethodDelegate>)caller
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        self.menuDelegate = caller;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.camerasVC = [[CamerasViewController alloc] initWithDelegate:self.menuDelegate parentVC:self];
    EarlierNavigationController *camerasNavContoller = [[EarlierNavigationController alloc] initWithRootViewController:_camerasVC];
    _camerasVC.tabBarItem.image = [UIImage imageNamed:@"hubble_logo2"];
    
    if (_cameras) {
        _camerasVC.camChannels = _cameras;
    }
    
    self.settingsVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _settingsVC.parentVC = self;
    UINavigationController *settingsNavContoller = [[UINavigationController alloc] initWithRootViewController:_settingsVC];
    _settingsVC.tabBarItem.image = [UIImage imageNamed:@"general"];
    
    self.accountVC = [[Account_ViewController alloc] init];
    _accountVC.parentVC = self;
    UINavigationController *accountNavContoller = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    _accountVC.tabBarItem.image = [UIImage imageNamed:@"account_icon"];
    
    NSLog(@"MenuVC - viewDidLoad: %p, %p", _menuDelegate, _accountVC.parentVC);
    
    cameraBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(selectMenuCamera)];
    settingsBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(selectSettings)];
    accountBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(selectAccountSetting)];

    NSArray *viewControllers = @[camerasNavContoller, settingsNavContoller, accountNavContoller];
    self.viewControllers = viewControllers;
    self.selectedViewController = camerasNavContoller;
    
    [camerasNavContoller release];
    [settingsNavContoller release];
    [accountNavContoller release];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    if (!_isFirttime) {
        //revert
        self.isFirttime = TRUE;
        
        [self menuBackAction:nil];
        [self removeNavigationBarBottomLine];
    }
    else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
        
        if (!isOffline && !self.camerasVC.waitingForUpdateData && !_notUpdateCameras) {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [self.navigationItem.rightBarButtonItems[1] setEnabled:NO];
            //[self.navigationItem.rightBarButtonItems[1] setHidden:YES];
            _camerasVC.waitingForUpdateData = TRUE;
            [_camerasVC.tableView reloadData];
            [self performSelectorInBackground:@selector(recreateAccount)
                                   withObject:nil];
        }
    }
}

#pragma mark - public methods

- (void)refreshCameraList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    self.camerasVC.waitingForUpdateData = FALSE;
    if (!isOffline && !self.camerasVC.waitingForUpdateData && !_notUpdateCameras) {
        self.camerasVC.waitingForUpdateData = TRUE;
        [self performSelectorInBackground:@selector(recreateAccount) withObject:nil];
    }
}

#pragma mark - Private methods

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

- (void)removeNavigationBarBottomLine
{
    for (UIView *parentView in self.navigationController.navigationBar.subviews) {
        for (UIView *childView in parentView.subviews) {
            if ([childView isKindOfClass:[UIImageView class]] && childView.bounds.size.height <= 1) {
                [childView removeFromSuperview];
                return;
            }
        }
    }
}

- (void)menuBackAction: (id)sender
{
    // Back to Player view. What is camera selected? 0?
    if (self.cameras != nil && self.cameras.count > 0) {
        self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
        
        CamChannel *camChannel = nil;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *regID = [userDefaults stringForKey:REG_ID];
        
        for (CamChannel *ch in _cameras) {
            if ([ch.profile.registrationID isEqualToString:regID]) {
                camChannel = ch;
                break;
            }
        }
        
        if (camChannel == nil) {
            camChannel = (CamChannel *)[self.cameras objectAtIndex:0];
            [userDefaults setObject:camChannel.profile.registrationID forKey:REG_ID];
        }
        
        if ([camChannel.profile isFwUpgrading:[NSDate date]]) {
            NSLog(@"%s FW is upgrading...", __FUNCTION__);
            return;
        }
        
        if ([camChannel.profile isNotAvailable]) {
            if ([camChannel.profile isSharedCam]) {
                NSLog(@"MenuVC - menuBackAction - Selected camera is NOT available & is SHARED_CAM");
            }
            else {
                // Show Earlier view
                [userDefaults setObject:camChannel.profile.mac_address forKey:CAM_IN_VEW];
                [userDefaults synchronize];
                
                EarlierViewController *earlierVC = [[EarlierViewController alloc] initWithCamChannel:camChannel];
                [self.navigationController pushViewController:earlierVC animated:YES];
                [earlierVC release];
            }
        }
        else {
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
    else {
        self.navigationItem.rightBarButtonItems = @[accountBarButton, cameraBarButton];
    }
}

- (void)stopStreamFinished:(CamChannel *)camChannel
{
    for (CamChannel *obj in _cameras) {
        if ([obj.profile.mac_address isEqualToString:camChannel.profile.mac_address]) {
            obj.waitingForStreamerToClose = NO;
        }
        else {
            NSLog(@"%@ ->waitingForClose: %d", obj.profile.name, obj.waitingForStreamerToClose);
        }
    }
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
    if (self.isViewLoaded && self.view.window) {
        if ([self rebindCamerasResource] == TRUE) {
            [self updateCameraList];
            self.camerasVC.camChannels = _cameras;
        }
        
        self.camerasVC.waitingForUpdateData = NO;
        [_camerasVC.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
        
        if ( _cameras.count > 0 ) {
            [self.navigationItem.rightBarButtonItems[1] setEnabled:YES];
            //[self.navigationItem.rightBarButtonItems[1] setHidden:NO];
            self.navigationItem.rightBarButtonItems = @[accountBarButton, settingsBarButton, cameraBarButton];
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }
        else {
            self.navigationItem.rightBarButtonItems = @[accountBarButton, cameraBarButton];
        }
    }
    else {
        NSLog(@"%s view is invisible. Do nothing!", __FUNCTION__);
    }
}

- (void)updateCameraList
{
    NSMutableArray *validChannels = [[NSMutableArray alloc] init];
    
    for (int i = _arrayChannel.count - 1 ; i > -1; i--) {
		CamChannel * ch = [_arrayChannel objectAtIndex:i];
        if ( ch.profile ) {
			[validChannels addObject:[_arrayChannel objectAtIndex:i]];
        }
	}
    
	self.cameras = validChannels;
    [validChannels release];
}

- (BOOL)rebindCamerasResource
{
    BOOL restore_successful = [self restoreConfigData];
    
    if (restore_successful == YES) {
        for (int i = 0; i< [_arrayChannel count]; i++) {
            CamChannel* ch = (CamChannel*) [_arrayChannel objectAtIndex:i];
            
            if ( ch.profile ) {
                for (int j = 0; j < _restoredProfiles.count; j++) {
                    CamProfile * cp = (CamProfile *) [_restoredProfiles objectAtIndex:j];
                    
                    if ( !cp.isSelected ) {
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

- (BOOL)restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
    
	if ( [savedData restoreSessionData] ) {
		//NSLog(@"restored data done");
		self.arrayChannel = savedData.channels;
		self.restoredProfiles = savedData.configuredCams;
	}
    
    [savedData release];
    
	return TRUE;
}

#pragma mark - Memory management methods

- (void)dealloc
{
    [_accountVC release];
    [super dealloc];
}

@end
