//
//  MBP_setupViewController.m
//  MBP_ios
//
//  Created by NxComm on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_DeviceConfigureViewController.h"
#import "Util.h"

@implementation MBP_DeviceConfigureViewController


@synthesize scrollView;
@synthesize deviceConf;

@synthesize keyIndexImg;
@synthesize securityTypeImg;
@synthesize addressingModeImg;
@synthesize wepTypeImg, wepTypeButton;
@synthesize keyIndexButton;


@synthesize ssidField;
@synthesize securityKeyField;

@synthesize usrNameField;
@synthesize passWdField;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.*/
- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
		 withDelegate:(id<SetupHttpDelegate>) delegate
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		httpDelegate = delegate;
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
		
	[self.scrollView setContentSize:CGSizeMake(480.0, 540.0)];
	
	/* Preprare dataSource those picker here */
	securityTypeData = [[NSArray alloc] initWithObjects:@"Open",@"WEP", @"WPA-PSK/WPA2-PSK",nil];
	securityTypeIcons = [[NSArray alloc] initWithObjects:@"buttons6_1.png", @"buttons4_1.png",@"WPA_on.png",nil];
	
	
	keyIndexData = [[NSArray alloc] initWithObjects:@"1",@"2", @"3",@"4",nil];
	keyIndexIcons = [[NSArray alloc] initWithObjects:@"buttons11_1.png", @"buttons12_1.png",@"buttons13_1.png", @"buttons14_1.png", nil];
	
	addressingModeData = [[NSArray alloc] initWithObjects:@"DHCP",@"Static",nil];
	addressingModeIcons= [[NSArray alloc] initWithObjects:@"DHCP_on.png", @"static_on.png", nil];


	wepTypeData = [[NSArray alloc] initWithObjects:@"OPEN",@"SHARED",nil];
	wepTypeIcons = [[NSArray alloc] initWithObjects:@"buttons6_1.png",@"shared_on.png",nil];
	
	self.keyIndexImg.hidden = YES;
	self.keyIndexButton.hidden = YES;
	self.wepTypeImg.hidden = YES;
	self.wepTypeButton.hidden  = YES;
	
	/* initialize transient object here */
	self.deviceConf = [[DeviceConfiguration alloc] init];
	
	[self restoreDataIfPossible];
	
	
	if ( [self.deviceConf.securityMode isEqualToString:@"WEP"])
	{
		self.keyIndexImg.hidden = NO;
		self.keyIndexButton.hidden = NO;
		self.wepTypeImg.hidden = NO;
		self.wepTypeButton.hidden  = NO;
		
		
		int img_idx = [keyIndexData indexOfObject:self.deviceConf.keyIndex];
		if (img_idx != NSNotFound)
		{
			[self.keyIndexImg setImage:[UIImage imageNamed:[keyIndexIcons objectAtIndex:img_idx]]];
		}
		
		img_idx = [wepTypeData indexOfObject:self.deviceConf.wepType];
		if (img_idx != NSNotFound)
		{
			[self.wepTypeImg setImage:[UIImage imageNamed:[wepTypeIcons objectAtIndex:img_idx]]];
		}
			 
	}
	
	
}

- (BOOL) restoreDataIfPossible
{
	
	
	NSDictionary * saved_data = [Util readDeviceConfiguration];
	
	if ( saved_data != nil) 
	{
		[self.deviceConf restoreConfigurationData:saved_data];
		
		//populate the fields with stored data 
		self.ssidField.text = self.deviceConf.ssid;
			
		/* Security mode field */
		int idx = [securityTypeData indexOfObject:self.deviceConf.securityMode];
		NSLog(@"sec: %@ idex: %d", self.deviceConf.securityMode, idx);
		if (idx == NSNotFound)
		{
			//TODO
		}
		
		[self.securityTypeImg setImage:
			[UIImage imageNamed:[securityTypeIcons objectAtIndex:idx]]];
		
		
		/* Key field*/
		self.securityKeyField.text = self.deviceConf.key;
		
		/* if security is WPA - skip this option*/
		if ([self.deviceConf.securityMode compare:[securityTypeData objectAtIndex:1]] ==  NSOrderedSame )
		{
			/* Key Index field - for WEP only */		
			idx = [keyIndexData indexOfObject:self.deviceConf.keyIndex];
			if (idx == NSNotFound)
			{
				//TODO: default to index 1
				[self.keyIndexImg setImage:[UIImage imageNamed:[keyIndexIcons objectAtIndex:0]]];
			}
			else
			{
				[self.keyIndexImg setImage:[UIImage imageNamed:[keyIndexIcons objectAtIndex:idx]]];

			}
			NSLog(@"keyIndex: %@ idex: %d", self.deviceConf.keyIndex, idx);
			
		}

		
	
		
		
		idx = [addressingModeData indexOfObject:self.deviceConf.addressMode];
		if (idx == NSNotFound)
		{
			//TODO
		}
		[self.addressingModeImg setImage:[UIImage imageNamed:[addressingModeIcons objectAtIndex:idx]]];
		
		self.usrNameField.text = self.deviceConf.usrName;
		self.passWdField.text = self.deviceConf.passWd;
		
		
		return TRUE;
	}

	return FALSE;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	
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
	
	
	[securityTypeData release];
	[keyIndexData release];
	[addressingModeData release];
	[wepTypeData release];
	 
	[securityTypeIcons release];
	[keyIndexIcons release];
	[addressingModeIcons release];
	[wepTypeIcons release];
	 
	 
	
	[ssidField release];
	[securityKeyField release];
	[usrNameField release];
	[passWdField release];
	
	[scrollView release];	
	[keyIndexImg  release];
	[securityTypeImg release];
	[addressingModeImg release];
	[keyIndexButton release];
	[wepTypeImg release];
	[wepTypeButton release];
	
	[deviceConf release];
    [super dealloc];
}

#pragma mark -
#pragma mark Button pressed



- (IBAction) handleButtonPressed:(id)sender
{
	int sender_tag = ((UIButton *) sender).tag;
	
	UIActionSheet * actionSheet = nil;
	
	switch (sender_tag) {
		case SETUP_WEP_TYPE_CHANGE_TAG:
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"WEP types:"
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:[wepTypeData objectAtIndex:0], 
						   [wepTypeData objectAtIndex:1], nil];
			
			actionSheet.tag = SETUP_WEP_TYPE_CHANGE_TAG;
			[actionSheet showInView:self.view];
			[actionSheet release];
			break;
			
		case SETUP_SEC_TYPE_CHANGE_TAG:
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Security types:"
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:[securityTypeData objectAtIndex:0], 
															   [securityTypeData objectAtIndex:1], 
						                                       [securityTypeData objectAtIndex:2], nil];
			
			actionSheet.tag = SETUP_SEC_TYPE_CHANGE_TAG;
			[actionSheet showInView:self.view];
			[actionSheet release];
			break;
		case SETUP_KEY_IDX_CHANGE_TAG:
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Key index:"
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:[keyIndexData objectAtIndex:0],[keyIndexData objectAtIndex:1], [keyIndexData objectAtIndex:2],[keyIndexData objectAtIndex:3], nil ];
			actionSheet.tag	= SETUP_KEY_IDX_CHANGE_TAG;
			[actionSheet showInView:self.view];
			[actionSheet release];
			break;
		case SETUP_ADDR_MODE_CHANGE_TAG:
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"IP Address Modes:"
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:[addressingModeData objectAtIndex:0],[addressingModeData objectAtIndex:1], nil ];
			actionSheet.tag = SETUP_ADDR_MODE_CHANGE_TAG;
			[actionSheet showInView:self.view];
			[actionSheet release];
			break;
			
		case SETUP_SAVE_CONFIGURATION_TAG:
			/* save to non-volatile memory */
			
			if ( [deviceConf isDataReadyForStoring])
			{
				NSLog(@"ok to save ");
				[Util writeDeviceConfigurationData:[deviceConf getWritableConfiguration]];
			}
			else 
			{
				UIAlertView * alert =
				[[UIAlertView alloc] initWithTitle:@"Error: Could not save data" 
										   message:@"Please check the following fields: SSID or Key"
										  delegate:self
								 cancelButtonTitle:@"OK"
								 otherButtonTitles:nil];
				[alert show];
				[alert release];
				
			}

			break;
		case SETUP_SEND_CONFIGURATION_TAG:
		{
			DeviceConfiguration * sent_conf = [[DeviceConfiguration alloc] init];
			[sent_conf restoreConfigurationData:[Util readDeviceConfiguration]];
			
			//create a http delegate, send the data thru delegate
			[httpDelegate sendConfiguration:sent_conf];
			
			NSLog(@"Send done!");
			
			break;
		}
		case SETUP_BACK_KEY_TAG:
			[self dismissModalViewControllerAnimated:YES];
			break;
		default:
			break;
	}
	
	
}


#pragma mark -
#pragma mark ActionSheet delegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	int action_tag = actionSheet.tag;
	
	switch (action_tag) {
		case SETUP_WEP_TYPE_CHANGE_TAG:

			self.deviceConf.wepType = [wepTypeData objectAtIndex:buttonIndex];
			
			//NSLog(@"new wep type %@", self.deviceConf.wepType);
			[self.wepTypeImg setImage:[UIImage imageNamed:[wepTypeIcons objectAtIndex:buttonIndex]]]; 
			break;
		case SETUP_SEC_TYPE_CHANGE_TAG:
			self.deviceConf.securityMode = [securityTypeData objectAtIndex:buttonIndex];
			//update the image 
			[self.securityTypeImg setImage:[UIImage imageNamed:[securityTypeIcons objectAtIndex:buttonIndex]]]; 
			
			if (buttonIndex == 1) /* if the type is  WEP */
			{
				/* enable a few options */
				self.keyIndexImg.hidden = NO;
				self.keyIndexButton.hidden = NO;
				
				self.wepTypeImg.hidden = NO;
				self.wepTypeButton.hidden  = NO;
				
			}
			else
			{
				/* disable a few options */
				self.keyIndexImg.hidden = YES;
				self.keyIndexButton.hidden = YES;
				self.wepTypeImg.hidden = YES;
				self.wepTypeButton.hidden  = YES;
			}

			
			break;
		case SETUP_KEY_IDX_CHANGE_TAG:
			self.deviceConf.keyIndex = [keyIndexData objectAtIndex:buttonIndex];
			[self.keyIndexImg setImage:[UIImage imageNamed:[keyIndexIcons objectAtIndex:buttonIndex]]]; 
			break;
		case SETUP_ADDR_MODE_CHANGE_TAG:
			self.deviceConf.addressMode = [addressingModeData objectAtIndex:buttonIndex];
			[self.addressingModeImg setImage:[UIImage imageNamed:[addressingModeIcons objectAtIndex:buttonIndex]]]; 
			break;
		default:
			break;
	}
	
	
}

#pragma mark  -
#pragma mark Textfield delegate




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	int text_tag = textField.tag;
	
	switch (text_tag) {
		case SETUP_SSID_TXT_TAG:
			self.deviceConf.ssid = textField.text;
			break;
		case SETUP_KEY_TXT_TAG:
			self.deviceConf.key = textField.text;
			break;
		case SETUP_USRNAME_TXT_TAG:
			self.deviceConf.usrName = textField.text;
			break;
		case SETUP_PSSWD_TXT_TAG:
			self.deviceConf.passWd = textField.text;
			break;

		default:
			break;
	}
	
	
	
	[textField resignFirstResponder];
	return NO;
}



@end
