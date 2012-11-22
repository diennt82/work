//
//  Step_10_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/27/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_10_ViewController.h"

@interface Step_10_ViewController ()

@end

@implementation Step_10_ViewController

@synthesize  userNameLabel, userEmailLabel,progressView ;
@synthesize  cameraMac, master_key; 
@synthesize setupFailView,setupCompleteView,  cameraName; 

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
    //[setupCompleteView release];
    //[setupFailView release];
    //[cameraName release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //can be user email or user name here --  
    self.userNameLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUsername"];	
    self.userEmailLabel.text = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    self.cameraMac = (NSString *) [userDefaults objectForKey:@"CameraMacWithQuote"];
    
    
    if (self.cameraMac == nil)
    {
        NSLog(@"Empty Camera mac !!!"); 
    }
    
    if (self.progressView == nil)
    {
        NSLog(@"progressView = nil!!!!");
    }
    
    
    
    
    
    BOOL firstime = [userDefaults boolForKey:FIRST_TIME_SETUP];
    
    
    //Check to see which path we should go 
    if (firstime == TRUE)
    {  
        // Do any additional setup after loading the view.
        
        self.navigationItem.title =@"Account Created";
        self.navigationItem.hidesBackButton = YES;
        
        [self.view addSubview:self.progressView];
        self.progressView.hidden = YES;
    }
    else //not first time --> this is normal add camera sequence..
    {
        self.navigationItem.title =@"Camera Configured";

        NSLog(@"Normal Add cam sequence" );
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
        
        
        
        [self.view addSubview:self.progressView];
        self.progressView.hidden = YES;
        [self.view addSubview:cameraAddedView];
        self.homeSSID.text = homeSsid; 
        
        
        
        
        
    }
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma  mark -
#pragma mark button handlers

-(IBAction)tryAddCameraAgain:(id)sender
{
    
    //Go back to the beginning
    
    NSLog(@"RESTART aa");
    
    
    //MBP_InitialSetupViewController * initSetupController =(MBP_InitialSetupViewController *) [[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //[initSetupController startMonitorCallBack];
    
}

-(IBAction)cameraTest:(id)sender
{

#if 0 ///TEST TEST TEST 
    [self  setupFailed];
#else 

    
    self.progressView.hidden = NO; 
    [self.view bringSubviewToFront:self.progressView];
    //[self.view addSubview:self.progressView]; 
    
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
    
    
    [bms_comm BMS_addCamWithUser:user_email 
                         AndPass:user_pass 
                         macAddr:mac 
                         camName:camName];
    
#endif
    
}

-(IBAction)starMonitor:(id)sender
{
    NSLog(@"START MONITOR");
    
   
    MBP_InitialSetupViewController * initSetupController =(MBP_InitialSetupViewController *) [[self.navigationController viewControllers] objectAtIndex:0];
     [self.navigationController popToRootViewControllerAnimated:NO];
    
    [initSetupController startMonitorCallBack];
}


#pragma  mark -
#pragma mark Timer callbacks

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
				
				int retries = 10; 
				do 
				{
					response = [comm sendCommandAndBlock:set_mkey];
					
					if (response == nil)
					{
						NSLog(@"can't send master key, camera is not fully up"); 
					}
					else {
						NSLog(@"response: %@", response);
						break; 
					}
                    
					
					//sleep for sometime and retry 
					[NSThread sleepForTimeInterval:2];
					
				} while (retries -- >0);
				
				
				
				
				///done
				NSLog(@"sending master key done");
				[self setupCompleted];
				
				
				
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
            ///done
            NSLog(@"sending master key done");
            [self setupCompleted];
            return TRUE;
        }
        
    }

    return FALSE;
    
}

- (void) setupCompleted
{
	self.progressView.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
    //Step 12
    [[NSBundle mainBundle] loadNibNamed:@"Setup_bm_step_12"
                                  owner:self
                                options:nil];
    
    [self.view addSubview:self.setupCompleteView];

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.cameraName.text =  (NSString *) [userDefaults objectForKey:@"CameraName"];
    self.navigationItem.title = @"Setup Complete";
}


- (void)  setupFailed
{
	self.progressView.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
	
	NSLog(@"Setup has failed - remove cam on server"); 
	// send a command to remove camera 
	NSString * mac = [Util strip_colon_fr_mac:self.cameraMac];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
	
	BMS_Communication * bms_comm; 
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(removeCamSuccessWithResponse:) ///TEST
											FailSelector:@selector(removeCamFailedWithError:) 
											   ServerErr:@selector(removeCamFailedServerUnreachable)];
	
	[bms_comm BMS_delCamWithUser:user_email AndPass:user_pass macAddr:mac];
	
    self.navigationItem.title = @"Add Camera Failed";
    
    //Step 11 
    [[NSBundle mainBundle] loadNibNamed:@"Setup_bm_step_11" 
                                  owner:self 
                                options:nil];

    
    UIScrollView *tempScrollView=(UIScrollView *) [self.setupFailView viewWithTag:1];
    tempScrollView.contentSize=CGSizeMake(320,400);
    
    [self.view addSubview:self.setupFailView];
    
    
    
    
    
    
    
    
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
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"AddCam Error"
						  message:[NSString stringWithFormat:@"Server error: %@", [BMS_Communication getLocalizedMessageForError:[error_response statusCode]]]
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    [self  setupFailed];
    
	return;
	
}
- (void) addCamFailedServerUnreachable
{
	NSLog(@"addcam failed : server unreachable");
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"AddCam Error"
						  message:@"Server unreachable"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    [self  setupFailed];
	
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





@end
