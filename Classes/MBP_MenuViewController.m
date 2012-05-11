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
@synthesize mainMenu, cameraMenu;

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
				break;
			case -20:
				lvl = @"Level 2";
				break;
			case -30:
				lvl = @"Level 3";
				break;
			case -38:
				lvl = @"Level 4(High)";
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
	int tempUnit = [userDefaults integerForKey:_tempUnit];
	
	
	switch (tempUnit) {
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
	NSString * videoQuality = nil;  
	
	videoQuality = [userDefaults objectForKey:@"str_VideoQuality"];
	if (videoQuality == nil)
	{
		videoQuality = 	@"Normal Quality(QVGA)";
	}
	[self.cameraMenuItemValues setValue:videoQuality forKey:_VIDEO_DICT_KEY];
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

	}
	
	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
