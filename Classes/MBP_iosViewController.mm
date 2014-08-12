//
//  MBP_iosViewController.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 Hubble Connected Ltd. All rights reserved.
//

//#define ALERT_GENERIC_SERVER_INFO @"0"

#import <CFNetwork/CFNetwork.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>
#import <MessageUI/MFMailComposeViewController.h>

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

@interface MBP_iosViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *statusDialogView;
@property (nonatomic, weak) IBOutlet UILabel *statusDialogLabel;
@property (nonatomic, weak) IBOutlet UITextView *statusDialogText;

@property (nonatomic, strong) UIAlertView *pushAlert;
@property (nonatomic, strong) CameraAlert *latestCamAlert;
@property (nonatomic, strong) DashBoard_ViewController *dashBoard;
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
                                        [UIImage imageNamed:@"loader_big_e"],
                                        //[UIImage imageNamed:@"loader_big_f"],
                                        ];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self initialize];
    
	//go Back to main menu
	[NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(wakeup_display_login:)
                                   userInfo:nil
                                    repeats:NO];
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self start_animation_with_orientation:interfaceOrientation];
    
    self.splashScreen.image = [UIImage imageNamed:@"loader_big_a"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                      @"Logging in to server..." , nil);
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

- (void)start_animation_with_orientation:(UIInterfaceOrientation)orientation
{
    self.splashScreen.animationDuration = 1.5;
    self.splashScreen.animationRepeatCount = 0;
}


- (void)wakeup_start_animte:(NSTimer *)timerExp
{
    NSLog(@"is animating? %d", [self.splashScreen isAnimating]);
    NSLog(@"animating images == nil? %d", (self.splashScreen.animationImages == nil));
    NSLog(@"count? %d", [self.splashScreen.animationImages count]);
}

- (void)wakeup_display_login:(NSTimer *)timerExp
{
#if 0
    NSLog(@">>> DBG PLAYER  ");
    PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
    //playbackViewController.urlVideo = @"http://nxcomm:2009nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00001.flv";
    
    playbackViewController.urlVideo = @"http://s3.amazonaws.com/sm.wowza.content/48022A2CAC31/clips/48022A2CAC31_04_20130918083756010_00001_last.flv?AWSAccessKeyId=AKIAIDBFDZTAR2EB4KPQ&Expires=1379501535&Signature=m%2FGcG%2BOh8wlwXcWqkiw%2BztAqAn8%3D";
    
    //[playbackViewController autorelease];
    
    [self presentViewController:playbackViewController animated:NO  completion:nil];
#else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:AUTO_LOGIN_KEY]) {
        NSLog(@"Auto login from AppDelegate. Do nothing");
        [self show_login_or_reg:nil];
    }
    else {
        self.app_stage = APP_STAGE_LOGGING_IN;
        NSLog(@"MBP_iosVC - show LoginVC from viewDidLoad after 4s");
        [self show_login_or_reg:nil];
    }
#endif
}

- (void)wakeup_display_first_page:(NSTimer *)timer_exp
{
    
}

- (void)startShowingCameraList:(NSNumber *)option
{
    if (_menuVC) {
        self.menuVC = nil;
    }
    
    self.menuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" withConnDelegate:self];
    
	NSMutableArray * validChannels = [[NSMutableArray alloc] init];
    
	for (int i = _channelArray.count - 1 ; i > -1; i--) {
		CamChannel *ch = _channelArray[i];
        if ( ch.profile ) {
			[validChannels addObject:_channelArray[i]];
        }
	}
    
	self.menuVC.cameras = validChannels;
    self.menuVC.camerasVC.camChannels = validChannels;
    
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:_menuVC animated:NO completion:nil];
        }];
    }
    else {
        [self presentViewController:_menuVC animated:NO completion:nil];
    }
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
                NSLog(@">>> SETUP ");
                //Normal add cam sequence - Load the next xib
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
                NSLog(@">>> REGISTER");
                [self createAccount];
            }
            
            break;
        }
            
		case SCAN_CAMERA:
        {
			//may be offline mode
            NSLog(@"start scanning");
            _statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;
            
            self.isRebinded = [self rebindCameraResource];
			[self performSelector:@selector(scan_for_devices)
                       withObject:nil
                       afterDelay:0.1];
            
			//Back from login- login success
			[self dismissViewControllerAnimated:NO completion:nil];
			self.progressView.hidden = NO;

			break;
        }
		
		case AFTER_DEL_RELOGIN: //Only use when cancel from Add camera
        {
            _statusDialogLabel.hidden = YES;
            [userDefaults setBool:YES forKey:AUTO_LOGIN_KEY];
            [userDefaults synchronize];
            
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(show_login_or_reg:)
                                           userInfo:nil
                                            repeats:NO];
            break;
        }
		case  BACK_FRM_MENU_NOLOAD: //USED by AppDelegate as well.. please check if modifying this case
        {
            NSLog(@"Back from menu");
            _statusDialogLabel.hidden = YES;
            //[self dismissViewControllerAnimated:NO completion:nil];
            
            if (self.presentedViewController) {
                [self dismissViewControllerAnimated:NO completion:^{}];
            }
            
            break;
        }
            
		case LOGIN_FAILED_OR_LOGOUT : //back from login -failed Or logout
        {
            _statusDialogLabel.hidden = YES;
            self.app_stage = APP_STAGE_LOGGING_IN;
            [self logoutAndUnregistration];
            [self show_login_or_reg:nil];
			
            break;
        }
            
        case SCAN_BONJOUR_CAMERA :
        {
            /*
             20130523_nguyendang :
             Scan camera with bonjour here
             If have any problem ? Back to Scan_for_camera
             */
            NSLog(@"start scanning Bonjour");
            
            _statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;
            
            self.isRebinded = [self rebindCameraResource];
            [self callForStartScanningBonjour]; // 1. Scan with Bonjour
            [self scan_for_devices];            // 2. Scan with ip server
            
            // 1 & 2 work parallely
            //Back from login- login success
            //[self dismissViewControllerAnimated:NO completion:^{}];
            self.progressView.hidden = NO;
            
            break;
        }
            
        case SHOW_CAMERA_LIST: // This  will actually switch to the selected camera
        {
            self.app_stage = APP_STAGE_LOGGED_IN;
            self.isRebinded = [self rebindCameraResource];
            
            [self performSelectorOnMainThread:@selector(startShowingCameraList:)
                                   withObject:[NSNumber numberWithInt:0]
                                waitUntilDone:NO];
            break;
        }
            
        case SHOW_CAMERA_LIST2:// Use this to force staying at camera list
        {
            self.app_stage = APP_STAGE_LOGGED_IN;
            self.isRebinded = [self rebindCameraResource];
            
            [self performSelectorOnMainThread:@selector(startShowingCameraList:)
                                   withObject:[NSNumber numberWithInt:STAY_AT_CAMERA_LIST]
                                waitUntilDone:NO];
            break;
        }
            
		default:
			break;
	}
}

- (void)createAccount
{
    NSLog(@"MBP_iosVC - Load RegistrationVC");
    RegistrationViewController *registrationVC = [[RegistrationViewController alloc] init];
    registrationVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registrationVC];
    [self presentViewController:nav animated:YES completion:^{}];
}

- (BOOL)rebindCameraResource
{
    BOOL restore_successful = NO;
    restore_successful = [self restoreConfigData];
    if (restore_successful == YES) {
        CamChannel* ch = nil;
        
        for (int i = 0; i < _channelArray.count; i++) {
            ch = (CamChannel*)_channelArray[i];
            if ( ch.profile ) {
                for (int j = 0; j < _restoredProfilesArray.count; j++) {
                    CamProfile * cp = (CamProfile *)_restoredProfilesArray[j];
                    if ( !cp.isSelected /*&& [cp.mac_address isEqualToString:ch.profile.mac_address]*/ ) {
                        //Re-bind camera - channel
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
        if ( [self isCurrentConnection3G] || _restoredProfilesArray.count == 0) {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            for (int j = 0; j < _restoredProfilesArray.count; j++) {
                CamProfile *cp = (CamProfile *)_restoredProfilesArray[j];
                cp.isInLocal = NO;
                cp.hasUpdateLocalStatus = YES;
            }
            
            [self finish_scanning];
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
		return FALSE;
	}
    
	CamProfile *cp = nil;
	for (int i = 0; i< _restoredProfilesArray.count; i++) {
		cp = (CamProfile *)_restoredProfilesArray[i];
		if ( cp.mac_address ) {
			NSString *mac_wo_colon = [Util strip_colon_fr_mac:cp.mac_address];
			if ([mac_wo_colon isEqualToString:mac_without_colon]) {
				return YES;
			}
		}
	}
    
	return NO;
}

- (BOOL)pushNotificationRcvedServerAnnouncement:(NSString *)custom_message andUrl:(NSString *)custom_url
{
    NSString *title = NSLocalizedStringWithDefaultValue(@"Server_Announcement",nil, [NSBundle mainBundle],
                                                        @"Server Announcement", nil);
    
    NSString *ignore = NSLocalizedStringWithDefaultValue(@"close",nil, [NSBundle mainBundle],
                                                         @"Close", nil);
    
    NSString *details = NSLocalizedStringWithDefaultValue(@"detail",nil, [NSBundle mainBundle],
                                                          @"Detail", nil);
    
    NSString *msg =[ NSString stringWithFormat:@"%@ %@",custom_message,custom_url];
    
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

	// mac with COLON
	NSString *camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    
    NSLog(@"camInView: %@ camAlert.cameraMacNoColon:%@", camInView,camAlert.cameraMacNoColon);
	
    if ( camInView ) {
		if ( [[Util strip_colon_fr_mac:camInView] isEqualToString:camAlert.cameraMacNoColon]) {
			NSLog(@"Silencely return, don't popup");
			return NO;
		}
	}
    
    if (self.app_stage == APP_STAGE_SETUP) {
        NSLog(@"APP_STAGE_SETUP. Don't popup!");
        return NO;
    }
    
    NSLog(@"latestCamAlert is: %@", _latestCamAlert);
    
    if ( [_latestCamAlert.cameraMacNoColon isEqualToString:camAlert.cameraMacNoColon]) {
        NSLog(@"Same cam alert is currenlty stored.");
        
        if ( [_pushAlert isVisible] ) {
            NSLog(@"Dialog exist, don't popup");
            
            @synchronized(self) {
                self.latestCamAlert = camAlert;
            }
            
            return NO;
        }
    }
    
    NSLog(@"camAlert : %@",camAlert);
    
    NSString *msg = NSLocalizedStringWithDefaultValue(@"Sound_detected",nil, [NSBundle mainBundle],
                                                      @"Sound detected", nil);
    NSString *msg2= NSLocalizedStringWithDefaultValue(@"Go_to_camera",nil, [NSBundle mainBundle],
                                                      @"Go to camera", nil);

    if ( [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI] ) {
        msg = NSLocalizedStringWithDefaultValue( @"Temperature_too_high",nil, [NSBundle mainBundle],
                                                @"Temperature too high", nil);
    }
    else if ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO]) {
        msg = NSLocalizedStringWithDefaultValue( @"Temperature_too_low",nil, [NSBundle mainBundle],
                                                @"Temperature too low", nil);
    }
    else if ([camAlert.alertType isEqualToString:ALERT_TYPE_MOTION]) {
        msg = NSLocalizedStringWithDefaultValue( @"Motion Detected",nil, [NSBundle mainBundle],
                                                @"Motion Detected", nil);
        msg2 = NSLocalizedStringWithDefaultValue(@"View_snapshot",nil, [NSBundle mainBundle],
                                                 @"View Snapshot", nil);
    }
    
    NSString *cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                         @"Cancel", nil);
    
    NSLog(@"pushAlert : %@", _pushAlert);
    
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
    
    NSLog(@"play sound");
    [self playSound];
    
    NSLog(@"show  alert");
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
        //REmove password and registration id
        [userDefaults removeObjectForKey:@"PortalPassword"];
        [userDefaults removeObjectForKey:_push_dev_token];
        
#if  !(TARGET_IPHONE_SIMULATOR)
        NSLog(@"De-Register push with both parties: APNs and BMS ");

        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *appId = [userDefaults objectForKey:@"APP_ID"];
        NSString *userName = [userDefaults objectForKey:@"PortalUsername"];
        
        [userDefaults removeObjectForKey:@"PortalApiKey"];
        [userDefaults removeObjectForKey:@"PortalUseremail"];
        
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        /* Drop all timeline for this user */
        [[TimelineDatabase getSharedInstance] clearEventForUserName:userName];
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:nil
                                                                              FailSelector:nil
                                                                                 ServerErr:nil];
        
        NSDictionary *responseDict = [jsonComm deleteAppBlockedWithAppId:appId
                                                               andApiKey:apiKey];
        
        NSLog(@"logout --> delete app status = %d", [[responseDict objectForKey:@"status"] intValue]);
        
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
                /*
                 * Try to hide MFMailComposeViewController's keyboard first.
                 */
                // Workaround: MFMailComposeViewController does not dismiss keyboard when application enters background or changes view screen.
                UITextView *dummyTextView = [[UITextView alloc] init];
                [((UIWindow *)[[[UIApplication sharedApplication] windows] objectAtIndex:0]).rootViewController.presentedViewController.view addSubview:dummyTextView];
                [dummyTextView becomeFirstResponder];
                [dummyTextView resignFirstResponder];
                [dummyTextView removeFromSuperview];
                // End of workaround
                
				if ( _menuVC ) {
					NSArray *views = _menuVC.navigationController.viewControllers;
					NSLog(@"views count = %d", views.count);
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
    
	if (tag == ALERT_PUSH_RECVED_RESCAN_AFTER) {
		switch(buttonIndex)
        {
			case 0:
                self.pushAlert = nil;
				break;
			case 1:
            {
				if ( _menuVC ) {
					NSLog(@"RESCAN_AFTER close all windows and thread");
                    
					NSArray *views = _menuVC.navigationController.viewControllers;
					NSLog(@"views count = %d", views.count);
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
                    
                    [_menuVC dismissViewControllerAnimated:NO completion:^{}];
				}
                
                NotifViewController *notifVC = [[NotifViewController alloc] init];
                
                @synchronized(self) {
                    //Feed in data now
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
                
                NSLog(@"alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex: %p, %p", self, _latestCamAlert);
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
                /*
                 * Try to hide MFMailComposeViewController's keyboard first.
                 */
                
                // Workaround: MFMailComposeViewController does not dismiss keyboard when application enters background or changes view screen.
                UITextView *dummyTextView = [[UITextView alloc] init];
                [((UIWindow *)[[[UIApplication sharedApplication] windows] objectAtIndex:0]).rootViewController.presentedViewController.view addSubview:dummyTextView];
                [dummyTextView becomeFirstResponder];
                [dummyTextView resignFirstResponder];
                [dummyTextView removeFromSuperview];
                // End of workaround
                
				if ( _menuVC ) {
					NSLog(@"RELOGIN_AFTER close all windows and thread");
					//[dashBoard.navigationController popToRootViewControllerAnimated:NO];
                    
					NSArray * views = _menuVC.navigationController.viewControllers;
					NSLog(@"views count = %d", views.count);
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
                
                [self dismissViewControllerAnimated:NO completion:^{}];
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
                //Detail
            {
                // Open the web browser now..
                NSArray *texts = [alertView.message componentsSeparatedByString:@" "];
                NSString *url = nil;
                BOOL found = FALSE;
                for (int i = texts.count-1; i > 0; i--) {
                    url =(NSString *)texts[i];
                    if ( [url hasPrefix:@"http://"] == TRUE ) {
                        found = YES;
                        break;
                    }
                }
                
                if ( found ) {
                    NSLog(@"server url:%@ ",url);
                    NSURL *ns_url = [NSURL URLWithString:url];
                    [[UIApplication sharedApplication] openURL:ns_url];
                }
                
                break;
            }
                
            default:
                break;
        }
    }
    else if (tag == 11) {
        if (buttonIndex == 1) {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                
                NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *logCrashedPath = [cachesDirectory stringByAppendingPathComponent:@"application_crash.log"];
                NSString *logPath0 = [cachesDirectory stringByAppendingPathComponent:@"application0.log"];
                
                NSData *dataLog = [NSData dataWithContentsOfFile:logCrashedPath];
                NSData *dataLog0 = nil;
                if ([[NSFileManager defaultManager] fileExistsAtPath:logPath0]) {
                    dataLog0 = [NSData dataWithContentsOfFile:logPath0];
                }
                
                NSInteger length = dataLog.length;
                if (dataLog0) {
                    length += dataLog0.length;
                }
                
                NSMutableData *dataZip = [NSMutableData dataWithLength:length];
                if (dataLog0) {
                    [dataZip appendData:dataLog0];
                }
                
                [dataZip appendData:dataLog];
                dataZip = [[NSData gzipData:dataZip] mutableCopy];
                [picker addAttachmentData:[dataZip AES128EncryptWithKey:CES128_ENCRYPTION_PASSWORD] mimeType:@"text/plain" fileName:@"application_crash.log"];
                
                // Set the subject of email
                [picker setSubject:@"iOS app crash log"];
                NSArray *toRecipents = [NSArray arrayWithObject:@"ios.crashreport@cvisionhk.com"];
                [picker setToRecipients:toRecipents];
                
                // Show email view
                [self presentViewController:picker animated:YES completion:nil];
            }
            else {
                NSLog(@"Can not send email from this device...");

                // Cancel
                /*
                 * 1. Try to remove crashed log file.
                 * 2. Force show login view, do not check again
                 */
                
                [self show_login_or_reg:nil];
                [self removeCrashedLogFile];
            }
        }
        else {
            /*
             * 1. Try to remove crashed log file.
             * 2. Force show login view, do not check again
             */
            
            [self show_login_or_reg:nil];
            [self removeCrashedLogFile];
        }
    }
}

#pragma mark - Scan For cameras

- (void)scan_for_devices
{
    if ( _isRebinded ) {
        if ( [self isCurrentConnection3G] || _restoredProfilesArray.count == 0 ) {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            for (int j = 0; j < _restoredProfilesArray.count; j++) {
                CamProfile * cp = (CamProfile *)_restoredProfilesArray[j];
                cp.isInLocal = NO;
                cp.hasUpdateLocalStatus = YES;
            }
            [self finish_scanning];
        }
        else {
            self.nextCameraToScanIndex = _restoredProfilesArray.count - 1;
            [self scan_next_camera:_restoredProfilesArray index:_nextCameraToScanIndex];
        }
        
        [self performSelectorOnMainThread:@selector(startShowingCameraList:)
                               withObject:[NSNumber numberWithInt:0]
                            waitUntilDone:NO];
    }
}

- (void)scan_next_camera:(NSArray *)profiles index:(int)i
{
    NSMutableArray *finalResult = [[NSMutableArray alloc] init];
    CamProfile *cp = nil;
    
    BOOL skipScan = FALSE;
    
    cp = (CamProfile *)profiles[i];
    if ( cp.mac_address ) {
        //Check if we are in the same network as the camera.. IF so
        // Try to scan .. otherwise... no point ..
        //20121130: phung: incase the ip address is not valid... also try to scan ..
        if ( !cp.ip_address || [self isInTheSameNetworkAsCamera:cp] ) {
            skipScan = [self isCurrentIpAddressValid:cp];
            
            if (skipScan) {
                cp.port = 80;
                //Dont need to scan.. call scan_done directly
                [finalResult addObject:cp];
                [self performSelector:@selector(scan_done:) withObject:finalResult afterDelay:0.1];
            }
            else {
                // NEED to do local scan
                ScanForCamera *scanner = [[ScanForCamera alloc] initWithNotifier:self];
                [scanner scan_for_device:cp.mac_address];
                //Can't call release because app is crashed, will fix later
                //[scanner release];
            }
        }
        else {
            //Skip scanning too and assume we don't get any result
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
    
    CamProfile *cp =(CamProfile *)_restoredProfilesArray[_nextCameraToScanIndex];
    // scan Done. read scan result
    
    if ( !scanResults  || scanResults.count == 0 ) {
        // Empty ..not found & also can't use the current IP?
        // Don't add to the final result
        cp.isInLocal = NO;
    }
    else {
        // found the camera ..
        // --> update local IP and other info
        CamProfile* scanned;
        for (int i = 0; i < scanResults.count; i++) {
            scanned = ((CamProfile*)scanResults[i]);
            
            if ([scanned.mac_address isEqualToString:cp.mac_address]) {
                cp.ip_address = ((CamProfile*)scanResults[i]).ip_address;
                cp.isInLocal = TRUE;
                cp.port = ((CamProfile*)scanResults[i]).port; //localport is always 80
                cp.hasUpdateLocalStatus = YES;
                
                break;
            }
        }
    }
    
    NSLog(@"cam:%@ -is in Local:%d -fw:%@", cp.mac_address, cp.isInLocal, cp.fw_version);
    --_nextCameraToScanIndex;
    [self scanNextIndex:&_nextCameraToScanIndex]; // Sync results of ipserver & bonjour
}

- (void)scanNextIndex:(int *)index
{
    // Stop scanning
    if (*index == -1) {
        NSLog(@"Scan done with ipserver");
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while ([_bonjourThread isExecuting]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        NSLog(@"\n=================================\nSCAN DONE - IPSERVER SYNC BONJOUR\nrestored_profiles: %@\nbonjourList: %@\n=================================\n", _restoredProfilesArray, _bonjourList);
        
        if ( _bonjourList.count != 0 ) {
            for (CamProfile *cp in _restoredProfilesArray) {
                for (CamProfile *cam in _bonjourList) {
                    if ([cp.mac_address isEqualToString:cam.mac_address]) {
                        NSLog(@"Camera %@ is on Bonjour, -port: %d", cp.mac_address, cam.port);
                        cp.ip_address = cam.ip_address;
                        cp.isInLocal = YES;
                        cp.port = cam.port;
                        
                        break;
                    }
                }
            }
        }
        
        for (CamProfile *cp in _restoredProfilesArray) {
            cp.hasUpdateLocalStatus = YES;
        }
        
        [self finish_scanning];
    }
    else if (*index > -1) {
        // this camera at index has not been scanned
        if ( _menuVC ) {
            NSLog(@"reload CamerasTableView in scan_done");
            // Notify to menuVC
            NSLog(@"%p, %p, %p", self, _menuVC, _menuVC.camerasVC);
            [_menuVC.camerasVC camerasReloadData];
        }
        
        if (((CamProfile *)_restoredProfilesArray[*index]).hasUpdateLocalStatus == NO) {
            NSLog(@"This camera at index has not been scanned");
            [self scan_next_camera:_restoredProfilesArray index:*index];
        }
        else {
            NSLog(@"This camera at index has been scanned");
            
            --(*index);
            [self scanNextIndex:index];
        }
    }
}

- (void)finish_scanning
{
    [self.menuVC.camerasVC camerasReloadData];
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
        return FALSE;
    }
    
    long camera_ip =0 ;
    if ( cp.ip_address ) {
        NSArray *tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if ([tokens count] != 4) {
            //sth is wrong
            return FALSE;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        if ( (camera_ip & netMask) == (ip & netMask) ) {
            NSLog(@"in same subnet");
            return TRUE;
        }
    }
    
    return FALSE;
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
    
	for (i=0; i < MAXADDRS; ++i) {
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
        
		NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
              broadcast_addrs[i]);
        
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
               broadcast_addrs[i]];
	}

	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];
    
	//NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	//NSLog(@"own iP: %d %@",i, deviceIP);
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
    
	for (i = 0; i < MAXADDRS; ++i) {
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
        
		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
		// broadcast_addrs[i]);
        
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

- (void)show_login_or_reg:(NSTimer *)timer
{
    /*
     * 1. If timer is NOT nil --> - check exist of crashed log file
     * 2. If time is nil need not to check.
     */
    BOOL hasOptionSendEmail = NO;
    
    if ( timer ) {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *logCrashedPath = [cachesDirectory stringByAppendingPathComponent:@"application_crash.log"];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:logCrashedPath]) {
            NSLog(@"App crashed!");
            hasOptionSendEmail = YES;
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send app log" message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
            av.tag = 11;
            [av show];
        }
    }
    
    NSLog(@"%s: show login view - timer: %p, has crashed log: %d", __FUNCTION__, timer, hasOptionSendEmail);
    
    if (!hasOptionSendEmail) {
        NSLog(@"show_login... ");
        self.app_stage = APP_STAGE_LOGGING_IN;
        
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController"   bundle:Nil   delegate:self];
        [self.navigationController pushViewController:loginVC animated:NO];
    }
}

- (void)showNotificationViewController:(NSTimer *)exp
{
    //Back from login- login success
    [self dismissViewControllerAnimated:NO completion:nil];
    self.progressView.hidden = NO;
    
    if ([self.camAlert.alertType isEqualToString:ALERT_TYPE_MOTION]) {
        NotifViewController *notifVC = [[NotifViewController alloc] initWithNibName:@"NotifViewController" bundle:Nil];
        notifVC.notifDelegate = self;

        //Feed in data now
        notifVC.cameraMacNoColon = self.camAlert.cameraMacNoColon;
        notifVC.cameraName       = self.camAlert.cameraName;
        notifVC.alertType        = self.camAlert.alertType;
        notifVC.alertVal         = self.camAlert.alertVal;
        notifVC.registrationID   = self.camAlert.registrationID;
        
        [self presentViewController:[[UINavigationController alloc]initWithRootViewController:notifVC] animated:YES completion:^{}];
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
		//NSLog(@"restored data done");
		self.channelArray = savedData.channels;
		self.restoredProfilesArray = savedData.configuredCams;
	}
    
    
	return YES;
}

// clear one warning
- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
    
}

#pragma mark - FMail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:^{
        /*
         * 1. Try to remove crashed log file
         * 2. Force show login view
         */
        [self show_login_or_reg:nil];
        [self removeCrashedLogFile];
    }];
}

- (void)removeCrashedLogFile
{
    // Remove crashed log file
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *logCrashedPath = [cachesDirectory stringByAppendingPathComponent:@"application_crash.log"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSError *errorFile;
    BOOL success = [fileManager removeItemAtPath:logCrashedPath error:&errorFile];
    if (success) {
        //        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        //        [removeSuccessFulAlert show];
        NSLog(@"Removed application_crash.log successfuly!");
    }
    else {
        NSLog(@"Could not delete file -:%@ ", [errorFile localizedDescription]);
    }
}

@end
