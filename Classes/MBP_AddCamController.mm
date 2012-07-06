//
//  MBP_AddCamController.m
//  MBP_ios
//
//  Created by NxComm on 5/2/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_AddCamController.h"


@implementation MBP_AddCamController

@synthesize step_1View, step_2View;
@synthesize connect, progress, progressView; 
@synthesize homeWifiSSID, cameraMac, cameraName, master_key; 
@synthesize finishView; 

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		delegate = d;
    }
    return self;
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	//Quickly remember the Home SSID
	self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
	[Util setHomeSSID:self.homeWifiSSID];
	NSLog(@"homessid is: %@", self.homeWifiSSID);
	
	// enable the progress indicator 
	self.progress.hidden = NO; 
	[self.progress startAnimating];
	
	step_1View.frame = CGRectMake(0, 0, 480, 320);
	step_1View.contentSize = CGSizeMake(480, 1194);
	
	task_cancelled = NO;
	
	[NSTimer scheduledTimerWithTimeInterval: 2 // 
									 target:self
								   selector:@selector(connectedToRabot:)
								   userInfo:nil
									repeats:NO];
}


/**/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
		 (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[connect release];
	[progress release];
	[step_1View release];
	[homeWifiSSID release];
	[cameraMac release];
	[master_key release];
}


- (void) setupCompleted
{
	self.progressView.hidden = YES; 

	[[NSBundle mainBundle] loadNibNamed:@"MBP_AddCamController_3" 
								  owner:self 
								options:nil];
	
	[self.view addSubview:finishView];
	
	
	// wait for about 2 secs then move on 
	[NSTimer scheduledTimerWithTimeInterval: 2 // 
									 target:self
								   selector:@selector(goToReLogin:)
								   userInfo:nil
									repeats:NO];
}


- (void)  setupFailed
{
	self.progressView.hidden = YES;
	
	
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
	
	[[NSBundle mainBundle] loadNibNamed:@"MBP_AddCamController_4" 
								  owner:self 
								options:nil];
	
	[self.view addSubview:finishView];
	
}

#pragma mark Timer callbacks 


- (void) wait_for_camera_to_reboot:(NSTimer *)exp
{
	num_scan_time --; 
	
	if (num_scan_time < 0)
	{
		//reach the scanning limit.. simply give up now.
		//TODO: error handling 
		NSLog(@" max scanning time reached.. stop now");
		[self setupFailed];
		return ; 
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


- (void) connectedToHomeWifi:(NSTimer *) expired
{
	
#if TARGET_IPHONE_SIMULATOR != 1
	NSString * bc1 = @"";
	NSString * own1 = @"";
	[MBP_iosViewController getBroadcastAddress:&bc1 AndOwnIp:&own1];
	//check for ip available before check for SSID to avoid crashing .. 
	if ([own1 isEqualToString:@""])
	{
		NSLog(@"IP is not available.. comeback later..");
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(connectedToHomeWifi:)
									   userInfo:nil
										repeats:NO];	
		return; 
	}
#endif
	
	
	
	
	
#if TARGET_IPHONE_SIMULATOR == 1
	NSString * currentSSID = @"NX-BROADBAND";
#else 
	NSString * currentSSID = [CameraPassword fetchSSIDInfo];
#endif 
 	NSLog(@"current SSID: %@ ", currentSSID);
	
	
	
#if TARGET_IPHONE_SIMULATOR == 0
	if ([currentSSID isEqualToString:self.homeWifiSSID])
#endif
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
#if TARGET_IPHONE_SIMULATOR == 1
		if ([own hasPrefix:@"192.168.5."])
		{
			NSLog(@"ip:%@", currentSSID, own );
			//We got the ip too.. proceed to enable the "next" btn
			[self.progress stopAnimating]; 
			self.connect.hidden = NO; 
			
			//Change the tag so that the click event is handled differently 
			self.connect.tag = STEP_2_NEXT_BTN;
			
			//dont reschedule another wake up 
			return; 
		}
#else 
		

		if (![own isEqualToString:@""])
		{
			NSLog(@"current SSID: %@ ip:%@", currentSSID, own );
			//We got the ip too.. proceed to enable the "next" btn
			[self.progress stopAnimating]; 
			self.connect.hidden = NO; 
			
			//Change the tag so that the click event is handled differently 
			self.connect.tag = STEP_2_NEXT_BTN;
			
			//dont reschedule another wake up 
			return; 
		}
#endif 
		
	}
	
	if (task_cancelled == YES)
	{
		//skip 
	}
	else
	{
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(connectedToHomeWifi:)
									   userInfo:nil
									repeats:NO];	
	}
}




- (void) connectedToRabot:(NSTimer *) expired
{
	
	
#if TARGET_IPHONE_SIMULATOR != 1
	NSString * bc1 = @"";
	NSString * own1 = @"";
	[MBP_iosViewController getBroadcastAddress:&bc1 AndOwnIp:&own1];
	//check for ip available before check for SSID to avoid crashing .. 
	if ([own1 isEqualToString:@""])
	{
		NSLog(@"IP is not available.. comeback later..");
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(connectedToRabot:)
									   userInfo:nil
										repeats:NO];	
		return; 
	}
#endif
	
	NSString * currentSSID = [CameraPassword fetchSSIDInfo];
	
	
	if ([currentSSID hasPrefix:DEFAULT_SSID_PREFIX])
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if ([own hasPrefix:DEFAULT_IP_PREFIX])
		{
			
			//We got the ip too.. proceed to enable the "next" btn
			[self.progress stopAnimating]; 
			self.connect.hidden = NO; 
			self.connect.tag = STEP_1_NEXT_BTN;
			
			//remember the mac address .. very important
			self.cameraMac = [CameraPassword fetchBSSIDInfo];
			self.cameraName = currentSSID;
			
			NSLog(@"camera mac: %@ ip:%@", self.cameraMac, own );
			
			//dont reschedule another wake up 
			return; 
		}
		
	}
	
	
	if (task_cancelled == YES)
	{
		//Don't do any thing here
		
	}
	else {
	
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(connectedToRabot:)
									   userInfo:nil
										repeats:NO];	
	}
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
					NSLog(@"camera %@ is up in home network with ip:%@", cp.ip_address); 
					
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
				//scan again .. 
			}

		}
		else //result = nil
		{
			//scan again ..
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

- (void) goToReLogin: (NSTimer *) expired
{
	
	[self dismissModalViewControllerAnimated:NO];
	[delegate sendStatus: 4];
	
}
#pragma mark Handle button press

- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	
	switch (sender_tag) {
		case STEP_1_NEXT_BTN:
		{
					
			MBP_DeviceConfigureViewController * setupController;
			setupController = [[MBP_DeviceConfigureViewController alloc] initWithNibName:@"MBP_DeviceConfigureViewController"
																				  bundle:nil
																			  withCaller:self];
			[self presentModalViewController:setupController animated:YES];
			
			break;
		}
	
		case STEP_2_NEXT_BTN:
		{
			NSLog(@" 1 mac: %@", self.cameraMac);
			//we are back to home network. 
			// 1 of 3. send the query to add camera
			
			BMS_Communication * bms_comm; 
			
			NSString * mac = [Util strip_colon_fr_mac:self.cameraMac];
#if TARGET_IPHONE_SIMULATOR == 1
			NSString * camName = @"Moto-Cam-";
#else
			NSString * camName = self.cameraName;
#endif
			
			NSLog(@"name: %@ mac: %@", camName, mac);
			
			bms_comm = [[BMS_Communication alloc] initWithObject:self
														Selector:@selector(addCamSuccessWithResponse:) 
													FailSelector:@selector(addCamFailedWithError:) 
													   ServerErr:@selector(addCamFailedServerUnreachable)];
			
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
			NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
			
			
			[bms_comm BMS_addCamWithUser:user_email 
								 AndPass:user_pass 
								 macAddr:mac 
								 camName:camName];
					
		
			//Show the progress bar.
			self.progressView.hidden = NO; 
			[self.view bringSubviewToFront:self.progressView];
			
			break;
		}
		case FINISH_BTN: ///// 20120618: not used -- 
			//Go back 
			
			[self dismissModalViewControllerAnimated:NO];
			[delegate sendStatus: 4];
			break; 
		case STEP_1_BACK_BTN:
			//cancel
			task_cancelled = YES;
			
			[self dismissModalViewControllerAnimated:NO];
			[delegate sendStatus: 4];
			
			break;
		case STEP_2_BACK_BTN:
			//cancel-- step 2 
			task_cancelled = YES;
			
			[self dismissModalViewControllerAnimated:NO];
			[delegate sendStatus: 4];
			
			break;
		default:
			break;
	}
	
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
	
	num_scan_time = 3; //can be changed later
	
	// 2 of 3. wait for the camera to reboot completely
	
	[NSTimer scheduledTimerWithTimeInterval: 50 //camera reboot time about 50secs  
									 target:self
								   selector:@selector(wait_for_camera_to_reboot:)
								   userInfo:nil
									repeats:NO];
	
	
}

- (void) addCamFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:[NSString stringWithFormat:@"Server error code: %d", [error_response statusCode]] 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	
}
- (void) addCamFailedServerUnreachable
{
	NSLog(@"Loging failed : server unreachable");
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:@"Server unreachable"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
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
	NSLog(@"removeCam failed errorcode: %d");
}
-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
}





- (void)sendStatus:(int) status
{
	switch (status) {
		case SEND_CONF_SUCCESS:

			[[NSBundle mainBundle] loadNibNamed:@"MBP_AddCamController_2" 
										  owner:self 
										options:nil];
			
			
			[self.view addSubview:step_2View];
			
			step_2View.frame = CGRectMake(0, 0, 480, 320);
			step_2View.contentSize = CGSizeMake(480, 1194);
			// enable the progress indicator 
			self.progress.hidden = NO; 
			[self.progress startAnimating];
			
			
			[NSTimer scheduledTimerWithTimeInterval: 2 // 
											 target:self
										   selector:@selector(connectedToHomeWifi:)
										   userInfo:nil
											repeats:NO];
			
			
			break;
		case SEND_CONF_ERROR:
			break; 
		default:
			break;
	}
}

@end
