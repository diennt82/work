//
//  MenuViewController.m
//  BlinkHD_ios
//
//  Created on 12/16/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "MenuViewController.h"
#import "AccountViewController.h"
#import "H264PlayerVCDelegate.h"
#import "EarlierNavigationController.h"
#import "EarlierViewController.h"
#import "PublicDefine.h"
#import "UserAccount.h"
#import "CameraAlert.h"
#import "SetupData.h"

@interface MenuViewController () <H264PlayerVCDelegate, UserAccountDelegate>

@property (nonatomic, strong) AccountViewController *accountVC;
@property (nonatomic, strong) NSMutableArray *restoredProfiles;
@property (nonatomic, strong) NSMutableArray *arrayChannel;
@property (nonatomic, strong) NSDictionary *buttonTitleTextAttrs;

@property (nonatomic, strong) UIBarButtonItem *cameraBarButton;
@property (nonatomic, strong) UIBarButtonItem *settingsBarButton;
@property (nonatomic, strong) UIBarButtonItem *accountBarButton;

@property (nonatomic) BOOL initialView;

@end

@implementation MenuViewController

#pragma mark - Initialization methods

- (id)initWithNibName:(NSString *)nibNameOrNil withConnDelegate:(id<ConnectionMethodDelegate>)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.menuDelegate = delegate;
    }
    return self;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.initialView = YES;
    
    self.buttonTitleTextAttrs = @{ NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
                                   NSForegroundColorAttributeName:[UIColor blackColor] };
    
    self.camerasVC = [[CamerasViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _camerasVC.parentVC = self;
    
    EarlierNavigationController *camerasNavContoller = [[EarlierNavigationController alloc] initWithRootViewController:_camerasVC];
    _camerasVC.tabBarItem.image = [UIImage imageNamed:@"logo2"];
    
    if (_cameras) {
        _camerasVC.camChannels = _cameras;
    }
    
    self.settingsVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _settingsVC.parentVC = self;
    UINavigationController *settingsNavContoller = [[UINavigationController alloc] initWithRootViewController:_settingsVC];
    _settingsVC.tabBarItem.image = [UIImage imageNamed:@"general"];
    
    self.accountVC = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
    _accountVC.parentVC = self;
    UINavigationController *accountNavContoller = [[UINavigationController alloc] initWithRootViewController:_accountVC];
    _accountVC.tabBarItem.image = [UIImage imageNamed:@"account_icon"];
    
    self.cameraBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStylePlain target:self action:@selector(selectMenuCamera)];
    self.settingsBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(selectSettings)];
    self.accountBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Account" style:UIBarButtonItemStylePlain target:self action:@selector(selectAccountSetting)];

    NSArray *viewControllers = @[camerasNavContoller, settingsNavContoller, accountNavContoller];
    self.viewControllers = viewControllers;
    self.selectedViewController = camerasNavContoller;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    if ( _initialView ) {
        self.initialView = NO;
        
        [self menuBackAction:nil];
        [self removeNavigationBarBottomLine];
    }
    else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isOffline = [userDefaults boolForKey:OFFLINE_MODE_KEY];
        
        if (!isOffline && !self.camerasVC.waitingForUpdateData && !_notUpdateCameras) {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [self.navigationItem.rightBarButtonItems[1] setEnabled:NO];
            _camerasVC.waitingForUpdateData = YES;
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
    BOOL isOffline = [userDefaults boolForKey:OFFLINE_MODE_KEY];
    _camerasVC.waitingForUpdateData = NO;
    if (!isOffline && !self.camerasVC.waitingForUpdateData && !_notUpdateCameras) {
        _camerasVC.waitingForUpdateData = YES;
        [self performSelectorInBackground:@selector(recreateAccount) withObject:nil];
    }
}

#pragma mark - Private methods

- (void)resetFontTextNormalBarButton
{
    NSDictionary *dict = @{ NSFontAttributeName : [UIFont systemFontOfSize:18],
                            NSForegroundColorAttributeName : [UIColor blackColor] };
    
    [_cameraBarButton setTitleTextAttributes:dict forState:UIControlStateNormal];
    [_settingsBarButton setTitleTextAttributes:dict forState:UIControlStateNormal];
    [_accountBarButton setTitleTextAttributes:dict forState:UIControlStateNormal];
}

- (void)selectMenuCamera
{
    [_camerasVC.view removeFromSuperview];
    [self resetFontTextNormalBarButton];
    [_cameraBarButton setTitleTextAttributes:_buttonTitleTextAttrs forState:UIControlStateNormal];
    [self.view addSubview:_camerasVC.view];
}

- (void)selectSettings
{
    [_settingsVC.view removeFromSuperview];
    [self resetFontTextNormalBarButton];
    [_settingsBarButton setTitleTextAttributes:_buttonTitleTextAttrs forState:UIControlStateNormal];
    _settingsVC.parentVC = self;
    [self.view addSubview:_settingsVC.view];
}

- (void)selectAccountSetting
{
    [_accountVC.view removeFromSuperview];
    [self.view addSubview:_accountVC.view];
    [self resetFontTextNormalBarButton];
    [_accountBarButton setTitleTextAttributes:_buttonTitleTextAttrs forState:UIControlStateNormal];
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

- (void)menuBackAction:(id)sender
{
    // Back to Player view. What is camera selected? 0?
    if ( _cameras.count > 0 ) {
        self.navigationItem.rightBarButtonItems = @[_accountBarButton, _settingsBarButton, _cameraBarButton];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *regID = [userDefaults stringForKey:REG_ID];
        
        CamChannel *camChannel = nil;
        for (CamChannel *ch in _cameras) {
            if ([ch.profile.registrationID isEqualToString:regID]) {
                camChannel = ch;
                break;
            }
        }
        
        if ( !camChannel) {
            camChannel = (CamChannel *)_cameras.firstObject;
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
            }
        }
        else {
            [CameraAlert clearAllAlertForCamera:camChannel.profile.mac_address];
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            [userDefaults setObject:camChannel.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
        }
    }
    else {
        self.navigationItem.rightBarButtonItems = @[_accountBarButton, _cameraBarButton];
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
                                             accountDelegate:self];
    [account readCameraListAndUpdate];
}

#pragma mark - UserAccount delegate

- (void)finishStoreCameraListData:(NSMutableArray *)camProfiles success:(BOOL)success
{
    if (self.isViewLoaded && self.view.window) {
        [self rebindCamerasResource];
        [self updateCameraList];
        
        self.camerasVC.camChannels = _cameras;
        self.camerasVC.waitingForUpdateData = NO;
        
        [_camerasVC.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
}

- (void)rebindCamerasResource
{
    [self restoreConfigData];
    
    for (int i = 0; i < _arrayChannel.count; i++) {
        CamChannel *ch = (CamChannel *)_arrayChannel[i];
        
        if ( ch.profile ) {
            for (int j = 0; j < _restoredProfiles.count; j++) {
                CamProfile *cp = (CamProfile *)_restoredProfiles[j];
                if ( !cp.isSelected ) {
                    // Re-bind camera - channel
                    [ch setCamProfile:cp];
                    cp.isSelected = YES;
                    [cp setChannel:ch];
                    break;
                }
            }
        }
    }
}

- (void)restoreConfigData
{
	SetupData *savedData = [[SetupData alloc] init];
    
	if ( [savedData restoreSessionData] ) {
		self.arrayChannel = savedData.channels;
		self.restoredProfiles = savedData.configuredCams;
	}
}

@end
