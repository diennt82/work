//
//  Step_10_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//


#import "Step_10_ViewController.h"
#import "StartMonitorCallback.h"
#import "UserAccount.h"
#import "HttpCom.h"
#import "MBP_iosViewController.h"
//#import "KISSMetricsAPI.h"
#import "HubbleProgressView.h"
#import "MBProgressHUD.h"
#import <MonitorCommunication/MonitorCommunication.h>

#import "define.h"
#import "Step_12_ViewController.h"
#import "Step_11_ViewController.h"
#import "Step_02_ViewController.h"
#import "UIView+Custom.h"

#define SEND_CONF_SUCCESS 1
#define SEND_CONF_ERROR 2

#define SETUP_CAMERAS_UNCOMPLETE 0
#define SETUP_CAMERAS_COMPLETE 1
#define SETUP_CAMERAS_FAIL 2

//Master_key=BC0B87B2832B67FF58F11749F19C4915D4B876C2505D9CC7D0D06F79653C8B11
#define MASTER_KEY @"Master_key="

#define TAG_IMAGE_VIEW_ANIMATION 595
#define PROXY_HOST @"192.168.193.1"
#define PROXY_PORT 8888

#if 0
#define DEV_STATUS_UNKOWN                   0
#define DEV_STATUS_NOT_IN_MASTER            1
#define DEV_STATUS_NOT_REGISTERED           2
#define DEV_STATUS_REGISTERED_LOGGED_USER   3
#define DEV_STATUS_REGISTERED_OTHER_USER    4
#define DEV_STATUS_DELETED                  5
#endif

#define ALERT_ADD_CAM_FAILED    500
#define ALERT_ADD_CAM_UNREACH   501
#define ALERT_CHECK_STATUS      502
#define ALERT_SELECTED_OPTION   503

#define TIMEOUT_PROCESS         2*60.f
#define GAI_CATEGORY            @"Step 10 view"

#define TAG_VIEW_FW_UPGRADE_PROGRESS     5990
#define TAG_VIEW_FW_UPGRADE_5MINUTES     5991
#define TAG_VIEW_FW_UPGRADE_INDICATOR    5992
#define TAG_VIEW_FW_UPGRADE_MESSAGE      5993

@interface Step_10_ViewController () <UIAlertViewDelegate>
#if 0
@property (nonatomic, retain) IBOutlet UIView * progressView;
#endif
@property (retain, nonatomic) IBOutlet UIView *viewFwOtaUpgrading;
@property (retain, nonatomic) IBOutlet UILabel *lblWordAddition;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UIButton *btnCancelFirmware;
@property (retain, nonatomic) IBOutlet UIView *ib_viewGuild;
@property (retain, nonatomic) IBOutlet UIScrollView *ib_scollViewGuide;
@property (retain, nonatomic) IBOutlet UIButton *ib_resumeSetup;

@property (retain, nonatomic) UserAccount *userAccount;
@property (nonatomic, retain) BMS_JSON_Communication *jsonCommBlocked;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic) BOOL shouldSendMasterKeyAgain;
@property (retain, nonatomic) UIProgressView *otaDummyProgressBar;
@property (nonatomic, retain) NSTimer *timeOut;
@property (nonatomic) BOOL forceSetupFailed;
@property (nonatomic) NSInteger fwUpgradePercentage;
@property (nonatomic) NSInteger fwUpgradeStatus;

@property (nonatomic, retain) NSTimer *timerAdditionalOption;
@property (nonatomic) BOOL should_stop_scanning;
@property (nonatomic) BOOL should_retry_silently;
@property (nonatomic, retain) NSString *cameraMac;
@property (nonatomic, retain) NSString *errorCode;
@property (nonatomic, retain) NSString *stringUDID;
@property (nonatomic, retain) NSString *stringAuth_token;

@end

@implementation Step_10_ViewController


//@synthesize  cameraMac, master_key;
//@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) dealloc
{
    NSLog(@"%s", __FUNCTION__);

    [_timerAdditionalOption release];
#if 0
    [_progressView release];
    [cameraMac release];
    [master_key release];
#endif
    [_userAccount release];
    [_ib_scollViewGuide release];
    [_ib_viewGuild release];
    [_ib_resumeSetup release];
    [_jsonCommBlocked release];
    [_viewFwOtaUpgrading release];
    [_btnCancel release];
    [_lblWordAddition release];
    [_btnContinue release];
    [_btnCancelFirmware release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self xibDefaultLocalization];
    self.trackedViewName = GAI_CATEGORY;
    [self.ib_scollViewGuide setContentSize:CGSizeMake(320, 1401)];
    
    //Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Do any additional setup after loading the view.
    //Note: handle notification center must be registed in viewDidLoad
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(becomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    self.cameraMac = (NSString *) [userDefaults objectForKey:@"CameraMacWithQuote"];
    self.stringUDID = [userDefaults stringForKey:CAMERA_UDID];
    
    
    
    //Hide back button -- can't go back now..
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    NSLog(@"Normal Add cam sequence" );
    
    
    //Add view guild first and hide it
    [self.view addSubview:self.ib_viewGuild];
    [self.ib_viewGuild setHidden:YES];
#if 1
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:595];
#else
    UIImageView *imageView = (UIImageView *)[_progressView viewWithTag:595];
#endif
    imageView.animationImages =[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"setup_camera_c1"],
                                [UIImage imageNamed:@"setup_camera_c2"],
                                [UIImage imageNamed:@"setup_camera_c3"],
                                [UIImage imageNamed:@"setup_camera_c4"],
                                nil];
    imageView.animationDuration = 1.5;
    imageView.animationRepeatCount = 0;
    
    //[self.view addSubview:self.progressView];
    
    [imageView startAnimating];
#if 0
    [self showProgress:nil];
#endif
    
#if 1
    self.timerAdditionalOption = [NSTimer scheduledTimerWithTimeInterval:57
                                                                  target:self
                                                                selector:@selector(showAdditionalOption:)
                                                                userInfo:nil
                                                                 repeats:NO];
#else
    [_lblWordAddition performSelector:@selector(setHidden:) withObject:NO afterDelay:57]; //1 * 60 - 3
    [_btnCancel performSelector:@selector(setHidden:) withObject:NO afterDelay:57]; //1 * 60 - 3
#endif
    
    self.otaDummyProgressBar = (UIProgressView *)[_viewFwOtaUpgrading viewWithTag:5990];
    self.fwUpgradeStatus = FIRMWARE_UPGRADE_SUCCEED;

    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION];
    
    NSString *message = NSLocalizedStringWithDefaultValue(@"take_up_to_a_minute", nil, [NSBundle mainBundle],
                                                          @"This may take up to a minute", nil);
    
    if ([fwVersion compare:FW_VERSION_FACTORY_SHOULD_BE_UPGRADED] == NSOrderedSame)
    {
        message = NSLocalizedStringWithDefaultValue(@"note_camera_upgrade_lasted_software", nil, [NSBundle mainBundle],
                                                    @"Note: Your camera may be upgraded to latest software. This may take about 5 minutes. During this time, you will not be able to access the camera.", nil);
    }
    
#if 1
    UILabel *lblProgress = (UILabel *)[self.view viewWithTag:695];
#else
    UILabel *lblProgress = (UILabel *)[_progressView viewWithTag:695];
#endif
    lblProgress.text = message;

    // >12.82 we can move on with new flow
    if ([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] >= NSOrderedSame ||
        [userDefaults integerForKey:SET_UP_CAMERA] == SETUP_CAMERA_FOCUS73)
    {
        //[self waitingCameraRebootAndForceToWifiHome];
        [self performSelectorOnMainThread:@selector(waitingCameraRebootAndForceToWifiHome)
                               withObject:nil
                            waitUntilDone:NO];
    }
    else
    {
        NSLog(@"Step10 - old flow");
        ///Old flow: First add camera
        [self registerCamera:nil];
    }
    
    if (isiPhone4) {
        CGRect rect = self.lblWordAddition.frame;
        rect.origin.y -= 80;
        self.lblWordAddition.frame = rect;
        
        rect = self.btnCancel.frame;
        rect.origin.y -= 80;
        self.btnCancel.frame = rect;
    }
}

- (void)xibDefaultLocalization
{
    [[self.view viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_checking_connection_camera", nil, [NSBundle mainBundle], @"Checking connection to camera", nil)];
    [[self.view viewWithTag:695] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_takeup_a_minute", nil, [NSBundle mainBundle], @"This may take up to a minute", nil)];
    [[self.view viewWithTag:2] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_re-start_settup", nil, [NSBundle mainBundle], @"If setup failed, press button below to re-start setup", nil)];
    [self.btnCancel setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_button_cancel", nil, [NSBundle mainBundle], @"Cancel", nil)];
    
    [[self.ib_viewGuild viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_wrong_wifi_network", nil, [NSBundle mainBundle], @"Wrong Wi-Fi Network", nil)];
    [[self.ib_viewGuild viewWithTag:2] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_change_wifi_network", nil, [NSBundle mainBundle], @"How to Change Wi-Fi Network", nil)];
    [[self.ib_viewGuild viewWithTag:3] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_connect_to_defferent_wifi_network", nil, [NSBundle mainBundle], @"Your phone has reconnected to a different Wi-Fi network than your camera. Both must be on the same network to complete the setup. ", nil)];
    [[self.ib_viewGuild viewWithTag:4] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_access_home_screen", nil, [NSBundle mainBundle], @"1. Access your home screen by clicking on the home button", nil)];
    [[self.ib_viewGuild viewWithTag:5] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_select_correct_wifi_network", nil, [NSBundle mainBundle], @"2. Select the correct Wi-Fi network by going to the iPhone settings app on your home screen", nil)];
    [[self.ib_viewGuild viewWithTag:6] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_open_wifi_to_view_network", nil, [NSBundle mainBundle], @"3. Open Wi-Fi to view networks", nil)];
    [[self.ib_viewGuild viewWithTag:7] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_select_network_during_camera_settup", nil, [NSBundle mainBundle], @"4. Select the network which you used during camera setup", nil)];
    [[self.ib_viewGuild viewWithTag:8] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_enter_password_if_prompted", nil, [NSBundle mainBundle], @"(and enter password if prompted)", nil)];
    [[self.ib_viewGuild viewWithTag:9] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_resume_settup", nil, [NSBundle mainBundle], @"Once you have completed the above steps return to this app and resume setup", nil)];
    [[self.ib_viewGuild viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_button_resume_settup", nil, [NSBundle mainBundle], @"Resume Setup", nil)];
    
    [[self.viewFwOtaUpgrading viewWithTag:5993] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_camera_firmware_is_being_upgrade", nil, [NSBundle mainBundle], @"Camera Firmware is being upgraded, please keep the camera power on during this process", nil)];
    [[self.viewFwOtaUpgrading viewWithTag:5991] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_label_takeup_5_minute", nil, [NSBundle mainBundle], @"This may take up to 5 minutes", nil)];
    [self.btnCancelFirmware setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_button_cancel", nil, [NSBundle mainBundle], @"Cancel", nil)];
    [self.btnContinue setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step10_button_continue", nil, [NSBundle mainBundle], @"Continue", nil)];
}

- (void)showAdditionalOption:(NSTimer *)timer
{
    _lblWordAddition.hidden = NO;
    _btnCancel.hidden = NO;
}

#if 0
-(void) showProgress:(NSTimer *) exp
{
    NSLog(@"show progress ");
    if (self.progressView != nil)
    {
        NSLog(@"show progress 01 ");
        self.progressView.hidden = NO;
        [self.view bringSubviewToFront:self.progressView];
    }
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    if (self.progressView != nil)
    {
        self.progressView.hidden = YES;
    }
}
#endif

- (void)sendCommandRebootCamera
{
    NSLog(@"%s", __FUNCTION__);
    //HttpCommunication *comm = [[HttpCommunication alloc]init];
    //NSString * command = RESTART_HTTP_CMD;
    //NSLog(@"[HttpCom instance]: %p", [HttpCom instance]);
    
    [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:RESTART_HTTP_CMD];
}

#pragma mark - Actions

- (void)hubbleItemAction:(id)sender
{
    if (_timerAdditionalOption)
    {
        [_timerAdditionalOption invalidate];
        self.timerAdditionalOption = nil;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancelTouchUpInsideAction:(id)sender
{
    self.btnCancel.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    NSString *cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
    hub.labelText = [cancel stringByAppendingString:@"..."];
    
    if (_timeOut)
    {
        [_timeOut invalidate];
        self.timeOut = nil;
    }
    
    [self setStopScanning:nil];
    
    [_lblWordAddition setHidden:YES];
    
    self.forceSetupFailed = TRUE;
}

- (IBAction)btnContinueTouchUpInside:(id)sender
{
    [_viewFwOtaUpgrading removeFromSuperview];
    self.btnContinue.enabled = NO;
    self.btnCancelFirmware.enabled = NO;
    [self performSelector:@selector(checkCameraStatusAgain) withObject:nil afterDelay:0.01];
}

- (IBAction)btnCancelFirmwareTouchUpInside:(id)sender
{
    [_viewFwOtaUpgrading removeFromSuperview];
    self.btnContinue.enabled = NO;
    self.btnCancelFirmware.enabled = NO;
    
    if (_timeOut != nil)
    {
        [self.timeOut invalidate];
        self.timeOut = nil;
    }
    
    [self setStopScanning:nil];
    
    id<StartMonitorDelegate> delegate = (id<StartMonitorDelegate>) [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [delegate startMonitorCallBack:FALSE];
}

#pragma  mark -
#pragma mark button handlers

- (IBAction)registerCamera:(id)sender
{
#if 0
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
#endif
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) // fw >= FW_MILESTONE
    {
        [self performSelectorInBackground:@selector(registerCameraWithProxy) withObject:nil];
    }
    else
    {
        [self registerCameraWithoutProxy];
    }
}

#pragma mark - BMS_JSON communication

- (void)registerCameraWithoutProxy
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:FW_VERSION];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    /*
     hack code for device 0066 which return UUID is wrong
     */
    NSString *udidOfFocus66Hack = @"01006644334C7E0C8AXHRRBOLC";
    
    if ([udid isEqualToString:@"01008344334C7E0C8AXHRRBOLC"])
    {
        NSLog(@"Step_10VC - registerCameraWithoutProxy - HACK_CODE for UDID");
        udid = udidOfFocus66Hack;
    }
    
    //NSLog(@"-----fwVersion = %@, ,model = %@", fwVersion, model);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    
    [stringFromDate insertString:@"." atIndex:3];
    
    //NSLog(@"%@", stringFromDate);
    
    [formatter release];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(addCamSuccessWithResponse:)
                                                                          FailSelector:@selector(addCamFailedWithError:)
                                                                             ServerErr:@selector(addCamFailedServerUnreachable)] autorelease];
    //NSString *mac = [Util strip_colon_fr_mac:self.cameraMac];
    NSString *camName = (NSString *) [userDefaults objectForKey:CAMERA_NAME];
    
    
    [jsonComm registerDeviceWithDeviceName:camName
                         andRegistrationID:udid
                                   andMode:@"upnp" // Need somethings more usefully
                              andFwVersion:fwVersion
                               andTimeZone:stringFromDate
                                 andApiKey:apiKey];
}

- (void)registerCameraWithProxy
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:FW_VERSION];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    /*
     hack code for device 0066 which return UUID is wrong
     */
    NSString *udidOfFocus66Hack = @"01006644334C7E0C8AXHRRBOLC";
    
    if ([udid isEqualToString:@"01008344334C7E0C8AXHRRBOLC"])
    {
        NSLog(@"Step_10VC - registerCameraWithProxy - HACK_CODE for UDID");
        udid = udidOfFocus66Hack;
    }
    
    //NSLog(@"-----fwVersion = %@, ,model = %@", fwVersion, model);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    
    [stringFromDate insertString:@"." atIndex:3];
    
    [formatter release];
    
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSString *camName = (NSString *) [userDefaults objectForKey:CAMERA_NAME];
    NSDictionary *responseDict = [_jsonCommBlocked registerDeviceBlockedWithProxyHost:PROXY_HOST
                                                                    proxyPort:PROXY_PORT
                                                                   deviceName:camName
                                                               registrationID:udid
                                                                         mode:@"upnp"
                                                                    fwVersion:fwVersion
                                                                     timeZone:stringFromDate
                                                                    andApiKey:apiKey];
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            [self addCamSuccessWithResponse:responseDict];
        }
        else
        {
            [self addCamFailedWithError:responseDict];
        }
    }
    else
    {
        [self addCamFailedServerUnreachable];
    }
}

- (void)checkCameraStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
 
    if (_should_stop_scanning == TRUE || !udid || [udid isEqualToString:@""])
    {
        NSLog(@"%s should_stop_scanning:%d", __FUNCTION__, _should_stop_scanning);
        return ;
    }
    
#if 1
    if (_userAccount == nil)
    {
        NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
        NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
        NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
        
        self.userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                     password:userPass
                                                       apiKey:userApiKey
                                                     listener:nil];
    }
    
    NSInteger deviceStatus = [_userAccount checkStatusCamera:udid];
    
    BOOL shouldCheckAgain = TRUE;
    
    switch (deviceStatus)
    {
        case DEV_STATUS_UNKOWN:
            // Check again...
            break;
            
        case DEV_STATUS_NOT_IN_MASTER:
        {
            self.statusMessage = NSLocalizedStringWithDefaultValue(@"device_is_not_present", nil, [NSBundle mainBundle], @"Device is NOT present in device master", nil);
            
            shouldCheckAgain = FALSE;
            
            self.errorCode = [NSString stringWithFormat:@"%d", deviceStatus];
            
            if (_timeOut != nil)
            {
                [self.timeOut invalidate];
                self.timeOut = nil;
            }
            
            [self setStopScanning:nil];
            //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step10 - Check camera status: %@", _statusMessage] withProperties:nil];
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:[NSString stringWithFormat:@"Check camera status: %@", _statusMessage]
                                                             withLabel:nil
                                                             withValue:nil];
            [self showDialogWithTag:ALERT_CHECK_STATUS message:_statusMessage];
            
            [self setupFailed];
        }
            break;
            
        case DEV_STATUS_NOT_REGISTERED:
        case DEV_STATUS_DELETED:
        case DEV_STATUS_REGISTERED_OTHER_USER:
        case DEV_STATUS_REGISTERED_LOGGED_USER:
            NSLog(@"Step_10_VC register successfully. Move on. DEV_STATUS:%d", deviceStatus);
            shouldCheckAgain = FALSE;
            //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step10 - Check camera status: %d", deviceStatus] withProperties:nil];
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:[NSString stringWithFormat:@"Check camera status: %@", _statusMessage]
                                                             withLabel:nil
                                                             withValue:nil];
            break;
            
        default:
            break;
    }
    
#else
    
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked checkStatusBlockedWithRegistrationId:udid apiKey:apiKey];
    
    //NSLog(@"Step_10_VC - checkCameraStatus: %@", responseDict);
    
    BOOL shouldCheckAgain = TRUE;

    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSInteger deviceStatus = [[[responseDict objectForKey:@"data"] objectForKey:@"device_status"] integerValue];
            
            switch (deviceStatus)
            {
                case DEV_STATUS_NOT_IN_MASTER:
                {
                    self.statusMessage = NSLocalizedStringWithDefaultValue(@"device_is_not_present", nil, [NSBundle mainBundle], @"Device is NOT present in device master", nil);
                    
                    shouldCheckAgain = FALSE;
                    self.errorCode = [NSString stringWithFormat:@"%d", deviceStatus];
                    
                    if (_timeOut != nil)
                    {
                        [self.timeOut invalidate];
                        self.timeOut = nil;
                    }
                    
                    [self setStopScanning:nil];
                    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step10 - Check camera status: %@", _statusMessage] withProperties:nil];
                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                    withAction:[NSString stringWithFormat:@"Check camera status: %@", _statusMessage]
                                                                     withLabel:nil
                                                                     withValue:nil];
                    [self showDialogWithTag:ALERT_CHECK_STATUS message:_statusMessage];
                    
                    [self setupFailed];
                }
                    break;
                    
                case DEV_STATUS_UNKOWN:
                case DEV_STATUS_NOT_REGISTERED:
                case DEV_STATUS_DELETED:
                case DEV_STATUS_REGISTERED_OTHER_USER:
                case DEV_STATUS_REGISTERED_LOGGED_USER:
                    NSLog(@"Step_10_VC register successfully. Move on. DEV_STATUS:%d", deviceStatus);
                    shouldCheckAgain = FALSE;
                    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step10 - Check camera status: %d", deviceStatus] withProperties:nil];
                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                    withAction:[NSString stringWithFormat:@"Check camera status: %@", _statusMessage]
                                                                     withLabel:nil
                                                                     withValue:nil];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            // Check again
        }
    }
    else
    {
        // Check again
    }
#endif
    
    if (shouldCheckAgain)
    {
        [self performSelector:@selector(checkCameraStatus) withObject:nil afterDelay:2];
    }
}

#if 0
- (void)updatesBasicInfoForCamera
{
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey     = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *udid       = [userDefaults objectForKey:CAMERA_UDID];
    NSString *hostSSID   = [userDefaults objectForKey:HOST_SSID];
    NSString *cameraName = [userDefaults objectForKey:CAMERA_NAME];
    
    NSDictionary *responseDict = [_jsonCommBlocked updateDeviceBasicInfoBlockedWithRegistrationId:udid
                                                                                       deviceName:cameraName
                                                                                         timeZone:nil
                                                                                             mode:nil
                                                                                  firmwareVersion:nil
                                                                                         hostSSID:hostSSID
                                                                                       hostRouter:nil
                                                                                        andApiKey:apiKey];
    BOOL updateFailed = TRUE;
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSString *bodyKey = [[responseDict objectForKey:@"data"] objectForKey:@"host_ssid"];
            
            if (![bodyKey isEqual:[NSNull null]])
            {
                if ([bodyKey isEqualToString:hostSSID])
                {
                    updateFailed = FALSE;
                }
            }
        }
    }
    
    if (updateFailed)
    {
        NSLog(@"Step10VC - updatesBasicInfoForCamera: %@", responseDict);
    }
    else
    {
        NSLog(@"Step10VC - updatesBasicInforForCamera successfully!");
    }
}
#endif

#pragma  mark -
#pragma mark Timer callbacks

- (void)timeOutSetupProcess: (NSTimer *)expired
{
    self.timeOut = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
    
    NSLog(@"Timeout while trying to search on Home Wifi: %@", homeSsid);
    
    [self setStopScanning:Nil];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step10 - Add camera failed - timeout" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Add camera failed: %@", _errorCode]
                                                     withLabel:nil
                                                     withValue:nil];
}

- (void)step10CheckConnectionToHomeWifi:(NSTimer *) expired
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //home wifi
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
	
    //current wifi
    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    //current wifi of camera setup
    NSString *wifiCameraSetup = [userDefaults stringForKey:CAMERA_SSID];
    
    
    if ((currentSSID == nil) || [currentSSID isEqualToString:wifiCameraSetup])
    {
        NSLog(@"Now, still connected to wifiOf Camera, continue check | currentSSID = nil");
        
        /*Phung: we are still connecting to wifi ... how about a restart_system to switch?  */
        [self sendCommandRebootCamera];
        
        [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                         target:self
                                       selector:@selector(step10CheckConnectionToHomeWifi:)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    else //
    {
        NSLog(@"Yeah, already connected to another wifi: %@ ",currentSSID);
        if ([currentSSID isEqualToString:homeSsid])
        {
            NSLog(@"It is wifi home");
        }
        else
        {
             NSLog(@"It is NOT wifi home");
        }
        //What if this wifi does not have internet connect OR
        //  The wifi selected for camera does not have internet connection ????
        
        
		[self.ib_viewGuild setHidden:YES];
#if 0
        [self showProgress:nil];
#endif
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if (![own isEqualToString:@""])
		{
            if (_timeOut != nil)
            {
                [_timeOut invalidate];
                self.timeOut = nil;
                
            }
            //Timer  1min - for camera reboot and add itself to server
            self.timeOut = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_PROCESS
                                                            target:self
                                                          selector:@selector(timeOutSetupProcess:)
                                                          userInfo:nil
                                                           repeats:NO];
            
            [self wait_for_camera_to_reboot:nil];
            [self checkCameraStatus];
        }
        else
        {
            NSLog(@"Dont get IP from wifi home");
            [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                             target:self
                                           selector:@selector(step10CheckConnectionToHomeWifi:)
                                           userInfo:nil
                                            repeats:NO];
        }
        
    }
    
}

- (void)connectToWifiHomeByHand
{
#if 0
    [self.progressView setHidden:YES];
#endif
    [self.ib_viewGuild setHidden:NO];
    [self.view bringSubviewToFront:self.ib_viewGuild];
}

-(void)becomeActive
{
    [self.ib_viewGuild setHidden:YES];
#if 0
    [self showProgress:nil];
#endif
    [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                     target:self
                                   selector:@selector(step10CheckConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)sendMasterKeyToDevice
{
    NSString * set_mkey = SET_MASTER_KEY;
    NSString * response;
    //set_mkey =[set_mkey stringByAppendingString:self.master_key];
    set_mkey =[set_mkey stringByAppendingString:_stringAuth_token];
    
    response = [[HttpCom instance].comWithDevice sendCommandAndBlock:set_mkey];
    
    if (response == nil)
    {
        NSLog(@"can't send master key, camera is not fully up");
    }
    else
    {
        NSLog(@"response: %@", response);
        
        if ([response hasPrefix:@"set_master_key: 0"])
        {
            ///done
            NSLog(@"sending master key done");
            [self sendCommandRebootCamera];
            [self performSelectorOnMainThread:@selector(waitingCameraRebootAndForceToWifiHome) withObject:nil waitUntilDone:NO];
        }
        else if ([response isEqualToString:@"set_master_key: -1"])
        {
            /*
             * Bug from Focus66 FW: version 01.12.68. Fixed on the newer version
             * - Set master key failed at the 1st time.
             * - Set again is ok, so try to set it one more time
             */
            if (_shouldSendMasterKeyAgain)
            {
                self.shouldSendMasterKeyAgain = FALSE;
                [self sendMasterKeyToDevice];
            }
        }
        else
        {
            // Do somethings else
        }
    }
}

- (void)waitingCameraRebootAndForceToWifiHome
{
    //show progress
#if 0
    [self showProgress:nil];
#endif
    //After sending reboot camera commmand
    //check connection to wifi home after 3 seconds
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(step10CheckConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];
    
}
#pragma mark -


-(void) setStopScanning:(NSTimer *) exp
{
    self.should_stop_scanning = TRUE;
}

- (void) wait_for_camera_to_reboot:(NSTimer *)exp
{
    if (_should_stop_scanning == TRUE)
    {
        NSLog(@"%s Stop scanning now.. should be 4 mins.", __FUNCTION__);
        
        [self setupFailed];
        return ;
    }
    else
    {
        NSLog(@"Step_10VC - Continue scan...");
    }
    
    [self checkCameraAvailableAndFWUpgrading];
}

- (NSInteger )checkCameraAvailableAndFWUpgrading
{
    if (_should_stop_scanning == TRUE)
    {
        NSLog(@"%s Stop scanning now.. should be 4 mins.", __FUNCTION__);
        
        [self setupFailed];
        return CAMERA_STATE_UNKNOWN;
    }
    
    if (_userAccount == nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
        NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
        NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
        
        UserAccount *user = [[UserAccount alloc] initWithUser:userEmail
                                 password:userPass
                                   apiKey:userApiKey
                                 listener:nil];
        self.userAccount = user;
        [user release];
    }
    
    NSInteger cameraStatus = [_userAccount checkAvailableAndFWUpgradingWithCamera:_cameraMac];
    
    NSLog(@"checkCameraAvailableAndFWUpgrading: %d", cameraStatus);
    
    if (cameraStatus == CAMERA_STATE_REGISTED_LOGGED_USER)
    {
        [_userAccount updatesBasicInfoForCamera];
        [self checkCameraIsAvailable];
    }
    else if (cameraStatus == CAMERA_STATE_FW_UPGRADING)
    {
        if (_timeOut)
        {
            [_timeOut invalidate];
            self.timeOut = nil;
        }
        
        [self askUserToWaitForUpgrade];
    }
    else// unkown
    {
        [self performSelector:@selector(checkCameraAvailableAndFWUpgrading)
                   withObject:nil afterDelay:0.01];
    }
    
    return cameraStatus;
}

- (BOOL)checkCameraIsAvailable
{
    if (_should_stop_scanning == TRUE)
    {
        NSLog(@"%s Stop scanning now.. should be 4 mins.", __FUNCTION__);
        
        [self setupFailed];
        return FALSE;
    }
    
    NSLog(@"--> Try to search IP online...");
    
    if (_userAccount == nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
        NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
        NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
        
        UserAccount *user = [[UserAccount alloc] initWithUser:userEmail
                                 password:userPass
                                   apiKey:userApiKey
                                 listener:nil];
        self.userAccount = user;
        [user release];
    }
    
    if ([_userAccount checkCameraIsAvailable:_cameraMac])
    {
        self.errorCode = @"NoErr";
        NSLog(@"Found it online");
        [self setupCompleted];
        return TRUE;
    }
    else
    {
        [self performSelector:@selector(checkCameraIsAvailable) withObject:nil afterDelay:0.001];
    }
    
    return FALSE;
}

#if 0
-(BOOL) checkItOnline
{
    NSLog(@"--> Try to search IP online...");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
    
    if (_userAccount == nil)
    {
        UserAccount *user = [[UserAccount alloc] initWithUser:userEmail
                                 password:userPass
                                   apiKey:userApiKey
                                 listener:nil];
        self.userAccount = user;
        [user release];
    }
#if 1
    if ([_userAccount checkCameraIsAvailable:_cameraMac])
    {
        self.errorCode = @"NoErr";
        return TRUE;
    }
    
#else
    NSString *localIp = [_userAccount query_cam_ip_online:self.cameraMac];
    
    if (localIp != nil)
    {
        NSLog(@"Found a local ip: %@", localIp);
        [self setupCompleted];
        return TRUE;
    }
#endif
    self.errorCode =@"NotAvail";
    return FALSE;
}
#endif

- (void) setupCompleted
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera success" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Add camera succeeded"
                                                     withLabel:nil
                                                     withValue:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_timerAdditionalOption)
    {
        [_timerAdditionalOption invalidate];
        self.timerAdditionalOption = nil;
    }
    
    // cancel timeout
    if (_timeOut != nil)// && [timeOut isValid])
    {
        [_timeOut invalidate];
        self.timeOut = nil;
    }
#if 0
    [self.progressView setHidden:YES];
#endif
    //Load step 12
    NSLog(@"Load step 12");
    
    //Load the next xib
    Step_12_ViewController *step12ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        step12ViewController = [[Step_12_ViewController alloc]
                                initWithNibName:@"Step_12_ViewController_ipad" bundle:nil];
    }
    else
    {
        step12ViewController = [[Step_12_ViewController alloc]
                                initWithNibName:@"Step_12_ViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:step12ViewController animated:NO];
    
    [step12ViewController release];
}


- (void)  setupFailed
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"Setup has failed - remove cam on server");
    
    if (_timerAdditionalOption)
    {
        [_timerAdditionalOption invalidate];
        self.timerAdditionalOption = nil;
    }
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step10 - Add camera failed" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Add camera failed:%@", _errorCode]
                                                     withLabel:nil
                                                     withValue:nil];
    // Dont remove camera anymore as we don't add it,
#if 0
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(removeCamSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCamFailedWithError:)
                                                                             ServerErr:@selector(removeCamFailedServerUnreachable)] autorelease];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [jsonComm deleteDeviceWithRegistrationId:_stringUDID
                                   andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
#endif
    if (_forceSetupFailed)
    {
        NSLog(@"%s Restarting setup immediately", __FUNCTION__);
        
        // Disable Keep screen on
        [UIApplication sharedApplication].idleTimerDisabled=  NO;
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        //Load step 11
        NSLog(@"Load step 11");
        
        //Load the next xib
        Step_11_ViewController *step11ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            step11ViewController = [[Step_11_ViewController alloc]
                                    initWithNibName:@"Step_11_ViewController_ipad" bundle:nil];
        }
        else
        {
            step11ViewController = [[Step_11_ViewController alloc]
                                    initWithNibName:@"Step_11_ViewController" bundle:nil];
        }
        
        step11ViewController.errorCode       = self.errorCode;
        [self.navigationController pushViewController:step11ViewController animated:NO];
        
        [step11ViewController release];
    }
}

- (void)showDialogWithTag:(NSInteger)tag message: (NSString *)msg
{
    NSString *title = NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                        @"AddCam Error" , nil);
    
    switch (tag)
    {
        case ALERT_ADD_CAM_FAILED:
        case ALERT_CHECK_STATUS:
        {
            NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
            
            //ERROR condition
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:msg
                                  delegate:nil
                                  cancelButtonTitle:ok
                                  otherButtonTitles:nil];
            alert.tag = tag;
            [alert show];
            [alert release];
        }
            break;
            
        case ALERT_ADD_CAM_UNREACH:
        {
            if (_should_stop_scanning)
            {
                // Need not to popup anymore
                return;
            }
            
            NSString * message = NSLocalizedStringWithDefaultValue(@"addcam_error_1" ,nil, [NSBundle mainBundle],
                                                               @"The device is not able to connect to the server. Please check the WIFI and the internet. Go to WIFI setting to confirm device is connected to intended router", nil);
            NSString * cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
            
            NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                                 @"Retry", nil);
            //ERROR condition
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:cancel
                                  otherButtonTitles:retry, nil];
            alert.delegate = self;
            alert.tag = ALERT_ADD_CAM_UNREACH;
            
            [alert show];
            [alert release];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark  Callbacks

- (void) addCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"Do for concurent modep - addcam response");
    self.stringAuth_token = [[responseData objectForKey:@"data"] objectForKey:@"auth_token"];
    //send master key to device
    self.shouldSendMasterKeyAgain = TRUE;
    [self sendMasterKeyToDevice];
}

- (void) addCamFailedWithError:(NSDictionary *) error_response
{
    if (error_response == nil) {
        NSLog(@"Error - error_response = nil");
        return;
    }
    
    NSLog(@"addcam failed with error code:%d", [[error_response objectForKey:@"status"] intValue]);
    NSString *msg = [error_response objectForKey:@"message"];
    
    [self showDialogWithTag:ALERT_ADD_CAM_FAILED message:msg];
    self.errorCode = msg;
    [self  setupFailed];
}

- (void) addCamFailedServerUnreachable
{
    NSLog(@"addcam failed : server unreachable");
    
    if (_should_retry_silently == TRUE)
    {
        NSLog(@"addcam failed : Retry without popup");
        [self registerCamera:nil];
    }
    else
    {
        [self showDialogWithTag:ALERT_ADD_CAM_UNREACH message:nil];
    }
}

-(void) removeCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"Log - removeCam success");
    
    //[delegate sendStatus:5 ];
    
}

-(void) removeCamFailedWithError:(NSDictionary *)error_response
{
    NSLog(@"Log - removeCam failed Server error: %@", [error_response objectForKey:@"message"]);
}

-(void) removeCamFailedServerUnreachable
{
    NSLog(@"Log - server unreachable");
}

#pragma mark -
#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step10 - dismiss alert view with btn indx: %d", buttonIndex] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Dismiss alert:%d", alertView.tag]
                                                     withLabel:[NSString stringWithFormat:@"Alert:%@", alertView.title]
                                                     withValue:[NSNumber numberWithInteger:buttonIndex]];
    
    int tag = alertView.tag;
    
    if (tag == ALERT_ADD_CAM_UNREACH)
    {
        switch(buttonIndex) {
            case 0: // Cancel
                self.errorCode = @"ServUnreach";
                
                [self  setupFailed];
                
                break;
            case 1: // Retry
                [self registerCamera:nil];
                break;
            default:
                break;
        }
    }
    
}

- (void)askUserToWaitForUpgrade
{
    //[self.progressView removeFromSuperview];
    
    [self.view addSubview:_viewFwOtaUpgrading];
    [self.view bringSubviewToFront:_viewFwOtaUpgrading];
    self.otaDummyProgressBar.progress = 0.0;
    self.fwUpgradeStatus = FIRMWARE_UPGRADE_IN_PROGRESS;
    
	[self performSelectorInBackground:@selector(upgradeFwReboot_bg)  withObject:nil];
    [self performSelectorInBackground:@selector(checkFwUpgradeStatus) withObject:nil];
}

-(void) upgradeFwReboot_bg
{
	//percentageProgress.
    
    @autoreleasepool {
        float sleepPeriod = TIME_FW_UPGRADE / 100.f; // 100 cycles
        NSInteger percentage = 0;
        
        while (percentage++ < 100 &&
               (_fwUpgradeStatus == FIRMWARE_UPGRADE_IN_PROGRESS || _fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT))
        {
            [self performSelectorOnMainThread:@selector(upgradeFwProgress_ui:)
                                   withObject:[NSNumber numberWithInt:percentage]
                                waitUntilDone:YES];
            
            [NSThread sleepForTimeInterval:sleepPeriod];
        }
        
        NSLog(@"%s percentage:%d, fwStatus:%d", __FUNCTION__, percentage, _fwUpgradeStatus);
        
        //[self performSelectorOnMainThread:@selector(checkCameraStatusAgain) withObject:nil waitUntilDone:NO];
        
        if (_fwUpgradeStatus == FIRMWARE_UPGRADE_SUCCEED)
        {
            [_viewFwOtaUpgrading performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(checkCameraStatusAgain) withObject:nil waitUntilDone:NO];
        }
        else
        {
#if 1
            if (!_userAccount)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
                NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
                NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
                
                self.userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                            password:userPass
                                                              apiKey:userApiKey
                                                            listener:nil];
            }
            
            [_userAccount readCameraListAndUpdate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.btnContinue.hidden = NO;
                self.btnCancelFirmware.hidden = NO;
                
                NSString *msg1 = NSLocalizedStringWithDefaultValue(@"alert_mes_firmware_upgrade_completed", nil, [NSBundle mainBundle], @"Firmware upgrade could not be completed.", nil);
                
                if (_fwUpgradeStatus == FIRMWARE_UPGRADE_FAILED)
                {
                    msg1 = NSLocalizedStringWithDefaultValue(@"alert_mes_incorrect_firmware_version", nil, [NSBundle mainBundle], @"Incorrect Firmware version.", nil);
                }
                else if(_fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT)
                {
                    msg1 = NSLocalizedStringWithDefaultValue(@"alert_mes_camera_offline_after_upgrading", nil, [NSBundle mainBundle], @"Camera offline after upgrading.", nil);
                }
                
                msg1 = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"alert_mes_please_manually_off_and_on_the_camera", nil, [NSBundle mainBundle], @"%@\n\rPlease manually off and on the camera.", nil), msg1];
                UILabel *lblTmp = (UILabel *)[_viewFwOtaUpgrading viewWithTag:TAG_VIEW_FW_UPGRADE_MESSAGE];
                lblTmp.text = msg1;
                
                [[_viewFwOtaUpgrading viewWithTag:TAG_VIEW_FW_UPGRADE_5MINUTES] setHidden:YES];
                [[_viewFwOtaUpgrading viewWithTag:TAG_VIEW_FW_UPGRADE_INDICATOR] setHidden:YES];
                [[_viewFwOtaUpgrading viewWithTag:TAG_VIEW_FW_UPGRADE_PROGRESS] setHidden:YES];
                
                self.fwUpgradeStatus = FIRMWARE_UPGRADE_SUCCEED; // Reset state of firmware upgrade.
            });
#else
            self.errorCode = [NSString stringWithFormat:@"%d", _fwUpgradeStatus];
            
            NSLog(@"%s errorCode:%@", __FUNCTION__, _errorCode);
            
            if (_timeOut != nil)
            {
                [self.timeOut invalidate];
                self.timeOut = nil;
            }
            
            [self setStopScanning:nil];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            if (!_userAccount)
            {
                NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
                NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
                NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
                
                self.userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                            password:userPass
                                                              apiKey:userApiKey
                                                            listener:nil];
            }
            
            [_userAccount readCameraListAndUpdate];
            
            [self performSelectorOnMainThread:@selector(setupFailed) withObject:nil waitUntilDone:NO];
#endif
        }
    }
}

- (void)checkCameraStatusAgain
{
#if 0
    [self.view bringSubviewToFront:_progressView];
#endif
    
    if (_timeOut)
    {
        [_timeOut invalidate];
        self.timeOut = nil;
    }
    
    self.timeOut = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_PROCESS
                                                    target:self
                                                  selector:@selector(timeOutSetupProcess:)
                                                  userInfo:nil
                                                   repeats:NO];
    
    [self checkCameraIsAvailable];
}

- (void)upgradeFwProgress_ui:(NSNumber *)number
{
	self.fwUpgradePercentage = [number intValue];
	float _value = (float)_fwUpgradePercentage;
	_value = _value/100.0;
    
	if (_fwUpgradePercentage >= 0)
	{
		self.otaDummyProgressBar.progress = _value;
	}
}


         //checkFwUpgradeStatus
- (void )checkFwUpgradeStatus
{
    NSLog(@"%s _fwUpgradePercentage:%d, _fwUpgradeStatus:%d", __FUNCTION__,_fwUpgradePercentage, _fwUpgradeStatus);
    
    while (_fwUpgradePercentage < 100 &&
           (_fwUpgradeStatus == FIRMWARE_UPGRADE_IN_PROGRESS || _fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT))
    {
        if (_fwUpgradePercentage <= 10)// 30s
        {
            self.fwUpgradeStatus = FIRMWARE_UPGRADE_IN_PROGRESS;
        }
        else
        {
            NSLog(@"%s", __FUNCTION__);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            if (!_userAccount)
            {
                NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
                NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
                NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
                
                self.userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                            password:userPass
                                                              apiKey:userApiKey
                                                            listener:nil];
            }
            
            NSString *udid       = [userDefaults objectForKey:CAMERA_UDID];
            NSString *fwVersion  = [userDefaults stringForKey:FW_VERSION];
            
            self.fwUpgradeStatus = [_userAccount checkFwUpgrageStatusWithRegistrationId:udid currentFwVersion:fwVersion];
        }
        
        [NSThread sleepForTimeInterval:2];
    }
}


@end



















