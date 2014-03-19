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

@interface Step_10_ViewController ()

@property (nonatomic, assign) IBOutlet UIView * progressView;
@property (retain, nonatomic) UserAccount *userAccount;

@end

@implementation Step_10_ViewController

@synthesize  userNameLabel, userEmailLabel;
@synthesize  cameraMac, master_key; 
@synthesize  cameraName;

@synthesize  homeSSID;
@synthesize  shouldStopScanning;
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
    //[userEmailLabel release];
    //[progressView release]; 
    [cameraMac release];
    [master_key release];

    
    //[cameraName release];
    [_ib_scollViewGuide release];
    [_ib_viewGuild release];
    [_ib_resumeSetup release];
    [super dealloc];
}
- (void)sendCommandRebootCamera
{
    NSLog(@"Send command reset camera");
//    HttpCommunication *comm = [[HttpCommunication alloc]init];
    NSString * command = RESTART_HTTP_CMD;
    [[HttpCom instance].comWithDevice sendCommandAndBlock:command];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if 1

    [self.ib_scollViewGuide setContentSize:CGSizeMake(320, 1401)];

#endif
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(becomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    //Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    


    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //can be user email or user name here --  
    self.userNameLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUsername"];	
    self.userEmailLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    self.cameraMac = (NSString *) [userDefaults objectForKey:@"CameraMacWithQuote"];
    self.stringUDID = [userDefaults stringForKey:CAMERA_UDID];
    
    if (self.progressView == nil)
    {
        NSLog(@"progressView = nil!!!!");
    }
    
    BOOL firstime = [userDefaults boolForKey:FIRST_TIME_SETUP];
    
    
    //Check to see which path we should go 
    if (firstime == TRUE)
    {  
        // Do any additional setup after loading the view.
        
        self.navigationItem.title =NSLocalizedStringWithDefaultValue(@"Account_Created",nil, [NSBundle mainBundle],
                                                                     @"Account Created" , nil);
        self.navigationItem.hidesBackButton = YES;
        
        [self.view addSubview:self.progressView];
        self.progressView.hidden = YES;
        
        
    }
    else //not first time --> this is normal add camera sequence..
    {
        //Hide back button -- can't go back now..
        self.navigationItem.hidesBackButton = TRUE;
#if 1
        self.navigationItem.hidesBackButton = YES;
        
        UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
        UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(hubbleItemAction:)];
        [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
        
        self.navigationItem.leftBarButtonItem = barBtnHubble;
#else
        self.navigationItem.title =NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                     @"Camera Configured" , nil);
#endif
        NSLog(@"Normal Add cam sequence" );
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
        
        UIImageView *imageView = (UIImageView *)[_progressView viewWithTag:595];
        imageView.animationImages =[NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"setup_camera_c1"],
                                    [UIImage imageNamed:@"setup_camera_c2"],
                                    [UIImage imageNamed:@"setup_camera_c3"],
                                    [UIImage imageNamed:@"setup_camera_c4"],
                                    nil];
        imageView.animationDuration = 1.5;
        imageView.animationRepeatCount = 0;
        
        [self.view addSubview:self.progressView];
        [imageView startAnimating];
        self.progressView.hidden = NO;

        self.homeSSID.text = homeSsid;
        
        
        //First add camera
        [self registerCamera:nil];
        
    }
        
}

-(void) handleEnteredBackground
{
//    showProgressNextTime = TRUE;
}

-(void) becomeActive
{
//    if (showProgressNextTime)
//    {
        NSLog(@"cshow progress 03");
        [self showProgress:nil];
//    }
    
//    task_cancelled = NO;
    [self waitingCameraRebootAndForceToWifiHome];
}

-(void) showProgress:(NSTimer *) exp
{
    NSLog(@"show progress ");
    {
        if (self.progressView != nil)
        {
            NSLog(@"show progress 01 ");
            self.progressView.hidden = NO;
            [self.view bringSubviewToFront:self.progressView];
        }
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
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

- (void)startAnimationWithOrientation
{
    UIImageView *animationView =  (UIImageView *)[cameraAddedView viewWithTag:TAG_IMAGE_VIEW_ANIMATION];
    //UIImageView *animationView = [[UIImageView alloc ] initWithFrame:deviceScreen];
    
    [animationView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        animationView.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"frame-1_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-2_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-3_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-4-2_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-5_update-iOS7_new"],
                                        [UIImage imageNamed:@"frame-6_update-iOS7_new2"],
                                        nil];
        NSLog(@"ios 7");
    }
    
    else
    {
        animationView.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"frame-1_update_new"],
                                        [UIImage imageNamed:@"frame-2_update_new"],
                                        [UIImage imageNamed:@"frame-3_update_new"],
                                        [UIImage imageNamed:@"frame-4-2_update_new"],
                                        [UIImage imageNamed:@"frame-5_update_new"],
                                        [UIImage imageNamed:@"frame-6_update_new"],
                                        nil];
        NSLog(@"ios < 7");
    }
    
    animationView.animationDuration = 18;
    animationView.animationRepeatCount = 0;
    
    [cameraAddedView bringSubviewToFront:animationView];
    
    [animationView startAnimating];
}

#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustViewsForOrientations:toInterfaceOrientation];
}

-(void) adjustViewsForOrientations: (UIInterfaceOrientation) interfaceOrientation
{
#if 0
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Step_10_ViewController_land_ipad" owner:self options:nil];
        }
        else
        {
           // [[NSBundle mainBundle] loadNibNamed:@"Step_10_ViewController_land" owner:self options:nil];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
           // [[NSBundle mainBundle] loadNibNamed:@"Step_10_ViewController_ipad" owner:self options:nil];
        }
        else
        {
           // [[NSBundle mainBundle] loadNibNamed:@"Step_10_ViewController" owner:self options:nil];
            
        }
    }
    

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL firstime = [userDefaults boolForKey:FIRST_TIME_SETUP];
  
    
    //can be user email or user name here --
    self.userNameLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
    self.userEmailLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
     //Hide back button -- can't go back now..
    self.navigationItem.hidesBackButton = YES;
    
    //Check to see which path we should go
    if (firstime == TRUE)
    {
        // Do any additional setup after loading the view.
        
        self.navigationItem.title =NSLocalizedStringWithDefaultValue(@"Account_Created",nil, [NSBundle mainBundle],
                                                                     @"Account Created" , nil);
        
        
        
        
        
    }
    else //not first time --> this is normal add camera sequence..
    {
       
        self.navigationItem.title =NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                     @"Camera Configured" , nil);
        
        [self.view addSubview:self.progressView];
        //self.progressView.hidden = hidden;
        [self.view addSubview:cameraAddedView];
        NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
        self.homeSSID.text = homeSsid;
        
    }
#endif

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (buttonIndex == 0) {
        //Cancel button pressed
        [_alertChooseConfig dismissWithClickedButtonIndex:0 animated:NO];
        _alertChooseConfig = nil;
    }
    else if (buttonIndex == BLUETOOTH_SETUP) {
        //BLE button pressed
        //NO longer first time
        [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
        [userDefaults synchronize];
        
        NSLog(@"load step BLE setup ");
        
        [userDefaults setInteger:BLUETOOTH_SETUP forKey:SET_UP_CAMERA];
        [userDefaults synchronize];
        
        //[self.navigationController popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate sendStatus:SETUP_CAMERA];
        }];
        
        
    }
    else if (buttonIndex == WIFI_SETUP) {
        //Wifi button pressed
        //NO longer first time
        [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
        [userDefaults synchronize];
        
        NSLog(@"load step Wifi setup: concurrent ");
        
        [userDefaults setInteger:WIFI_SETUP forKey:SET_UP_CAMERA];
        [userDefaults synchronize];
        //[self.delegate sendStatus:SETUP_CAMERA];
        //[self.navigationController popToRootViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate sendStatus:SETUP_CAMERA];
        }];
    }
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
#if 1
    [self performSelectorInBackground:@selector(registerCameraWithProxy) withObject:nil];
#else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:@"FW_VERSION"];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    /*
     hack code for device 0066 which return UUID is wrong
     */
    NSString *udidOfFocus66Hack = @"01006644334C7E0C8AXHRRBOLC";
    if ([udid isEqualToString:@"01008344334C7E0C8AXHRRBOLC"])
    {
        udid = udidOfFocus66Hack;
    }
    
    //NSLog(@"-----fwVersion = %@, ,model = %@", fwVersion, model);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    
    [stringFromDate insertString:@"." atIndex:3];
    
    NSLog(@"%@", stringFromDate);
    
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

    //DEMO.SM.COM
    [jsonComm registerDeviceWithDeviceName:camName
                                  andRegId:mac
                             andDeviceType:@"Camera"
                                  andModel:@"blink1_hd"
                                   andMode:@"upnp"
                              andFwVersion:fwVersion
                               andTimeZone:stringFromDate
                                 andApiKey:apiKey];
    NSLog(@"Mac address and cam name is %@, %@", mac, camName);

    //Api
    [jsonComm registerDeviceWithDeviceModelID:@"5"
                                      andName:camName
                            andRegistrationID:mac
                                      andMode:@"upnp"
                                 andFwVersion:fwVersion
                                  andTimeZone:stringFromDate
                          andSubscriptionType:@"tier1"
                                    andApiKey:apiKey];
    
#endif
}

- (void)registerCameraWithProxy
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:@"FW_VERSION"];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    /*
     hack code for device 0066 which return UUID is wrong
     */
    NSString *udidOfFocus66Hack = @"01006644334C7E0C8AXHRRBOLC";
    if ([udid isEqualToString:@"01008344334C7E0C8AXHRRBOLC"])
    {
        udid = udidOfFocus66Hack;
    }
    
    //NSLog(@"-----fwVersion = %@, ,model = %@", fwVersion, model);
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    
    [stringFromDate insertString:@"." atIndex:3];
    
    NSLog(@"%@", stringFromDate);
    
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
-(void) silentRetryTimeout:(NSTimer *) expired
{
    
    //TIMEOUT --
    should_retry_silently = FALSE; 
    
}


-(void) homeWifiScanTimeout: (NSTimer *) expired
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];

    NSLog(@" Timeout while trying to search for Home Wifi: %@", homeSsid);
    
    shouldStopScanning = TRUE;
    
}

- (void) checkConnectionToHomeWifi:(NSTimer *) expired
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
	
    
    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    
    
    NSNumber * retry_count =  (NSNumber *) expired.userInfo;
    
    if ([retry_count intValue] <= 0)
    {
        // ..
        [self connectToWifiHomeByHand];
        return;
    }
    
    
    
    
    
    NSLog(@"check ConnectionToHomeWifi 03: %@", currentSSID);
        NSLog(@"check ConnectionToHomeWifi : %@ and homeSsid: %@", currentSSID, homeSsid);
	if ([currentSSID isEqualToString:homeSsid])
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if (![own isEqualToString:@""])
		{
            
            if (timeOut != nil && [timeOut isValid])
            {
                [timeOut invalidate];
                
            }
            
            
            [self wait_for_camera_to_reboot:nil];
            
            //Timer ticky 5min - for camera reboot and scan camera
            timeOut = [NSTimer scheduledTimerWithTimeInterval:5*60.0
                                                       target:self
                                                     selector:@selector(homeWifiScanTimeout:)
                                                     userInfo:nil
                                                      repeats:NO];
            
            return;
		}
		
	}
    
	
    retry_count = [[NSNumber alloc] initWithUnsignedInt:[retry_count intValue] -1 ];
    
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:retry_count
                                    repeats:NO];

}

- (void)connectToWifiHomeByHand
{
    [self.progressView setHidden:YES];
#if 1
    [self.view addSubview:self.ib_viewGuild];
    
#else
    
    [self startAnimationWithOrientation];
    [self.view addSubview:cameraAddedView];
#endif
    
    /* TODO
     - Do nothing UNTIL user go out and go into the app again 
     - Start timer to check [checkConnectionToHomeWifi]
     
      */
    
    

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
            
       

            [self waitingCameraRebootAndForceToWifiHome];
        }
        
    }

}

- (void)waitingCameraRebootAndForceToWifiHome
{
    //time out to force is 2s
    [self.progressView setHidden:NO];
    

    //Set timer - repeated = YES
    //    expired -> checkConnectionToHomeWifi:
    //     ...
    //     .. counter ---
    //      counter = 0 -> Repeat  = NO ;

    //retry for 20x3 = 60 sec
    NSNumber * retry_count = [[NSNumber alloc] initWithInt:7];//change to 7 is 21s
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:retry_count
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
        NSLog(@" stop scanning now.. should be 4 mins");
        self.errorCode = @"Time Out";
		[self setupFailed];
		return ;
    }
    else
    {
        NSLog(@"Continue scan..."); 
    }

	if (scanner == nil)
	{
		scanner =[[ScanForCamera alloc]init];
	}
	[scanner scan_for_device:self.cameraMac];
	
	
	
	[NSTimer scheduledTimerWithTimeInterval: 2 // 
									 target:self
								   selector:@selector(checkScanResult:)
								   userInfo:nil
									repeats:NO];
}

- (void) checkScanResult: (NSTimer *) expired
{
	
	
	if (scanner == nil)
	{
		NSLog(@"ERROR : scan = nil, don't reschedule");
		return; 
	}
	
	
	NSArray * result ; 
	if ([scanner getResults:&result])
	{
		NSLog(@"Got some result, check if there is this camera that we are waiting for ");

		if (result != nil)
		{
			CamProfile * cp ; 
			BOOL found = FALSE;
			for (int i =0; i<[result count]; i++)
			{
				
				cp = [result objectAtIndex:i];
				if ([cp.mac_address isEqualToString:[self.cameraMac uppercaseString]])
				{
					NSLog(@"camera %@ is up in home network with ip:%@",cp.mac_address, cp.ip_address); 
					
					found = TRUE;
					break; 
				}
				
			}
			
			//3 of 3. send the master key to device 
			if (found == TRUE)
			{
                //[self setupCompleted]; // Follow the new Flow, this is not need to do
                //return;
            }
            
		}
		else //result = nil
		{
			NSLog(@"scan again ..");
		}

        
        if ([self checkItOnline])
        {
            //Found it online
            NSLog(@"Found it online");
            return;
        }
        
		//retry scannning..
		[NSTimer scheduledTimerWithTimeInterval: 0.01  
										 target:self
									   selector:@selector(wait_for_camera_to_reboot:)
									   userInfo:nil
										repeats:NO];
	}
    else
	{
		
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(checkScanResult:)
									   userInfo:nil
										repeats:NO];	
	} 
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
    
    NSString *localIp = [_userAccount query_cam_ip_online: self.cameraMac];
    
    if ( localIp != nil)
    {
        NSLog(@"Found a local ip: %@", localIp);
#if 0
        HttpCommunication *comm = [[HttpCommunication alloc]init];
        comm.device_ip = localIp;
        
        NSString * set_mkey = SET_MASTER_KEY;
        NSString * response;
        set_mkey =[set_mkey stringByAppendingString:self.master_key];
        
        response = [comm sendCommandAndBlock:set_mkey];
        
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
                
                [comm release];
                [self setupCompleted];
                return TRUE;
            }
            
        }
        
        [comm release];
#endif
        [self setupCompleted];
        return TRUE;
    }
    
    return FALSE;
}

- (void) setupCompleted
{
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

- (IBAction)resumeSetupAction:(id)sender {
}

- (void)  setupFailed
{
 	NSLog(@"Setup has failed - remove cam on server");
	// send a command to remove camera
	//NSString *mac = [Util strip_colon_fr_mac:self.cameraMac];
	
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(removeCamSuccessWithResponse:)
                                                                         FailSelector:@selector(removeCamFailedWithError:)
                                                                            ServerErr:@selector(removeCamFailedServerUnreachable)] autorelease];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [jsonComm deleteDeviceWithRegistrationId:_stringUDID
                                   andApiKey:[userDefaults objectForKey:@"PortalApiKey"]];
    
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
    NSLog(@"Do for concurent modep - addcam response: %@", responseData);
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
                self.errorCode = @"Server Unreachable";
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
