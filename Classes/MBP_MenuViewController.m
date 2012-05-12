//
//  MBP_MenuViewController.m
//  MBP_ios
//
//  Created by NxComm on 5/11/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_MenuViewController.h"


@implementation MBP_MenuViewController

@synthesize mainMenuItems;
@synthesize mainMenu, cameraMenu, mPickerView;

@synthesize cameraMenuItems, cameraMenuItemValues;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d modeDirect:(BOOL) isDirect
{
	
	//Read from an xml file 
	NSString *plistPath;

	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		delegate = d;
		isDirectMode = isDirect;
		if (isDirect == TRUE)
		{
			//same options as router mode - issue 170 
			self.mainMenuItems = [[NSArray alloc] initWithObjects:@"main_menu_direct_mode.png",
							 @"main_menu_router_mode.png",
							 @"main_menu_cam_settings.png",
							 @"main_menu_exit.png",
							 nil];

			plistPath = [[NSBundle mainBundle] pathForResource:@"cameraMenuDirect" ofType:@"plist"];

			
			if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
				NSLog(@"FILE %@ does not exist",plistPath) ;
				
			}
			
			self.cameraMenuItems = [NSArray arrayWithContentsOfFile:plistPath];
									
			
		}
		else //Router mode 
		{
			self.mainMenuItems = [[NSArray alloc] initWithObjects:@"main_menu_direct_mode.png",
							 @"main_menu_router_mode.png",
							 @"main_menu_cam_settings.png",
							 @"main_menu_exit.png",
							 nil];
			
			

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
	
	devicePort = [userDefaults integerForKey:_DevicePort];
	deviceIp = [userDefaults stringForKey:_DeviceIp];
	deviceMac = [userDefaults stringForKey:_DeviceMac];
	deivceName = [userDefaults stringForKey:_DeviceName];
	[self.cameraMenuItemValues setObject:deivceName forKey:_NAME_DICT_KEY];
	
	httpUserName = BASIC_AUTH_DEFAULT_USER;
	httpUserPass = [CameraPassword getPasswordForCam:deviceMac];
	
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//NSLog(@"reload data");
	//[self.mainMenu reloadData]; 
	
	[self readPreferenceData];
	
	//setup array for picker view
	levels = [[NSArray alloc] initWithObjects:@"Level1", @"Level2", @"Level3", @"Level4", nil];
	voxlevels = [[NSArray alloc] initWithObjects:@"Disable",
				 @"Level1(Low)", @"Level2", @"Level3", @"Level4 (High)", nil];
	temperature = [[NSArray alloc] initWithObjects:@"Fahrenheit",@"Celsius",nil];
	videoQuality = [[NSArray alloc] initWithObjects:@"High Quality (VGA)",@"Normal Quality (QVGA)",nil]; 
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL gotoSubMenu = [userDefaults boolForKey:_to_SubMenu];
	
	if (gotoSubMenu == TRUE)
	{
		//Read data and setup sub menu now.. 
	}
	else {
		//setup main menu .. 
	}

	
	dev_comm = [[HttpCommunication alloc] init];
	dev_comm.device_ip = deviceIp;
	dev_comm.device_port = devicePort;
	
	[self setupSubMenu];
	
	
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
    
	[mainMenuItems release];
	[cameraMenu release];
	[mainMenu release];
	
	[cameraMenuItems release];
	[cameraMenuItemValues release];
	[super dealloc];
}


- (void) setupSubMenu
{
	
	//1. setup title bar with name
	
	
	//2.query camera settings 
	[self updateVoxStatus];
	[self updateBrightnessLvl];
	[self updateTemperatureConversion];
	[self updateVolumeLvl];
	[self updateVQ];
	
	//reload table 
	[self.cameraMenu reloadData];
	
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
			return [self.mainMenuItems count];			
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

	if (tag == MAIN_MENU_TAG)
	{
	
		/// CONFIGURE main menu cell 
		static NSString *CellIdentifier = @"MainMenuCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Configure the cell...
		UIImage * img = [UIImage imageNamed:[mainMenuItems objectAtIndex:indexPath.row]];
		
		cell.imageView.image = img; 
		cell.imageView.contentMode	= UIViewContentModeScaleAspectFit;
		
		
	}
	else if (tag == CAM_MENU_TAG)
	{
		static NSString *CellIdentifier1 = @"CamMenuCell";
		UILabel * label, * value;
		int label_width; 

		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		

		
		if (cell == nil) {

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										    reuseIdentifier:CellIdentifier1] autorelease];
		}
		else {

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
	
	if (tag == MAIN_MENU_TAG)
	{
	
		NSString * options = [ self.mainMenuItems objectAtIndex:indexPath.row];
		
		if (indexPath.row == 2 ) //camera settings.
		{
			
			self.mainMenu.hidden = YES;
			self.cameraMenu.hidden = NO;
		}
		
	
	}
	else if (tag == CAM_MENU_TAG)
	{
		if (isDirectMode)
		{
		
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
				case 6 :// view angle
					[self onViewAngle];
					break;
				case 7 ://remote this camera
					break;
				case 8 ://port fwd
					break;
				case 9 ://chk upnp
					break;
				case 10 ://information
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
			NSString * msg =@"Unable to rename this camera. Camera is in DirectMode or You have not log-in";
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
		default:
			break;
	}
}

- (void)onName
{
	if (userName == nil || userPass == nil)
	{
		[self showDialog:DIALOG_CANT_RENAME];
		return;
	}
	
	[self askForNewName];
	
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


-(void) changeNameSuccessWithResponse:(NSData *) responsedata
{
	NSLog(@"changeName success");
}
-(void) changeNameFailedWithError:(NSHTTPURLResponse*) error_response
{
		NSLog(@"changeNamed failed errorcode: %d");
}
-(void) changeNameFailedServerUnreachable
{
	NSLog(@"server unreachable");
}


- (void) askForNewName 
{
	
	UIAlertView * _myAlert = nil;
	
	_myAlert = [[UIAlertView alloc] initWithTitle:@"Change Camera Name" 
										  message:@"Please enter new name for this camera" 
										 delegate:self 
								cancelButtonTitle:@"Cancel"
								otherButtonTitles:@"Ok", 
				nil];
	_myAlert.tag = ALERT_CHANGE_NAME; //used for tracking later 
	[_myAlert addTextFieldWithValue:@"" label:@"name"];
	[[_myAlert textField] setTextAlignment:UITextAlignmentCenter];
	[[_myAlert textField] becomeFirstResponder]; 
	
	[[_myAlert textField] setDelegate:self];
	[_myAlert show];
	[_myAlert release];
	
	
}

-(void) onViewAngle
{
	if (userName == nil || userPass == nil)
	{
		[self showDialog:DIALOG_CANT_RENAME];
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
				NSString * newName = [[alertView textField] text];
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


-(void) onSetVideoQuality:(int) vq
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:vq forKey:@"int_VideoQuality"];

	[self updateVQ];
	[self.cameraMenu reloadData];
	
}
-(void) onSetTempUnit:(int) unit
{
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:unit forKey:_tempUnit];

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

@end
