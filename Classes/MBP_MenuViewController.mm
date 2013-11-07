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
	//deviceName = [userDefaults stringForKey:_DeviceName];
	
    deviceName = self.camChan.profile.name;
    
    
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
	levels = [[NSArray alloc] initWithObjects:
              NSLocalizedStringWithDefaultValue(@"Level1",nil, [NSBundle mainBundle],
                                                @"Level 1", nil),
              NSLocalizedStringWithDefaultValue(@"Level2",nil, [NSBundle mainBundle],
                                                @"Level 2", nil),
              NSLocalizedStringWithDefaultValue(@"Level3",nil, [NSBundle mainBundle],
                                                @"Level 3", nil),
              NSLocalizedStringWithDefaultValue(@"Level4",nil, [NSBundle mainBundle],
                                                @"Level 4", nil),
              nil];
    
    
	voxlevels = [[NSArray alloc] initWithObjects:
                 NSLocalizedStringWithDefaultValue(@"Level1_",nil, [NSBundle mainBundle],
                                                   @"Level 1 (Low)", nil),
                 NSLocalizedStringWithDefaultValue(@"Level2",nil, [NSBundle mainBundle],
                                                   @"Level 2", nil),
                 NSLocalizedStringWithDefaultValue(@"Level3",nil, [NSBundle mainBundle],
                                                   @"Level 3", nil),
                 NSLocalizedStringWithDefaultValue(@"Level4_",nil, [NSBundle mainBundle],
                                                   @"Level 4 (High)", nil),
                 nil];
    
    
	temperature = [[NSArray alloc] initWithObjects:
                   NSLocalizedStringWithDefaultValue(@"Fahrenheit",nil, [NSBundle mainBundle],
                                                     @"Fahrenheit", nil),
                   NSLocalizedStringWithDefaultValue(@"Celsius",nil, [NSBundle mainBundle],
                                                     @"Celsius", nil),
                   nil];
    
	videoQuality = [[NSArray alloc] initWithObjects:
                    NSLocalizedStringWithDefaultValue(@"Normal_Quality",nil, [NSBundle mainBundle],
                                                      @"Normal Quality (QVGA)", nil),
                    NSLocalizedStringWithDefaultValue(@"High_Quality",nil, [NSBundle mainBundle],
                                                      @"High Quality (VGA)", nil),
                    nil];
	
    progressView.hidden = NO; 
    [self.view bringSubviewToFront:progressView]; 
    
	if (  commMode == COMM_MODE_STUN      ||
        commMode ==  COMM_MODE_STUN_RELAY2 )
	{

        /*20120822: Camera settings page is on OVERLAY mode 
          This means the connection to the camera is still going on. 
        --> No need to setup a new connection here . Just simply send the command over 
         to BMS */
        
		NSLog(@"com mode STUN"); 
		//[self setupStunConnectionToMac:deviceMac];
        
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
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) 
    {
  

        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        background.transform = transform;
        background.frame = CGRectMake(0,0, screenBounds.size.height,
                                      screenBounds.size.width);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_MenuProgress_land_ipad"
                                          owner:self
                                        options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_MenuProgress_land"
                                          owner:self
                                        options:nil];
            
            progressView.frame = CGRectMake(0, 0, screenBounds.size.height,
                                            screenBounds.size.width);
        }
       
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        background.transform = transform;
        background.frame = CGRectMake(0,0, screenBounds.size.width,
                                      screenBounds.size.height);

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_MenuProgress_portrait_ipad"
                                          owner:self
                                        options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"MBP_MenuProgress_portrait"
                                          owner:self
                                        options:nil];
            
            progressView.frame = CGRectMake(0, 0,screenBounds.size.width,
                                            screenBounds.size.height);

        }

        
       
        
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
    
    
    if (  commMode == COMM_MODE_STUN      ||
        commMode ==  COMM_MODE_STUN_RELAY2 )
	{
        
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
    
    if (  commMode == COMM_MODE_STUN      ||
        commMode ==  COMM_MODE_STUN_RELAY2 )
	{
        
    }
    else
    {

        response = [dev_comm sendCommandAndBlock:command];
    }
    
    
    if ( (response != nil)  && [response hasPrefix:VOX_GET_THRESHOLD])
    {
        NSString * str_value = [response substringFromIndex:([VOX_GET_THRESHOLD length] + 2)];
        
        int vox_value  = [str_value intValue];
      
        NSString * lvl = NSLocalizedStringWithDefaultValue(@"Level2",nil, [NSBundle mainBundle],
                                                           @"Level 2", nil);
        
        switch(vox_value)
        {
            case VOX_LEVEL_1:
                lvl = NSLocalizedStringWithDefaultValue(@"Level1_",nil, [NSBundle mainBundle],
                                                        @"Level 1 (Low)", nil);
                voxLevel = 0;
                break;
            case VOX_LEVEL_2:
                lvl = NSLocalizedStringWithDefaultValue(@"Level2",nil, [NSBundle mainBundle],
                                                        @"Level 2", nil);
                voxLevel = 1;
                break;
            case VOX_LEVEL_3:
                lvl =  NSLocalizedStringWithDefaultValue(@"Level3",nil, [NSBundle mainBundle],
                                                         @"Level 3", nil);
                voxLevel = 2;
                break;
            case VOX_LEVEL_4:
                lvl = NSLocalizedStringWithDefaultValue(@"Level4_",nil, [NSBundle mainBundle],
                                                        @"Level 4 (High)", nil);
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
    
    if (  commMode == COMM_MODE_STUN      ||
        commMode ==  COMM_MODE_STUN_RELAY2 )
	{
        
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
				lvl = NSLocalizedStringWithDefaultValue(@"Level1",nil, [NSBundle mainBundle],
                                                        @"Level 1", nil);
				break;
			case 1:
                lvl = NSLocalizedStringWithDefaultValue(@"Level2",nil, [NSBundle mainBundle],
                                                        @"Level 2", nil);
				break;
			case 2:
				lvl =  NSLocalizedStringWithDefaultValue(@"Level3",nil, [NSBundle mainBundle],
                                                         @"Level 3", nil);
				break;
			case 3:
				lvl = NSLocalizedStringWithDefaultValue(@"Level4",nil, [NSBundle mainBundle],
                                                        @"Level 4", nil);
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
    
    if (  commMode == COMM_MODE_STUN      ||
        commMode ==  COMM_MODE_STUN_RELAY2 )
	{
        
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
				lvl = NSLocalizedStringWithDefaultValue(@"Level1",nil, [NSBundle mainBundle],
                                                        @"Level 1", nil);
				break;
			case 1:
                lvl = NSLocalizedStringWithDefaultValue(@"Level2",nil, [NSBundle mainBundle],
                                                        @"Level 2", nil);
				break;
			case 2:
				lvl =  NSLocalizedStringWithDefaultValue(@"Level3",nil, [NSBundle mainBundle],
                                                         @"Level 3", nil);
				break;
			case 3:
				lvl = NSLocalizedStringWithDefaultValue(@"Level4",nil, [NSBundle mainBundle],
                                                        @"Level 4", nil);
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
		

		label.text = NSLocalizedStringWithDefaultValue([self.cameraMenuItems  objectAtIndex:indexPath.row],nil, [NSBundle mainBundle],
                                                       [self.cameraMenuItems  objectAtIndex:indexPath.row], nil);
    
		
		value = [[UILabel alloc] initWithFrame:CGRectMake(label_width,0, label_width, 
														  cell.contentView.frame.size.height)];
		value.adjustsFontSizeToFitWidth = YES;
		/*
		value.text = [Internationalization get:[[self.cameraMenuItems allValues] objectAtIndex:indexPath.row]
										 alter:[[self.cameraMenuItems allValues] objectAtIndex:indexPath.row]];
		 */
		
        value.lineBreakMode = UILineBreakModeWordWrap;
        
		value.text = [self.cameraMenuItemValues  objectForKey:[self.cameraMenuItems objectAtIndex:indexPath.row]];
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
    
    
    NSString * msg = nil; 

    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    
	switch (dialogType) {
		case DIALOG_IS_NOT_REACHABLE:
		{
            msg  = NSLocalizedStringWithDefaultValue(@"cam_menu_err_1",nil, [NSBundle mainBundle],
                                                               @"Camera is not reachable" , nil);
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:ok
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case DIALOG_CANT_RENAME:
		{
            msg  = NSLocalizedStringWithDefaultValue(@"cam_menu_err_2",nil, [NSBundle mainBundle],
                                                    @"Unable to rename this camera. Please re-login and try again" , nil);

			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:nil
								  cancelButtonTitle:ok
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case ALERT_NAME_CANT_BE_EMPTY:
		{
            msg  = NSLocalizedStringWithDefaultValue(@"cam_menu_err_3",nil, [NSBundle mainBundle],
                                                     @"Camera name cant be empty, please try again" , nil);

			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg 
								  delegate:self
								  cancelButtonTitle:ok
								  otherButtonTitles:nil];
			alert.tag = ALERT_NAME_CANT_BE_EMPTY; 
			[alert show];
			[alert release];
			break;
		}
        case ALERT_CAMERA_NAME_LENGHT_ERROR:
        {
            NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                                 @"Invalid Camera Name", nil);
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                               @"Camera Name has to be between 3-15 characters", nil);
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:msg
                                                            delegate:self
                                                   cancelButtonTitle:ok
                                                   otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            
            break;
        }
        case ALERT_INVALID_CAMERA_NAME:
        {NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                              @"Invalid Camera Name", nil);
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                               @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:msg
                                                            delegate:self
                                                   cancelButtonTitle:ok
                                                   otherButtonTitles:nil];
            
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
                msg  = NSLocalizedStringWithDefaultValue(@"cam_menu_err_4",nil, [NSBundle mainBundle],
                                                         @"Camera name can't be removed, please log-in" , nil);


				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle:@""
									  message:msg 
									  delegate:nil
									  cancelButtonTitle:ok
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
				
			}
			else {
				
				if (deviceInLocal)
				{
                    msg  = NSLocalizedStringWithDefaultValue(@"cam_rem_msg",nil, [NSBundle mainBundle],
                                                             @"Please confirm that you want to remove this camera from your account. This action will also switch your camera to default settings. You will need to add the camera into your account again to use it." , nil);

					UIAlertView *alert = [[UIAlertView alloc]
										  initWithTitle:@""
										  message:msg 
										  delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:ok,nil];
					alert.tag = ALERT_REMOVE_CAM_LOCAL; 
					[alert show];
					[alert release];

				}
				else
				{
                    msg  = NSLocalizedStringWithDefaultValue(@"cam_rem_msg1",nil, [NSBundle mainBundle],
                                                             @"Please confirm that you want to remove this camera from your account. The camera is not accessible right now, it will not be switched to direct mode. Please refer to FAQ to reset it manually." , nil);
					UIAlertView *alert = [[UIAlertView alloc]
										  initWithTitle:@""
										  message:msg 
										  delegate:self
										  cancelButtonTitle:cancel
										  otherButtonTitles:ok,nil];

					alert.tag = ALERT_REMOVE_CAM_REMOTE; 
					[alert show];
					[alert release];
				}
				
			}

			break;
		}

		case ALERT_MANUAL_FWD_MODE:
		{
            //Obsolete
            break;
		}
		case ALERT_UPNP_OK:
		{
			//Obsolete
			break;
		}
		case ALERT_UPNP_NOT_OK:
		{
			//Obsolete
			break;
		}
		case ALERT_UPNP_RUNNING:
		{
			//Obsolete
			break;
		}
		case ALERT_EMPTY_PORTS:
		{
			//Obsolete
			break;
		}	

		case ALERT_INVALID_PORTS:
		{
			//Obsolete
			break;
		}	
		case ALERT_NEED_LOGIN:
		{
			//Obsolete
			break;
		}	
		case ALERT_PASS_CANT_BE_EMPTY_NOR_DEFAULT:
		{
			//Obsolete
			break;
		}		
			

		case ALERT_CHANGE_PASS_FAILED:
		{
			//Obsolete
			break;
		}
            
        case ALERT_CHANGE_NAME_FAILED:
		{
            msg  = NSLocalizedStringWithDefaultValue(@"cam_menu_err_5",nil, [NSBundle mainBundle],
                                                     @"Failed to change camera name. Please try again later" , nil);
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@""
								  message:msg
								  delegate:nil
								  cancelButtonTitle:ok
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
    
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Change_Camera_Name",nil, [NSBundle mainBundle],
                                                       @"Change Camera Name", nil);
    NSString * msg2 = NSLocalizedStringWithDefaultValue(@"enter_new_camera_name",nil, [NSBundle mainBundle],
                                                        @"Enter new camera name", nil);
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    // NSString * newName = NSLocalizedStringWithDefaultValue(@"New_Name",nil, [NSBundle mainBundle],
    //                                                    @"New Name", nil);
#if 0
    UIAlertView * _myAlert = nil;
    
    _myAlert = [[UIAlertView alloc] initWithTitle:msg
                                          message:msg2
                                         delegate:self
                                cancelButtonTitle:cancel
                                otherButtonTitles:ok,
                nil];
    _myAlert.tag = ALERT_CHANGE_NAME; //used for tracking later
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(32.0, 85.0, 220.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    myTextField.placeholder = newName;
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.backgroundColor = [UIColor whiteColor];
    myTextField.textColor = [UIColor blackColor];
    myTextField.delegate = self;
    myTextField.tag = 10;
    [myTextField becomeFirstResponder];
    
    [_myAlert addSubview:myTextField];
    
    
    [_myAlert show];
    [_myAlert release];
    
#else
    
    AlertPrompt *prompt = [AlertPrompt alloc];
    prompt = [prompt initWithTitle:msg
                           message:msg2
                      promptholder:msg2
                          delegate:self
                 cancelButtonTitle:cancel
                     okButtonTitle:ok];
    prompt.tag = ALERT_CHANGE_NAME;
    [prompt show];
    [prompt release];
#endif
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
    
    if (  commMode == COMM_MODE_STUN      ||
        commMode ==  COMM_MODE_STUN_RELAY2 )
	{
        
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
	
    NSString * info = NSLocalizedStringWithDefaultValue(@"information",nil, [NSBundle mainBundle],
                                                       @"Information", nil);
    NSString * msg = NSLocalizedStringWithDefaultValue(@"information_msg",nil, [NSBundle mainBundle],
                                                       @"Motorola Monitor\nApplication version: %@\nFirmware version:%@,\nMonitoreverywhere \u00A9 All rights Reserved.\n", nil);
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);

	NSString * information = [NSString stringWithFormat:msg,bundleVersion, version];
	
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:info
						  message:information
						  delegate:nil
						  cancelButtonTitle:ok
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

-(BOOL) isCameraNameValidated:(NSString *) cameraNames
{
    
    NSString * validString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890. '_-";
    
    
    
    for (int i = 0; i < cameraNames.length; i ++)
    {
        NSRange range = [validString rangeOfString:[NSString stringWithFormat:@"%c",[cameraNames characterAtIndex:i]]];
        if (range.location == NSNotFound) {
            return NO;
        }
    }
    
    
    return YES;
    
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
				NSString *newName = [(AlertPrompt *)alertView enteredText];
				if( (newName == nil) || [newName length] ==0)
				{
					
					[self showDialog:ALERT_NAME_CANT_BE_EMPTY];
				}
                else if (newName.length < 3 || newName.length > 15)
                {
                    [self showDialog:ALERT_CAMERA_NAME_LENGHT_ERROR];
                }
                else if (![self isCameraNameValidated:newName])
                {
                    [self showDialog:ALERT_INVALID_CAMERA_NAME];
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
    NSLog(@" CameraMenu: Go all the way bacK");
    
    UITabBarController * root =  (UITabBarController *)[[self.navigationController viewControllers] objectAtIndex:0];
   
    [self.navigationController popToRootViewControllerAnimated:NO];
   
    DashBoard_ViewController * dashBoard =  (DashBoard_ViewController *)[[root viewControllers] objectAtIndex:0];
    
    [dashBoard forceRelogin];
}

#if JSON_FLAG
- (void) onCameraRemoveLocal
{
	NSString * command , *response;
	
    [delegate sendStatus:1];
    
	command = SWITCH_TO_DIRECT_MODE;
	response = [dev_comm sendCommandAndBlock:command];
	
	command = RESTART_HTTP_CMD;
	response = [dev_comm sendCommandAndBlock:command];
    
    NSLog(@"On Camera remove local");
	
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(removeCamSuccessWithResponse:)
                                                                         FailSelector:@selector(removeCamFailedWithError:)
                                                                            ServerErr:@selector(removeCamFailedServerUnreachable)];
    NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaluts objectForKey:@"PortalApiKey"];
    NSString *mac = [Util strip_colon_fr_mac:deviceMac];
	
	[jsonComm deleteDeviceWithRegistrationId:mac andApiKey:apiKey];
}

#else
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
#endif

#if JSON_FLAG
-(void) onCameraRemoveRemote
{
	BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(removeCamSuccessWithResponse:)
                                                                         FailSelector:@selector(removeCamFailedWithError:)
                                                                            ServerErr:@selector(removeCamFailedServerUnreachable)];
    NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaluts objectForKey:@"PortalApiKey"];
    NSString *mac = [Util strip_colon_fr_mac:deviceMac];
	
	[jsonComm deleteDeviceWithRegistrationId:mac andApiKey:apiKey];
}

#else
-(void) onCameraRemoveRemote
{
	BMS_Communication * bms_comm; 
	bms_comm = [[BMS_Communication alloc] initWithObject:self
												Selector:@selector(removeCamSuccessWithResponse:) 
											FailSelector:@selector(removeCamFailedWithError:) 
											   ServerErr:@selector(removeCamFailedServerUnreachable)];
	
	[bms_comm BMS_delCamWithUser:userName AndPass:userPass macAddr:deviceMac];
}
#endif

//callback frm alert
- (void) onCameraNameChanged:(NSString*) newName
{
	//Update BMS server with the new name;;
	
    deviceName = newName;
    [deviceName retain];
    progressView.hidden = NO;
    [self.view bringSubviewToFront:progressView];
    
}

-(void) onSetVideoQuality:(int) vq
{
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	[userDefaults setInteger:vq forKey:@"int_VideoQuality"];
//	[userDefaults synchronize];

    //Toggle by cameraviewController... 
    
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    int parentViewControllerIndex = [viewControllerArray count] - 2;

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
            vox_sensitivity = VOX_LEVEL_1;
            break;
        case 1:
            vox_sensitivity = VOX_LEVEL_2;
            break;
        case 2:
            vox_sensitivity = VOX_LEVEL_3;
            break;
        case 3:
            vox_sensitivity = VOX_LEVEL_4;
            break;
        default:
            vox_sensitivity = VOX_LEVEL_2;
            break;
    }
    command = VOX_ENABLE;
    
    if (self.camChan.communication_mode == COMM_MODE_STUN   ||
         self.camChan.communication_mode ==  COMM_MODE_STUN_RELAY2 )
    {
    }
    else
    {
        response = [dev_comm sendCommandAndBlock:command];
    }

    
    command = [NSString stringWithFormat:@"%@%@%d", VOX_SET_THRESHOLD,
               VOX_SET_THRESHOLD_VALUE, vox_sensitivity];
    
    if (self.camChan.communication_mode == COMM_MODE_STUN   ||
        self.camChan.communication_mode ==  COMM_MODE_STUN_RELAY2 )
    {
        
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
        
        if (self.camChan.communication_mode == COMM_MODE_STUN   ||
            self.camChan.communication_mode ==  COMM_MODE_STUN_RELAY2 )
        {
            
            
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

        if (self.camChan.communication_mode == COMM_MODE_STUN   ||
            self.camChan.communication_mode ==  COMM_MODE_STUN_RELAY2 )
        {
            
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
    
    if (self.camChan.communication_mode == COMM_MODE_STUN   ||
        self.camChan.communication_mode ==  COMM_MODE_STUN_RELAY2 )
    {
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
#pragma mark BMS_JSON_Communication callbacks 

#if JSON_FLAG
- (void) removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"removeCam success-- fatality");
    
    [self goBackAndReLogin];
}

- (void) removeCamFailedWithError:(NSDictionary *) errorResponse
{
	NSLog(@"removeCam failed errorcode: %d", [[errorResponse objectForKey:@"status"] intValue]);
}

#else
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
#endif

-(void) removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
}



-(void) changeNameSuccessWithResponse:(NSData *) responsedata
{
	NSLog(@"changeName success - reset the camera name now:");
    //1. Change title
    self.camChan.profile.name = deviceName;
     self.navigationItem.title = deviceName;
    [self.cameraMenuItemValues setObject:deviceName forKey:_NAME_DICT_KEY];
    [cameraMenu reloadData];
   
    //2. Change camera name in cameraview.selected channel
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    int parentViewControllerIndex = [viewControllerArray count] - 2;

    //3. Change name in dashboard.
    UITabBarController * tabs = [viewControllerArray objectAtIndex:(parentViewControllerIndex-1)] ;
    DashBoard_ViewController * db = [tabs.viewControllers objectAtIndex:0];
    [db changeNameSuccessWithResponse:nil];

    [deviceName release];
    
    progressView.hidden = YES;


    
}
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"changeNamed failed errorcode: ");
    progressView.hidden = YES;
    
    deviceName = [self.cameraMenuItemValues objectForKey:_NAME_DICT_KEY];
    
    [self showDialog:ALERT_CHANGE_NAME_FAILED];
        [deviceName release];
}
-(void) changeNameFailedServerUnreachable
{
	NSLog(@"server unreachable");
    progressView.hidden = YES;
    
    deviceName = [self.cameraMenuItemValues objectForKey:_NAME_DICT_KEY];
    [self showDialog:ALERT_CHANGE_NAME_FAILED];
        [deviceName release];
}



@end
