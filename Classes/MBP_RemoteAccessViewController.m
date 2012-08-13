//
//  MBP_RemoteAccessViewController.m
//  MBP_ios
//
//  Created by NxComm on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_RemoteAccessViewController.h"
#import "Util.h"
#import "CamChannel.h"
#import "CamProfile.h"

@implementation MBP_RemoteAccessViewController

@synthesize cam1_url, cam1_port, cam2_url, cam2_port, cam3_url,cam3_port, cam4_url, cam4_port;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/
 - (void)viewDidLoad {
    [super viewDidLoad];
	 
	 self.cam1_url = nil;
	 self.cam1_port = @"80";
	 
	 self.cam2_url = nil;
	 self.cam2_port = @"80";
	 self.cam3_url = nil;
	 self.cam3_port = @"80";
	 self.cam4_url = nil;
	 self.cam4_port = @"80";
	 
	 
	 /* Try to restore data */
	 [self restoreData];
	 	 
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
	
    
	
	
	[cam1_url release];
	[cam1_port release];
	[cam2_url release];
	[cam2_port release];
	[cam3_url release];
	[cam3_port release];
	[cam4_url release];
	[cam4_port release];
    [super dealloc];
}
#pragma mark -
#pragma mark button handling 


- (IBAction) handleButtonPressed:(id) sender
{
	
	int sender_tag = ((UIButton *) sender).tag;
	
	//NSLog(@"got %d", sender_tag);
	
	switch (sender_tag) {
	
		case RA_MENU_SAVE_BTN_TAG:
			
			[self saveData];
			break;
		case RA_MENU_BACK_BTN_TAG:
			[self dismissModalViewControllerAnimated:YES];
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
		case RA_MENU_CAM1_URL_TAG:
			self.cam1_url = [NSString stringWithString:textField.text];
			
			NSLog(@"cam1_url :%@", self.cam1_url);
			break;
		case RA_MENU_CAM1_PRT_TAG:
			self.cam1_port = textField.text;
			break;
		case RA_MENU_CAM2_URL_TAG:
			self.cam2_url = textField.text;
			break;
		case RA_MENU_CAM2_PRT_TAG:
			self.cam2_port = textField.text;
			break;
		case RA_MENU_CAM3_URL_TAG:
			self.cam3_url = textField.text;
			break;
		case RA_MENU_CAM3_PRT_TAG:
			self.cam3_port = textField.text;
			break;
		case RA_MENU_CAM4_URL_TAG:
			self.cam4_url = textField.text;
			break;
		case RA_MENU_CAM4_PRT_TAG:
			self.cam4_port = textField.text;
			break;
					
		default:
			break;
	}
	
	
	
	[textField resignFirstResponder];
	return NO;
}


#pragma mark - 
#pragma mark Save/Restore



- (void) saveData
{
	NSString * filename; 
	int barker = RA_DATA_BARKER;
	filename = [Util getDataFileName];
	
	
	FILE  * fd = fopen([filename UTF8String], "wb");
	if ( fd == NULL)
	{
		NSLog(@"can't open data file ");
		return ;
	}
	fwrite(&barker, sizeof(barker), 1, fd);
	
	/* Write number of channel*/
	int numberOfChannel = 4;
	fwrite(&numberOfChannel, sizeof(int), 1, fd);
	

	CamChannel * ch ; 
	CamProfile * cp;
	
	NSMutableData * chann= nil;
	unsigned char  data_len = 0;
	
	
	//NSLog(@"chann1 : %@:%@", self.cam1_url, self.cam1_port);
	/* create a temp channel to store data */
	ch = [[CamChannel alloc] initWithChannelIndex:1];
	if (self.cam1_url == nil)
	{
		self.cam1_url = @"nil";
		self.cam1_port= @"80";
		ch.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
	}
	else
	{
		ch.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
	}
	
	cp = [[CamProfile alloc] initWithMacAddr:@"NOTSET"];
	cp.isRemoteAccess = YES;
	cp.ip_address = self.cam1_url;
	cp.port = [self.cam1_port intValue];
	cp.isSelected = YES;
	[ch setProfile:cp];
	
	
	
	chann = [ch getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	[cp release];
	[ch release];
	
	//NSLog(@"chann1 done");
	
	/* create a temp channel to store data */
	ch = [[CamChannel alloc] initWithChannelIndex:1];
	if (self.cam2_url == nil)
	{
		self.cam2_url = @"nil";
		self.cam2_port= @"80";
		ch.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
	}
	else
	{
		ch.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
	}

	
	cp = [[CamProfile alloc] initWithMacAddr:@"NOTSET"];
	cp.isRemoteAccess = YES;
	cp.ip_address = self.cam2_url;
	cp.port = [self.cam2_port intValue];
	cp.isSelected = YES;
	[ch setProfile:cp];
	
	
	chann = [ch getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	[cp release];
	[ch release];
	
	
	
	/* create a temp channel to store data */
	ch = [[CamChannel alloc] initWithChannelIndex:1];
	if (self.cam3_url == nil)
	{
		self.cam3_url = @"nil";
		self.cam3_port= @"80";
		ch.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
	}
	else
	{
		ch.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
	}

	
	cp = [[CamProfile alloc] initWithMacAddr:@"NOTSET"];
	cp.isRemoteAccess = YES;
	cp.ip_address = self.cam3_url;
	cp.port = [self.cam3_port intValue];
	cp.isSelected = YES;
	[ch setProfile:cp];
	
	
	chann = [ch getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	[cp release];
	[ch release];
	
	
	
	/* create a temp channel to store data */
	ch = [[CamChannel alloc] initWithChannelIndex:1];
	if (self.cam4_url == nil)
	{
		self.cam4_url = @"nil";
		self.cam4_port= @"80";
		ch.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
	}
	else
	{
		ch.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
	}

	
	cp = [[CamProfile alloc] initWithMacAddr:@"NOTSET"];
	cp.isRemoteAccess = YES;
	cp.ip_address = self.cam4_url;
	cp.port = [self.cam4_port intValue];
	cp.isSelected = YES;
	[ch setProfile:cp];
	
	
	chann = [ch getBytes];
	data_len = [chann length];
	fwrite(&data_len, sizeof(char), 1, fd);
	fwrite([chann bytes], 1, [chann length], fd);
	
	[cp release];
	[ch release];
	
	fclose(fd);
	
	NSLog(@"write to file %@ done", filename);
	
}

- (void) restoreData
{
	//TODO
}

@end
