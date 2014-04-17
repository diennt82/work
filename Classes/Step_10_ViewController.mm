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

@interface Step_10_ViewController () <UIAlertViewDelegate>

@property (nonatomic, assign) IBOutlet UIView * progressView;
@property (retain, nonatomic) UserAccount *userAccount;

@end

@implementation Step_10_ViewController


@synthesize  cameraMac, master_key;




//@synthesize  shouldStopScanning;
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

- (void)viewWillDisappear:(BOOL)animated
{
    //Dismiss alertView in case interrupt : lock key, home key, phone call
    if (_alertChooseConfig)
    {
        [_alertChooseConfig dismissWithClickedButtonIndex:0 animated:NO];
        [_alertChooseConfig release];
        _alertChooseConfig = nil;
    }
}

#pragma mark - Actions
- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showDialogChooseConfigCamera
{
    NSString *selectPlease = NSLocalizedStringWithDefaultValue(@"please_select",nil, [NSBundle mainBundle],
                                                               @"Please select", nil);
    NSString *message = NSLocalizedStringWithDefaultValue(@"guide_choose_config",nil, [NSBundle mainBundle],
                                                          @"BLE to config camera through bluetooth.\nWifi to config camera through wifi.", nil);
    NSString *cancelText = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                             @"Cancel", nil);
    NSString *BLEText = NSLocalizedStringWithDefaultValue(@"BLE",nil, [NSBundle mainBundle],
                                                          @"BLE", nil);
    NSString *wifiText = NSLocalizedStringWithDefaultValue(@"Wifi",nil, [NSBundle mainBundle],
                                                           @"Wifi", nil);
    
    _alertChooseConfig = [[UIAlertView alloc]
                          initWithTitle:selectPlease
                          message:message
                          delegate:self
                          cancelButtonTitle:cancelText
                          otherButtonTitles:BLEText, wifiText, nil];
    [_alertChooseConfig show];
}

#pragma  mark -
#pragma mark button handlers

-(IBAction) startConfigureCamera:(id)sender
{
    [self showDialogChooseConfigCamera];
}


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
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSString *camName = (NSString *) [userDefaults objectForKey:@"CameraName"];
    NSDictionary *responseDict = [jsonComm registerDeviceBlockedWithProxyHost:PROXY_HOST
                                                                    proxyPort:PROXY_PORT
                                                                   deviceName:camName
                                                               registrationID:udid
                                                                         mode:@"upnp"
                                                                    fwVersion:fwVersion
                                                                     timeZone:stringFromDate
                                                                    andApiKey:apiKey];
    [jsonComm release];
    
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
        NSLog(@"Now, still connected to wifiOf Camera, continue check");
        
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
        should_stop_scanning = FALSE;
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
    NSLog(@"--> Try to search IP onlinexxxx");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * userEmail = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * userPass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
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

#pragma mark -
#pragma mark  Callbacks

- (void) addCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"Do for concurent modep - addcam response");
    self.stringAuth_token = [[responseData objectForKey:@"data"] objectForKey:@"auth_token"];
    //send master key to device
    [self sendMasterKeyToDevice];
    
}

- (void) addCamFailedWithError:(NSDictionary *) error_response
{
    if (error_response == nil) {
        NSLog(@"Error - error_response = nil");
        return;
    }
    
    NSLog(@"addcam failed with error code:%d", [[error_response objectForKey:@"status"] intValue]);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@" , nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    //ERROR condition
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                          @"AddCam Error" , nil)
                          message:[error_response objectForKey:@"message"]
                          delegate:self
                          cancelButtonTitle:ok
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    self.errorCode = msg;
    [self  setupFailed];
    
    return;
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
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"addcam_error_1" ,nil, [NSBundle mainBundle],
                                                           @"The device is not able to connect to the server. Please check the WIFI and the internet. Go to WIFI setting to confirm device is connected to intended router", nil);
        NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                              @"Cancel", nil);
        
        NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                             @"Retry", nil);
        //ERROR condition
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                              @"AddCam Error" , nil)
                              message:msg
                              delegate:self
                              cancelButtonTitle:cancel
                              otherButtonTitles:retry, nil];
        alert.delegate = self;
        alert.tag = ALERT_ADDCAM_SERVER_UNREACH;
        
        [alert show];
        [alert release];
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
    
    if (tag == ALERT_ADDCAM_SERVER_UNREACH)
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
