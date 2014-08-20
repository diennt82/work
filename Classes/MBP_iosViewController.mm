//
//  MBP_iosViewController.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 Hubble Connected Ltd. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import <sys/socket.h>
#import <netinet/in.h>

#include <ifaddrs.h>

#import "MBP_iosViewController.h"
#import "PlayListViewController.h"
#import "H264PlayerViewController.h"
#import "NotifViewController.h"

#import "Step_02_ViewController.h"
#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import "define.h"
#import "SetupData.h"

#import "AlertPrompt.h"
#import "NSData+AESCrypt.h"

@interface MBP_iosViewController ()

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *statusDialogView;
@property (nonatomic, weak) IBOutlet UILabel *statusDialogLabel;
@property (nonatomic, weak) IBOutlet UITextView *statusDialogText;

@property (nonatomic, strong) UIAlertView *pushAlert;
@property (nonatomic, strong) CameraAlert *latestCamAlert;
@property (nonatomic, strong) Bonjour *bonjourBrowser;
@property (nonatomic, strong) NSArray *bonjourList;
@property (nonatomic, strong) NSThread *bonjourThread;

@property (nonatomic, copy) NSString *iFileName;

@property (nonatomic) SystemSoundID soundFileObject;
@property (nonatomic) int iMaxRecordSize;
@property (nonatomic) int nextCameraToScanIndex;
@property (nonatomic) BOOL isRebinded;

@end

@implementation MBP_iosViewController

- (void)initialize
{
	self.toTakeSnapShot = NO;
	self.recordInProgress = NO;
    self.app_stage = APP_STAGE_LOGGING_IN;
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("Voicemail"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_soundFileObject);
    
    CFRelease(soundFileURLRef);
    self.splashScreen.animationImages = @[
                                        [UIImage imageNamed:@"loader_big_a"],
                                        [UIImage imageNamed:@"loader_big_b"],
                                        [UIImage imageNamed:@"loader_big_c"],
                                        [UIImage imageNamed:@"loader_big_d"],
                                        [UIImage imageNamed:@"loader_big_e"]
                                        ];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self initialize];
    
	[NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(wakeupDisplayLogin:)
                                   userInfo:nil
                                    repeats:NO];
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self startAnimationWithOrientation:interfaceOrientation];
    
    self.splashScreen.image = [UIImage imageNamed:@"loader_big_a"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *msg = LocStr(@"Logging_in_to_server");
    UILabel *labelMessage = (UILabel *)[self.view viewWithTag:509];
    [labelMessage setText:msg];
    
    if ( _splashScreen) {
        [_splashScreen startAnimating];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ( _splashScreen ) {
        [_splashScreen stopAnimating];
    }
}

- (CGRect)deviceFrameWithOrientation:(UIInterfaceOrientation)orientation
{
    CGRect deviceBound = [UIScreen mainScreen].bounds;
    
    if ( UIInterfaceOrientationIsLandscape(orientation) ) {
        deviceBound = CGRectMake(0, 0, deviceBound.size.height, deviceBound.size.width);
    }
    
    return deviceBound;
}

- (void)startAnimationWithOrientation:(UIInterfaceOrientation)orientation
{
    self.splashScreen.animationDuration = 1.5;
    self.splashScreen.animationRepeatCount = 0;
}

- (void)wakeupDisplayLogin:(NSTimer *)timerExp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:AUTO_LOGIN_KEY]) {
        DLog(@"Auto login from AppDelegate. Do nothing");
        [self showLogin];
    }
    else {
        self.app_stage = APP_STAGE_LOGGING_IN;
        DLog(@"MBP_iosVC - show LoginVC from viewDidLoad after 4s");
        [self showLogin];
    }
}

- (void)startShowingCameraList
{
    if (_menuVC) {
        self.menuVC = nil;
    }
    
    self.menuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" withConnDelegate:self];
    
	NSMutableArray *validChannels = [[NSMutableArray alloc] init];
    
	for ( int i = _channelArray.count - 1 ; i > -1; i-- ) {
		CamChannel *ch = _channelArray[i];
        if ( ch.profile ) {
			[validChannels addObject:_channelArray[i]];
        }
	}
    
	self.menuVC.cameras = validChannels;
    self.menuVC.camerasVC.camChannels = validChannels;
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:_menuVC animated:NO completion:nil];
            }];
        }
        else {
            [self presentViewController:_menuVC animated:NO completion:nil];
        }
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -  ConnectionMethodDelegate - Views navigation

/**
 * Main program switching point is here 
 */
- (void)sendStatus:(int)method
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	switch (method)
    {
		case SETUP_CAMERA:
        {
            self.app_stage = APP_STAGE_SETUP;
            BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
            
            if (isFirstTimeSetup == NO) {
                DLog(@">>> SETUP ");
                // Normal add cam sequence - Load the next xib
                Step_02_ViewController *step02ViewController = [[Step_02_ViewController alloc] initWithNibName:@"Step_02_ViewController" bundle:nil];
                step02ViewController.delegate = self;
                step02ViewController.cameraType = [userDefaults integerForKey:SET_UP_CAMERA];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:step02ViewController];
                
                if (self.presentedViewController) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self presentViewController:nav animated:NO completion:nil];
                    }];
                }
                else {
                    [self presentViewController:nav animated:NO completion:nil];
                }
            }
            else {
                DLog(@">>> REGISTER");
                [self createAccount];
            }
            
            break;
        }
            
		case SCAN_CAMERA:
        {
			// May be offline mode
            DLog(@"start scanning");
            _statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;
            
            self.isRebinded = [self rebindCameraResource];
			[self performSelector:@selector(scanForDevices) withObject:nil afterDelay:0.1];
            
			// Back from login - login success
			[self dismissViewControllerAnimated:NO completion:nil];
			self.progressView.hidden = NO;

			break;
        }
		
		case AFTER_DEL_RELOGIN: // Only use when cancel from Add camera
        {
            _statusDialogLabel.hidden = YES;
            [userDefaults setBool:YES forKey:AUTO_LOGIN_KEY];
            [userDefaults synchronize];
            
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(showLogin)
                                           userInfo:nil
                                            repeats:NO];
            break;
        }
		case BACK_FROM_MENU_NOLOAD: // USED by AppDelegate as well.. please check if modifying this case
        {
            DLog(@"Back from menu");
            _statusDialogLabel.hidden = YES;
            
            if (self.presentedViewController) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
            
            break;
        }
            
		case LOGIN_FAILED_OR_LOGOUT : //back from login -failed Or logout
        {
            _statusDialogLabel.hidden = YES;
            self.app_stage = APP_STAGE_LOGGING_IN;
            [self logoutAndUnregistration];
            [self showLogin];
			
            break;
        }
            
        case SCAN_BONJOUR_CAMERA :
        {
            /*
             20130523_nguyendang :
             Scan camera with bonjour here
             If have any problem ? Back to Scan_for_camera
             */
            DLog(@"start scanning Bonjour");
            
            _statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;
            
            self.isRebinded = [self rebindCameraResource];
            [self callForStartScanningBonjour]; // 1. Scan with Bonjour
            [self scanForDevices];              // 2. Scan with ip server
            
            // 1 & 2 work parallely
            // Back from login - login success
            self.progressView.hidden = NO;
            
            break;
        }
            
        case SHOW_CAMERA_LIST: // This will actually switch to the selected camera
        {
            self.app_stage = APP_STAGE_LOGGED_IN;
            self.isRebinded = [self rebindCameraResource];
            [self startShowingCameraList];
            break;
        }
            
		default:
			break;
	}
}

- (void)createAccount
{
    DLog(@"MBP_iosVC - Load RegistrationVC");
    RegistrationViewController *registrationVC = [[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
    registrationVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registrationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)rebindCameraResource
{
    BOOL restore_successful = [self restoreConfigData];
    if (restore_successful) {
        for ( CamChannel *ch in _channelArray ) {
            if ( ch.profile ) {
                for ( CamProfile *cp in _restoredProfilesArray ) {
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
    
    return restore_successful;
}

- (void)callForStartScanningBonjour
{
    if ( _isRebinded ) {
        if ( [self isCurrentConnection3G] || _restoredProfilesArray.count == 0 ) {
            DLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            for ( CamProfile *cp in _restoredProfilesArray ) {
                cp.isInLocal = NO;
                cp.hasUpdateLocalStatus = YES;
            }
            
            [self finishScanning];
        }
        else {
            self.bonjourThread = [[NSThread alloc] initWithTarget:self selector:@selector(scan_with_bonjour) object:nil];
            [_bonjourThread start];
        }
    }
}

- (void)scan_with_bonjour
{
    @autoreleasepool {
        self.bonjourBrowser = [[Bonjour alloc] initSetupWith:_restoredProfilesArray];
        [_bonjourBrowser setDelegate:self];
        [_bonjourBrowser startScanLocalWiFi];
        
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while (_bonjourBrowser.isSearching) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        self.bonjourList = _bonjourBrowser.cameraList;
    }
    
    [NSThread exit];
}

- (BOOL)isThisMacStoredOffline:(NSString *)mac_without_colon
{
	if ( !_restoredProfilesArray && !_channelArray ) {
		// No offline data is available --> force re login
		return NO;
	}
    
	
	for ( CamProfile *cp in _restoredProfilesArray ) {
		if ( cp.mac_address ) {
			NSString *mac_wo_colon = [Util strip_colon_fr_mac:cp.mac_address];
			if ([mac_wo_colon isEqualToString:mac_without_colon]) {
				return YES;
			}
		}
	}
    
	return NO;
}

- (BOOL)pushNotificationRcvedServerAnnouncement:(NSString *)customMessage andUrl:(NSString *)customUrl
{
    NSString *title = LocStr(@"Server Announcement");
    NSString *ignore = LocStr(@"Close");
    NSString *details = LocStr(@"Details");
    NSString *msg = [NSString stringWithFormat:@"%@ %@", customMessage, customUrl];
    
    self.pushAlert = [[AlertPrompt alloc] initWithTitle:title
                                                message:msg
                                               delegate:self
                                      cancelButtonTitle:ignore
                                      otherButtonTitles:details, nil];
    
    _pushAlert.tag = ALERT_PUSH_SERVER_ANNOUNCEMENT;
    
    [self playSound];
    [_pushAlert show];
    
    return YES;
}

- (BOOL)pushNotificationRcvedInForeground:(CameraAlert *)camAlert
{
    // Check if we should popup
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	// MAC with COLON
	NSString *camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    
    DLog(@"camInView: %@ camAlert.cameraMacNoColon:%@", camInView,camAlert.cameraMacNoColon);
	
    if ( camInView ) {
		if ( [[Util strip_colon_fr_mac:camInView] isEqualToString:camAlert.cameraMacNoColon] ) {
			DLog(@"Silencely return, don't popup");
			return NO;
		}
	}
    
    if ( _app_stage == APP_STAGE_SETUP ) {
        DLog(@"APP_STAGE_SETUP. Don't popup!");
        return NO;
    }
    
    DLog(@"latestCamAlert is: %@", _latestCamAlert);
    
    if ( [_latestCamAlert.cameraMacNoColon isEqualToString:camAlert.cameraMacNoColon] ) {
        DLog(@"Same cam alert is currenlty stored.");
        
        if ( [_pushAlert isVisible] ) {
            DLog(@"Dialog exist, don't popup");
            
            @synchronized(self) {
                self.latestCamAlert = camAlert;
            }
            
            return NO;
        }
    }
    
    DLog(@"camAlert : %@",camAlert);
    
    NSString *msg = LocStr(@"Sound_detected");
    NSString *msg2= LocStr(@"Go_to_camera");

    if ( [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI] ) {
        msg = LocStr(@"Temperature_too_high");
    }
    else if ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO]) {
        msg = LocStr(@"Temperature_too_low");
    }
    else if ([camAlert.alertType isEqualToString:ALERT_TYPE_MOTION]) {
        msg = LocStr(@"Motion Detected");
        msg2 = LocStr(@"View_snapshot");
    }
    
    NSString *cancel = LocStr(@"Cancel");
    
    DLog(@"pushAlert : %@", _pushAlert);
    
    if ( _pushAlert ) {
        if ([_pushAlert isVisible]) {
            [_pushAlert dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
    
    self.pushAlert = [[UIAlertView alloc] initWithTitle:camAlert.cameraName
                                                message:msg
                                               delegate:self
                                      cancelButtonTitle:cancel
                                      otherButtonTitles:msg2, nil];
    
    _pushAlert.tag = ALERT_PUSH_RECVED_NON_MOTION;
    
    if ([camAlert.alertType isEqualToString:ALERT_TYPE_MOTION]) {
        _pushAlert.tag = ALERT_PUSH_RECVED_RESCAN_AFTER;
    }

    @synchronized(self) {
        self.latestCamAlert = camAlert;
    }
    
    [self playSound];
    [_pushAlert show];
    
	return YES;
}

- (void)playSound
{
	//Play beep
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        AudioServicesPlaySystemSound(_soundFileObject);
    }
    else {
        AudioServicesPlayAlertSound(_soundFileObject);
    }
}

- (void)logoutAndUnregistration
{
    @autoreleasepool {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        // Remove password and registration id
        [userDefaults removeObjectForKey:@"PortalPassword"];
        [userDefaults removeObjectForKey:_push_dev_token];
        
#if  !(TARGET_IPHONE_SIMULATOR)
        DLog(@"De-Register push with both parties: APNs and BMS ");

        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *appId = [userDefaults objectForKey:@"APP_ID"];
        NSString *userName = [userDefaults objectForKey:@"PortalUsername"];
        
        [userDefaults removeObjectForKey:@"PortalApiKey"];
        [userDefaults removeObjectForKey:@"PortalUseremail"];
        
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        // Drop all timeline for this user
        [[TimelineDatabase getSharedInstance] clearEventForUserName:userName];
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:nil
                                                                              FailSelector:nil
                                                                                 ServerErr:nil];
        
        NSDictionary *responseDict = [jsonComm deleteAppBlockedWithAppId:appId
                                                               andApiKey:apiKey];
        
        DLog(@"logout --> delete app status = %d", [[responseDict objectForKey:@"status"] intValue]);
        
        [NSThread sleepForTimeInterval:0.10];
#endif
        [userDefaults synchronize];
    }
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	int tag = alertView.tag;
    
    if (tag == ALERT_PUSH_RECVED_NON_MOTION) {
        switch(buttonIndex)
        {
			case 0:
                self.pushAlert = nil;
				break;
			case 1:
            {
				if ( _menuVC ) {
					NSArray *views = _menuVC.navigationController.viewControllers;
					DLog(@"views count = %d", views.count);
					if ( views.count > 1 ) {
                        if ( views.count > 2 ) {
                            id obj2 = views[2];
                            
                            if ([obj2 isKindOfClass:[PlaybackViewController class]]) {
                                PlaybackViewController *playbackViewController = (PlaybackViewController *)obj2;
                                [playbackViewController stopStream:nil];
                            }
                        }
                        
                        id obj = views[1];
                        
                        if ([obj isKindOfClass:[H264PlayerViewController class]]) {
                            H264PlayerViewController * h264PlayerViewController = (H264PlayerViewController *) obj;
                            [h264PlayerViewController goBackToCameraList];
                        }
					}
                    
                    [_menuVC dismissViewControllerAnimated:NO completion:nil];
				}
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:_latestCamAlert.registrationID forKey:REG_ID];
                [userDefaults synchronize];
                
                [self sendStatus:SHOW_CAMERA_LIST];
                self.latestCamAlert = nil;
                self.pushAlert = nil;

                break;
            }
                
			default:
				break;
		}
    }
	else if (tag == ALERT_PUSH_RECVED_RESCAN_AFTER) {
		switch(buttonIndex)
        {
			case 0:
                self.pushAlert = nil;
				break;
			case 1:
            {
				if ( _menuVC ) {
					DLog(@"RESCAN_AFTER close all windows and thread");
					NSArray *views = _menuVC.navigationController.viewControllers;
					DLog(@"views count = %d", views.count);
					if ( views.count > 1 ) {
                        if ( views.count > 2 ) {
                            id obj2 = views[2];
                            
                            if ([obj2 isKindOfClass:[PlaybackViewController class]]) {
                                PlaybackViewController *playbackViewController = (PlaybackViewController *)obj2;
                                [playbackViewController stopStream:nil];
                            }
                        }
                        
                        id obj = views[1];
                        
                        if ([obj isKindOfClass:[H264PlayerViewController class]]) {
                            H264PlayerViewController * h264PlayerViewController = (H264PlayerViewController *) obj;
                            [h264PlayerViewController goBackToCameraList];
                        }
					}
                    
                    [_menuVC dismissViewControllerAnimated:NO completion:nil];
				}
                
                NotifViewController *notifVC = [[NotifViewController alloc] initWithNibName:@"NotifViewController" bundle:nil];
                
                @synchronized(self) {
                    // Feed in data now
                    notifVC.cameraMacNoColon = _latestCamAlert.cameraMacNoColon;// @"34159E8D4F7F";//latestCamAlert.cameraMacNoColon;
                    notifVC.cameraName  = _latestCamAlert.cameraName;//@"SharedCam8D4F7F";//latestCamAlert.cameraName;
                    notifVC.alertType   = _latestCamAlert.alertType;//@"4";//latestCamAlert.alertType;
                    notifVC.alertVal    = _latestCamAlert.alertVal;//@"20130921064439810";//latestCamAlert.alertVal;
                    notifVC.registrationID = _latestCamAlert.registrationID;
                    notifVC.alertTime = _latestCamAlert.alertTime;
                    notifVC.NotifDelegate = self;
                    
                    self.latestCamAlert = nil;
                }
                
                [self.navigationController pushViewController:notifVC animated:NO];
                self.pushAlert = nil;
                
				break;
            }
                
			default:
				break;
		}
	}
	else if (tag == ALERT_PUSH_RECVED_RELOGIN_AFTER) {
		switch(buttonIndex)
        {
			case 0:
				break;
			case 1:
            {
				if ( _menuVC ) {
					DLog(@"RELOGIN_AFTER close all windows and thread");
					NSArray *views = _menuVC.navigationController.viewControllers;
					DLog(@"views count = %d", views.count);
					if ( views.count > 1 ) {
						if ( views.count > 2 ) {
                            id obj2 = views[2];
                            
                            if ([obj2 isKindOfClass:[PlaybackViewController class]]) {
                                PlaybackViewController *playbackViewController = (PlaybackViewController *)obj2;
                                [playbackViewController stopStream:nil];
                            }
                        }
                        
                        id obj = views[1];
                        
                        if ([obj isKindOfClass:[H264PlayerViewController class]]) {
                            H264PlayerViewController *h264PlayerViewController = (H264PlayerViewController *) obj;
                            [h264PlayerViewController goBackToCameraList];
                        }
					}
				}
                
                [self dismissViewControllerAnimated:NO completion:nil];
				[self sendStatus:LOGIN];

				break;
            }
                
			default:
				break;
		}
	}
    else if (tag == ALERT_PUSH_SERVER_ANNOUNCEMENT) {
        switch(buttonIndex)
        {
			case 0:
                //IGNORE
				break;
                
			case 1:
            {
                // Detail
                // Open the web browser now..
                NSArray *texts = [alertView.message componentsSeparatedByString:@" "];
                NSString *url = nil;
                BOOL found = NO;
                for (int i = texts.count-1; i > 0; i--) {
                    url =(NSString *)texts[i];
                    if ( [url hasPrefix:@"http://"] ) {
                        found = YES;
                        break;
                    }
                }
                
                if ( found ) {
                    DLog(@"server url: %@ ", url);
                    NSURL *ns_url = [NSURL URLWithString:url];
                    [[UIApplication sharedApplication] openURL:ns_url];
                }
                
                break;
            }
                
            default:
                break;
        }
    }
    else {
        DLog(@">>> !!! Unknown tag in MBP_iosViewController: %i", tag);
        [self showLogin];
    }
}

#pragma mark - Scan For cameras

- (void)scanForDevices
{
    if ( _isRebinded ) {
        if ( [self isCurrentConnection3G] || _restoredProfilesArray.count == 0 ) {
            DLog(@"Connection over 3g OR empty cam list  --> Skip scanning all together");
            for ( CamProfile *cp in _restoredProfilesArray ) {
                cp.isInLocal = NO;
                cp.hasUpdateLocalStatus = YES;
            }
            [self finishScanning];
        }
        else {
            self.nextCameraToScanIndex = _restoredProfilesArray.count - 1;
            [self scanNextCamera:_restoredProfilesArray index:_nextCameraToScanIndex];
        }
        
        [self performSelectorOnMainThread:@selector(startShowingCameraList)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

- (void)scanNextCamera:(NSArray *)profiles index:(int)i
{
    NSMutableArray *finalResult = [[NSMutableArray alloc] init];
    CamProfile *cp = nil;
    BOOL skipScan = NO;
    
    cp = (CamProfile *)profiles[i];
    if ( cp.mac_address ) {
        // Check if we are in the same network as the camera.. IF so
        // Try to scan .. otherwise... no point ..
        // 20121130: phung: incase the ip address is not valid... also try to scan ..
        if ( !cp.ip_address || [self isInTheSameNetworkAsCamera:cp] ) {
            skipScan = [self isCurrentIpAddressValid:cp];
            
            if (skipScan) {
                cp.port = 80;
                // Dont need to scan.. call scan_done directly
                [finalResult addObject:cp];
                [self performSelector:@selector(scan_done:) withObject:finalResult afterDelay:0.1];
            }
            else {
                // NEED to do local scan
                ScanForCamera *scanner = [[ScanForCamera alloc] initWithNotifier:self];
                [scanner scan_for_device:cp.mac_address];
            }
        }
        else {
            // Skip scanning too and assume we don't get any result
            [self performSelector:@selector(scan_done:) withObject:nil afterDelay:0.1];
        }
    }
}

#pragma mark - ScanForCameraNotifier protocol methods

- (void)scan_done:(NSArray *)scanResults
{
    // limit value of nextCameraToScanIndex
    if ( _nextCameraToScanIndex < 0 ) {
        return;
    }
    
    CamProfile *cp = (CamProfile *)_restoredProfilesArray[_nextCameraToScanIndex];

    // Scan done. read scan result
    if ( !scanResults  || scanResults.count == 0 ) {
        // Empty ..not found & also can't use the current IP?
        // Don't add to the final result
        cp.isInLocal = NO;
    }
    else {
        // found the camera ..
        // --> update local IP and other info
        for ( CamProfile *scanned in scanResults ) {
            if ([scanned.mac_address isEqualToString:cp.mac_address]) {
                cp.ip_address = scanned.ip_address;
                cp.isInLocal = YES;
                cp.port = scanned.port; // localport is always 80
                cp.hasUpdateLocalStatus = YES;
                break;
            }
        }
    }
    
    DLog(@"cam:%@ -is in Local:%d -fw:%@", cp.mac_address, cp.isInLocal, cp.fw_version);
    --_nextCameraToScanIndex;
    [self scanNextIndex:&_nextCameraToScanIndex]; // Sync results of ipserver & bonjour
}

#pragma mark - Private methods

- (void)scanNextIndex:(int *)index
{
    // Stop scanning
    if (*index == -1) {
        DLog(@"Scan done with ipserver");
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while ([_bonjourThread isExecuting]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        DLog(@"\n=================================\nSCAN DONE - IPSERVER SYNC BONJOUR\nrestored_profiles: %@\nbonjourList: %@\n=================================\n", _restoredProfilesArray, _bonjourList);
        
        if ( _bonjourList.count != 0 ) {
            for ( CamProfile *cp in _restoredProfilesArray ) {
                for ( CamProfile *cam in _bonjourList ) {
                    if ( [cp.mac_address isEqualToString:cam.mac_address] ) {
                        DLog(@"Camera %@ is on Bonjour, -port: %d", cp.mac_address, cam.port);
                        cp.ip_address = cam.ip_address;
                        cp.isInLocal = YES;
                        cp.port = cam.port;
                        
                        break;
                    }
                }
            }
        }
        
        for ( CamProfile *cp in _restoredProfilesArray ) {
            cp.hasUpdateLocalStatus = YES;
        }
        
        [self finishScanning];
    }
    else if (*index > -1) {
        // this camera at index has not been scanned
        if ( _menuVC ) {
            DLog(@"reload CamerasTableView in scan_done");
            // Notify to menuVC
            DLog(@"%p, %p, %p", self, _menuVC, _menuVC.camerasVC);
            [_menuVC.camerasVC camerasReloadData];
        }
        
        if (((CamProfile *)_restoredProfilesArray[*index]).hasUpdateLocalStatus == NO) {
            DLog(@"This camera at index has not been scanned");
            [self scanNextCamera:_restoredProfilesArray index:*index];
        }
        else {
            DLog(@"This camera at index has been scanned");
            
            --(*index);
            [self scanNextIndex:index];
        }
    }
}

- (void)finishScanning
{
    [_menuVC.camerasVC camerasReloadData];
}

- (BOOL)isInTheSameNetworkAsCamera:(CamProfile *)cp
{
    long ip = 0, ownip = 0;
    long netMask = 0 ;
	struct ifaddrs *ifa = NULL, *ifList;
    
    NSString *bc = @"";
	NSString *own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own ipasLong:&ownip];
    
    getifaddrs(&ifList); // should check for errors
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_netmask != NULL) {
            ip = (( struct sockaddr_in *)ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == ownip) {
                netMask = (( struct sockaddr_in *)ifa->ifa_netmask)->sin_addr.s_addr;
                break;
            }
        }
    }
    
    freeifaddrs(ifList); // clean up after yourself
    
    if (netMask == 0 || ip == 0) {
        return NO;
    }
    
    long camera_ip =0 ;
    if ( cp.ip_address ) {
        NSArray *tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if ([tokens count] != 4) {
            //sth is wrong
            return NO;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        if ( (camera_ip & netMask) == (ip & netMask) ) {
            DLog(@"in same subnet");
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isCurrentIpAddressValid:(CamProfile *)cp
{
    if ( cp.ip_address ) {
        HttpCommunication *dev_com = [[HttpCommunication alloc] init];
        dev_com.device_ip = cp.ip_address;
        
        NSString *mac = [dev_com sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:3.0];
        
        if ( mac.length == 12 ) {
            mac = [Util add_colon_to_mac:mac];
            
            if ([mac isEqualToString:cp.mac_address]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - 3G connection checks

- (BOOL)isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable) {
        //No internet
    }
    else if (status == ReachableViaWiFi) {
        //WiFi
    }
    else if (status == ReachableViaWWAN) {
        //3G
        return YES;
    }
    
    return NO;
}

#pragma mark -

+ (void)getBroadcastAddress:(NSString **)bcast AndOwnIp:(NSString**)ownip
{
	//Free & re-init Addresses
	FreeAddresses();
    
    GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
	NSString *log = @"";
	int i;
    
	for ( i = 0; i < MAXADDRS; ++i ) {
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
        
		theAddr = ip_addrs[i];
        
		if (theAddr == INVALID_IP) {
			break;
		}
        
		if (theAddr == localHost) {
            continue;
        }
        
		if (strncmp(if_names[i], "en", strlen("en")) == 0) {
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
		}
        
		DLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
              broadcast_addrs[i]);
        
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
               broadcast_addrs[i]];
	}

	if ( deviceIP ) {
		*ownip = [NSString stringWithString:deviceIP];
	}
    
	if ( deviceBroadcastIP ) {
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
}

+ (void)getBroadcastAddress:(NSString **)bcast AndOwnIp:(NSString**)ownip ipasLong:(long *)_ownip
{
	//Free & re-init Addresses
	FreeAddresses();
    
    GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
	NSString *log = @"";
	int i;
    
	for ( i = 0; i < MAXADDRS; ++i ) {
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
		theAddr = ip_addrs[i];
        
		if (theAddr == INVALID_IP) {
			break;
		}
        
		if (theAddr == localHost) {
            continue;
        }
        
		if (strncmp(if_names[i], "en", strlen("en")) == 0) {
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
            *_ownip = ip_addrs[i];
		}
        
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n",
               i, if_names[i], hw_addrs[i], ip_names[i], broadcast_addrs[i]];
	}
    
	if ( deviceIP ) {
		*ownip = [NSString stringWithString:deviceIP];
	}
    
	if ( deviceBroadcastIP ) {
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
}

- (void)showLogin
{
    self.app_stage = APP_STAGE_LOGGING_IN;
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil delegate:self];
    [self.navigationController pushViewController:loginVC animated:NO];
}

- (void)showNotificationViewController:(NSTimer *)exp
{
    // Back from login- login success
    [self dismissViewControllerAnimated:NO completion:nil];
    _progressView.hidden = NO;
    
    if ( [_camAlert.alertType isEqualToString:ALERT_TYPE_MOTION] ) {
        NotifViewController *notifVC = [[NotifViewController alloc] initWithNibName:@"NotifViewController" bundle:nil];
        notifVC.notifDelegate = self;

        //Feed in data now
        notifVC.cameraMacNoColon = _camAlert.cameraMacNoColon;
        notifVC.cameraName       = _camAlert.cameraName;
        notifVC.alertType        = _camAlert.alertType;
        notifVC.alertVal         = _camAlert.alertVal;
        notifVC.registrationID   = _camAlert.registrationID;
        
        [self presentViewController:[[UINavigationController alloc]initWithRootViewController:notifVC] animated:YES completion:nil];
    }
    else {
        // Sound/Temphi/templo - go to camera
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_latestCamAlert.registrationID forKey:REG_ID];
        [userDefaults synchronize];
        
        [self sendStatus:SHOW_CAMERA_LIST];
    }
}

#pragma mark - Read Configure data

- (BOOL)restoreConfigData
{
	SetupData *savedData = [[SetupData alloc] init];
	if ( [savedData restoreSessionData] ) {
		self.channelArray = savedData.channels;
		self.restoredProfilesArray = savedData.configuredCams;
	}
	return YES;
}

#pragma mark - Bonjour protocol methods from CameraScanner framework

- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
    
}

@end
