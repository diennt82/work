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
//#define ALERT_ADDCAM_SERVER_UNREACH 1

@interface Step_10_ViewController () <UIAlertViewDelegate>

@property (nonatomic, assign) IBOutlet UIView * progressView;
@property (retain, nonatomic) UserAccount *userAccount;
@property (nonatomic, retain) BMS_JSON_Communication *jsonCommBlocked;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic) BOOL shouldSendMasterKeyAgain;

@end

@implementation Step_10_ViewController


@synthesize  cameraMac, master_key;
@synthesize  timeOut;
@synthesize delegate;


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
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION];

    // >12.82 we can move on with new flow
    if ([fwVersion compare:FW_MILESTONE_F66_NEW_FLOW] >= NSOrderedSame)
    {
        [self waitingCameraRebootAndForceToWifiHome];
    }
    else
    {
        NSLog(@"Step10 - old flow");
        ///Old flow: First add camera
        [self registerCamera:nil];
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
    NSLog(@"Send command reset camera");
    //    HttpCommunication *comm = [[HttpCommunication alloc]init];
    NSString * command = RESTART_HTTP_CMD;
    
    NSLog(@"[HttpCom instance]: %p", [HttpCom instance]);
    
    [[HttpCom instance].comWithDevice sendCommandAndBlock:command];
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    if (self.progressView != nil)
    {
        self.progressView.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Actions
- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    NSString *camName = (NSString *) [userDefaults objectForKey:@"CameraName"];
    
    
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
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSString *camName = (NSString *) [userDefaults objectForKey:@"CameraName"];
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
    if (should_stop_scanning == TRUE)
    {
        return ;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    
    if (_jsonCommBlocked == nil)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
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
                    // Check again
                    break;
                    
                case DEV_STATUS_NOT_IN_MASTER:
                case DEV_STATUS_REGISTERED_OTHER_USER:
                {
                    if (deviceStatus == DEV_STATUS_NOT_IN_MASTER)
                    {
                        self.statusMessage = @"Device is NOT present in device master";
                    }
                    else
                    {
                        self.statusMessage = @"Device is registered with other User";
                    }
                    
                    shouldCheckAgain = FALSE;
                    self.errorCode = [NSString stringWithFormat:@"%d", deviceStatus];
                    
                    if (timeOut != nil)
                    {
                        [timeOut invalidate];
                    }
                    
                    [self setStopScanning:nil];
                    
                    [self showDialogWithTag:ALERT_CHECK_STATUS message:_statusMessage];
                    
                    [self setupFailed];
                }
                    break;
                    
                case DEV_STATUS_REGISTERED_LOGGED_USER:
                    NSLog(@"Step_10_VC register successfully. Move on");
                    shouldCheckAgain = FALSE;
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

#pragma  mark -
#pragma mark Timer callbacks

-(void) homeWifiScanTimeout: (NSTimer *) expired
{
    timeOut = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
    
    NSLog(@" Timeout while trying to search for Home Wifi: %@", homeSsid);
    
    [self setStopScanning:Nil];
}

- (void) step10CheckConnectionToHomeWifi:(NSTimer *) expired
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //home wifi
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
	
    //current wifi
    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    //current wifi of camera setup
    NSString *wifiCameraSetup = [userDefaults stringForKey:@"CameraName"];
    
    
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
            if (timeOut != nil && [timeOut isValid])
            {
                [timeOut invalidate];
                
            }
            //Timer  1min - for camera reboot and add itself to server
            timeOut = [NSTimer scheduledTimerWithTimeInterval:1*60.0
                                                       target:self
                                                     selector:@selector(homeWifiScanTimeout:)
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
        NSLog(@"Step_10VC - stop scanning now.. should be 4 mins");
        
        [self setupFailed];
        return ;
    }
    else
    {
        NSLog(@"Step_10VC - Continue scan...");
    }
    
    if ([self checkItOnline])
    {
        //Found it online
        NSLog(@"Found it online");
        [self setupCompleted];
        return;
    }
    else
    {
        //retry scannning..
        [NSTimer scheduledTimerWithTimeInterval: 0.01
                                         target:self
                                       selector:@selector(wait_for_camera_to_reboot:)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    return;
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
        self.userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                    password:userPass
                                                      apiKey:userApiKey
                                                    listener:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // cancel timeout
    if (timeOut != nil)// && [timeOut isValid])
    {
        [timeOut invalidate];
        
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
    // send a command to remove camera
    //NSString *mac = [Util strip_colon_fr_mac:self.cameraMac];
    
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
    
    step11ViewController.errorCode = self.errorCode;
    [self.navigationController pushViewController:step11ViewController animated:NO];
    
    [step11ViewController release];
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
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            
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
            NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                                  @"Cancel", nil);
            
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

@end
