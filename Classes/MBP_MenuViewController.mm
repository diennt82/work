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


@synthesize camChan; 
@synthesize dev_s_comm ;
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
	deviceName = [userDefaults stringForKey:_DeviceName];
	
	commMode = [userDefaults integerForKey:_CommMode]; 
	
	[self.cameraMenuItemValues setObject:deviceName forKey:_NAME_DICT_KEY];
	
	httpUserName = BASIC_AUTH_DEFAULT_USER;
	httpUserPass = [CameraPassword getPasswordForCam:deviceMac];
	
}

-(void) viewWillAppear:(BOOL)animated
{
    
     NSLog(@"try to rotate myself");
	

    
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self readPreferenceData];
    
    UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
	[self adjustViewsForOrientation:infOrientation];
    
    
        
    //Setup navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = deviceName;
	
	//setup array for picker view
	levels = [[NSArray alloc] initWithObjects:@"Level1", @"Level2", @"Level3", @"Level4", nil];
	voxlevels = [[NSArray alloc] initWithObjects:
				 @"Level1(Low)", @"Level2", @"Level3", @"Level4 (High)", nil];
	temperature = [[NSArray alloc] initWithObjects:@"Fahrenheit",@"Celsius",nil];
	videoQuality = [[NSArray alloc] initWithObjects:@"Normal Quality (QVGA)",@"High Quality (VGA)",nil]; 
	
    progressView.hidden = NO; 
    [self.view bringSubviewToFront:progressView]; 
    
	if (commMode == COMM_MODE_STUN)
	{

        /*20120822: Camera settings page is on OVERLAY mode 
          This means the connection to the camera is still going on. 
        --> No need to setup a new connection here . Just simply send the command over 
         to BMS */
        
		NSLog(@"com mode STUN"); 
		//[self setupStunConnectionToMac:deviceMac];
        
        if (self.dev_s_comm == nil)
        {
            NSLog(@"ERROR no COMM channel being set"); 
        }
        
		
	}
	else 
	{
		dev_comm = [[HttpCommunication alloc] init];
		dev_comm.device_ip = deviceIp;
		dev_comm.device_port = devicePort;
		
    }
    
    
    
    //Let it delay a bit 
	[self performSelector:@selector(setupSubMenu) withObject:nil afterDelay:0.10];
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
 
    BOOL isShown = FALSE; 
    if (progressView != nil)
    {
        isShown = !progressView.isHidden;
    }
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) 
    {
  

        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        background.transform = transform;
        background.frame = CGRectMake(0,0, 480,320);
        
        [[NSBundle mainBundle] loadNibNamed:@"MBP_MenuProgress_land"
                                      owner:self
                                    options:nil];
        
        progressView.frame = CGRectMake(0, 0, 480, 320);
        
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        background.transform = transform;
        background.frame = CGRectMake(0,0, 320,480);

        [[NSBundle mainBundle] loadNibNamed:@"MBP_MenuProgress_portrait"
                                      owner:self
                                    options:nil];
        
        progressView.frame = CGRectMake(0, 0, 320  , 480);
    }
    
    [self.view addSubview:progressView];
    
    if (isShown)
    {
        
        [self.view bringSubviewToFront:progressView]; 
    }
  
    [cameraMenu reloadData];
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




#pragma mark -

- (void) setupSubMenu
{
	
	
	//2.query camera settings 
	[self updateVoxStatus];
	[self updateBrightnessLvl];
	[self updateTemperatureConversion];
	[self updateVolumeLvl];
	[self updateVQ];
	
    
	
	//reload table 
	[self.cameraMenu reloadData];
	
    
    progressView.hidden = YES; 
}



- (void) updateVoxStatus
{
	NSString * response, * command;
    
    command = VOX_STATUS;
    
    
    if (commMode == COMM_MODE_STUN)
	{
        
        NSData * response_data;
        response_data =  [self.dev_s_comm sendCommandThruUdtServer:command
                                                           withMac:camChan.profile.mac_address
                                                        AndChannel:camChan.channID];
        
        if (response_data != nil)
        {
            response = [[[NSString alloc] initWithData:response_data encoding: NSUTF8StringEncoding] autorelease];
            
        }
        else
        {
            NSLog(@"updateVoxStatus: Failed to get response via Stun Server");
        }


    }
    else
    { 
        response = [dev_comm sendCommandAndBlock:command];
    }
    
    
    if ( (response != nil)  && [response hasPrefix:VOX_STATUS])
    {
        NSString * str_value = [response substringFromIndex:([VOX_STATUS length] + 2)];
        
        int vox_status  = [str_value intValue];
        if (vox_status == 0)
        {
            //SHOULD NOT BE HERE ANY MORE..
            NSLog(@"updateVoxStatus: SHOULD NOT BE HERE ANY MORE..");
            //vox disabled
            voxLevel = 0;
            [self.cameraMenuItemValues setValue:@" " forKey:_VOX_DICT_KEY]; 
            return;
        }
    }
    
    
    command = VOX_GET_THRESHOLD;
    
    if (commMode == COMM_MODE_STUN)
	{
        
        NSData * response_data;
        response_data =  [self.dev_s_comm sendCommandThruUdtServer:command
                                                           withMac:camChan.profile.mac_address
                                                        AndChannel:camChan.channID];
        
        if (response_data != nil)
        {
            response = [[[NSString alloc] initWithData:response_data encoding: NSUTF8StringEncoding] autorelease];
            
        }
        else
        {
            NSLog(@"updateVoxStatus: Failed to get response via Stun Server");
        }
        
        
    }
    else
    {

        response = [dev_comm sendCommandAndBlock:command];
    }
    
    
    if ( (response != nil)  && [response hasPrefix:VOX_GET_THRESHOLD])
    {
        NSString * str_value = [response substringFromIndex:([VOX_GET_THRESHOLD length] + 2)];
        
        int vox_value  = [str_value intValue];
        
        NSString * lvl = @"Level 2";
        
        switch(vox_value)
        {
            case -10:
                lvl = @"Level 1(low)";
                voxLevel = 0;
                break;
            case -20:
                lvl = @"Level 2";
                voxLevel = 1;
                break;
            case -30:
                lvl = @"Level 3";
                voxLevel = 2;
                break;
            case -38:
                lvl = @"Level 4(High)";
                voxLevel = 3;
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
	NSString * response = nil, * command;
	command = GET_VOLUME;
    
    if (commMode == COMM_MODE_STUN)
	{
        NSData * response_data; 
        response_data =  [self.dev_s_comm sendCommandThruUdtServer:command 
                                                           withMac:camChan.profile.mac_address
                                                        AndChannel:camChan.channID];
        
        if (response_data != nil)
        {
            response = [[[NSString alloc] initWithData:response_data encoding: NSUTF8StringEncoding] autorelease];
            
        }
        else
        {
            NSLog(@"updateVolumeLvl:Failed to get response via Stun Server"); 
        }
        
    }
    else
    {
     
        response = [dev_comm sendCommandAndBlock:command];
    }
	
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
	NSString * response = nil , * command;
    
	command = GET_BRIGHTNESS_VALUE;
    
    if (commMode == COMM_MODE_STUN)
	{
        NSData * response_data; 
        response_data =  [self.dev_s_comm sendCommandThruUdtServer:command 
                                                           withMac:camChan.profile.mac_address
                                                        AndChannel:camChan.channID];
        
        if (response_data != nil)
        {
            response = [[[NSString alloc] initWithData:response_data encoding: NSUTF8StringEncoding] autorelease];
            
        }
        else
        {
            NSLog(@"updateBrightnessLvl:Failed to get response via Stun Server"); 
        }
        
    }
    else
    {
        
        response = [dev_comm sendCommandAndBlock:command];
        
    }
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
		UILabel * label, *value;
		int label_width; 

		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		

		
		if (cell == nil) 
        {

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										    reuseIdentifier:CellIdentifier1] autorelease];
            
            
		}
		else 
        {


            
			//Clear old data incase of reuse
			NSArray * arr = [cell.contentView subviews];
			
			for (int i =0; i< [arr count]; i++)
			{
				[(UIView *)[arr objectAtIndex:i] removeFromSuperview];
			}
		}

	
		
		// Configure the cell...
		
		cell.contentView.frame= CGRectMake(0, 0, self.cameraMenu.frame.size.width,cell.contentView.frame.size.height);
	
		label_width = self.cameraMenu.frame.size.width/2 - 2;
	
		label= [[UILabel alloc] initWithFrame:CGRectMake(2,0, label_width, 
														 cell.contentView.frame.size.height)];
		label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines =2 ; 
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
		
        value.lineBreakMode = UILineBreakModeWordWrap;
        
		value.text = [self.cameraMenuItemValues  objectForKey:label.text];
        value.textColor = [UIColor whiteColor];
        value.backgroundColor = [UIColor clearColor];
        value.numberOfLines =2 ; 

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
					
					NSString * msg =@"Please confirm that you want to remove this camera from your account. This action will also switch your camera to default settings. You will need to add the camera into your account again to use it.";
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
            
        case ALERT_CHANGE_NAME_FAILED:
		{
			NSString * msg =@"Failed to change camera name. Please try again later";
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
										  message:@"Please enter new name for this camera\n\n\n" 
										 delegate:self 
								cancelButtonTitle:@"Cancel"
								otherButtonTitles:@"Ok", 
				nil];
	_myAlert.tag = ALERT_CHANGE_NAME; //used for tracking later 

    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 90.0, 220.0, 25.0)];
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

-(void) onInformation
{
 
    progressView.hidden = NO; 
    [self.view bringSubviewToFront:progressView]; 
    
    [self performSelector:@selector(onInformation_worker) withObject:nil afterDelay:0.10];
}
-(void) onInformation_worker
{
	if (deviceIp == nil)
	{
		[self showDialog: DIALOG_IS_NOT_REACHABLE];
		return; 
	}
	
	NSString * response, * command;
	command = GET_VERSION;
    
    if (commMode == COMM_MODE_STUN)
	{
        NSData * response_data; 
        response_data =  [self.dev_s_comm sendCommandThruUdtServer:command 
                                                           withMac:camChan.profile.mac_address
                                                        AndChannel:camChan.channID];
        
        if (response_data != nil)
        {
            response = [[[NSString alloc] initWithData:response_data encoding: NSUTF8StringEncoding] autorelease];
            
        }
        else
        {
            NSLog(@"onInformation:Failed to get response via Stun Server"); 
        }
        
    }
    else
    {
        response = [dev_comm sendCommandAndBlock:command];
    }
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

    
     progressView.hidden = YES; 
	
	
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
			[self onSetBrightnessLevel:row];
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
		
		//NSLog(@"level: %d --> %@", row, [levels objectAtIndex:row]);
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
	
    deviceName = newName;
    progressView.hidden = NO;
    [self.view bringSubviewToFront:progressView];
    
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
    
    progressView.hidden = NO;
    [self.view bringSubviewToFront:progressView];
    
    
    [self performSelector:@selector(onSetVoxLevel_:)
               withObject:[[NSNumber alloc] initWithInt:level]
               afterDelay:0.10];
}

-(void) onSetVoxLevel_:(NSNumber *) lvl
{
	int level = [lvl intValue];


	NSString * command, * response ;
   
    //20121108: no longer need to disable vox on Device..
    //	if (level == 0)
    //	{
    //		//disable
    //		command = VOX_DISABLE;
    //
    //	}else
    
    
    int vox_sensitivity;
    switch (level)
    {
        case 0:
            vox_sensitivity = -10;
            break;
        case 1:
            vox_sensitivity = -20;
            break;
        case 2:
            vox_sensitivity = -30;
            break;
        case 3:
            vox_sensitivity = -38;
            break;
        default:
            vox_sensitivity = -20;
            break;
    }
    command = VOX_ENABLE;
    
    if (self.camChan.communication_mode == COMM_MODE_STUN)
    {
        if (self.dev_s_comm != nil)
        {
            NSData * response_data;
            response_data = [self.dev_s_comm sendCommandThruUdtServer:command
                                                              withMac:self.camChan.profile.mac_address
                                                           AndChannel:self.camChan.channID];
            response = [[[NSString alloc] initWithData:response_data encoding: NSASCIIStringEncoding] autorelease];
            
        }
        
    }
    else
    {
        response = [dev_comm sendCommandAndBlock:command];
    }

    
    command = [NSString stringWithFormat:@"%@%@%d", VOX_SET_THRESHOLD,
               VOX_SET_THRESHOLD_VALUE, vox_sensitivity];
    
    if (self.camChan.communication_mode == COMM_MODE_STUN)
    {
        if (self.dev_s_comm != nil)
        {
            NSData * response_data;
            response_data = [self.dev_s_comm sendCommandThruUdtServer:command
                                                              withMac:self.camChan.profile.mac_address
                                                           AndChannel:self.camChan.channID];
            response = [[[NSString alloc] initWithData:response_data encoding: NSASCIIStringEncoding] autorelease];
            
        }
        
    }
    else
    {
        response = [dev_comm sendCommandAndBlock:command];
    }
    
   
    progressView.hidden = YES;
	[self updateVoxStatus];
	[self.cameraMenu reloadData];
	
}


-(void)onSetBrightnessLevel:(int) level
{
    progressView.hidden = NO; 
    [self.view bringSubviewToFront:progressView]; 
    

    [self performSelector:@selector(onSetBrightnessLevel_:) 
               withObject:[[NSNumber alloc] initWithInt:level] 
               afterDelay:0.10];
}

-(void) onSetBrightnessLevel_:(NSNumber *) lvl
{
	int _level = [lvl intValue] *2; 
	
	if (_level >8)
	{
		_level = 8;
	}
	
	//get the current level 
	NSString * response = nil, * command;
	
	
	int bright = -1;
	do 
	{
        response = nil; 
		command = GET_BRIGHTNESS_VALUE;
        
        if (self.camChan.communication_mode == COMM_MODE_STUN)
        {
            if (self.dev_s_comm != nil)
            {
                NSData * response_data; 
                response_data = [self.dev_s_comm sendCommandThruUdtServer:command 
                                                  withMac:self.camChan.profile.mac_address
                                               AndChannel:self.camChan.channID];
                response = [[[NSString alloc] initWithData:response_data encoding: NSASCIIStringEncoding] autorelease];
                
            }
            
        }
        else
        {
            response = [dev_comm sendCommandAndBlock:command];
        }
        
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

        if (self.camChan.communication_mode == COMM_MODE_STUN)
        {
            if (self.dev_s_comm != nil)
            {
                
                [self.dev_s_comm sendCommandThruUdtServer:command 
                                                  withMac:self.camChan.profile.mac_address
                                               AndChannel:self.camChan.channID];
                
            }
            
        }
        else
        {
            [dev_comm sendCommandAndBlock:command];
        }
	
	}
	while (bright != _level);
	
    progressView.hidden = YES;
    
	[self updateBrightnessLvl];
	[self.cameraMenu reloadData];

}


-(void)onSetVolumeLevel:(int) level
{
    progressView.hidden = NO; 
    [self.view bringSubviewToFront:progressView]; 
    
    
    [self performSelector:@selector(onSetVolumeLevel_:) 
               withObject:[[NSNumber alloc] initWithInt:level] 
               afterDelay:0.10];
}


-(void) onSetVolumeLevel_:(NSNumber *) lvl
{
    
    
	int _level = [lvl intValue] *25; 
	
	if (_level >100)
	{
		_level = 100; 
	}
	
	
	NSString * response, * command;
	command = [NSString stringWithFormat:@"%@%@%d",SET_VOLUME, SET_VOLUME_PARAM, _level];
    
    if (self.camChan.communication_mode == COMM_MODE_STUN)
    {
        if (self.dev_s_comm != nil)
        {
            NSData * response_data; 
            response_data = [self.dev_s_comm sendCommandThruUdtServer:command 
                                                              withMac:self.camChan.profile.mac_address
                                                           AndChannel:self.camChan.channID];
            response = [[[NSString alloc] initWithData:response_data encoding: NSASCIIStringEncoding] autorelease];
            
        }
        
    }
    else
    {
        response = [dev_comm sendCommandAndBlock:command];
    }
	
	if ( (response != nil)  && [response hasPrefix:SET_VOLUME])
	{
		//Dont care about response, here -- just simply read back the volume level
	}
	
    progressView.hidden = YES;
    
    
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
	NSLog(@"changeName success - reset the camera name now:");
    //1. Change title
     self.navigationItem.title = deviceName;
    [self.cameraMenuItemValues setObject:deviceName forKey:_NAME_DICT_KEY];
    [cameraMenu reloadData];
   
    //2. Change camera name in cameraview.selected channel
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    int parentViewControllerIndex = [viewControllerArray count] - 2;
    CameraViewController * camview = [viewControllerArray objectAtIndex:parentViewControllerIndex] ;
    camview.selected_channel.profile.name = deviceName;
    camview.barBtnName.title = deviceName; 

    //3. Change name in dashboard.
    UITabBarController * tabs = [viewControllerArray objectAtIndex:(parentViewControllerIndex-1)] ;
    DashBoard_ViewController * db = [tabs.viewControllers objectAtIndex:0];
    [db changeNameSuccessWithResponse:nil];

    
    
    progressView.hidden = YES;


    
}
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"changeNamed failed errorcode: ");
    progressView.hidden = YES;
    
    deviceName = [self.cameraMenuItemValues objectForKey:_NAME_DICT_KEY];
    
    [self showDialog:ALERT_CHANGE_NAME_FAILED];
}
-(void) changeNameFailedServerUnreachable
{
	NSLog(@"server unreachable");
    progressView.hidden = YES;
    
    deviceName = [self.cameraMenuItemValues objectForKey:_NAME_DICT_KEY];
    [self showDialog:ALERT_CHANGE_NAME_FAILED];
}



@end
