//
//  MBP_iosViewController.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define ALERT_PUSH_RECVED_RESCAN_AFTER              200
#define ALERT_PUSH_RECVED_RELOGIN_AFTER             201
#define ALERT_PUSH_SERVER_ANNOUNCEMENT              203
#define ALERT_PUSH_RECVED_SOUND_TEMP_HI_TEMP_LO     204
#define ALERT_PUSH_RECVED_MULTIPLE                  205
#define ALERT_PUSH_RECVED_REMOVE_CAM                206
#define ALERT_PUSH_RECVED_PASSWORD_CHANGED          207

#import <CFNetwork/CFNetwork.h>
#include <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "MBP_iosViewController.h"
#import "H264PlayerViewController.h"

#import "Step_02_ViewController.h"
#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import "define.h"
//#import "Reachability.h"
#import "SetupData.h"

#import "AlertPrompt.h"
//#import "KISSMetricsAPI.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "NSData+AESCrypt.h"
#import "CameraMenuViewController.h"
#import "MenuViewController.h"
#import "TimelineDatabase.h"
#import "NotifViewController.h"
#import "PushNotificationAlert.h"
#import "PublicDefine.h"

@interface MBP_iosViewController () <MFMailComposeViewControllerDelegate, ConnectionMethodDelegate, UIActionSheetDelegate>
{
    SystemSoundID soundFileObject;
    NSArray * channel_array;
    NSMutableArray * restored_profiles ;
    int app_stage;
    BOOL isRebinded;
    
    //int nextCameraToScanIndex;
    //Bonjour * _bonjourBrowser;
    //NSArray * bonjourList;
    //NSThread * bonjourThread;
}

@property (nonatomic, retain) IBOutlet UIImageView * splashScreen;

@property (nonatomic, retain) NSArray * channel_array;
@property (nonatomic, retain) NSMutableArray * restored_profiles ;
@property (nonatomic, retain) PushNotificationAlert * pushAlert;
@property (nonatomic, retain) MenuViewController *menuVC;
@property (nonatomic) BOOL changePasswordReady;

@end

@implementation MBP_iosViewController


@synthesize channel_array;
@synthesize restored_profiles ;

@synthesize app_stage;

- (void) initialize
{
	//self.app_stage = APP_STAGE_INIT;
    self.app_stage = APP_STAGE_LOGGING_IN;
    
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("Voicemail"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    CFRelease(soundFileURLRef);
    self.splashScreen.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"loader_big_a"],
                                        [UIImage imageNamed:@"loader_big_b"],
                                        [UIImage imageNamed:@"loader_big_c"],
                                        [UIImage imageNamed:@"loader_big_d"],
                                        [UIImage imageNamed:@"loader_big_e"],
                                        //[UIImage imageNamed:@"loader_big_f"],
                                        nil];
    self.changePasswordReady = YES;
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    //self.navigationController.navigationBarHidden = YES;
    
	[self initialize];
    
    
	//go Back to main menu
	[NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(wakeup_display_login:)
                                   userInfo:nil
                                    repeats:NO];
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //    [self adjustViewsForOrientations:interfaceOrientation];
    
    [self start_animation_with_orientation:interfaceOrientation];
    
    self.splashScreen.image = [UIImage imageNamed:@"loader_big_a"];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Logging_in_to_server" ,nil, [NSBundle mainBundle],
                                                       @"Logging in to server..." , nil);
    UILabel *labelMessage = (UILabel *)[self.view viewWithTag:509];
    [labelMessage setText:msg];
    
    if (_splashScreen != nil)
    {
        [_splashScreen startAnimating];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_splashScreen != nil)
    {
        [_splashScreen stopAnimating];
    }
}

-(CGRect) deviceFrameWithOrientation:(UIInterfaceOrientation) orientation
{
    CGRect deviceBound = [UIScreen mainScreen].bounds;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect newBound = CGRectMake(0, 0, deviceBound.size.height, deviceBound.size.width);
        return newBound;
    }
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return deviceBound;
    }
    
    return deviceBound;
}

-(void)start_animation_with_orientation :(UIInterfaceOrientation) orientation
{
    
    
    self.splashScreen.animationDuration = 1.5;
    self.splashScreen.animationRepeatCount = 0;
    
    //    [_splashScreen startAnimating];
}


- (void)wakeup_start_animte:(NSTimer*) timer_exp
{
    
    NSLog(@"is animating? %d", [self.splashScreen isAnimating]);
    
    NSLog(@"animating images == nil? %d", (self.splashScreen.animationImages == nil));
    NSLog(@"count? %d", [self.splashScreen.animationImages count]);
    //[self.splashScreen startAnimating];
    
}

- (void)wakeup_display_login:(NSTimer*) timer_exp
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
    
    if ([userDefaults boolForKey:_AutoLogin])
    {
        NSLog(@"Auto login from AppDelegate. Do nothing");
        [self show_login_or_reg:nil];
    }
    else
    {
        self.app_stage = APP_STAGE_LOGGING_IN;
        NSLog(@"MBP_iosVC - show LoginVC from viewDidLoad after 4s");
        
        [self show_login_or_reg:nil];
    }
    
    
#endif
}


- (void)wakeup_display_first_page:(NSTimer*) timer_exp
{
    
}

-(void) startShowingCameraList:(NSNumber *) option
{
#if 1
    _menuVC = [[MenuViewController alloc] initWithCaller:self];
#else
    if (_menuVC)
    {
        self.menuVC = nil;
    }
    
    _menuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController"
                                                       bundle:nil
                                             withConnDelegate:self];
#endif
    
	NSMutableArray * validChannels = [[NSMutableArray alloc]init ];
    
	for (int i = channel_array.count - 1 ; i > -1; i--)
	{
		CamChannel * ch = [channel_array objectAtIndex:i];
        if (ch.profile != nil)
        {
            ch.profile.hasUpdateLocalStatus = YES;
			[validChannels addObject:[channel_array objectAtIndex:i]];
        }
        
	}
    
    if (option != nil && [option intValue] == STAY_AT_CAMERA_LIST)
    {
        self.menuVC.isFirttime = TRUE;
    }
    
	self.menuVC.cameras = validChannels;
    self.menuVC.camerasVC.camChannels = validChannels;
    
#if 1
    [self.navigationController pushViewController:_menuVC animated:NO];
#else
    EarlierNavigationController *nav = [[EarlierNavigationController alloc] initWithRootViewController:self.menuVC];
    
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self presentViewController:nav animated:NO completion:nil];
        }];
    } else {
        [self presentViewController:nav animated:NO completion:nil];
    }
    
    
    NSLog(@"MBP_iosVC - Showing cameralist?  %d", self.menuVC.isFirttime);
    [nav release];
#endif
    [validChannels release];
}



/*
 // Override to allow orientations other than the default portrait orientation.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return NO;
    
}

- (BOOL) shouldAutorotate
{
    
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    //return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
    
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
	// [mainMenuView release];
    //[_bonjourBrowser release];
    [_splashScreen release];
    
	[channel_array release];
	[restored_profiles release];
    
    //[bonjourThread release];
    [_menuVC release];
    [_pushAlert release];
	[super dealloc];
}

#pragma mark -
#pragma mark ConnectionMethodDelegate - Views navigation

/**** Main program switching point is here *****/
- (void)sendStatus:(int) method
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
	switch (method)
    {
        case SETUP_CAMERA:
        {
            NSLog(@">>> SETUP.");
            
            self.app_stage = APP_STAGE_SETUP;
            
            Step_02_ViewController *step02ViewController = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                step02ViewController = [[Step_02_ViewController alloc]
                                        initWithNibName:@"Step_02_ViewController_ipad" bundle:nil];
            }
            else
            {
                step02ViewController = [[Step_02_ViewController alloc]
                                        initWithNibName:@"Step_02_ViewController" bundle:nil];
            }
            
            step02ViewController.delegate = self;
            step02ViewController.cameraType = [[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:step02ViewController];
            //[self presentViewController:nav animated:NO completion:^{}];
            [step02ViewController release];
            
            if (self.presentedViewController) {
                [self dismissViewControllerAnimated:NO completion:^{
                    [self presentViewController:nav animated:YES completion:nil];
                }];
            } else {
                [self presentViewController:nav animated:YES completion:nil];
            }
            
            [nav release];
        }
            break;
            
		case LOGIN_FAILED_OR_LOGOUT : //back from login -failed Or logout
        {
            NSLog(@"%s LOGIN_FAILED_OR_LOGOUT.", __FUNCTION__);
            //Clear Do Not Disturb Cache
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:(NSInteger)[[NSDate date] timeIntervalSince1970] forKey:TIME_TO_EXPIRED];
            [userDefaults setBool:NO forKey:ENABLE_DO_NOT_DISTURB];
            [userDefaults synchronize];
            
            //statusDialogLabel.hidden = YES;
            self.app_stage = APP_STAGE_LOGGING_IN;
            
            
            [self logoutAndUnregistration_bg];
            [self show_login_or_reg:nil];
        }
            break;
            
        case SHOW_CAMERA_LIST: // This  will actually switch to the selected camera
        {
            self.app_stage = APP_STAGE_LOGGED_IN;
            isRebinded = [self rebindCameraResource];
            
            [self performSelectorOnMainThread:@selector(startShowingCameraList:)
                                   withObject:[NSNumber numberWithInt:0]
                                waitUntilDone:NO];
        }
            break;
            
        case SHOW_CAMERA_LIST2:// Use this to force staying at camera list
        {
            self.app_stage = APP_STAGE_LOGGED_IN;
            isRebinded = [self rebindCameraResource];
            
            [self performSelectorOnMainThread:@selector(startShowingCameraList:)
                                   withObject:[NSNumber numberWithInt:STAY_AT_CAMERA_LIST]
                                waitUntilDone:NO];
            
            break;
        }
#if 0
        case SETUP_CAMERA:
        {
            self.app_stage = APP_STAGE_SETUP;
            
            BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
            
            if (isFirstTimeSetup == FALSE)
            {
                NSLog(@">>> SETUP ");
                //Normal add cam sequence
                //Load the next xib
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                Step_02_ViewController *step02ViewController = nil;
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    step02ViewController = [[Step_02_ViewController alloc]
                                            initWithNibName:@"Step_02_ViewController_ipad" bundle:nil];
                }
                else
                {
                    step02ViewController = [[Step_02_ViewController alloc]
                                            initWithNibName:@"Step_02_ViewController" bundle:nil];
                }
                
                step02ViewController.delegate = self;
                step02ViewController.cameraType = [userDefaults integerForKey:SET_UP_CAMERA];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:step02ViewController];
                //[self presentViewController:nav animated:NO completion:^{}];
                [step02ViewController release];
                
                if (self.presentedViewController) {
                    [self dismissViewControllerAnimated:NO completion:^{
                        [self presentViewController:nav animated:YES completion:nil];
                    }];
                } else {
                    [self presentViewController:nav animated:YES completion:nil];
                }
                [nav release];
            }
            else
            {
                NSLog(@">>> REGISTER");
                [self createAccount];
            }
        }
            break;
            
        case SCAN_CAMERA:
        {
            //may be offline mode
            NSLog(@"start scanning");
            //statusDialogLabel.hidden = NO;
            self.app_stage = APP_STAGE_LOGGED_IN;
            
            isRebinded = [self rebindCameraResource];
            [self performSelector:@selector(scan_for_devices)
                       withObject:nil
                       afterDelay:0.1];
            
            //Back from login- login success
            [self dismissViewControllerAnimated:NO completion:nil];
            //self.progressView.hidden = NO;
        }
            break;
            
        case AFTER_DEL_RELOGIN: //Only use when cancel from Add camera
        {
            
            //statusDialogLabel.hidden = YES;
            
            [userDefaults setBool:TRUE forKey:_AutoLogin];
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
            //statusDialogLabel.hidden = YES;
            //[self dismissViewControllerAnimated:NO completion:nil];
            
            if (self.presentedViewController)
            {
                [self dismissViewControllerAnimated:NO completion:^{}];
            }
            
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
            
            //statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;
            
            isRebinded = [self rebindCameraResource];
            [self callForStartScanningBonjour]; // 1. Scan with Bonjour
            [self scan_for_devices];            // 2. Scan with ip server
            
            // 1 & 2 work parallely
            
            //Back from login- login success
            //[self dismissViewControllerAnimated:NO completion:^{}];
            //self.progressView.hidden = NO;

            break;
        }
#endif
		default:
			break;
	}
    
}

- (void)startPasswordChanged {
    self.changePasswordReady = NO;
}

- (void)finishPasswordChanged {
    self.changePasswordReady = YES;
}
#pragma mark - 

- (void)createAccount
{
    NSLog(@"MBP_iosVC - Load RegistrationVC");
    RegistrationViewController *registrationVC = [[RegistrationViewController alloc] init];
    registrationVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registrationVC];
    [self presentViewController:nav animated:YES completion:^{}];
    //[self.navigationController presentViewController:registrationVC animated:YES completion:^{}];
    [registrationVC release];
}

-(BOOL) rebindCameraResource
{
    BOOL restore_successful = FALSE;
    restore_successful = [self restoreConfigData];
    if (restore_successful == YES)
    {
        CamChannel* ch = nil;
        
        for (int i = 0; i< [channel_array count]; i++)
        {
            ch = (CamChannel*) [channel_array objectAtIndex:i];
            
            if ( ch.profile != nil)
            {
                for (int j = 0; j < [restored_profiles count]; j++)
                {
                    CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                    if ( !cp.isSelected //&&
                        //[cp.mac_address isEqualToString:ch.profile.mac_address]
                        )
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

-(BOOL) pushNotificationRcvedServerAnnouncement:(NSString *) custom_message andUrl:(NSString *) custom_url
{
    
    NSString * title = NSLocalizedStringWithDefaultValue(@"Server_Announcement",nil, [NSBundle mainBundle],
                                                         @"Server Announcement", nil);
    
    NSString * ignore = NSLocalizedStringWithDefaultValue(@"close",nil, [NSBundle mainBundle],
                                                          @"Close", nil);
    
    NSString * details = NSLocalizedStringWithDefaultValue(@"detail",nil, [NSBundle mainBundle],
                                                           @"Detail", nil);
    
    NSString * msg =[ NSString stringWithFormat:@"%@ %@",custom_message,custom_url];
    
    _pushAlert = [[PushNotificationAlert alloc]
                 initWithTitle:title
                 message:msg
                 delegate:self
                 cancelButtonTitle:ignore
                 otherButtonTitles:details, nil];
    
    
    self.pushAlert.tag = ALERT_PUSH_SERVER_ANNOUNCEMENT;
    
    [self playSound];
    [self.pushAlert show];
    
    
    return TRUE;
}


- (void)pushNotificationRcvedInForeground:(CameraAlert *)camAlert
{
    //Check if we should popup
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//mac with COLON
	NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    
    NSLog(@"camInView: %@ ", camInView);
	
    NSLog(@"camAlert.cameraMacNoColon:%@, alert time: %@", camAlert.cameraMacNoColon,camAlert.alertTime);
    
    [CameraAlert clearObsoleteAlerts];
    
    if ([self isStayingLoginPage])
    {
        // current user stay in Login page
        return;
    }
    if ([self isStayingSettupPage] && ![camAlert.alertType isEqualToString:ALERT_TYPE_PASSWORD_CHANGED])
    {
        NSLog(@"APP_STAGE_SETUP. Don't popup! ignore?");
        return;
    }
    
    if ([self isStayingSelectedCamaraPage])
    {
        // User is staying Player View
		if ([self playingCameraEqualCamera:camAlert.cameraMacNoColon])
		{
            if ([camAlert.alertType isEqualToString:ALERT_TYPE_SOUND] ||
                [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI]  ||
                [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO] ||
                [camAlert.alertType isEqualToString:ALERT_TYPE_MOTION])
            {
                NSLog(@"Silencely return, don't popup");
                //Broadcast a message to trigger updating event.
                [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_NOTIFY_BROADCAST_WHILE_APP_INVIEW
                                                                    object:nil];
                return;
            }
        }
        else
        {
            if ([camAlert.alertType isEqualToString:ALERT_TYPE_REMOVED_CAM])
            {
                return;
            }
        }
    }
    
    if ([self isStayingCamerasListPage])
    {
        if ([camAlert.alertType isEqualToString:ALERT_TYPE_REMOVED_CAM] && ![self isStayingCameraSettingsPage])
        {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *justRemovedMac = [userDefault objectForKey:CAM_MAC_JUST_REMOVED];
            if (justRemovedMac)
            {
                if ([justRemovedMac hasPrefix:camAlert.cameraMacNoColon])
                {
                    [userDefault setObject:nil forKey:CAM_MAC_JUST_REMOVED];
                    [userDefault synchronize];
                    return;
                }
            }
            [self refreshCamerasListPage:camAlert.registrationID];
            return;
        }
    }
    
    if (self.pushAlert != nil && self.pushAlert.tag == ALERT_PUSH_RECVED_MULTIPLE)
    {
        NSLog(@"already shown the aggregation message");
        return;
    }
    
    
    NSString *alertTitle = @"";
    NSString *alertMess = @"";
    NSString * alertLeftButtonText = NSLocalizedStringWithDefaultValue(@"ok",nil, [NSBundle mainBundle],
                                                                       @"OK", nil);
    NSString *alertOtherButtonText = nil;
    int tag = -1;;
    int autoDissmisAlertIndex = 0;
    if ([camAlert.alertType isEqualToString:ALERT_TYPE_PASSWORD_CHANGED])
    {
        [self verifyPasswordChangedPushNotification];
        return;
    }
    else
    {
        if ([self checkPushNotification:camAlert.cameraMacNoColon] == NO)
        {
            return;
        }
        alertTitle = camAlert.cameraName;
        alertLeftButtonText = NSLocalizedStringWithDefaultValue(@"cancel",nil, [NSBundle mainBundle],
                                                                @"Cancel", nil);
        alertOtherButtonText = NSLocalizedStringWithDefaultValue(@"Go_to_camera",nil, [NSBundle mainBundle],
                                                                 @"Go to camera", nil);
        tag = ALERT_PUSH_RECVED_SOUND_TEMP_HI_TEMP_LO;
        autoDissmisAlertIndex = 0;
        
        if ([camAlert.alertType isEqualToString:ALERT_TYPE_SOUND])
        {
            alertMess = NSLocalizedStringWithDefaultValue(@"Sound_detected",nil, [NSBundle mainBundle],
                                                          @"Sound detected", nil);
            alertMess = [self formatDetectedDate:camAlert.alertTime andAlertMess:alertMess];
        }
        else if ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI])
        {
            alertMess = NSLocalizedStringWithDefaultValue( @"Temperature_too_high",nil, [NSBundle mainBundle],
                                                          @"Temperature too high", nil);
            alertMess = [self formatDetectedDate:camAlert.alertTime andAlertMess:alertMess];
        }
        else if ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO])
        {
            alertMess = NSLocalizedStringWithDefaultValue( @"Temperature_too_low",nil, [NSBundle mainBundle],
                                                          @"Temperature too low", nil);
            alertMess = [self formatDetectedDate:camAlert.alertTime andAlertMess:alertMess];
        }
        else if ([camAlert.alertType isEqualToString:ALERT_TYPE_MOTION])
        {
            alertMess = NSLocalizedStringWithDefaultValue( @"Motion Detected",nil, [NSBundle mainBundle],
                                                          @"Motion Detected", nil);
            alertMess = [self formatDetectedDate:camAlert.alertTime andAlertMess:alertMess];
            alertOtherButtonText = NSLocalizedStringWithDefaultValue(@"View_snapshot",nil, [NSBundle mainBundle],
                                                                     @"View Snapshot", nil);
            tag = ALERT_PUSH_RECVED_RESCAN_AFTER;
        }
        else if ([camAlert.alertType isEqualToString:ALERT_TYPE_REMOVED_CAM])
        {
            alertTitle = @"";//camAlert.cameraName;
            alertMess = [NSString stringWithFormat:@"%@ %@", camAlert.cameraName, NSLocalizedStringWithDefaultValue( @"camera_removed",nil, [NSBundle mainBundle], @"has been removed on a different terminal. Please check and add camera again to continue to view.", nil)];
            alertLeftButtonText = NSLocalizedStringWithDefaultValue(@"ok",nil, [NSBundle mainBundle],
                                                                    @"OK", nil);
            alertOtherButtonText = nil;
            tag = ALERT_PUSH_RECVED_REMOVE_CAM;
            autoDissmisAlertIndex = -1;
        }
    }
    
    if (self.pushAlert != nil && [self.pushAlert isVisible] && [self.pushAlert.camAlert.cameraMacNoColon isEqualToString:camAlert.cameraMacNoColon])
    {
        NSLog(@"Same cam alert is currenlty shown.");
        
        NSTimeInterval oldestTimestamp = [CameraAlert getOldestAlertTimestampOfCamera:camAlert.cameraMacNoColon];
        NSDate * oldestDate = [NSDate dateWithTimeIntervalSince1970:oldestTimestamp];
        
        NSLog(@"Dialog exist, don't popup, current msg:%@, title: %@", self.pushAlert.message, self.pushAlert.title);
        if ([camAlert.alertType isEqualToString:ALERT_TYPE_SOUND] ||
            [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI]  ||
            [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO] ||
            [camAlert.alertType isEqualToString:ALERT_TYPE_MOTION])
        {
            NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
            [df_local setTimeZone:[NSTimeZone localTimeZone]];
            df_local.dateFormat = @"hh:mm a, dd-MM-yyyy";
            alertMess = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"multiple_detection", nil, [NSBundle mainBundle], @"Multiple detections at camera since %@", nil),
                         [df_local stringFromDate:oldestDate]];
            
            [df_local release];
            
            alertLeftButtonText = NSLocalizedStringWithDefaultValue(@"cancel",nil, [NSBundle mainBundle],
                                                                    @"Cancel", nil);
            alertOtherButtonText = NSLocalizedStringWithDefaultValue(@"Go_to_camera",nil, [NSBundle mainBundle],
                                                                     @"Go to camera", nil);
            tag = ALERT_PUSH_RECVED_MULTIPLE;
        }
    }
    
    [CameraAlert insertAlertForCamera:camAlert];
    
    NSLog(@"pushAlert : %@", self.pushAlert);
    if (self.pushAlert != nil && [self.pushAlert isVisible])
    {
        [self.pushAlert dismissWithClickedButtonIndex:autoDissmisAlertIndex animated:NO];
    }
    
    NSLog(@"camAlert : %@",camAlert);
    
    [self showPushNotificationAlert:alertTitle
                         andMessage:alertMess
                    andCancelButton:alertLeftButtonText
                     andOtherButton:alertOtherButtonText
                        andAlertTag:tag andCameraAlert:camAlert];

    
    NSLog(@"play sound");
    [self playSound];
    
    NSLog(@"show  alert");
    [self.pushAlert show];
}

- (NSString *)formatDetectedDate:(NSString *)alertTime andAlertMess:(NSString *)alertMess {
    NSString *mess = alertMess;
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFormater.calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    dateFormater.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    
    NSError *error = nil;
    NSDate *eventDate = nil;
    [dateFormater getObjectValue:&eventDate forString:alertTime range:nil error:&error];
    
    NSLog(@"eventDate: %@ & insert to database & clear obsolete history ", eventDate);
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    df_local.dateFormat = @"hh:mm a, dd-MM-yyyy";
    mess = [NSString stringWithFormat:@"%@ %@ %@", alertMess, NSLocalizedStringWithDefaultValue(@"at", nil, [NSBundle mainBundle], @"at", nil), [df_local stringFromDate:eventDate]];
    [df_local release];
    [dateFormater release];
    return mess;
}

-(void) playSound
{
    
	//Play beep
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AudioServicesPlaySystemSound(soundFileObject);
    }
    else
    {
        AudioServicesPlayAlertSound(soundFileObject);
    }
}

-(void) logoutAndUnregistration_bg
{
    @autoreleasepool
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //REmove password and registration id
        [userDefaults removeObjectForKey:@"PortalPassword"];
        [userDefaults removeObjectForKey:_push_dev_token];
        
#if  TARGET_IPHONE_SIMULATOR
#else
        
        NSLog(@"De-Register push with both parties: APNs and BMS ");
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *appId = [userDefaults objectForKey:@"APP_ID"];
        NSString * userName = [userDefaults objectForKey:@"PortalUsername"];
        
        [userDefaults removeObjectForKey:@"PortalApiKey"];
        [userDefaults removeObjectForKey:@"PortalUseremail"];
        
        // Let the device know we want to receive push notifications
        MBP_iosAppDelegate *appDelegate = (MBP_iosAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate unregisterForRemoteNotifications];
        
        /* Drop all timeline for this user */
        [[TimelineDatabase getSharedInstance] clearEventForUserName:userName];
        
        /* clear all alert histories */
        [CameraAlert clearAllAlerts];
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:nil
                                                                             FailSelector:nil
                                                                                ServerErr:nil];
        
        NSDictionary *responseDict = [jsonComm deleteAppBlockedWithAppId:appId
                                                               andApiKey:apiKey];
        [jsonComm release];
        NSLog(@"logout --> delete app status = %d", [[responseDict objectForKey:@"status"] intValue]);
        
        [NSThread sleepForTimeInterval:0.10];
#endif
        
        [userDefaults synchronize];
        
    }
}

#pragma mark -
#pragma mark Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag ;
    if ([alertView isKindOfClass:[PushNotificationAlert class]])
    {
        PushNotificationAlert *pushNotiAlert = (PushNotificationAlert *)alertView;
        if (tag == ALERT_PUSH_RECVED_SOUND_TEMP_HI_TEMP_LO || tag == ALERT_PUSH_RECVED_MULTIPLE)
        {
            NSLog(@"%s alert ALERT_PUSH_RECVED_NON_MOTION", __FUNCTION__);
            
            switch(buttonIndex)
            {
                case 0:
                {
                }
                    break;
                case 1:
                {
                    [self gotoSelectedCameraPage:pushNotiAlert.camAlert.registrationID];
                }
                    break;
                default:
                    break;
            }
        }
        else if (tag == ALERT_PUSH_RECVED_REMOVE_CAM)
        {
            NSLog(@"%s alert ALERT_PUSH_RECVED_REMOVE_CAM", __FUNCTION__);
            
            switch(buttonIndex)
            {
                case 0:
                {
                    if ([self isStayingCamerasListPage])
                    {
                        [self refreshCamerasListPage:pushNotiAlert.camAlert.registrationID];
                    }
                    else
                    {
                        [self gotoCamerasListPage:pushNotiAlert.camAlert.registrationID];
                    }
                }
                    break;
                case 1:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
        else if (tag == ALERT_PUSH_RECVED_PASSWORD_CHANGED)
        {
            NSLog(@"%s alert: ALERT_PUSH_RECVED_PASSWORD_CHANGED", __FUNCTION__);
            switch(buttonIndex)
            {
                case 0:
#if 1
                    [self popAllViewControllers];
#else
                    [self dismissMenuHubbleView];
#endif
                    [self sendStatus:LOGIN_FAILED_OR_LOGOUT];
                    break;
                    
                default:
                    break;
                    
            }
        }
        else if (tag == ALERT_PUSH_RECVED_RESCAN_AFTER)
        {
            NSLog(@"%s alert: ALERT_PUSH_RECVED_RESCAN_AFTER", __FUNCTION__);
            
            switch(buttonIndex)
            {
                case 0:
                    
                    break;
                case 1:
                {
#if 1
                    [self popAllViewControllers];
#else
                    NSLog(@"%s, %d", __FUNCTION__, self.navigationController.viewControllers.count);
                    [self dismissMenuHubbleView];
                    [self dismissNotificationViewController];
#endif
                    [self showNotifViewController:pushNotiAlert.camAlert];
                }
                    break;
                default:
                    break;
                    
            }
        }
        else if (tag == ALERT_PUSH_RECVED_RELOGIN_AFTER)
        {
            NSLog(@"%s alert ALERT_PUSH_RECVED_RELOGIN_AFTER", __FUNCTION__);
            
            switch(buttonIndex)
            {
                case 0:
                    break;
                case 1:
                {
#if 1
                    [self popAllViewControllers];
                    [self show_login_or_reg:nil];
#else
                    [self dismissMenuHubbleView];
                    [self sendStatus:LOGIN];
#endif
                }
                    break;
                    
                default:
                    break;
                    
            }
        }
        [CameraAlert clearAllAlertForCamera:pushNotiAlert.camAlert.cameraMacNoColon];
    }
    else
    {
        if (tag == ALERT_PUSH_SERVER_ANNOUNCEMENT)
        {
            NSLog(@"%s alert ALERT_PUSH_SERVER_ANNOUNCEMENT", __FUNCTION__);
            
            switch(buttonIndex)
            {
                case 0://IGNORE
                    break;
                case 1://Detail
                {
                    // Open the web browser now..
                    NSArray * texts = [alertView.message componentsSeparatedByString:@" "];
                    NSString * url = nil;
                    BOOL found = FALSE;
                    
                    for (int i = texts.count-1; i > 0; i --)
                    {
                        url =(NSString *) [texts objectAtIndex:i];
                        if ((url != nil) &&
                            [url hasPrefix:@"http://"] == TRUE)
                        {
                            found = TRUE;
                            break;
                        }
                    }
                    
                    if (url != nil && found == TRUE)
                    {
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
        else if (tag == 11)
        {
            NSLog(@"%s alert Send Email", __FUNCTION__);
            
            if (buttonIndex == 1)
            {
                if ([MFMailComposeViewController canSendMail])
                {
                    [self showMFMailComposeView];
                }
                else
                {
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
            else
            {
                /*
                 * 1. Try to remove crashed log file.
                 * 2. Force show login view, do not check again
                 */
                
                [self show_login_or_reg:nil];
                [self removeCrashedLogFile];
            }
        }
    }
    
    self.pushAlert = nil;
}

- (void)refreshCamerasListPage:(NSString *)registrationId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:registrationId forKey:REG_ID];
    [userDefaults synchronize];
    
    NSLog(@"%s", __FUNCTION__);
    [self.menuVC refreshCameraList];
}

- (void)gotoCamerasListPage:(NSString *)registrationId {
#if 1
     [self popAllViewControllers];
#else
    [self dismissMenuHubbleView];
    [self dismissNotificationViewController];
#endif
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:registrationId forKey:REG_ID];
    [userDefaults synchronize];
    
    [self sendStatus:SHOW_CAMERA_LIST2];
}

- (void)gotoSelectedCameraPage:(NSString *)registrationId {
#if 1
    [self popAllViewControllers];
#else
    [self dismissMenuHubbleView];
    [self dismissNotificationViewController];
#endif
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:registrationId forKey:REG_ID];
    [userDefaults synchronize];
    
    // Put a slight wait of 1sec here - to alow Previous H264Player (if any) to clean up
    dispatch_queue_t qt = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(qt,^{
        [NSThread sleepForTimeInterval:1.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%s sendstatus: SHOW_CAMERA_LIST", __FUNCTION__);
            [self sendStatus:SHOW_CAMERA_LIST];
        });
    });
}

- (void)showMFMailComposeView
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logCrashedPath = [cachesDirectory stringByAppendingPathComponent:@"application_crash.log"];
    NSString *logPath0 = [cachesDirectory stringByAppendingPathComponent:@"application0.log"];
    
    NSData *dataLog = [NSData dataWithContentsOfFile:logCrashedPath];
    NSData *dataLog0 = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath0])
    {
        dataLog0 = [NSData dataWithContentsOfFile:logPath0];
    }
    
    NSInteger length = dataLog.length;
    
    if (dataLog0)
    {
        length += dataLog0.length;
    }
    
    NSMutableData *dataZip = [NSMutableData dataWithLength:length];
    
    if (dataLog0)
    {
        [dataZip appendData:dataLog0];
    }
    
    [dataZip appendData:dataLog];
    
    dataZip = [NSData gzipData:dataZip];
    
    [picker addAttachmentData:[dataZip AES128EncryptWithKey:CES128_ENCRYPTION_PASSWORD] mimeType:@"text/plain" fileName:@"application_crash.log"];
    
    // Set the subject of email
    [picker setSubject:@"iOS app crash log"];
    NSArray *toRecipents = [NSArray arrayWithObject:@"ios.crashreport@cvisionhk.com"];
    [picker setToRecipients:toRecipents];
    
    // Show email view
    [self presentViewController:picker animated:YES completion:nil];
    
    // Release picker
    [picker release];
}

- (void)dismissMenuHubbleView
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_menuVC != nil)
    {
        NSArray * views = _menuVC.navigationController.viewControllers;
        NSLog(@"views count = %d",[views count] );
        
        if ( [views count] > 1)
        {
            if (views.count > 2)
            {
                id obj2 = [views objectAtIndex:2];
                
                if ([obj2 isKindOfClass:[PlaybackViewController class]])
                {
                    PlaybackViewController *playbackViewController = (PlaybackViewController *)obj2;
                    [playbackViewController closePlayBack:nil];
                }
            }
            
            id obj = [views objectAtIndex:1];
            
            if ([obj isKindOfClass:[H264PlayerViewController class]])
            {
                H264PlayerViewController * h264PlayerViewController = (H264PlayerViewController *) obj;
                [h264PlayerViewController prepareGoBackToCameraList:nil];
    
                
            }
            else if([obj isKindOfClass:[EarlierViewController class]]) // Camera is offline
            {
                [((EarlierViewController *)obj).navigationController popToRootViewControllerAnimated:NO];
            }
        }

        [_menuVC removeSubviews];
        _menuVC.menuDelegate = nil;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (void)dismissNotificationViewController
{    
    id aViewController = [self.navigationController.viewControllers lastObject];
    
    NSLog(@"%s %d %@", __FUNCTION__, self.navigationController.viewControllers.count, aViewController);
    
    if ([aViewController isKindOfClass:[PlaybackViewController class]])
    {
        PlaybackViewController *playbackViewController = (PlaybackViewController *)aViewController;
        [playbackViewController closePlayBack:nil];
    }
    else if ([aViewController isKindOfClass:[NotifViewController class]])
    {
        NotifViewController *aNotifVC = ((NotifViewController *)aViewController);
        aNotifVC.notifDelegate = nil;
        [aNotifVC cancelTaskDoInBackground];
        //[aNotifVC.navigationController popToRootViewControllerAnimated:NO];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)popAllViewControllers
{
    UIViewController *aViewController = [self.navigationController topViewController];
    
    NSLog(@"%s %d %@", __FUNCTION__, self.navigationController.viewControllers.count, [aViewController class]);
    
    if ([aViewController isKindOfClass:[PlaybackViewController class]])
    {
        PlaybackViewController *playbackViewController = (PlaybackViewController *)aViewController;
        [playbackViewController closePlayBack:nil];
    }
    else if ([aViewController isKindOfClass:[NotifViewController class]])
    {
        NotifViewController *aNotifVC = (NotifViewController *)aViewController;
        aNotifVC.notifDelegate = nil;
        [aNotifVC cancelTaskDoInBackground];
    }
    else if ([aViewController isKindOfClass:[H264PlayerViewController class]])
    {
        H264PlayerViewController *h264VC = (H264PlayerViewController *)aViewController;
        [h264VC prepareGoBackToCameraList:nil];
    }
    else if ([aViewController isKindOfClass:[EarlierViewController class]])
    {
        // Ignoring.
    }
    else if ([aViewController isKindOfClass:[MenuViewController class]])
    {
        // Do some stuffs.
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)showNotifViewController:(CameraAlert *)cameraAlert
{
    NotifViewController *notifVC = [[NotifViewController alloc] init];
    
    @synchronized(self)
    {
        //Feed in data now
        notifVC.cameraMacNoColon = cameraAlert.cameraMacNoColon;// @"34159E8D4F7F";
        notifVC.cameraName       = cameraAlert.cameraName;//@"SharedCam8D4F7F";
        notifVC.alertType        = cameraAlert.alertType;//@"4";
        notifVC.alertVal         = cameraAlert.alertVal;//@"20130921064439810";
        notifVC.registrationID   = cameraAlert.registrationID;
        notifVC.alertTime        = cameraAlert.alertTime;
        notifVC.notifDelegate    = self;
    }
    
    [self.navigationController pushViewController:notifVC animated:NO];
    
    [notifVC release];
}

#pragma mark -

+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip
{
    
	//Free & re-init Addresses
	FreeAddresses();
    
    GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
    
	NSString * log = @"";
    
    
	int i;
    
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
        
		theAddr = ip_addrs[i];
        
		if (theAddr == INVALID_IP)
		{
            
			break;
		}
        
		if (theAddr == localHost) continue;
        
		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
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
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}
    
	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
    
	
	return ;
}

+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip
{
    
	//Free & re-init Addresses
	FreeAddresses();
    
    GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
    
	NSString * log = @"";
    
    
	int i;
    
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
        
		theAddr = ip_addrs[i];
        
		if (theAddr == INVALID_IP)
		{
            
			break;
		}
        
		if (theAddr == localHost) continue;
        
		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
            *_ownip = ip_addrs[i];
		}
        
		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
		// broadcast_addrs[i]);
        
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
               broadcast_addrs[i]];
        
	}
    
    
	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];
    
	//NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	//NSLog(@"own iP: %d %@",i, deviceIP);
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}
    
	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
    
	
	return ;
}

#pragma mark -
#pragma mark SetupHTTPDelegate --- NOT USED --- check ..

-(void) show_login_or_reg:(NSTimer *)timer
{
    /*
     * 1. If timer is NOT nil --> - check exist of crashed log file
     * 2. If time is nil need not to check.
     */
    
    BOOL hasOptionSendEmail = FALSE;
    
    if (timer != nil )
    {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *logCrashedPath = [cachesDirectory stringByAppendingPathComponent:@"application_crash.log"];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:logCrashedPath])
        {
            NSLog(@"App was crashed!");
            hasOptionSendEmail = TRUE;
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Send app log"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil)
                                               otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil];
            av.tag = 11;
            [av show];
            [av release];
        }
    }
    
    NSLog(@"%s: show login view - timer: %p, has crashed log: %d", __FUNCTION__, timer, hasOptionSendEmail);
    
    if (!hasOptionSendEmail)
    {
        NSLog(@"show_login... ");
        
        self.app_stage = APP_STAGE_LOGGING_IN;
        
        LoginViewController *loginVC = [[LoginViewController alloc] initWithDelegate:self];
        [self.navigationController pushViewController:loginVC animated:NO];
        [loginVC release];
    }
}

- (void)showNotificationViewController: (NSTimer *)exp
{
    NSLog(@"%s", __FUNCTION__);
    
    if ([self isStayingLoginPage]) {
        return;
    }
    
    if ([self.camAlert.alertType isEqualToString:ALERT_TYPE_PASSWORD_CHANGED])
    {
        if ([self isStayingLoginPage] == NO)
        {
            [self verifyPasswordChangedPushNotification];
        }
        return;
    }
    
    if ([self checkPushNotification:self.camAlert.cameraMacNoColon] == NO)
    {
        return;
    }
    
    if ([self.camAlert.alertType isEqualToString:ALERT_TYPE_REMOVED_CAM])
    {
        BOOL needShowElert = NO;
        if ([self isStayingCamerasListPage])
        {
            if (![self isStayingCameraSettingsPage])
            {
                [self refreshCamerasListPage:self.camAlert.registrationID];
            }
            else
            {
                needShowElert = YES;
            }
        }
        else if ([self isStayingSelectedCamaraPage])
        {
            if ([self playingCameraEqualCamera:self.camAlert.cameraMacNoColon]) {
                needShowElert = YES;
            }
        }
        if (needShowElert)
        {
            if (self.pushAlert != nil && [self.pushAlert isVisible])
            {
                self.pushAlert.tag = 0;
                [self.pushAlert dismissWithClickedButtonIndex:-1 animated:NO];
            }
            [self showPushNotificationAlert:@""
                                 andMessage:[NSString stringWithFormat:@"%@ %@", self.camAlert.cameraName, NSLocalizedStringWithDefaultValue( @"camera_removed",nil, [NSBundle mainBundle], @"has been removed on a different terminal. Please check and add camera again to continue to view.", nil)]
                            andCancelButton:NSLocalizedStringWithDefaultValue(@"ok",nil, [NSBundle mainBundle], @"OK", nil)
                             andOtherButton:nil
                                andAlertTag:ALERT_PUSH_RECVED_REMOVE_CAM andCameraAlert:self.camAlert];
        }
        return;
    }
#if 1
    [self popAllViewControllers];
#else
    //Back from login- login success
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissMenuHubbleView];
    [self dismissNotificationViewController];
#endif
    //self.progressView.hidden = NO;
    
    if ([self.camAlert.alertType isEqualToString:ALERT_TYPE_MOTION])
    {
        [self showNotifViewController:self.camAlert];
    }
    else //Sound/Temphi/templo - go to camera
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.camAlert.registrationID forKey:REG_ID];
        [userDefaults synchronize];
        
        [self sendStatus:SHOW_CAMERA_LIST];
    }
}


#pragma mark -
#pragma mark Read Configure data

- (BOOL) restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
    
	if ([savedData restore_session_data] ==TRUE)
	{
		//NSLog(@"restored data done");
		self.channel_array = savedData.channels;
        
		self.restored_profiles = savedData.configured_cams;
	}
    
    [savedData release];
    
	return TRUE;
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
        //        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"close",nil, [NSBundle mainBundle],
//        @"Close", nil) otherButtonTitles:nil];
        //        [removeSuccessFulAlert show];
        NSLog(@"Removed application_crash.log successfuly!");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ", [errorFile localizedDescription]);
    }
}

- (BOOL)isStayingCamerasListPage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    if (camInView == nil && self.app_stage == APP_STAGE_LOGGED_IN)
        return YES;
    return NO;
}

- (BOOL)isStayingSelectedCamaraPage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    return camInView != nil;
}

- (BOOL)playingCameraEqualCamera:(NSString *)cameraMacNoColon {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    if (camInView != nil && self.app_stage == APP_STAGE_LOGGED_IN) {
        if ([[Util strip_colon_fr_mac:camInView] isEqualToString:cameraMacNoColon]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isStayingSettupPage {
    return self.app_stage == APP_STAGE_SETUP;
}

- (BOOL)isStayingLoginPage {
    return self.app_stage == APP_STAGE_LOGGING_IN;
}

- (BOOL)isStayingCameraSettingsPage {
    if (self.menuVC)
    {
        id obj = [self.menuVC.navigationController topViewController];
        if ([obj isKindOfClass:[CameraMenuViewController class]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkPushNotification:(NSString *)camMacNoColon {
    // check if push notification has camara mac address not exist any user account's camaras list
    BOOL allowPushNoti = NO;
    for (int i = channel_array.count - 1; i >= 0; i--)
    {
        CamChannel *ch = [channel_array objectAtIndex:i];
        if (ch.profile != nil)
        {
            NSString *cachedCamMac = ch.profile.mac_address;
            if ([[Util strip_colon_fr_mac:cachedCamMac] isEqualToString:camMacNoColon])
            {
                allowPushNoti = YES;
                break;
            }
        }
    }
    return allowPushNoti;
}

- (void)verifyPasswordChangedPushNotification {
    if (self.changePasswordReady)
    {
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                  Selector:@selector(verifyApikeySuccessWithResponse:)
                                                                              FailSelector:@selector(verifyApikeyFailedWithResponse:)
                                                                                 ServerErr:@selector(verifyApikeyFailedServerUnreachable:)] autorelease];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        [jsonComm getUserInfoWithApiKey:apiKey];
    }
    else
    {
         NSLog(@"%s passsword changed not ready yet", __FUNCTION__);
    }
}

- (void)verifyApikeySuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict)
    {
        NSLog(@"%s Verify passsword changed success %@", __FUNCTION__, [responseDict description]);
        
        NSInteger status = [[responseDict objectForKey:@"status"] integerValue];
        if (status != 200)
        {
            [self showAlertPasswordChanged];
        }
    }
}

- (void)verifyApikeyFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"%s Verify passsword changed failed", __FUNCTION__);
    [self showAlertPasswordChanged];
}

- (void)verifyApikeyFailedServerUnreachable: (NSDictionary *)responseDict
{
    NSLog(@"%s Verify passsword changed unreachable", __FUNCTION__);
    [self showAlertPasswordChanged];
}

- (void)showAlertPasswordChanged {
    if (self.pushAlert != nil && [self.pushAlert isVisible])
    {
        if (self.pushAlert.tag != ALERT_PUSH_RECVED_PASSWORD_CHANGED)
        {
            self.pushAlert.tag = 0;
            [self.pushAlert dismissWithClickedButtonIndex:-1 animated:NO];
        }
    }
    else
    {
        [self showPushNotificationAlert:@""
                             andMessage:NSLocalizedStringWithDefaultValue( @"reset_password",nil, [NSBundle mainBundle],
                                                                          @"Your credentials has changed. Please re-login to continue.", nil)
                        andCancelButton:NSLocalizedStringWithDefaultValue(@"ok",nil, [NSBundle mainBundle], @"OK", nil)
                         andOtherButton:nil
                            andAlertTag:ALERT_PUSH_RECVED_PASSWORD_CHANGED andCameraAlert:self.camAlert];
    }
}

- (void)showPushNotificationAlert:(NSString *)title andMessage:(NSString *)message andCancelButton:(NSString *)cancel andOtherButton:(NSString *)other andAlertTag:(NSInteger)tag andCameraAlert:(CameraAlert *)camAlert{
    _pushAlert = [[PushNotificationAlert alloc]
                 initWithTitle:title
                 message:message
                 delegate:self
                 cancelButtonTitle:cancel
                 otherButtonTitles:other, nil];
    self.pushAlert.tag = tag;
    self.pushAlert.camAlert = camAlert;
    [self.pushAlert show];
}

#if 0 // As far as, this flow has been terminated!
#pragma mark -
#pragma mark Scan For cameras

- (void) scan_for_devices
{
    if (isRebinded)
    {
        
        if ( [self isCurrentConnection3G] ||
            [self.restored_profiles count] ==0 )
        {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            
            
            for (int j = 0; j < [restored_profiles count]; j++)
            {
                CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                
                cp.isInLocal = FALSE;
                cp.hasUpdateLocalStatus = TRUE;
            }
            [self finish_scanning];
        }
        else
        {
            nextCameraToScanIndex = self.restored_profiles.count - 1;
            [self scan_next_camera:self.restored_profiles index:nextCameraToScanIndex];
            
        }
        
        [self performSelectorOnMainThread:@selector(startShowingCameraList:)
                               withObject:[NSNumber numberWithInt:0]
                            waitUntilDone:NO];
    }
}

- (void) scan_next_camera:(NSArray *) profiles index:(int) i
{
    NSMutableArray * finalResult = [[NSMutableArray alloc] init];
    CamProfile * cp = nil;
    
    BOOL skipScan = FALSE;
    
    cp =(CamProfile *) [profiles objectAtIndex:i];
    
    if (cp != nil &&
        cp.mac_address !=nil)
    {
        
        //Check if we are in the same network as the camera.. IF so
        // Try to scan .. otherwise... no point ..
        //20121130: phung: incase the ip address is not valid... also try to scan ..
        if (cp.ip_address == nil || [self isInTheSameNetworkAsCamera:cp ])
        {
            skipScan = [self isCurrentIpAddressValid:cp];
            
            if (skipScan)
            {
                
                cp.port = 80;
                //Dont need to scan.. call scan_done directly
                [finalResult addObject:cp];
                
                [self performSelector:@selector(scan_done:)
                           withObject:finalResult afterDelay:0.1];
                
            }
            else // NEED to do local scan
            {
                ScanForCamera *scanner = [[ScanForCamera alloc] initWithNotifier:self];
                [scanner scan_for_device:cp.mac_address];
                //Can't call release because app is crashed, will fix later
                //[scanner release];
                
            } /* skipScan = false*/
            
        }
        else
        {
            //Skip scanning too and assume we don't get any result
            [self performSelector:@selector(scan_done:)
                       withObject:nil afterDelay:0.1];
        }
    }
    
    [finalResult release];
}

- (void)scan_done:(NSArray *) _scan_results
{
    //limit value of nextCameraToScanIndex
    if (nextCameraToScanIndex < 0)
        return;
    CamProfile * cp =(CamProfile *) [self.restored_profiles objectAtIndex:nextCameraToScanIndex];
    //scan Done. read scan result
    
    
    
    if ( _scan_results == nil  || [_scan_results count] == 0 )
    {
        //Empty ..not found & also can't use the current IP?
        //Dont add to the final result
        cp.isInLocal = FALSE;
        //cp.hasUpdateLocalStatus = TRUE;
        
    }
    else
    {
        //found the camera ..
        // --> update local IP and other info
        
        CamProfile* scanned;
        for (int i=0 ; i< [_scan_results count]; i++)
        {
            scanned = ((CamProfile*) [_scan_results objectAtIndex:i]);
            
            if ([scanned.mac_address isEqualToString:cp.mac_address])
            {
                cp.ip_address = ((CamProfile*) [_scan_results objectAtIndex:i]).ip_address;
                cp.isInLocal = TRUE;
                cp.port = ((CamProfile*) [_scan_results objectAtIndex:i]).port;//localport is always 80
                cp.hasUpdateLocalStatus = TRUE;
                
                break;
            }
            
        }
    }
    
    NSLog(@"cam:%@ -is in Local:%d -fw:%@", cp.mac_address, cp.isInLocal, cp.fw_version);
    --nextCameraToScanIndex;
    [self scanNextIndex:&nextCameraToScanIndex]; // Sync results of ipserver & bonjour
}

- (void) scanNextIndex: (int *) index
{
    // Stop scanning
    if (*index == -1)
    {
        NSLog(@"Scan done with ipserver");
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while ([bonjourThread isExecuting])
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        NSLog(@"\n=================================\nSCAN DONE - IPSERVER SYNC BONJOUR\nrestored_profiles: %@\nbonjourList: %@\n=================================\n", restored_profiles, bonjourList);
        
        if(bonjourList && [bonjourList count] != 0)
        {
            for (CamProfile * cp in restored_profiles)
            {
                for (CamProfile * cam in bonjourList)
                {
                    if ([cp.mac_address isEqualToString:cam.mac_address])
                    {
                        NSLog(@"Camera %@ is on Bonjour, -port: %d", cp.mac_address, cam.port);
                        
                        cp.ip_address = cam.ip_address;
                        cp.isInLocal = YES;
                        cp.port = cam.port;
                        
                        break;
                    }
                }
                
                //cp.hasUpdateLocalStatus = YES;
            }
        }
        
        for (CamProfile * cp in restored_profiles)
        {
            cp.hasUpdateLocalStatus = YES;
        }
        
        [self finish_scanning];
    }
    // this camera at index has not been scanned
#if 1
    else if (*index > -1)
    {
        if (self.menuVC != nil)
        {
            NSLog(@"reload CamerasTableView in scan_done");
            // Notify to menuVC
            NSLog(@"%p, %p, %p", self, self.menuVC, self.menuVC.camerasVC);
            [self.menuVC.camerasVC camerasReloadData];
        }
        
        if (((CamProfile *)[self.restored_profiles objectAtIndex:*index]).hasUpdateLocalStatus == NO)
        {
            NSLog(@"This camera at index has not been scanned");
            [self scan_next_camera:self.restored_profiles index:*index];
        }
        else
        {
            NSLog(@"This camera at index has been scanned");
            
            --(*index);
            [self scanNextIndex:index];
        }
    }
#else

#endif
}

- (void)finish_scanning
{
#if 1
    //Notify to MenuVC
    [self.menuVC.camerasVC camerasReloadData];
#else

#endif
}



-(BOOL) isInTheSameNetworkAsCamera :(CamProfile *) cp
{
    long ip = 0, ownip =0 ;
    long netMask = 0 ;
    struct ifaddrs *ifa = NULL, *ifList;
    
    NSString * bc = @"";
    NSString * own = @"";
    [MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own ipasLong:&ownip];
    
    
    getifaddrs(&ifList); // should check for errors
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        
        
        if (ifa->ifa_netmask != NULL)
        {
            ip = (( struct sockaddr_in *)ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == ownip)
            {
                netMask = (( struct sockaddr_in *)ifa->ifa_netmask)->sin_addr.s_addr;
                
                break;
            }
        }
        
    }
    freeifaddrs(ifList); // clean up after yourself
    
    
    if (netMask ==0 || ip ==0)
    {
        return FALSE;
    }
    
    long camera_ip =0 ;
    if (cp != nil &&
        cp.ip_address != nil)
    {
        NSArray * tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if ([tokens count] != 4)
        {
            //sth is wrong
            return FALSE;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        
        
        if ( (camera_ip & netMask) == (ip & netMask))
        {
            NSLog(@"in same subnet");
            return TRUE;
        }
    }
    
    return FALSE;
}

-(BOOL) isCurrentIpAddressValid :(CamProfile *) cp
{
    if (cp != nil &&
        cp.ip_address != nil)
    {
        HttpCommunication * dev_com = [[HttpCommunication alloc] init];
        
        dev_com.device_ip = cp.ip_address;
        
        NSString * mac = [dev_com sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:3.0];
        
        [dev_com release];
        
        if (mac != nil && mac.length == 12)
        {
            mac = [Util add_colon_to_mac:mac];
            
            
            if([mac isEqualToString:cp.mac_address])
            {
                return TRUE;
            }
        }
        
    }
    
    
    return FALSE;
}


#pragma mark -
#pragma mark 3G connection checks


-(BOOL) isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        
        return TRUE;
    }
    
    
    return FALSE;
    
}

-(void) callForStartScanningBonjour
{
    
    if (isRebinded)
    {
        if ( [self isCurrentConnection3G] ||
            [self.restored_profiles count] ==0)
        {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            
            
            for (int j = 0; j < [restored_profiles count]; j++)
            {
                CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                
                cp.isInLocal = FALSE;
                cp.hasUpdateLocalStatus = TRUE;
            }
            
            [self finish_scanning];
        }
        else
        {
            bonjourThread = [[NSThread alloc] initWithTarget:self selector:@selector(scan_with_bonjour) object:nil];
            [bonjourThread start];
        }
    }
}

-(void) scan_with_bonjour
{
    @autoreleasepool
    {
        NSDate * endDate;
        // When use autoreleseapool, no need to call autorelease.
        _bonjourBrowser = [[Bonjour alloc] initSetupWith:self.restored_profiles];
        [_bonjourBrowser setDelegate:self];
        
        [_bonjourBrowser startScanLocalWiFi];
        
        endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while (_bonjourBrowser.isSearching)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        bonjourList = _bonjourBrowser.cameraList;
    }
    
    [NSThread exit];
}

- (BOOL) isThisMacStoredOffline:(NSString*) mac_without_colon
{
    
    if (self.restored_profiles == nil &&
        self.channel_array == nil)
    {
        // No offline data is available --> force re login
        return FALSE;
        
    }
    
    
    CamProfile * cp = nil;
    for (int i =0; i< [self.restored_profiles count]; i++)
    {
        cp = (CamProfile *) [self.restored_profiles objectAtIndex:i];
        if (cp!= nil &&
            cp.mac_address != nil )
        {
            NSString *  mac_wo_colon = [Util strip_colon_fr_mac:cp.mac_address];
            if ([mac_wo_colon isEqualToString:mac_without_colon])
            {
                return TRUE;
            }
        }
        
    }
    
    return FALSE;
}
#endif
@end
