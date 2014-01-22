//
//  Step_10_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#define TAG_IMAGE_VIEW_ANIMATION 595

#import "Step_10_ViewController_ble.h"
#import "StartMonitorCallback.h"

@interface Step_10_ViewController_ble ()

@end

@implementation Step_10_ViewController_ble

@synthesize  userNameLabel, userEmailLabel,progressView ;
@synthesize  cameraMac, master_key; 
@synthesize  cameraName;

@synthesize  homeSSID;
@synthesize  shouldStopScanning;
@synthesize  timeOut;



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

    //[userNameLabel release];
    //[userEmailLabel release];
    //[progressView release]; 
    [cameraMac release];
    [master_key release];

    
    //[cameraName release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
        [self startAnimationWithOrientation];
        //Hide back button -- can't go back now..
        self.navigationItem.hidesBackButton = TRUE;
        
        self.navigationItem.title =NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                     @"Camera Configured" , nil);

        NSLog(@"Normal Add cam sequence" );
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
        
        
        
        [self.view addSubview:self.progressView];
        self.progressView.hidden = YES;
        [self.view addSubview:cameraAddedView];
        self.homeSSID.text = homeSsid;
#if 0
        [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                         target:self
                                       selector:@selector(checkConnectionToHomeWifi:)
                                       userInfo:nil
                                        repeats:NO];

        
        
        
      
        shouldStopScanning = FALSE;
        
        timeOut = [NSTimer scheduledTimerWithTimeInterval:2*60.0
                                                   target:self
                                                 selector:@selector(homeWifiScanTimeout:)
                                                 userInfo:nil
                                                  repeats:NO];
        
#endif
        
        
        //CameraTest: try to search for camera now..
        [self registerCamera:nil];

        
        
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
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
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

#pragma  mark -
#pragma mark button handlers

-(IBAction) startConfigureCamera:(id)sender
{
   
    
    //NO longer first time
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:FALSE forKey:FIRST_TIME_SETUP];
    [userDefaults synchronize];
    
    NSLog(@"load step 2 ");
    
    //Load the next xib
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
    
    //Copy from initViewController the delegate which is pointing to MBP_iosViewcontroller. Support cancel button
    MBP_InitialSetupViewController * vc = (MBP_InitialSetupViewController *) [[self.navigationController viewControllers] objectAtIndex:0];
    step02ViewController.delegate = vc.delegate;
    
    [self.navigationController pushViewController:step02ViewController animated:NO];
    
    [step02ViewController release];
    
}

- (IBAction)registerCamera:(id)sender
{
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
    NSString *apiKey    = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *fwVersion = [userDefaults objectForKey:@"FW_VERSION"];
    NSString *udid      = [userDefaults objectForKey:CAMERA_UDID];
    
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

    NSString * camName = (NSString *) [userDefaults objectForKey:@"CameraName"];
#if 1
    [jsonComm registerDeviceWithDeviceName:camName
                         andRegistrationID:udid
                                   andMode:@"upnp" // Need somethings more usefully
                              andFwVersion:fwVersion
                               andTimeZone:stringFromDate
                                 andApiKey:apiKey];
#else
//    //DEMO.SM.COM
//    [jsonComm registerDeviceWithDeviceName:camName
//                                  andRegId:mac
//                             andDeviceType:@"Camera"
//                                  andModel:@"blink1_hd"
//                                   andMode:@"upnp"
//                              andFwVersion:fwVersion
//                               andTimeZone:stringFromDate
//                                 andApiKey:apiKey];

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
    if (shouldStopScanning == TRUE)
    {

        //Now we are not connecting to any wifi??
        self.errorCode = @"Not connecting to any wifi";
        [self setupFailed];
        return;
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
	
    
    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    
    
    
    NSLog(@"checkConnectionToHomeWifi 03: %@", currentSSID);
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
                //[timeOut release];
                timeOut = nil;
            }
            
            should_retry_silently = TRUE;
            
            //CameraTest: try to search for camera now..
            [self registerCamera:nil];
            
            
            
            //check back later..
            [NSTimer scheduledTimerWithTimeInterval: 4.0//
                                             target:self
                                           selector:@selector(silentRetryTimeout:)
                                           userInfo:nil
                                            repeats:NO];
            
			return;
		}
		
	}
	   
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
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
    NSString *addColonToMac = [Util add_colon_to_mac:[self.cameraMac uppercaseString]];
	[scanner scan_for_device:addColonToMac];
	
	
	
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
				if ([cp.mac_address isEqualToString:[Util add_colon_to_mac:[self.cameraMac uppercaseString]]])
				{
					NSLog(@"camera %@ is up in home network with ip:%@",cp.mac_address, cp.ip_address); 
					
					found = TRUE;
					break; 
				}
                else
                {
                    NSLog(@"Does not match : %@ vs %@",cp.mac_address,[Util add_colon_to_mac:[self.cameraMac uppercaseString]]  );
                }
				
			}
			
			//3 of 3. send the master key to device 
			if (found == TRUE)
			{
				HttpCommunication *comm = [[HttpCommunication alloc]init];
				comm.device_ip = cp.ip_address;

				NSString * set_mkey = SET_MASTER_KEY;
				NSString * response;
				//set_mkey =[set_mkey stringByAppendingString:self.master_key];
                set_mkey =[set_mkey stringByAppendingString:_stringAuth_token];
				BOOL master_key_sent = FALSE; 
				int retries = 10; 
				do 
				{
					response = [comm sendCommandAndBlock:set_mkey];
					
					if (response == nil)
					{
						NSLog(@"can't send master key, camera is not fully up");
                        [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Add Cameras"
                                                                           withAction:@"Get MasterKey"
                                                                            withLabel:@"Add MasterKey Failed Cause respond is nil"
                                                                            withValue:nil];
					}
					else
                    {
						NSLog(@"response: %@", response);
                        if ([response hasPrefix:@"set_master_key: 0"])
                        {
                            ///done
                            master_key_sent = TRUE;
                            NSLog(@"sending master key done");
                            
                            break;
                        }
						
					}
                    
					
					//sleep for sometime and retry 
					[NSThread sleepForTimeInterval:2];
					
				} while (retries -- >0);

                if (master_key_sent == TRUE)
                {
                    ///done
                    NSLog(@"sending master key done");
                    [self setupCompleted];
                }
               
				[comm release];
				
				return; 
			}
			else //if not found
			{
				                
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
    NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
    
    UserAccount *account = [[UserAccount alloc] initWithUser:userEmail
                                                     andPass:userPass
                                                   andApiKey:userApiKey
                                                 andListener:nil];
    
    NSString *localIp = [account query_cam_ip_online: self.cameraMac];
    
    [account release];
    
    if ( localIp != nil)
    {
        NSLog(@"Found a local ip: %@", localIp);
        HttpCommunication *comm = [[HttpCommunication alloc]init];
        comm.device_ip = localIp;
        
        NSString * set_mkey = SET_MASTER_KEY;
        NSString * response;
        //set_mkey =[set_mkey stringByAppendingString:self.master_key];
        set_mkey =[set_mkey stringByAppendingString:_stringAuth_token];
        
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
        
    }
    
    return FALSE;
}

- (void) setupCompleted
{
    //Disconnect BLE
    NSLog(@"Disconnect BLE ");
    [[BLEConnectionManager getInstanceBLE] disconnect];
    
    //Load step 12
    NSLog(@"Load step 12");
    
    //Load the next xib
    Step_12_ViewController *step12ViewController = nil;
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        
//        step12ViewController = [[Step_12_ViewController alloc]
//                                initWithNibName:@"Step_12_ViewController_ipad" bundle:nil];
//    }
//    else
    {
        step12ViewController = [[Step_12_ViewController alloc]
                                initWithNibName:@"Step_12_ViewController" bundle:nil];
    }

    [self.navigationController pushViewController:step12ViewController animated:NO];
    
    [step12ViewController release];
}

- (void)  setupFailed
{
    //Disconnect BLE
    NSLog(@"Disconnect BLE ");
    [[BLEConnectionManager getInstanceBLE] disconnect];
    
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

//Oblivion
-(void) extractMasterKey:(NSString*) raw
{
	NSArray * token_list;
	NSString * m_str; 
	//self.master_key = nil;
	token_list = [raw componentsSeparatedByString:@"<br>"];
	
	m_str = [token_list objectAtIndex:1];
	if ([m_str hasPrefix:MASTER_KEY])
	{
		NSRange m_range = {[MASTER_KEY length], 64};
		self.master_key = [NSString stringWithString:[m_str substringWithRange:m_range]];
		
		if ([self.master_key length] != 64)
		{
			NSLog(@"ERROR master key len is %d: %@", master_key.length , master_key);
            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"Add Cameras"
                                                               withAction:@"Get MasterKey"
                                                                withLabel:@"Add MasterKey Failed Cause error with masterKey length"
                                                                withValue:nil];
		}
		else {
			NSLog(@"Master key is %@",  master_key);
		}
        
	}
	
	return ; 
	
}



#pragma mark -
#pragma mark  Callbacks

- (void) addCamSuccessWithResponse:(NSDictionary *)responseData
{
    NSLog(@"addcam response: %@", responseData);
    //[self extractMasterKey:[[responseData objectForKey:@"data"] objectForKey:@"master_key"]];
    //self.master_key = [[responseData objectForKey:@"data"] objectForKey:@"master_key"];
    self.stringAuth_token = [[responseData objectForKey:@"data"] objectForKey:@"auth_token"];
    should_stop_scanning = FALSE;
    

#ifdef BLE_SETUP_CONCURRENT_MODE
    [NSTimer scheduledTimerWithTimeInterval: SCAN_TIMEOUT
									 target:self
								   selector:@selector(setStopScanning:)
								   userInfo:nil
									repeats:NO];
    
	// 2 of 3. wait for the camera to reboot completely
    [NSTimer scheduledTimerWithTimeInterval: 10.0//camera reboot time about 50secs
									 target:self
								   selector:@selector(wait_for_camera_to_reboot:)
								   userInfo:nil
									repeats:NO];
#else
    [NSTimer scheduledTimerWithTimeInterval: SCAN_TIMEOUT
									 target:self
								   selector:@selector(setStopScanning:)
								   userInfo:nil
									repeats:NO];
    
	// 2 of 3. wait for the camera to reboot completely
    [NSTimer scheduledTimerWithTimeInterval: 30.0//camera reboot time about 50secs
									 target:self
								   selector:@selector(wait_for_camera_to_reboot:)
								   userInfo:nil
									repeats:NO];
#endif

}

- (void) addCamFailedWithError:(NSDictionary *) error_response
{
    if (error_response == nil) {
        NSLog(@"error_response = nil");
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
	NSLog(@"removeCam success");
	
	//[delegate sendStatus:5 ];
	
}

-(void) removeCamFailedWithError:(NSDictionary *)error_response
{
	NSLog(@"removeCam failed Server error: %@", [error_response objectForKey:@"message"]);
}

-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
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


#pragma mark -



@end
