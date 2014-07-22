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
#import "KISSMetricsAPI.h"
#import "HubbleProgressView.h"

#define TAG_IMAGE_VIEW_ANIMATION 595
#define PROXY_HOST @"192.168.193.1"
#define PROXY_PORT 8888

#define DEV_STATUS_UNKOWN                   0
#define DEV_STATUS_NOT_IN_MASTER            1
#define DEV_STATUS_NOT_REGISTERED           2
#define DEV_STATUS_REGISTERED_LOGGED_USER   3
#define DEV_STATUS_REGISTERED_OTHER_USER    4
#define DEV_STATUS_DELETED                  5

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

@property (nonatomic, assign) IBOutlet UIView * progressView;
@property (retain, nonatomic) IBOutlet UIView *viewFwOtaUpgrading;
@property (retain, nonatomic) IBOutlet UILabel *lblWordAddition;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UIButton *btnCancelFirmware;

@property (retain, nonatomic) UserAccount *userAccount;
@property (nonatomic, retain) BMS_JSON_Communication *jsonCommBlocked;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic) BOOL shouldSendMasterKeyAgain;
@property (retain, nonatomic) UIProgressView *otaDummyProgressBar;
@property (nonatomic, retain) NSTimer *timeOut;
@property (nonatomic) BOOL forceSetupFailed;
@property (nonatomic) NSInteger fwUpgradePercentage;
@property (nonatomic) NSInteger fwUpgradeStatus;

@end

@implementation Step_10_ViewController


@synthesize  cameraMac, master_key;
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
    [_userAccount release];
    [cameraMac release];
    [master_key release];
    [_ib_scollViewGuide release];
    [_ib_viewGuild release];
    [_ib_resumeSetup release];
    [_jsonCommBlocked release];
    
    [_viewFwOtaUpgrading release];
    [_btnCancel release];
    [_lblWordAddition release];
    [_btnContinue release];
    [_btnCancel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    UIImageView *imageView = (UIImageView *)[_progressView viewWithTag:595];
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
    [self showProgress:nil];
    
    [_lblWordAddition performSelector:@selector(setHidden:) withObject:NO afterDelay:57]; //1 * 60 - 3
    [_btnCancel performSelector:@selector(setHidden:) withObject:NO afterDelay:57]; //1 * 60 - 3
    
    self.otaDummyProgressBar = (UIProgressView *)[_viewFwOtaUpgrading viewWithTag:5990];
    self.fwUpgradeStatus = FIRMWARE_UPGRADE_SUCCEED;

    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION];
    
    if ([fwVersion compare:FW_VERSION_FACTORY_SHOULD_BE_UPGRADED] == NSOrderedSame)
    {
        UILabel *lblProgress = (UILabel *)[_progressView viewWithTag:695];
        lblProgress.text = @"Note : Your camera may be upgraded to latest software. This may take about 5 minutes. During this time, you will not be able to access the camera.";
    }

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

- (void)sendCommandRebootCamera
{
    NSLog(@"%s", __FUNCTION__);
    //HttpCommunication *comm = [[HttpCommunication alloc]init];
    //NSString * command = RESTART_HTTP_CMD;
    //NSLog(@"[HttpCom instance]: %p", [HttpCom instance]);
    
    [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:RESTART_HTTP_CMD];
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    if (self.progressView != nil)
    {
        self.progressView.hidden = YES;
    }
}

#pragma mark - Actions

- (void)hubbleItemAction:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancelTouchUpInsideAction:(id)sender
{
    if (_timeOut)
    {
        [_timeOut invalidate];
        self.timeOut = nil;
    }
    
    [self setStopScanning:nil];
    
    [_btnCancel setHidden:YES];
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
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
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
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
 
    if (should_stop_scanning == TRUE || !udid)
    {
        NSLog(@"%s should_stop_scanning:%d", __FUNCTION__, should_stop_scanning);
        return ;
    }
    
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
    
    NSLog(@"Step_10_VC - checkCameraStatus: %@", responseDict);
    
    BOOL shouldCheckAgain = TRUE;

    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            NSInteger deviceStatus = [[[responseDict objectForKey:@"data"] objectForKey:@"device_status"] integerValue];
            
            switch (deviceStatus)
            {
                case DEV_STATUS_UNKOWN:
                case DEV_STATUS_NOT_REGISTERED:
                case DEV_STATUS_DELETED:
                case DEV_STATUS_REGISTERED_OTHER_USER:
                    // Check again
                    break;
                    
                case DEV_STATUS_NOT_IN_MASTER:
                {
                    if (deviceStatus == DEV_STATUS_NOT_IN_MASTER)
                    {
                        self.statusMessage = NSLocalizedStringWithDefaultValue(@"device_is_not_present", nil, [NSBundle mainBundle], @"Device is NOT present in device master", nil);
                    }
                    else
                    {
                        self.statusMessage = NSLocalizedStringWithDefaultValue(@"device_is_registered", nil, [NSBundle mainBundle], @"Device is registered with other User", nil);
                    }
                    
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
                    
                case DEV_STATUS_REGISTERED_LOGGED_USER:
                    NSLog(@"Step_10_VC register successfully. Move on");
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
    
    if (shouldCheckAgain)
    {
        [self performSelector:@selector(checkCameraStatus) withObject:nil afterDelay:2];
    }
}

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
        [self showProgress:nil];
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
    [self.progressView setHidden:YES];
    [self.ib_viewGuild setHidden:NO];
    [self.view bringSubviewToFront:self.ib_viewGuild];
}

-(void)becomeActive
{
    [self.ib_viewGuild setHidden:YES];
    [self showProgress:nil];
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
    [self showProgress:nil];
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
    should_stop_scanning = TRUE;
}

- (void) wait_for_camera_to_reboot:(NSTimer *)exp
{
    if (should_stop_scanning == TRUE)
    {
        NSLog(@"%s Step_10VC - stop scanning now.. should be 4 mins.", __FUNCTION__);
        
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
    if (should_stop_scanning == TRUE)
    {
        NSLog(@"%s Step_10VC - stop scanning now.. should be 4 mins.", __FUNCTION__);
        
        [self setupFailed];
        return CAMERA_STATE_UNKNOWN;
    }
    
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
    
    NSInteger cameraStatus = [_userAccount checkAvailableAndFWUpgradingWithCamera:self.cameraMac];
    
    NSLog(@"checkCameraAvailableAndFWUpgrading: %d", cameraStatus);
    
    if (cameraStatus == CAMERA_STATE_REGISTED_LOGGED_USER)
    {
        [self updatesBasicInfoForCamera];
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
    if (should_stop_scanning == TRUE)
    {
        NSLog(@"%s Step_10VC - stop scanning now.. should be 4 mins.", __FUNCTION__);
        
        [self setupFailed];
        return FALSE;
    }
    
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
    
    if ([_userAccount checkCameraIsAvailable:self.cameraMac])
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
    if ([_userAccount checkCameraIsAvailable:self.cameraMac])
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

- (void) setupCompleted
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera success" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Add camera succeeded"
                                                     withLabel:nil
                                                     withValue:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // cancel timeout
    if (_timeOut != nil)// && [timeOut isValid])
    {
        [_timeOut invalidate];
        self.timeOut = nil;
    }
    
    [self.progressView setHidden:YES];
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
        NSLog(@"%s restarting setup immediately", __FUNCTION__);
        
        // Disable Keep screen on
        [UIApplication sharedApplication].idleTimerDisabled=  NO;
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
            if (should_stop_scanning)
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
    
    if (should_retry_silently == TRUE)
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
                
                NSString *msg1 = @"Firmware upgrade could not be completed.";
                
                if (_fwUpgradeStatus == FIRMWARE_UPGRADE_FAILED)
                {
                    msg1 = @"Incorrect Firmware version.";
                }
                else if(_fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT)
                {
                    msg1 = @"Camera offline after upgrading.";
                }
                
                msg1 = [NSString stringWithFormat:@"%@\n\rPlease manually off and on the camera.", msg1];
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
    [self.view bringSubviewToFront:_progressView];
    
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



















