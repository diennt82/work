//
//  Step_10_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_10_ViewController.h"
#import "StartMonitorCallback.h"

@interface Step_10_ViewController ()

@end

@implementation Step_10_ViewController

@synthesize  userNameLabel, userEmailLabel,progressView ;
@synthesize  cameraMac, master_key; 
@synthesize  cameraName;

@synthesize  homeSSID;


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
        
        self.navigationItem.title =NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                     @"Camera Configured" , nil);

        NSLog(@"Normal Add cam sequence" );
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
        
        
        
        [self.view addSubview:self.progressView];
        self.progressView.hidden = YES;
        [self.view addSubview:cameraAddedView];
        self.homeSSID.text = homeSsid;
        
        [NSTimer scheduledTimerWithTimeInterval: 2.0//
                                         target:self
                                       selector:@selector(checkConnectionToHomeWifi:)
                                       userInfo:nil
                                        repeats:NO];

        
        
        
        //DBG ONLY 
        //self.progressView.hidden = NO;
        //[self.view bringSubviewToFront:self.progressView];
        //self.homeSSID.text = @"homeSsid";
        
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

#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; 
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
    
    [self.navigationController pushViewController:step02ViewController animated:NO];
    
    [step02ViewController release];
    
}


-(IBAction)registerCamera:(id)sender
{
    
    
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_Communication * bms_comm;
    
    NSString * mac = [Util strip_colon_fr_mac:self.cameraMac];
#if TARGET_IPHONE_SIMULATOR == 1
    NSString * camName = @"Camera-";
#else
    
    
    NSString * camName = (NSString *) [userDefaults objectForKey:@"CameraName"];
#endif
    
    NSLog(@"name: %@ mac: %@", camName, mac);
    
    bms_comm = [[BMS_Communication alloc] initWithObject:self
                                                Selector:@selector(addCamSuccessWithResponse:)
                                            FailSelector:@selector(addCamFailedWithError:)
                                               ServerErr:@selector(addCamFailedServerUnreachable)];
    
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    
    [bms_comm BMS_addCamWithUser:user_email AndPass:user_pass macAddr:mac camName:camName];
    
}



#pragma  mark -
#pragma mark Timer callbacks

- (void) checkConnectionToHomeWifi:(NSTimer *) expired
{
    
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
			
            //CameraTest: try to search for camera now..
            [self registerCamera:nil];
            
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
				
				HttpCommunication *  comm; 
				comm = [[HttpCommunication alloc]init];
				comm.device_ip = cp.ip_address;
				
				
				
				NSString * set_mkey = SET_MASTER_KEY;
				NSString * response;
				set_mkey =[set_mkey stringByAppendingString:self.master_key];
				BOOL master_key_sent = FALSE; 
				int retries = 10; 
				do 
				{
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
               
				
				
				return; 
			}
			else //if not found
			{
				                
			}
            
		}
		else //result = nil
		{
			//scan again ..
		}

        
        if ([self checkItOnline])
        {
            //Found it online
            NSLog(@"Found it online");
            return;
        }
        else
        {
            
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
    //--> Try to search IP onlinexxxx
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    UserAccount * account = [[UserAccount alloc] initWithUser:user_email
                                                      AndPass:user_pass
                                                 WithListener: nil];
    
    NSString * localIp = [account query_cam_ip_online: self.cameraMac];
    
    if ( localIp != nil)
    {
        
        NSLog(@"Found a local ip: %@", localIp);
        HttpCommunication *  comm;
        comm = [[HttpCommunication alloc]init];
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
                [self setupCompleted];
                return TRUE;
            }
           
        }
        
    }

    return FALSE;
    
}

- (void) setupCompleted
{

    

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
 	NSLog(@"Setup has failed - remove cam on server"); 
	// send a command to remove camera 
	NSString * mac = [Util strip_colon_fr_mac:self.cameraMac];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	

	BMS_Communication * bms_comm;
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(removeCamSuccessWithResponse:)
											FailSelector:@selector(removeCamFailedWithError:) 
											   ServerErr:@selector(removeCamFailedServerUnreachable)];
	
	[bms_comm BMS_delCamWithUser:user_email AndPass:user_pass macAddr:mac];
	

    
    
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
    
    
    [self.navigationController pushViewController:step11ViewController animated:NO];
    
    [step11ViewController release];
    
        
}



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
		}
		else {
			NSLog(@"Master key is %@",  master_key);
		}
        
	}
	
	return ; 
	
}



#pragma mark -
#pragma mark  Callbacks
- (void) addCamSuccessWithResponse:(NSData*) responseData
{
	NSString * raw_data = [[[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding] autorelease];
	
	NSLog(@"addcam response: %@", raw_data);
	
	[self extractMasterKey:raw_data];
	
    should_stop_scanning = FALSE;
    
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
	
	
}

- (void) addCamFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"addcam failed with error code:%d", [error_response statusCode]);
	
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Server_error_" ,nil, [NSBundle mainBundle],
                                                       @"Server error: %@" , nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);

	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedStringWithDefaultValue(@"AddCam_Error" ,nil, [NSBundle mainBundle],
                                                                          @"AddCam Error" , nil)
						  message:[NSString stringWithFormat:msg, [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]]
						  delegate:self
						  cancelButtonTitle:ok
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    [self  setupFailed];
    
	return;
	
}


- (void) addCamFailedServerUnreachable
{
	NSLog(@"addcam failed : server unreachable");
	
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"addcam_error_1" ,nil, [NSBundle mainBundle],
                                                       @"The device is not able to connect to the server. Please check the WIFI and the internet connection", nil);
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


-(void) removeCamSuccessWithResponse:(NSData *) responsedata
{
	NSLog(@"removeCam success");
	
	//[delegate sendStatus:5 ];
	
}
-(void) removeCamFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"removeCam failed Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]);
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
