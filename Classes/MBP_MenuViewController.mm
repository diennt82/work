//
//  MBP_MenuViewController.m
//  MBP_ios
//
//  Created by NxComm on 5/11/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_MenuViewController.h"


@implementation MBP_MenuViewController


@synthesize cameraMenu, mPickerView;

@synthesize cameraMenuItems, cameraMenuItemValues;

@synthesize manualFWDView, manualFWDCancel,manualFWDChange, manualFWDprt80,manualFWDprt51108, manualOrAuto; 
@synthesize manualFWDSubView;

@synthesize camChan; 
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    //Read from an xml file 
	NSString *plistPath;
    
	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		delegate = nil ;
		isDirectMode = FALSE;
		
    
       
        
        
        
        plistPath = [[NSBundle mainBundle] pathForResource:@"cameraMenuRouter" ofType:@"plist"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            
            NSLog(@"FILE %@ does not exist",plistPath) ;
            
        }
        
        self.cameraMenuItems = [NSArray arrayWithContentsOfFile:plistPath];
        
    
		
		self.cameraMenuItemValues = [[NSMutableDictionary alloc]initWithCapacity:[self.cameraMenuItems count]];
		for (NSString * str in self.cameraMenuItems)
		{
			if (str != nil)
			{
				[self.cameraMenuItemValues setValue:@"" forKey:str];
			}
		}
		
		
    }
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d modeDirect:(BOOL) isDirect
{
	
	//Read from an xml file 
	NSString *plistPath;

	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		delegate = d;
		isDirectMode = isDirect;
		
		{
			
			
			

			plistPath = [[NSBundle mainBundle] pathForResource:@"cameraMenuRouter" ofType:@"plist"];
			
			if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {

				NSLog(@"FILE %@ does not exist",plistPath) ;
				
			}
			
			self.cameraMenuItems = [NSArray arrayWithContentsOfFile:plistPath];
						
		}
		
		self.cameraMenuItemValues = [[NSMutableDictionary alloc]initWithCapacity:[self.cameraMenuItems count]];
		for (NSString * str in self.cameraMenuItems)
		{
			if (str != nil)
			{
				[self.cameraMenuItemValues setValue:@"" forKey:str];
			}
		}
		
		
    }
    return self;
}




-(void) readPreferenceData
{
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
	isLoggedIn = [userDefaults boolForKey:_is_Loggedin];
	userName = [userDefaults stringForKey:_UserName];
	userPass = [userDefaults stringForKey:_UserPass];
	
	deviceInLocal = [userDefaults boolForKey:_DeviceInLocal];
	devicePort = [userDefaults integerForKey:_DevicePort];
	deviceIp = [userDefaults stringForKey:_DeviceIp];
	deviceMac = [userDefaults stringForKey:_DeviceMac];
	deivceName = [userDefaults stringForKey:_DeviceName];
	
	commMode = [userDefaults integerForKey:_CommMode]; 
	
	[self.cameraMenuItemValues setObject:deivceName forKey:_NAME_DICT_KEY];
	
	httpUserName = BASIC_AUTH_DEFAULT_USER;
	httpUserPass = [CameraPassword getPasswordForCam:deviceMac];
	
}

-(void) viewWillAppear:(BOOL)animated
{
    //check first
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

    NSLog(@"try to rotate myself");
    [self adjustViewsForOrientation:(UIInterfaceOrientation)deviceOrientation];
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self readPreferenceData];
    
        
    //Setup navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = deivceName;
	
	//setup array for picker view
	levels = [[NSArray alloc] initWithObjects:@"Level1", @"Level2", @"Level3", @"Level4", nil];
	voxlevels = [[NSArray alloc] initWithObjects:@"Disable",
				 @"Level1(Low)", @"Level2", @"Level3", @"Level4 (High)", nil];
	temperature = [[NSArray alloc] initWithObjects:@"Fahrenheit",@"Celsius",nil];
	videoQuality = [[NSArray alloc] initWithObjects:@"High Quality (VGA)",@"Normal Quality (QVGA)",nil]; 
	
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	BOOL gotoSubMenu = [userDefaults boolForKey:_to_SubMenu];
//	
//	if (gotoSubMenu == TRUE)
//	{
//		//Read data and setup sub menu now.. 
//	}
//	else {
//		//setup main menu .. 
//	}

	

    
    
	if (commMode == COMM_MODE_STUN)
	{
#if 0
		dev_s_comm = [[StunCommunication alloc] initWithIp:deviceIp
													  port:devicePort
													 lPort:xxxx]; 
		
#endif 
		NSLog(@"com mode STUN"); 
		[self setupStunConnectionToMac:deviceMac];
		
	}
	else 
	{
		dev_comm = [[HttpCommunication alloc] init];
		dev_comm.device_ip = deviceIp;
		dev_comm.device_port = devicePort;
		
		[self setupSubMenu];
	
	}
	
}




-(void) setupStunConnectionToMac:(NSString *) mac 
{
	NSString * _mac = [Util	strip_colon_fr_mac:mac];
	NSLog(@"call setup dummy stun connection:%@", _mac); 
	
	CamChannel * dummy = [[CamChannel alloc]init]; 
	dummy.channID = 0; 
	dummy.channel_index = 1; 
	dummy.communication_mode = COMM_MODE_STUN; 
	dummy.profile = [[CamProfile alloc]initWithMacAddr:_mac];
	dummy.profile.name = @"dummy"; 
	
	
	
	
	//setup remote camera via upnp 
	
	RemoteConnection * cameraConn;
	
	
	cameraConn = [[RemoteConnection alloc]init]; 
	if ([cameraConn connectToRemoteCamera:dummy
								 callback:self
								 Selector:@selector(remoteConnectionSucceeded:)
							 FailSelector:@selector(remoteConnectionFailed:)])
	{
		//the process started successfuly
	}
	else 
	{
		NSLog(@"Start remote connection Failed!!!"); 
		//ERROR condition
		UIAlertView *_alert = [[UIAlertView alloc]
							   initWithTitle:@"Remote View Error"
							   message:@"Initializing remote connection failed, please retry" 
							   delegate:self
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
		[_alert show];
		[_alert release];
	}		
}


/**/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
    // ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
	//		(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}








- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) 
    {
  

        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        background.transform = transform;
        background.frame = CGRectMake(0,0, 480,320);
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        background.transform = transform;
        background.frame = CGRectMake(0,0, 320,480);

    }
  
    
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
    

	[cameraMenu release];

	
	[cameraMenuItems release];
	[cameraMenuItemValues release];
	[super dealloc];
}


#pragma mark Remote Connection Callbacks

-(void) remoteConnectionSucceeded:(CamChannel *) camChannel
{
	
	//Start to display this channel
	camChan = camChannel;
	
	NSLog(@"Remote camera-channel is %d with cam name: %@", camChan.channel_index, camChan.profile.name);
	//create a stream to this channel;
	
	
	
	dummy_streamer = [[MBP_Streamer alloc]initWithIp:camChan.profile.ip_address 
									   andPort:camChan.profile.port
									   handler:self ];
	dummy_streamer.remoteView = TRUE;
	dummy_streamer.remoteViewKey = camChan.remoteViewKey; 
	dummy_streamer.communication_mode = COMM_MODE_STUN;
	dummy_streamer.local_port = camChan.localUdtPort; 
	
	
	[dummy_streamer startUdtStream]; 
	

	dev_s_comm = [[StunCommunication alloc] initWithIp:camChan.profile.ip_address
												  port:camChan.profile.port
												 lPort:camChan.localUdtPort]; 
	

	
	
}

-(void) remoteConnectionFailed:(CamChannel *) camChannel
{
	//camChannel = nil 
	
	NSLog(@"Remote connection Failed!!!");
}



#pragma mark -
#pragma mark StreamerEventHandler

-(void) statusReport:(int) status andObj:(NSObject*) obj
{
	
	
	switch (status) {
		case STREAM_STARTED:
		{
			
			
			break;
		}
		case STREAM_STOPPED:
			break;
		case STREAM_STOPPED_UNEXPECTEDLY:
		{
			
			
			break;
		}
		case REMOTE_STREAM_STOPPED_UNEXPECTEDLY:
		{
			
			break;
		}
		case STREAM_RESTARTED:
			break; 
		default:
			break;
	}
}
#pragma mark -

- (void) setupSubMenu
{
	
	//1. setup title bar with name
	
	
	//2.query camera settings 
	[self updateVoxStatus];
	[self updateBrightnessLvl];
	[self updateTemperatureConversion];
	[self updateVolumeLvl];
	[self updateVQ];
	if (isDirectMode == TRUE)
	{
		[self updateCamPass];
	}
	
	//reload table 
	[self.cameraMenu reloadData];
	
}

-(void) updateCamPass
{
	NSString * camPass = [CameraPassword getPasswordForCam:deviceMac]; 
	if (camPass == nil)
	{
		camPass = @"000000";
	}
	[self.cameraMenuItemValues setValue:camPass forKey:_CAMPASS_DICT_KEY];
}


- (void) updateVoxStatus
{
	NSString * response, * command;
	command = VOX_STATUS;
	response = [dev_comm sendCommandAndBlock:command];
	
	if ( (response != nil)  && [response hasPrefix:VOX_STATUS])
	{
		NSString * str_value = [response substringFromIndex:([VOX_STATUS length] + 2)];
		
		int vox_status  = [str_value intValue];
		if (vox_status == 0)
		{
			//vox disabled
			voxLevel = 0;
			[self.cameraMenuItemValues setValue:@"Disabled" forKey:_VOX_DICT_KEY];
			return;
		}
	}
	
	
	command = VOX_GET_THRESHOLD;
	response = [dev_comm sendCommandAndBlock:command];
	if ( (response != nil)  && [response hasPrefix:VOX_GET_THRESHOLD])
	{
		NSString * str_value = [response substringFromIndex:([VOX_GET_THRESHOLD length] + 2)];
		
		int vox_value  = [str_value intValue];
		
		NSString * lvl = @"-1"; 
		
		switch(vox_value)
		{
			case -10:
				lvl = @"Level 1(low)";
				voxLevel = 1;
				break;
			case -20:
				lvl = @"Level 2";
				voxLevel = 2;
				break;
			case -30:
				lvl = @"Level 3";
				voxLevel = 3;
				break;
			case -38:
				lvl = @"Level 4(High)";
				voxLevel = 4;
				break;
			default:
				break;
		}
		
		
		
		[self.cameraMenuItemValues setValue:lvl forKey:_VOX_DICT_KEY];


	}
	
}


- (void) updateTemperatureConversion
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	tempunit = [userDefaults integerForKey:_tempUnit];
	
	
	switch (tempunit) {
		case 0://F
			[self.cameraMenuItemValues setValue:@"\u00B0F" forKey:_TEMP_DICT_KEY]; 
			break;
		case 1:
			[self.cameraMenuItemValues setValue:@"\u00B0C" forKey:_TEMP_DICT_KEY]; 
			break;
		default:
			break;
	}
	
}


- (void) updateVQ
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	videoQ =[userDefaults integerForKey:@"int_VideoQuality"];

	[self.cameraMenuItemValues setValue:[videoQuality objectAtIndex:videoQ]
								 forKey:_VIDEO_DICT_KEY];
}

- (void) updateVolumeLvl
{
	NSString * response, * command;
	command = GET_VOLUME;
	response = [dev_comm sendCommandAndBlock:command];
	
	if ( (response != nil)  && [response hasPrefix:GET_VOLUME])
	{
		NSString * str_value = [response substringFromIndex:([GET_VOLUME length] + 2)];
		
		int bright  = [str_value intValue];
		
		if (bright >0)
		{
			bright = (bright -1)/25 ; 
		}
		
		
		
		NSString * lvl = nil; 
		switch(bright)
		{
			case 0:
				lvl = @"Level 1";
				break;
			case 1:
				lvl = @"Level 2";
				break;
			case 2:
				lvl = @"Level 3";
				break;
			case 3:
				lvl = @"Level 4";
				break;
			default:
				break;
		}
		
		if (lvl != nil)
		{
			volLevel = bright;
			//vox disabled
			[self.cameraMenuItemValues setValue:lvl forKey:_VOL_DICT_KEY];
			
		}
	}
}
- (void) updateBrightnessLvl
{
	NSString * response, * command;
	command = GET_BRIGHTNESS_VALUE;
	response = [dev_comm sendCommandAndBlock:command];
	
	if ( (response != nil)  && [response hasPrefix:GET_BRIGHTNESS_VALUE])
	{
		NSString * str_value = [response substringFromIndex:([GET_BRIGHTNESS_VALUE length] + 2)];
		
		int bright  = [str_value intValue];
		
		bright = bright/2 ; 
		NSString * lvl = nil; 
		switch(bright)
		{
			case 0:
				lvl = @"Level 1";
				break;
			case 1:
				lvl = @"Level 2";
				break;
			case 2:
				lvl = @"Level 3";
				break;
			case 3:
				lvl = @"Level 4";
				break;
			default:
				break;
		}
		
		if (lvl != nil)
		{
			brightLevel = bright;
			//vox disabled
			[self.cameraMenuItemValues setValue:lvl forKey:_BR_DICT_KEY];
	
		}
	}
	
	
	
}


#pragma mark -
#pragma mark TableView Datasource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int tag = tableView.tag; 

	switch (tag)
	{
		case MAIN_MENU_TAG:
			return 1;			
		case CAM_MENU_TAG:
			return 1; 
			break;
		default:
			break;
	}
	
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag; 


	switch (tag)
	{
		case MAIN_MENU_TAG:
			return 0;			
		case CAM_MENU_TAG:
             NSLog(@"row: %d",  [self.cameraMenuItems  count]);
			return [self.cameraMenuItems  count];
			break;
		default:
			break;
	}
	
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	UITableViewCell *cell  = nil;
	int tag = tableView.tag; 
    if (tag == CAM_MENU_TAG)
	{
		static NSString *CellIdentifier1 = @"CamMenuCell";
		UILabel * label, * value;
		int label_width; 

		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		

		
		if (cell == nil) {

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										    reuseIdentifier:CellIdentifier1] autorelease];
            
            NSLog(@"create new");
		}
		else {

            NSLog(@"re use");
            
			//Clear old data incase of reuse
			NSArray * arr = [cell.contentView subviews];
			
			for (int i =0; i< [arr count]; i++)
			{
				[(UIView *)[arr objectAtIndex:i] removeFromSuperview];
			}
		}

	
		
		// Configure the cell...
		
		cell.contentView.frame= CGRectMake(0, 0, self.cameraMenu.frame.size.width,cell.contentView.frame.size.height);
	
		label_width = self.cameraMenu.frame.size.width/2;
	
		label= [[UILabel alloc] initWithFrame:CGRectMake(0,0, label_width, 
														 cell.contentView.frame.size.height)];
		label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
		/*
		label.text = [Internationalization get:[[self.cameraMenuItems allKeys] objectAtIndex:indexPath.row]
										 alter:[[self.cameraMenuItems allKeys] objectAtIndex:indexPath.row]];
		
		*/
		label.text =[self.cameraMenuItems objectAtIndex:indexPath.row];
		

		
		value = [[UILabel alloc] initWithFrame:CGRectMake(label_width,0, label_width, 
														  cell.contentView.frame.size.height)];
		value.adjustsFontSizeToFitWidth = YES;
		/*
		value.text = [Internationalization get:[[self.cameraMenuItems allValues] objectAtIndex:indexPath.row]
										 alter:[[self.cameraMenuItems allValues] objectAtIndex:indexPath.row]];
		 */
		
		value.text = [self.cameraMenuItemValues  objectForKey:label.text];
        value.textColor = [UIColor whiteColor];
        value.backgroundColor = [UIColor clearColor];

        //[cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:label];
		[cell.contentView addSubview:value];
	}

	
	
	
   return cell;
}


#pragma mark -
#pragma mark TableView Delegate  

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	int tag = tableView.tag; 
	
	if (tag == CAM_MENU_TAG)
	{
		if (isDirectMode)
		{
			//SHOULD NOT BE HERE
			
			
		}
		else //router mode
		{
			switch (indexPath.row) {
				case 0 : //name
					[self onName ];
					break;
				case 1 : //vol
					[self onVol];
					break;
				case 2 ://brightness
					[self onBright];
					break;
				case 3 ://vox
					[self onVox];
					break;
				case 4 :// temp
					[self onTemp];
					break;
				case 5 ://video Quality
					[self onVQ];
					break;

				case 6 ://remove this camera
					[self onRemoveCamera];
					break;

				case 7 ://information
					[self onInformation];
					break;
				
				default:
					break;
			}
		}

		
	}
	
	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark Handle Menu selection


- (void) showDialog:(int) dialogType
{
	switch (dialogType) {
		case DIALOG_IS_NOT_REACHABLE:
		{
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:@"Camera is not reachable" 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case DIALOG_CANT_RENAME:
		{
			NSString * msg =@"Unable to rename this camera. Please log-in and try again";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_NAME_CANT_BE_EMPTY:
		{
			NSString * msg =@"Camera name cant be empty, please try again";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			alert.tag = ALERT_NAME_CANT_BE_EMPTY; 
			[alert show];
			[alert release];
			break;
		}
		case ALERT_REMOVE_CAM:
		{
			// isLoggedIn - true  deviceInLocale - false -- remove online
			// isLoggedIn - fase - need to login 
			// isLoggedIn - true   deviceInLocal - true -- remove camera(on/offline)
			
			if (isLoggedIn == FALSE)
			{ 
				//cant' remove 
				NSString * msg =@"Camera name can't be removed, please log-in";
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle:@""
									  message:msg 
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
				
			}
			else {
				
				if (deviceInLocal)
				{
					
					NSString * msg =@"Please confirm that you want to remove this camera from your account. This action will also switch your camera to direct mode.";
					UIAlertView *alert = [[UIAlertView alloc]
										  initWithTitle:@""
										  message:msg 
										  delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK",nil];
					alert.tag = ALERT_REMOVE_CAM_LOCAL; 
					[alert show];
					[alert release];

				}
				else
				{
					NSString * msg =@"Please confirm that you want to remove this camera from your account. The camera is not accessible right now, it will not be switched to direct mode. Please refer to FAQ to reset it manually.";
					UIAlertView *alert = [[UIAlertView alloc]
										  initWithTitle:@""
										  message:msg 
										  delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK",nil];

					alert.tag = ALERT_REMOVE_CAM_REMOTE; 
					[alert show];
					[alert release];
				}
				
			}

			break;
		}

		case ALERT_MANUAL_FWD_MODE:
		{
			NSString * msg =@"Camera is in manual port forwarding mode, please check \"Router Port Forwarding Settings\" for more info";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			break;
		}
		case ALERT_UPNP_OK:
		{
			NSString * msg =@"Camera has successfully opened ports on router";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_UPNP_NOT_OK:
		{
			NSString * msg =@"UPNP is not enabled (or not supported) by router. Please enable UPNP on router.";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_UPNP_RUNNING:
		{
			NSString * msg =@"Camera is still in the process of running UPNP, please check again later";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_EMPTY_PORTS:
		{
			NSString * msg =@"Ports can't be empty, please enter a valid port";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}	

		case ALERT_INVALID_PORTS:
		{
			NSString * msg =@"Port has to be in the range (1024-65535)";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}	
		case ALERT_NEED_LOGIN:
		{
			NSString * msg =@"You need to login to carry out this operation";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}	
		case ALERT_PASS_CANT_BE_EMPTY_NOR_DEFAULT:
		{
			NSString * msg =@"Password can't be empty or the same as default password.Please try again";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			alert.tag = ALERT_PASS_CANT_BE_EMPTY_NOR_DEFAULT;
			[alert show];
			[alert release];
			break;
		}		
			

		case ALERT_CHANGE_PASS_FAILED:
		{
			NSString * msg =@"Password changed failed. Please try again later";
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}		

		default:
			break;
	}
}

- (void)onName
{ 
	if (userName == nil || userPass == nil ||
        isLoggedIn == FALSE)
	{
		[self showDialog:DIALOG_CANT_RENAME];
		return;
	}
	
	[self askForNewName];
	
}





- (void) askForNewName 
{
	
	UIAlertView * _myAlert = nil;
	
	_myAlert = [[UIAlertView alloc] initWithTitle:@"Change Camera Name" 
										  message:@"Please enter new name for this camera\n\n" 
										 delegate:self 
								cancelButtonTitle:@"Cancel"
								otherButtonTitles:@"Ok", 
				nil];
	_myAlert.tag = ALERT_CHANGE_NAME; //used for tracking later 

    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 75.0, 220.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = @"New Name";
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.textColor = [UIColor blackColor];
    myTextField.delegate = self;
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    [_myAlert addSubview:myTextField];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    
	
}

-(void) onViewAngle
{
	if (deviceIp == nil )
	{
		[self showDialog:DIALOG_IS_NOT_REACHABLE];
		return;
	}
	
	[self viewAnglePopup];
}



- (void) viewAnglePopup 
{
	
	UIAlertView * _myAlert = nil;
	
	_myAlert = [[UIAlertView alloc] initWithTitle:@"Change Camera Angle" 
										  message:@"Flip the camera angle by 180 degree?" 
										 delegate:self 
								cancelButtonTitle:@"Cancel"
								otherButtonTitles:@"Ok", 
				nil];
	_myAlert.tag = ALERT_CHANGE_ANGLE; //used for tracking later 
	[_myAlert show];
	[_myAlert release];
	
	
}


-(void) onInformation
{
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	NSString * response, * command;
	command = GET_VERSION;
	response = [dev_comm sendCommandAndBlock:command];
	NSString * version = nil; 
	
	if ( (response != nil)  && [response hasPrefix:GET_VERSION])
	{
		version = [response substringFromIndex:([GET_VERSION length] + 1)];
	}
	
	
	if( version!=nil && [version hasPrefix:@"-1"])
	{    
		version = @"Unknown";
	}    
	
	
	NSString * bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	
	NSString * information = [NSString stringWithFormat:@"Motorola Baby Monitor\nApplication version: %@\nFirmware version:%@,\nMotorola \u00A9 All rights Reserved.\nCamera address:%@",bundleVersion, version, deviceIp];
	
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Information"
						  message:information
						  delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];

	
	
}



-(void) onVol
{
	
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	//SET picker view tag 
	self.mPickerView.tag = VOL_LEVEL_PICKER;
	self.mPickerView.hidden = NO;
	[self.mPickerView reloadAllComponents];
	[self.mPickerView selectRow:volLevel inComponent:0 animated:NO];
	
}


-(void) onBright
{
	
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	//SET picker view tag 
	self.mPickerView.tag = BRIGHTNESS_LEVEL_PICKER;
	self.mPickerView.hidden = NO;
	[self.mPickerView reloadAllComponents];
	[self.mPickerView selectRow:brightLevel inComponent:0 animated:NO];
}

-(void) onVox
{
	
	
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	//SET picker view tag 
	self.mPickerView.tag = VOX_LEVEL_PICKER;
	self.mPickerView.hidden = NO;
	[self.mPickerView reloadAllComponents];
	[self.mPickerView selectRow:voxLevel inComponent:0 animated:NO];
}

-(void) onTemp
{
	self.mPickerView.tag = TEMP_UNIT_PICKER;
	self.mPickerView.hidden = NO;
	[self.mPickerView reloadAllComponents];
	[self.mPickerView selectRow:tempunit inComponent:0 animated:NO];
}

-(void) onVQ
{
	self.mPickerView.tag = VQ_PICKER;
	self.mPickerView.hidden = NO;
	[self.mPickerView reloadAllComponents];
	[self.mPickerView selectRow:videoQ inComponent:0 animated:NO];
}


-(void) onRemoveCamera
{
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	[self showDialog:ALERT_REMOVE_CAM];
}


-(void) onCheckUPnpStatus
{
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	
	//may need to do in background..
	
	
	NSString * command , *response ; 
	command = GET_UPNP_PORT; 
	response = [dev_comm sendCommandAndBlock:command];
	int upnp_port = -1; 
	int upnp_status;
	
	if ( (response != nil)  && [response hasPrefix:GET_UPNP_PORT])
	{
		NSString * upnp_port_str; 
		upnp_port_str = [response substringFromIndex:([GET_UPNP_PORT length] + 2)];
		
		upnp_port = [upnp_port_str intValue];
		
	}
	
	if (upnp_port != -1 && upnp_port != 0 )
	{
		///upnp_status = MSG_MANUAL_FWD;
		[self showDialog:ALERT_MANUAL_FWD_MODE];
	}
	else
	{
		
		command = CHECK_UPNP;
		response = [dev_comm sendCommandAndBlock:command];
		
		if ( (response != nil)  && [response hasPrefix:CHECK_UPNP])
		{
			NSString * upnp_status_str; 
			upnp_status_str = [response substringFromIndex:([CHECK_UPNP length] + 2)];
			
			upnp_status = [upnp_status_str intValue];
			
		}
		

	
		switch (upnp_status) {
			case 1:
				[self showDialog:ALERT_UPNP_OK];
				break;

			case 0:
				[self showDialog:ALERT_UPNP_NOT_OK];
				break;
			case 2:
				[self showDialog:ALERT_UPNP_RUNNING];
				break;
				
			default:
				break;
		}
		

		
	}
		
	
	
}

-(void) onManualPortFwd
{
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	
	//may need to do in background..
	
	BOOL camera_upnp_status_auto;
	NSString * command , *response ; 
	command = GET_UPNP_PORT; 
	response = [dev_comm sendCommandAndBlock:command];
	int upnp_port = -1; 

	int camera_fwd_port_AV, camera_fwd_port_PTT; 
	
	if ( (response != nil)  && [response hasPrefix:GET_UPNP_PORT])
	{
		NSString * upnp_port_str; 
		upnp_port_str = [response substringFromIndex:([GET_UPNP_PORT length] + 2)];
		
		upnp_port = [upnp_port_str intValue];
	
		
		if (upnp_port == 0) 
		{
			camera_upnp_status_auto = TRUE;
		}
		else if (upnp_port >0)
		{
			camera_upnp_status_auto = FALSE;
			camera_fwd_port_AV = (upnp_port>>16) & 0xFFFF;
			camera_fwd_port_PTT = upnp_port & 0xFFFF;
			
		}
	}
	
	[self.view addSubview:self.manualFWDView];
	
	if (camera_upnp_status_auto == TRUE)
	{
		self.manualOrAuto.selectedSegmentIndex = 0; 
		self.manualFWDSubView.hidden = YES;
	}
	else 
	{
		self.manualOrAuto.selectedSegmentIndex = 1; 
		self.manualFWDSubView.hidden = NO;
		
		[self.manualFWDprt80 becomeFirstResponder];
		[self.manualFWDprt51108 becomeFirstResponder];
		
		[self.manualFWDprt80 setText:[NSString stringWithFormat:@"%d",camera_fwd_port_AV]];
		[self.manualFWDprt51108 setText:[NSString stringWithFormat:@"%d",camera_fwd_port_PTT]];
		
	}

}

-(void) onChangePassword
{
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}

	
	[self askForNewPassword];
	
}



- (void) askForNewPassword 
{
	
	UIAlertView * _myAlert = nil;
    
	
	_myAlert = [[UIAlertView alloc] initWithTitle:@"Change Camera Password" 
										  message:@"Please enter new password for this camera.\nPassword has to be 6 characters.\n\n" 
										 delegate:self 
								cancelButtonTitle:@"Cancel"
								otherButtonTitles:@"Ok", 
				nil];
	_myAlert.tag = ALERT_CHANGE_CAMPASS; //used for tracking later 
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 75.0, 220.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = @"Password";
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.textColor = [UIColor blackColor];
    myTextField.delegate = self;
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    [_myAlert addSubview:myTextField];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    
    
	
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}




#pragma mark -
#pragma mark Handle Button 

-(IBAction) handleButtonPress:(id)sender
{
	int tag = ((UIView *) sender).tag; 
	
	switch (tag ) {
		case 100:
			if (self.manualOrAuto.selectedSegmentIndex == 0)
			{
				self.manualFWDSubView.hidden = YES;
			}
			else {
				self.manualFWDSubView.hidden = NO; 
			}


			
			
			break;
		case 101: //cancel;
			[self.manualFWDView removeFromSuperview];
			break;
		case 102: //change
		{
			NSString *  param_1;
			if ([self.manualOrAuto isEnabledForSegmentAtIndex:0] )
			{
				//automatic
				param_1 =@"0";
			}
			else 
			{
				//manual
				
				if ( [self.manualFWDprt80.text length] == 0 ||
					 [self.manualFWDprt51108.text length] == 0)
				{
					[self showDialog:ALERT_EMPTY_PORTS];
				}
				
				int port80 = [self.manualFWDprt80.text intValue];
				int port51108 = [self.manualFWDprt51108.text intValue];
				
				if (  (port80 < 1024 && port80 >65535 ) ||
					(port51108 < 1024 && port51108 >65535 ))
				{
					[self showDialog:ALERT_INVALID_PORTS];
				}					
				
				
				param_1 =[NSString stringWithFormat:@"%x%x", port80, port51108];
			}
			
			
			NSString * command = SET_UPNP_PORT;
			command = [command stringByAppendingFormat:@"%@%@", 
					   SET_UPNP_PORT_PARAM_1, param_1];
			

			//Dont block here because set_upnp_port&setup=0 will not response -- crap
			[dev_comm sendCommand:command];
			
			[self.manualFWDView removeFromSuperview];			
			break;
		}
		case 110: //BacK
		{
			[delegate sendStatus:6 ];
			break;
		}	
		default:
			break;
	}
}

#pragma mark -
#pragma mark Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	int tag = alertView.tag ;
	
	if (tag == ALERT_CHANGE_NAME)
	{
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
			{
				NSString * newName = ((UITextField*)[alertView viewWithTag:10]).text;
				if( (newName == nil) || [newName length] ==0)
				{
					
					[self showDialog:ALERT_NAME_CANT_BE_EMPTY];
				}
				else {
					[self onCameraNameChanged:newName];
				}
				break;
			}
			default:
				break;
				
		}
	}
	else if (tag == ALERT_NAME_CANT_BE_EMPTY)
	{
		//any button pressed -- dont care -- just launched the alert to ask for name again
		[self askForNewName];
	}
	else if (tag == ALERT_CHANGE_ANGLE)
	{
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
			{
				NSString * command = FLIP_IMAGE;
				[dev_comm sendCommandAndBlock:command];
				
				break;
			}
			default:
				break;
				
		}
	}
	else if (tag == ALERT_REMOVE_CAM_LOCAL)
	{
		if (buttonIndex == 1)
		{
			[self onCameraRemoveLocal];
		}
	}
	else if (tag == ALERT_REMOVE_CAM_REMOTE)
	{
		
		if (buttonIndex == 1)
		{
			[self onCameraRemoveRemote];
		}
		
	}
	else if (tag == ALERT_CHANGE_CAMPASS)
	{
		if (buttonIndex == 1) 
		{
			NSString * newPass =  ((UITextField*)[alertView viewWithTag:10]).text;
			if( (newPass == nil) || 
			   ([newPass length] !=6) ||
			   [newPass isEqualToString:BASIC_AUTH_DEFAULT_PASS])
			{
				
				[self showDialog:ALERT_PASS_CANT_BE_EMPTY_NOR_DEFAULT];
			}
			else {
				[self onCameraPassChanged:newPass];
			}

		}

	}
	else if (tag == ALERT_PASS_CANT_BE_EMPTY_NOR_DEFAULT)
	{
		[self askForNewPassword];
	}
	
}


#pragma mark -
#pragma mark Picker view 
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	switch (pickerView.tag ) {
		case VOL_LEVEL_PICKER:
			[self onSetVolumeLevel:row+1];
			pickerView.hidden = YES;//close it now 
			break;
		case BRIGHTNESS_LEVEL_PICKER:
			[self onSetBrightnessLevel:row+1];
			pickerView.hidden = YES;
			break;
		case VOX_LEVEL_PICKER:
			[self onSetVoxLevel:row];
			pickerView.hidden = YES;
			break;
		case TEMP_UNIT_PICKER:
			[self onSetTempUnit:row];
			pickerView.hidden = YES;
			break;
		case VQ_PICKER:
			[self onSetVideoQuality:row];
			pickerView.hidden = YES;
			break;
		default:
			break;
	}	
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
	if ( (pickerView.tag == VOL_LEVEL_PICKER) ||
		 (pickerView.tag == BRIGHTNESS_LEVEL_PICKER))
	{	
		return [levels count];
	}

	
	if  (pickerView.tag == VOX_LEVEL_PICKER)
	{
		return [voxlevels count]; 
	}
	
	
	if  (pickerView.tag == TEMP_UNIT_PICKER)
	{
		return [temperature count]; 
	}
	
	if  (pickerView.tag == VQ_PICKER)
	{
		return [videoQuality count]; 
	}
	
	
	
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
	
	if ( (pickerView.tag == VOL_LEVEL_PICKER) ||
		(pickerView.tag == BRIGHTNESS_LEVEL_PICKER))
	{	
		
		NSLog(@"level: %d --> %@", row, [levels objectAtIndex:row]);
		return [levels objectAtIndex:row];
	}
	
	if  (pickerView.tag == VOX_LEVEL_PICKER)
	{
		return [voxlevels objectAtIndex:row]; 
	}
	
	
	if  (pickerView.tag == TEMP_UNIT_PICKER)
	{
		return [temperature objectAtIndex:row];
		
	}
	
	if  (pickerView.tag == VQ_PICKER)
	{
		return [videoQuality objectAtIndex:row];
	}
	
	
   
	return nil;
}

#pragma mark -
#pragma mark Callbacks 


-(void)onCameraPassChanged: (NSString *) newpass
{
	
	NSString *command, *response; 
	
	
	command = [NSString stringWithFormat:@"%@%@%@:%@",
			   BASIC_AUTH_USR_PWD_CHANGE, 
			   BASIC_AUTH_USR_PWD_CHANGE_PARAM,
			   BASIC_AUTH_DEFAULT_USER,
			   newpass];
	response = [dev_comm sendCommandAndBlock:command];
	
	NSLog(@"changepass res: %@", response);

	if ( (response != nil)  && [response hasPrefix:BASIC_AUTH_USR_PWD_CHANGE])
	{
	
		NSString * str_value = [response substringFromIndex:([BASIC_AUTH_USR_PWD_CHANGE length] + 2)];
		
		if ( [str_value isEqualToString:@"0"])
		{
			//save camera password now 

			CameraPassword * cp = [[CameraPassword alloc] initWithMac:deviceMac 
																 User:BASIC_AUTH_DEFAULT_USER 
																 Pass:newpass];
		    [CameraPassword saveCameraPassword:cp];
		}
		else {
			[self showDialog:ALERT_CHANGE_PASS_FAILED];
		}

		
		
	}
}

-(void) goBackAndReLogin
{
    NSLog(@"Go all the way bacK");
    
    UITabBarController * root =  (UITabBarController *)[[self.navigationController viewControllers] objectAtIndex:0];
    [self.navigationController popToRootViewControllerAnimated:NO];
   
    DashBoard_ViewController * dashBoard =  (DashBoard_ViewController *)[[root viewControllers] objectAtIndex:0]; 
    
    [dashBoard forceRelogin];
}

-(void) onCameraRemoveLocal
{
	NSString * command , *response; 
	
    
    [delegate sendStatus:1];
    
	command = SWITCH_TO_DIRECT_MODE; 
	response = [dev_comm sendCommandAndBlock:command];
	
	//NSLog(@"swithToDirect res: %@", response);
	
	command = RESTART_HTTP_CMD;
	response = [dev_comm sendCommandAndBlock:command];
	//NSLog(@"restart res: %@", response);
	
	BMS_Communication * bms_comm; 
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(removeCamSuccessWithResponse:) 
											FailSelector:@selector(removeCamFailedWithError:) 
											   ServerErr:@selector(removeCamFailedServerUnreachable)];
	
	[bms_comm BMS_delCamWithUser:userName AndPass:userPass macAddr:deviceMac];
	
    //Once we're here -- have to pop back all the way to cam list 
    
    
    
}


-(void) onCameraRemoveRemote
{
	BMS_Communication * bms_comm; 
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(removeCamSuccessWithResponse:) 
											FailSelector:@selector(removeCamFailedWithError:) 
											   ServerErr:@selector(removeCamFailedServerUnreachable)];
	
	[bms_comm BMS_delCamWithUser:userName AndPass:userPass macAddr:deviceMac];
}


//callback frm alert
- (void) onCameraNameChanged:(NSString*) newName
{
	//Update BMS server with the new name;;
	
	BMS_Communication * bms_comm; 
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(changeNameSuccessWithResponse:) 
											FailSelector:@selector(changeNameFailedWithError:) 
											   ServerErr:@selector(changeNameFailedServerUnreachable)];
	
	[bms_comm BMS_camNameWithUser:userName AndPass:userPass macAddr:deviceMac camName:newName];
}

-(void) onSetVideoQuality:(int) vq
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:vq forKey:@"int_VideoQuality"];
	[userDefaults synchronize];
	
	[self updateVQ];
	[self.cameraMenu reloadData];
	
}
-(void) onSetTempUnit:(int) unit
{
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:unit forKey:_tempUnit];
	[userDefaults synchronize];
	
	[self updateTemperatureConversion];
	[self.cameraMenu reloadData];
	
	
}


-(void) onSetVoxLevel:(int) level
{
	NSString * command; 
	if (level == 0)
	{
		//disable
		command = VOX_DISABLE;
		
	}
	else {
		int vox_sensitivity; 
		switch (level)
		{
			case 1:
				vox_sensitivity = -10;
				break;
			case 2:
				vox_sensitivity = -20; 
				break;
			case 3:
				vox_sensitivity = -30;
				break;
			case 4:
				vox_sensitivity = -38;
				break;
			default:
				vox_sensitivity = -20;
				break;
		}
		command = VOX_ENABLE;
		
		[dev_comm sendCommandAndBlock:command];
		
		command = [NSString stringWithFormat:@"%@%@%d", VOX_SET_THRESHOLD, 
				   VOX_SET_THRESHOLD_VALUE, vox_sensitivity];
		
				
	}

	NSString *response; 
	
	response = [dev_comm sendCommandAndBlock:command];
	//NSLog(@"response: %@", response);
	[self updateVoxStatus];
	[self.cameraMenu reloadData];
	
}

-(void) onSetBrightnessLevel:(int) level
{
	int _level = level *2; 
	
	if (_level >8)
	{
		_level = 8;
	}
	
	//get the current level 
	NSString * response, * command;
	
	
	int bright = 0;
	do 
	{
		command = GET_BRIGHTNESS_VALUE;
		response = [dev_comm sendCommandAndBlock:command];
		if ( (response != nil)  && [response hasPrefix:GET_BRIGHTNESS_VALUE])
		{
			NSString * str_value = [response substringFromIndex:([GET_BRIGHTNESS_VALUE length] + 2)];
			
			 bright = [str_value intValue];
			
		}
		
		NSLog(@"current bright: %d, ntarget: %d", bright, _level);
		
		if (bright > _level)
		{
			command = GET_BRIGHTNESS_MINUS;
		}
		else if(bright < _level)
		{
			command = GET_BRIGHTNESS_PLUS;
		}
		else {
			break;
		}

		
		response = [dev_comm sendCommandAndBlock:command];
	
	}
	while (bright != 0);
	
	[self updateBrightnessLvl];
	[self.cameraMenu reloadData];

}


-(void) onSetVolumeLevel:(int) level
{
	int _level = level *25; 
	
	if (_level >100)
	{
		_level = 100; 
	}
	
	
	NSString * response, * command;
	command = [NSString stringWithFormat:@"%@%@%d",SET_VOLUME, SET_VOLUME_PARAM, _level];
	response = [dev_comm sendCommandAndBlock:command];
	
	if ( (response != nil)  && [response hasPrefix:SET_VOLUME])
	{
		//Dont care about response, here -- just simply read back the volume level
	}
	
	[self updateVolumeLvl];
	[self.cameraMenu reloadData];
	
	
}

#pragma mark -
#pragma mark BMS_Communication callbacks 

-(void) removeCamSuccessWithResponse:(NSData *) responsedata
{
	NSLog(@"removeCam success-- fatality");

	//[delegate sendStatus:5 ];
    
    [self goBackAndReLogin];
	
}
-(void) removeCamFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"removeCam failed errorcode:");
}
-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
}



-(void) changeNameSuccessWithResponse:(NSData *) responsedata
{
	NSLog(@"changeName success");
}
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"changeNamed failed errorcode: ");
}
-(void) changeNameFailedServerUnreachable
{
	NSLog(@"server unreachable");
}



@end
