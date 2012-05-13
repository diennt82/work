//
//  MBP_iosViewController.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <CFNetwork/CFNetwork.h>
#import "MBP_FirstPage.h"
#import "MBP_iosViewController.h"
#import "MBP_CamView.h"
#import "Util.h"
#import "ADPCMDecoder.h"
#import "AsyncUdpSocket.h"

#import "MBP_DeviceScanViewController.h"
#import "CameraPassword.h"

@implementation MBP_iosViewController

@synthesize camView, mainMenuView;
@synthesize scan_results, next_profile_index;
@synthesize toTakeSnapShot,recordInProgress ;
@synthesize bc_addr,own_addr;



@synthesize comm; 
@synthesize camListView;

@synthesize channel_array; 
@synthesize restored_profiles ; 

@synthesize streamer; 

@synthesize progressView;

@synthesize fullScreenTimer;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
				
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	[super loadView];


}*/

- (void) initialize 
{
	self.camView = nil;
	self.mainMenuView = nil;
	
	

	
	self.toTakeSnapShot = NO;
	self.recordInProgress = NO;

	self.scan_results = [NSMutableArray arrayWithCapacity:4]; 
	self.next_profile_index = 0;

	
	
	
	walkie_talkie_enabled = NO;
	

	current_view_mode = CURRENT_VIEW_MODE_MULTI;
	deviceScanInProgress = NO;
	
	
	self.comm = [[HttpCommunication alloc]init]; 
	
	fullScreenTimer = nil;
	
	
	[UIDevice currentDevice].batteryMonitoringEnabled = YES;
	
	// Register for battery level and state change notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelDidChange:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];

}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	
	[self initialize];
		
	//go Back to main menu
	[NSTimer scheduledTimerWithTimeInterval:2.0
									 target:self
								   selector:@selector(wakeup_display_main_cam:)
								   userInfo:nil
									repeats:NO];
		
}



- (void)wakeup_display_main_cam:(NSTimer*) timer_exp
{
	
	MBP_FirstPage * firstPage;
	firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage"
												bundle:nil
									  withConnDelegate:self];
	
	[self presentModalViewController:firstPage animated:YES];

}


/* Simply try to authenticate and connect to the camera 
 at default address 192.168.2.1 
 */
-(void) startDirectConnect
{
	[[NSBundle mainBundle] loadNibNamed:@"MBP_CamView" 
								  owner:self 
								options:nil];
	
	
	[self.view addSubview:camView];
	
	[camView.oneCamView initializedWithViewController:self];

	
	
	
	
	/* Setup for 1 cam */
	
	
	UIPinchGestureRecognizer * pinchGesture = 
	[[UIPinchGestureRecognizer alloc] initWithTarget:self
											  action:@selector(handlePinchGesture:)];
	[camView.oneCamView.videoView addGestureRecognizer:pinchGesture];
	[pinchGesture release];
	
	/* Kick off the two timer for direction sensing */
	currentDirUD = DIRECTION_V_NON;
	lastDirUD    = DIRECTION_V_NON;
	delay_update_lastDir_count = 1;
	
	
	
	send_UD_dir_req_timer = 
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(v_directional_change_callback:)
								   userInfo:nil
									repeats:YES];
	
	currentDirLR = DIRECTION_H_NON;
	lastDirLR    = DIRECTION_H_NON;
	delay_update_lastDirLR_count = 1;
	
	
	
	send_LR_dir_req_timer = 
	[NSTimer scheduledTimerWithTimeInterval:0.2
									 target:self
								   selector:@selector(h_directional_change_callback:)
								   userInfo:nil
									repeats:YES];
	
	
	
	
	
	[self.view addSubview:camView];
	
	
	[self.camView.statusBar switchChannel:10];
	
	self.camView.oneCamView.hidden = NO;

	self.camView.oneCamView.progressView.hidden = NO;
	self.camView.statusBar.temperature_label.hidden = NO;
	[self.camView.oneCamView.progressView startAnimating];
	current_view_mode = CURRENT_VIEW_MODE_SINGLE;
	
	
	[comm babymonitorAuthentication];
	
	
	[NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
									 target:self
								   selector:@selector(_connectDefaultRabot:)
								   userInfo:nil
									repeats:NO];
	
	
	
	
	
}


-(void) startShowingCameraList
{
	if (camListView == nil)
	{
		
		[[NSBundle mainBundle] loadNibNamed:@"MBP_CamListView" 
									  owner:self 
									options:nil];
		
		[camListView initViews];
		[self.view addSubview:camListView];
		
	}
	
	camListView.hidden = NO;
	
	/* setup for one by one channel */
	CamProfile * cp ; 
	CamChannel * ch;
	CamListItemView * itemView; 

	
	NSLog(@"channelViews count: %d ", [camListView.channelViews count]);
	
	for (int i =0 ; i< [camListView.channelViews count]; i++)
	{
		itemView = [camListView.channelViews objectAtIndex:i];
		
		
		ch = [channel_array  objectAtIndex:i];
		cp = ch.profile;

		NSLog(@"camera: %@ ", cp.mac_address);
		if (cp == nil)
		{
			itemView.hidden = YES;
		}
		else
		{
			if (cp.isInLocal ==TRUE)
			{
				
				[itemView.cameraLocationIndicator setImage:[UIImage imageNamed:@"camera_online.png"]];
			}
			else 
			{
				
				[itemView.cameraLocationIndicator setImage:[UIImage imageNamed:@"camera_offline.png"]];
					
			}
			
			
			//TODO: setup melody image
			
			
			//Set camera name
			[itemView.cameraName setText:cp.name];
			
			//set camera info
			if (cp.isInLocal == TRUE)
			{
				NSLog(@"online lastComm %@", cp.last_comm); 
				[itemView.cameraLastComm setText:[NSString stringWithFormat:@"last seen %@", cp.last_comm]]; 
			}
			else
			{
				NSLog(@"offline lastComm %@", cp.last_comm); 
				[itemView.cameraLastComm setText:[NSString stringWithFormat:@"last seen %@", cp.last_comm]];
			}

			
			
			//set camera image
			if (cp.profileImage != nil)
			{
				[itemView.cameraSnapshot setImage:cp.profileImage];
			}
			else 
			{
				[itemView.cameraSnapshot setImage:[UIImage imageNamed:@"photo_item.png"]];
			}

			//set Setting button functionality -
			//TODO: 
			
			
			//Set onclick for this item
			itemView.userInteractionEnabled = YES;
			
			
			UITapGestureRecognizer *singleFingerTap = 
			[[UITapGestureRecognizer alloc] initWithTarget:self 
													action:@selector(channelSelect:)];
			[itemView addGestureRecognizer:singleFingerTap];
			[singleFingerTap autorelease];

			
		}
		
		
	}//end for 
		
		
		
		
	/**** setup the video screen */
	if (camView == nil)
	{
		[[NSBundle mainBundle] loadNibNamed:@"MBP_CamView" 
									  owner:self 
									options:nil];
		
		
		[self.view addSubview:camView];
		
		
		[camView.oneCamView initializedWithViewController:self];
		
		/* Setup for 1 cam */
		
		UIPinchGestureRecognizer * pinchGesture = 
		[[UIPinchGestureRecognizer alloc] initWithTarget:self
												  action:@selector(handlePinchGesture:)];
		[camView.oneCamView.videoView addGestureRecognizer:pinchGesture];
		[pinchGesture release];
		
		/* Kick off the two timer for direction sensing */
		currentDirUD = DIRECTION_V_NON;
		lastDirUD    = DIRECTION_V_NON;
		delay_update_lastDir_count = 1;
		
		
		
		send_UD_dir_req_timer = 
		[NSTimer scheduledTimerWithTimeInterval:0.1
										 target:self
									   selector:@selector(v_directional_change_callback:)
									   userInfo:nil
										repeats:YES];
		
		currentDirLR = DIRECTION_H_NON;
		lastDirLR    = DIRECTION_H_NON;
		delay_update_lastDirLR_count = 1;
		
		
		
		send_LR_dir_req_timer = 
		[NSTimer scheduledTimerWithTimeInterval:0.2
										 target:self
									   selector:@selector(h_directional_change_callback:)
									   userInfo:nil
										repeats:YES];
		
		[self.view addSubview:camView];
		 
		
		NSLog(@"finish setup the video view ");
		
		
	}
	
	self.camView.hidden = YES;
	
	
	
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[camView release];
	[mainMenuView release];
	[scan_results release];
	[bc_addr release];
	[own_addr release];
	[comm release];
	[channel_array release]; 
	[restored_profiles release];
	[fullScreenTimer release];
    [super dealloc];
}


- (void) showSideMenusAndStatus
{
	
	if ( fullScreenTimer != nil )
	{
		//invalidate the timer .. 
		[fullScreenTimer invalidate];
		fullScreenTimer = nil;
	}
		NSLog(@"show menus");
	if (self.camView != nil)
	{
		self.camView.oneCamView.directionPad.hidden = NO;
		self.camView.oneCamView.directionIndicator.hidden = NO;
		
		
		self.camView.statusBar.hidden = NO;
		self.camView.leftSideMenu.hidden = NO;
		self.camView.rightSideMenu.hidden = NO;
		
	}
}
- (void) showJoysticksOnly
{
	NSLog(@"show joystick");
	if (self.camView != nil)
	{
		self.camView.oneCamView.directionPad.hidden = NO;
		self.camView.oneCamView.directionIndicator.hidden = NO;
		
		
		self.camView.statusBar.hidden = YES;
		self.camView.leftSideMenu.hidden = YES;
		self.camView.rightSideMenu.hidden = YES;
		
	}
}
- (void) showFullScreenNow: (NSTimer*) exp
{
	
	
	fullScreenTimer = nil;
	
	//Make status bar, left, right menus disappear
	if (self.camView != nil)
	{
		self.camView.oneCamView.directionPad.hidden = YES;
		self.camView.oneCamView.directionIndicator.hidden = YES;
		
		
		self.camView.statusBar.hidden = YES;
		self.camView.leftSideMenu.hidden = YES;
		self.camView.rightSideMenu.hidden = YES;
		
	}
}


- (void) tryToShowFullScreen
{
	
	if ( (fullScreenTimer != nil))
	{
		//invalidate the timer .. 
		[fullScreenTimer invalidate];
		fullScreenTimer = nil;
	}
	

	NSLog(@"start fullscreen timer .");
	fullScreenTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 
											  target:self 
											selector:@selector(showFullScreenNow:) 
											userInfo:nil
											 repeats:NO];
	
}


#pragma mark - Battery notifications

- (void)batteryLevelDidChange:(NSNotification *)notification
{
	[self  updateBatteryIcon];
}


- (void) updateBatteryIcon
{
	/* 0.0  (0%) - 1.0 (100%)*/
	float lvl = [UIDevice currentDevice].batteryLevel;
	if (lvl == -1.0)
	{
		//invalide battery state .. could be simulator 
		return; 
	}
	int index = (int)(lvl / 0.2);
	
	if (lvl == 1.0)
	{
		index  = 4;
	}
	
	NSLog(@"batt lvl:%f, index:%d", lvl, index);
	
	
	NSArray * batteryLvl; 
	batteryLvl = [[NSArray alloc] initWithObjects:@"status_icon1_5.png",@"status_icon1_1.png",
				@"status_icon1_2.png", @"status_icon1_3.png", @"status_icon1_4.png"
				,nil];
	
	UIImage * img = [UIImage imageNamed:(NSString*)[batteryLvl objectAtIndex:index]];
	
	[self.camView.statusBar.batt_status_icon setImage:img];
	
}

#pragma mark -
#pragma mark Button Handlers



- (void) channelSelect: (UIGestureRecognizer *) sender 
{
	
	NSLog(@"get Touchupinside from tag: %d", sender.view.tag);
	int senderTag = sender.view.tag;
	
	if (self.channel_array == nil)
	{
		NSLog(@"error: channel array is null !!!");
		return;
	}
	

	
	switch (senderTag) {
		case CHANNEL_1_TAG:
			selected_channel = [self.channel_array objectAtIndex:0]; 
			break;
		case CHANNEL_2_TAG:
			selected_channel = [self.channel_array objectAtIndex:1]; 
			break;
		case CHANNEL_3_TAG:
			selected_channel = [self.channel_array objectAtIndex:2]; 
			break;
		case CHANNEL_4_TAG:
			selected_channel = [self.channel_array objectAtIndex:3]; 
			

			
			break;
		default:
			break;
	}
	
	if (selected_channel == nil )
	{
		NSLog(@"channel is nil");
		return; 
	}

	if (selected_channel.profile == nil )
	{
		NSLog(@"channel profile is nil");
		return; 
	}
	
	
	NSLog(@"channel is %d with cam name: %@", selected_channel.channel_index, selected_channel.profile.name);
	
	
	[self setupInfraCamera:selected_channel];
	
}



- (IBAction) handlePinchGesture: (UIGestureRecognizer *) sender
{
	CGFloat factor = [(UIPinchGestureRecognizer *) sender scale];
	if (factor > 1) 
	{
		// zoom in
		self.streamer.currentZoomLevel-=0.05;
									
	}
	else
	{
		// zoom out 
		self.streamer.currentZoomLevel +=0.05;
	}
	
	if (self.streamer.currentZoomLevel >5.0)
	{
		self.streamer.currentZoomLevel = 5.0;
	}
	
	if (self.streamer.currentZoomLevel < 1.0)
	{
		self.streamer.currentZoomLevel =1.0 ;
	}
	
}


- (IBAction) handleLongPress: (UIGestureRecognizer *) sender
{
	
	if (sender.state == UIGestureRecognizerStateBegan)
	{
		NSLog(@" PTT Enaged");
		[self toggle_walkie_talkie];
		
		
		UIButton * bttn = (UIButton *) sender.view; 
		
		[bttn setImage:[UIImage imageNamed:@"mic_d.png"]
								  forState:UIControlStateNormal];

	}
	else if (sender.state == UIGestureRecognizerStateEnded)
	{
		
		NSLog(@" PTT disengaged");
		UIButton * bttn = (UIButton *) sender.view; 
		[bttn setImage:[UIImage imageNamed:@"mic.png"]
								  forState:UIControlStateNormal];

		[self toggle_walkie_talkie];
	}

	
}

- (IBAction) mainMenuButtonClicked:(id) sender
{
	int sender_tag = ((UIButton*)sender).tag;
	
	 
	
	
	
	switch (sender_tag) {
		case MENU_SETUP_TAG:

		{
			MBP_MainSetupViewController * setupController;
			setupController = [[MBP_MainSetupViewController alloc] initWithNibName:@"MBP_MainSetupViewController"
																		bundle:nil
																  withDelegate:self ];
			
			[self presentModalViewController:setupController animated:YES];
			break;
		}


		case MENU_PLAYLIST_TAG:
		{
			AiBallVideoListViewController * listController;
			listController = [[AiBallVideoListViewController alloc] initWithNibName:@"AiBallVideoListViewController"
																	   bundle:nil];
			//[listController autorelease];
			//[self.navigationController pushViewController:listController animated:YES];
			[self presentModalViewController:listController animated:YES];
			break;
		}
		
		case MENU_MELODY_TAG:
			[self onMelody: ((UIButton*)sender)];
			break;
		case MENU_BACK_TAG:
			if ( mainMenuView != nil)
			{
				mainMenuView.hidden = YES;
				
				
#if 0
				if ( current_view_mode == CURRENT_VIEW_MODE_MULTI)
				{
					if ( deviceScanInProgress == NO)
					{
						/* Reconnect */	
						[self scan_for_devices];
					}
				}
				else {
					[self switchToSingleCameraMode: -1];
				}
#endif 
			}
			
			if (selected_channel != nil)
			{
				[self setupInfraCamera:selected_channel];
			}
			else 
			{
				//start by scanning for cameras 
				[self scan_for_devices];
			}

			
			
			break;
		case MENU_INFO_TAG:
		{
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"INFORMATION"
								  message:@"V1.0" 
								  delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}	
			break;
			
		default:
			break;
	}
	
	
}



- (IBAction) sideMenuButtonPressed:(id) sender
{
	
	[self showSideMenusAndStatus];
}



- (IBAction) sideMenuButtonClicked:(id) sender
{
	
	int sender_tag = ((UIButton*)sender).tag; 
	UIActionSheet * actionSheet = nil;

	
	[self tryToShowFullScreen];
	
	
	switch (sender_tag) {
		case SIDEBUTTON_MULTICAM_TAG:
			
						
			self.camView.hidden = YES;
			[self.streamer stopStreaming]; 
			
			[self startShowingCameraList];
			
			break;
		case SIDEBUTTON_SNAPSHOT_TAG:
			/* Dont take snapshot while recording */
			if (self.recordInProgress == NO)
			{	
				self.streamer.takeSnapshot = YES;
			}
			break;
		case SIDEBUTTON_MAINMENU_TAG:
		{
			
			[self.streamer stopStreaming];
#if 0 //old menu -- to be removed 
			if ( mainMenuView == nil)
			{
			
				[[NSBundle mainBundle] loadNibNamed:@"MBP_MainMenuView" 
											  owner:self 
											options:nil];
				/* after  loading mainMenuView should be not nil*/
				/* adjust the location of the menuview */
				CGRect menuFrame = [mainMenuView frame];
				menuFrame.origin.y += 20;
				mainMenuView.frame = menuFrame;
				
				
				
				[self.view  addSubview:mainMenuView]; 
			}
			else {
				mainMenuView.hidden = NO;
			}
#endif
			
			
			MBP_MenuViewController * menuViewCtrl;
			
				
			
			menuViewCtrl = [[MBP_MenuViewController alloc] initWithNibName:@"MBP_MenuViewController"
																bundle:nil
													  withConnDelegate:self
																modeDirect:FALSE];
			
			[self presentModalViewController:menuViewCtrl animated:NO];
			
			
			
			
			break;
		}
		case SIDEBUTTON_RECORD_TAG:
			[self.streamer toggleRecording ]; 
			
			if (self.streamer.recordInProgress == YES)
			{
				[self.camView.leftSideMenu.recordButton setImage:[UIImage imageNamed:@"smallicon4_2.png"]
														forState:UIControlStateNormal];
				
			}
			else
			{

				[self.camView.leftSideMenu.recordButton setImage:[UIImage imageNamed:@"smallicon4_1.png"]
														forState:UIControlStateNormal];

			}

			
			camView.statusBar.video_rec_status_icon.hidden = (!self.streamer.recordInProgress) ;
			
			break;
		case SIDEBUTTON_MELODY_TAG:
		{
			NSArray * melodies; 
			
			//TODO: change to picker view & internationalize..
			melodies = [[NSArray alloc] initWithObjects:@"Mute",@"Rock a Bye Baby",
						@"Lullaby and Goodnight", @"Lavender Blue", @"Twinkle Twinkle Little Start",
						@"Hush Little Baby",nil];
			
			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a melody"
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:[melodies objectAtIndex:0], 
						   [melodies objectAtIndex:1],
						   [melodies objectAtIndex:2],
						   [melodies objectAtIndex:3],
						   [melodies objectAtIndex:4],
						   [melodies objectAtIndex:5],
						   nil];
			
			actionSheet.tag = MELODY_SELECTION_TAG;
			
			[actionSheet showInView:self.camView];
			[actionSheet release];
			
			
			break;
		}
		case SIDEBUTTON_PTT_TAG:
			
			break;
		default:
			break;
	}
}


- (IBAction) cameraListButtonClicked:(id) sender
{
	int sender_tag = ((UIButton*)sender).tag; 
	
	switch (sender_tag) {
		case SEARCH_CAM_BTN:
			self.progressView.hidden = NO;
			[self.view bringSubviewToFront:self.progressView];

			[self scan_for_devices];
			break;
		case ADD_CAM_BTN:
		{
			MBP_AddCamController * addCamCtrl;
			addCamCtrl = [[MBP_AddCamController alloc] initWithNibName:@"MBP_AddCamController"
																   bundle:nil
														 withConnDelegate:self];
			
			[self presentModalViewController:addCamCtrl animated:NO];
			
			
			break;
		}
		case SCAN_CAM_BTN:
			break;
		case LOGOUT_CAM_BTN:
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
		case MELODY_SELECTION_TAG:

			if (comm != nil)
			{
				NSString * command = nil;
				if (buttonIndex == 0 ) //mute
				{
					command = SET_MELODY_OFF;
				}
				else 
				{
					command = [NSString stringWithFormat:@"%@%d",SET_MELODY,buttonIndex];
				}
				
				if (command != nil)
				{
					[comm sendCommandAndBlock:command];
				}
				
			}
			
			

			if (buttonIndex == 0 ) //mute
			{
				[self.camView.leftSideMenu.melodyButton setImage:[UIImage imageNamed:@"smallicon5_2.png"]
																			forState:UIControlStateNormal];
			}
			else 
			{
				[self.camView.leftSideMenu.melodyButton setImage:[UIImage imageNamed:@"smallicon5_1.png"]
																		   forState:UIControlStateNormal];

			}
			
			break;
		default:
			break;
	}
	
	
}


#pragma mark -
#pragma mark Connectivity


#define SOCKET_ID_LISTEN  100
#define SOCKET_ID_SEND    200



- (void) scan_for_devices
{
	
	///GET IP here 
	NSString * bc = @"";
	NSString * own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
	self.bc_addr = [NSString stringWithString:bc];
	self.own_addr = [NSString stringWithString:own];
	
	
	NSString *str =  AIBALL_QUERY_REQUEST_STRING;
	NSString * my_ip_str = self.own_addr;
	NSString * blank_str = @" ";
	int blank_chars = 0, i = 0;
	blank_chars = 16 - [my_ip_str length];
	if (blank_chars >0)
	{
		for (i = 0 ; i< blank_chars; i++)
		{
			my_ip_str= [my_ip_str stringByAppendingString:blank_str];
		}
	}
	
	str = [str stringByAppendingString:my_ip_str];
	str = [str substringToIndex:47];
	
	NSLog(@"scan req: %@", str);
	
	NSData* bytes = [str dataUsingEncoding:NSUTF8StringEncoding];
	
	
	@synchronized (self)
	{
		deviceScanInProgress = YES;
	}
	

	
	//NSLog(@"broadcast addr: %@ self:%@", self.bc_addr, self.own_addr);

	
	
	self.next_profile_index = 0;
	[ self.scan_results removeAllObjects];
	
	AsyncUdpSocket * udpSock = [[AsyncUdpSocket alloc] initIPv4];
	[udpSock setDelegate:self];
	
	BOOL status;
	status = [udpSock bindToPort:10001 error:nil];
	//[udpSock enableBroadcast:YES error: nil];
	[udpSock receiveWithTimeout:5 tag:1];

	//NSLog(@"buff size: %d", [udpSock maxReceiveBufferSize]);
	
	/* Sending socket */
	AsyncUdpSocket * udpSSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
	
	
	// Broadcast 
	[udpSSock enableBroadcast:YES error: nil];
	[udpSSock sendData:bytes toHost:self.bc_addr port:10000 withTimeout:1 tag:1];
	//[udpSSock sendData:bytes toHost:@"192.168.1.102" port:10000 withTimeout:1 tag:1];
	
	
	self.progressView.hidden = NO;
	[self.view bringSubviewToFront:self.progressView];
}


-(void) startConnect
{

	BOOL restore_successful = FALSE;
	CamChannel * ch = nil;
	restore_successful = [self restoreConfigData];
	CamProfile * cp = nil;

	//Hide it, since we're done
	self.progressView.hidden = YES;
	
	
	if ( restore_successful == TRUE)
	{
		

		if (scan_results != nil &&
			restored_profiles != nil &&
			[restored_profiles count] >0)
		{
			
			for (int i=0; i<[restored_profiles count]; i++)
			{
				if ( [restored_profiles objectAtIndex:i] == nil)
				{
					continue;
				}
				cp = [restored_profiles objectAtIndex:i]; 
				cp.isInLocal = FALSE;
				for (int j = 0; j < next_profile_index; j++)
				{
					CamProfile * cp1 = (CamProfile *) [scan_results objectAtIndex:j];
				
					
					if ( [cp.mac_address isEqualToString:cp1.mac_address])
					{
						
						
						cp.ip_address = cp1.ip_address;
						cp.profileImage = cp1.profileImage;
						cp.isInLocal = TRUE; 
						cp.port = 80;//localport is always 80
						//cp setMelodyStatus- TODO
						//cp setVersionString- TODO
						
						
					}
					
				}
				
			}
			
			
			/* Rebinding local cameras to restored channel
			 In the case of remote access, the mac address is set to an 
			 invalid value "NOTSET" which will not match any MAC address gathered thru 
			 scanning.
			 */
			for (int i = 0; i< [channel_array count]; i++)
			{
				ch = (CamChannel*) [channel_array objectAtIndex:i];
				
				if ( ch.profile != nil)
				{
					for (int j = 0; j < [restored_profiles count]; j++)
					{
						CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
						if ( !cp.isSelected //&&  
							//[cp.mac_address isEqualToString:ch.profile.mac_address]
							)
						{
							//Re-bind camera - channel
							NSLog(@"binding cam: %@(%@) to channel:%d",
								  cp.name, cp.mac_address, ch.channel_index);
							[ch setCamProfile:cp]; 
							cp.isSelected = TRUE;
							[cp setChannel:ch];
							break;
							
						}
						
						
					}
				}
				else {
					
					//NSLog(@"channel profile = nil");
				}
				
				
			}
			
		}
		
		
		
		/* show the camera list page now */
		[self startShowingCameraList];
		
#if 0
		
		/* hide the channel icon */
        [self.camView.statusBar switchChannel:10];
		

		
		
		/* Setup and start streaming */

		
		self.camView.oneCamView.hidden = YES;
		self.camView.statusBar.melody_status_icon.hidden = YES;
        self.camView.statusBar.temperature_label.hidden = YES;

		self.camView.sideMenu.snapShotButton.enabled = NO;
		self.camView.sideMenu.recordButton.enabled = NO;
#endif
	
	}
	
}


-(void) setupInfraCamera:(CamChannel *) ch
{
	int channel_number = ch.channel_index;
	
	current_view_mode = CURRENT_VIEW_MODE_SINGLE;
	
	self.camListView.hidden = YES;
	self.camView.hidden = NO;
	self.camView.oneCamView.hidden = NO;
	
	self.camView.leftSideMenu.snapShotButton.enabled = YES;
	self.camView.leftSideMenu.recordButton.enabled = YES;
	
	//ch.profile should not be NULL here --
	
	if ( channel_number >0)
	{
		[self.camView.statusBar switchChannel:channel_number];
	}
	
	//self.camView.oneCamView.progressView.hidden = NO;
	//[self.camView.oneCamView.progressView startAnimating];
	
	/* setup talk back*/
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
										  initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.minimumPressDuration = 2; //user needs to press for 2 seconds
	[self.camView.rightSideMenu.pushTTButton addGestureRecognizer:lpgr];
	[lpgr release];
	
	//read battery level
	[self  updateBatteryIcon];
	
	
	self.camView.statusBar.temperature_label.hidden = NO;

	//Set camera name
	[self.camView.statusBar.camName_label setText:ch.profile.name];
		
	NSString* ip = ch.profile.ip_address;
	int port = ch.profile.port;

	NSLog(@"connect to cam %@: %@:%d",ch.profile.name, ip, port);
	
	
	if (comm != nil)
	{
		[comm release];
		comm = nil; 
	}
	
	comm = [[HttpCommunication alloc]init];
	comm.device_ip = ip;
	comm.device_port = port; 

	//send first command now.. non-blocking call - ignore result
	[comm sendCommand:SET_RESOLUTION_QVGA];
	

	//start fullscreen timer here.. 
	[self tryToShowFullScreen];
	
	
	
	
	if (streamer != nil)
	{
		[streamer stopStreaming];
		[streamer release];
	}
	
	
	streamer = [[MBP_Streamer alloc]initWithIp:ip andPort:port];
	[streamer setVideoImage:self.camView.oneCamView.videoView];
	[streamer setTemperatureLabel:self.camView.statusBar.temperature_label];

	[streamer startStreaming];
	
	
	
	
	//Store some of the info for used in menu  -- 
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:TRUE forKey:_is_Loggedin];
	
	
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];

	
	[userDefaults setObject:old_usr forKey:_UserName];	
	[userDefaults setObject:old_pass forKey:_UserPass];	

	[userDefaults setBool:ch.profile.isInLocal forKey:_DeviceInLocal];
	[userDefaults setInteger:port forKey:_DevicePort];
	[userDefaults setObject:ip forKey:_DeviceIp];
	[userDefaults setObject:ch.profile.mac_address forKey:_DeviceMac];
	[userDefaults setObject:ch.profile.name forKey:_DeviceName];	

}


#if 0
-(void) switchToSingleCameraMode:(int) channel_number
{
	
	current_view_mode = CURRENT_VIEW_MODE_SINGLE;
	
	self.camView.oneCamView.hidden = NO;

	self.camView.statusBar.melody_status_icon.hidden = NO;
	self.camView.statusBar.temperature_label.hidden = NO;
	self.camView.leftSideMenu.snapShotButton.enabled = YES;
	self.camView.leftSideMenu.recordButton.enabled = YES;

	
	if ( channel_number >0)
	{
		[self.camView.statusBar switchChannel:channel_number];
	}
	
	
	
	
	self.camView.oneCamView.progressView.hidden = NO;
	[self.camView.oneCamView.progressView startAnimating];
	
	if ( pcmPlayer == nil)
	{
		/* Start the player to playback & record */
		pcmPlayer = [[PCMPlayer alloc] init];
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Play];

	}
	else {
		[[pcmPlayer player] setPlay_now:FALSE];

	}

	
	NSArray * img_array; 
	img_array = [[NSArray alloc] initWithObjects:@"melody_muted_icon.png",@"melody_1_icon.png",
				 @"melody_2_icon.png",@"melody_3_icon.png",nil];
	[self set_current_melody_status:self.camView.statusBar.melody_status_icon updateIcons:img_array];
	self.camView.statusBar.melody_status_icon.hidden = NO;
	[img_array release];
    self.camView.statusBar.temperature_label.hidden = NO;
	
	
	/* adjust resolution :QVGA*/
	[self performSelectorInBackground:@selector(requestURLSync_bg:) 
						   withObject:[Util getVideoModeURL:1]];
	
	
	//NSLog(@"saved_url: %@", [Util getDefaultURL]);		
	NSString* ip = [Util getIPFromURL:[Util getDefaultURL]];
	int port = [Util getPortFromURL:[Util getDefaultURL]];
	
	if (initialFlag == 1)
	{
		[self disconnectRabot];
	}
	
	initialFlag = 1;
	
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];	
	[listenSocket setUserData:SOCKET_ID_LISTEN];
	
	
	//Non-blocking connect
    [listenSocket connectToHost:ip onPort:port withTimeout:3 error:nil];
	
}
#endif 

- (void) _connectDefaultRabot:(NSTimer *) expired
{
	if (comm.authInProgress == FALSE)
	{
		[self setupDirectModeCamera];
		
	}
	else {
		[NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
										 target:self
									   selector:@selector(_connectDefaultRabot:)
									   userInfo:nil
										repeats:NO];
	}

}

- (void) setupDirectModeCamera 
{
	
	NSString * defaultName = [CameraPassword fetchSSIDInfo];
	NSString* ip = DEFAULT_BM_IP;
	int port = DEFAULT_BM_PORT;
	
	NSLog(@"connect to cam %@:%d", ip, port);
	
	//read battery level
	[self  updateBatteryIcon];

	if (comm != nil)
	{
		[comm release];
		comm = nil; 
	}
	
	comm = [[HttpCommunication alloc]init];
	comm.device_ip = ip;
	comm.device_port = port; 
	
	//send first command now.. non-blocking call - ignore result
	[comm sendCommand:SET_RESOLUTION_QVGA];
	
	
	/* setup talk back*/
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
										  initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.minimumPressDuration = 2; //user needs to press for 2 seconds
	[self.camView.rightSideMenu.pushTTButton addGestureRecognizer:lpgr];
	[lpgr release];
	
	/* set camera name */
	[self.camView.statusBar.camName_label setText:defaultName];
	
	/* disable the multi button */
	[self.camView.rightSideMenu.multiModeButton setUserInteractionEnabled:FALSE];
	
	
	if (streamer != nil)
	{
		[streamer stopStreaming];
		[streamer release];
	}
	
	
	streamer = [[MBP_Streamer alloc]initWithIp:ip andPort:port];
	[streamer setVideoImage:self.camView.oneCamView.videoView];
	[streamer setTemperatureLabel:self.camView.statusBar.temperature_label];
	
	[streamer startStreaming];
	
	
	
	
#if 0
	initialFlag = 1;
	
	if ( pcmPlayer == nil)
	{
		/* Start the player to playback & record */
		pcmPlayer = [[PCMPlayer alloc] init];
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Play];
		
	}
	else {
		[[pcmPlayer player] setPlay_now:FALSE];
		
	}
	

	

	
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];	
	[listenSocket setUserData:SOCKET_ID_LISTEN];
	
	
	NSString* ip = @"192.168.2.1";//[Util getIPFromURL:[Util getDefaultURL]];
	int port = 80;//[Util getPortFromURL:[Util getDefaultURL]];
	
	NSLog(@"ip: %@: port: %d", ip, port);
	//Non-blocking connect
    [listenSocket connectToHost:ip onPort:port withTimeout:3 error:nil];
#endif 
	
}



- (void) disconnectRabot
{
	
	if(listenSocket != nil) {
		[listenSocket setDelegate:nil];
		[listenSocket disconnect];
		[listenSocket release];
		listenSocket = nil;
	}
	
	if(responseData != nil) {
		[responseData release];
		responseData = nil;
	}
	
	
	initialFlag = 0;
}

- (void) startReceivingVideoAudio
{
	
	
	
	NSString *getReq = [NSString stringWithFormat:@"%@Authorization: Basic %@\r\n\r\n", AIBALL_GET_REQUEST, [Util getCredentials]];
	NSData *getReqData = [getReq dataUsingEncoding:NSUTF8StringEncoding];
	
	[listenSocket writeData:getReqData withTimeout:2 tag:1];
	
	[listenSocket readDataWithTimeout:2 tag:1];	
	
	
	
	responseData = [[NSMutableData alloc] init];
	
	
	[self.camView.oneCamView.progressView stopAnimating];
}





#pragma mark -- TCP delegate ---


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	
	[listenSocket readDataWithTimeout:3 tag:1];	
	
	
	NSString *strBoundary = BOUNDARY_STRING;
	NSData *boundaryString = [strBoundary dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString *strDoubleReturn = @"\r\n\r\n";
	NSData *doubleReturnString = [strDoubleReturn dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableData* buffer;
	
	
	if(initialFlag) {
		
		
		//process data
		NSString* initialResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSRange range = [initialResponse rangeOfString:AUTHENTICATION_ERROR];
		if(range.location != NSNotFound) {
			// authentication error
			// just return here
			
			return;
		}
		[initialResponse release];
		// truncate the http header
		[responseData appendData:data];
		int pos = [Util offsetOfBytes:responseData searchPattern:doubleReturnString];
		if(pos < 0) return;
		
		initialFlag = 0;
		NSRange range0 = {pos + 4, [responseData length] - pos - 4};
		NSData* tmpData = [responseData subdataWithRange:range0];
		
		buffer = [[NSMutableData alloc] init];
		[buffer appendData:tmpData];
	} else {
		buffer = [[NSMutableData alloc] init];
		[buffer appendData:responseData];
		[buffer appendData:data];	
	}
	
	int length = [buffer length];	
	//int pos = -1;
	int index = 0;
	int totalOffset = 0;
	
	while(1) {
		NSRange range = {totalOffset, length - totalOffset};
		NSData* ptr = [buffer subdataWithRange:range];
		int endPos = [Util offsetOfBytes:ptr searchPattern:boundaryString];
		
		if(endPos >= 0) {
			// there is a match for the end boundary
			// we have the entire data chunk ready
			if(endPos > 0) {
				NSRange range1 = {0, endPos};
				NSData* data = [ptr subdataWithRange:range1];
				int dl = [data length];
			    //Byte* p1 = (Byte*)[data bytes];
				//Byte ch = p1[dl-1];
				index = endPos + [boundaryString length];
				totalOffset += index;
				int startIndex = [Util offsetOfBytes:data searchPattern:doubleReturnString];
				if(startIndex >= 0) {
					NSRange range2 = {startIndex + 4, dl - startIndex - 4};
					NSData* actualData = [data subdataWithRange:range2];
					Byte* actualDataPtr = (Byte*)[actualData bytes];
					int audioLength = (actualDataPtr[1] << 24) + (actualDataPtr[2] << 16) + (actualDataPtr[3] << 8) + actualDataPtr[4];
					int imageIndex = (actualDataPtr[5] << 24) + (actualDataPtr[6] << 16) + (actualDataPtr[7] << 8) + actualDataPtr[8];
					
					
					
#if WIFI_AND_BATTERY_IN_VIDEO_DATA
					//Byte resolutionJpeg =  actualDataPtr[9] ;
					/* re-use the field below to get battery and wifi level*/
					Byte wifi_and_batt = actualDataPtr[9];/*resolutionJpeg*/
					
					
					[self update_battery_and_wifi:wifi_and_batt];
#endif
					
					
					Byte resetAudioBufferCount = actualDataPtr[10];
					int temperature = (actualDataPtr[11]<<24) | (actualDataPtr[12]<<16) |
					                  (actualDataPtr[13]<<8 )|   actualDataPtr[14];
					
					//Update temperature 
					camView.statusBar.temperature_label.text = [NSString stringWithFormat:@"%d \u2103", temperature];
					
					
					int avdata_offset = 10 + 4 + 1 ; //old data + temperature + 1 
					
					
					
#ifdef IBALL_AUDIO_SUPPORT	
					if( audioLength > 0 )
					{
						NSRange range3 = {avdata_offset, audioLength};
						NSData* audioData = [actualData subdataWithRange:range3];
#ifdef IRABOT_PCM_AUDIO_SUPPORT
						NSData* decodedPCM = audioData;
						
#else
						NSMutableData* decodedPCM = [[NSMutableData alloc] init];
						[ADPCMDecoder Decode:audioData outData:decodedPCM];
#endif
						
						if(self.recordInProgress) 
						{
							[iRecorder GetAudio:decodedPCM resetAudioBufferCount:resetAudioBufferCount];
						}
						//NSLog(@"decoded audio len: %d", [decodedPCM length]);
						
						
						[self PlayPCM:decodedPCM];
					    
#if !defined(IRABOT_PCM_AUDIO_SUPPORT)
						[decodedPCM release];
#endif
						
			
						
					} 
#endif /* IBALL_AUDIO_SUPPORT */
					
					NSRange range4 = {avdata_offset + audioLength, 
						              [actualData length] - avdata_offset - audioLength};
					NSData* imageData = [actualData subdataWithRange:range4];
					
					UIImage *image = [UIImage imageWithData:imageData];
					
#if 0
					if (currentZoomLevel < 5.0f)
					{
						//CGRect frame = camView.oneCamView.videoView.frame;
						
						CGFloat newDeltaWidth =   image.size.width*(5.0f - currentZoomLevel)*2;
						CGFloat newDeltaHeight =  image.size.height*(5.0f - currentZoomLevel)*2;
						CGRect newRect = CGRectZero;
						newRect.origin.x = - newDeltaWidth/2;
						newRect.origin.y = - newDeltaHeight/2;
						
						newRect.size.width =  image.size.width +newDeltaWidth;
						newRect.size.height = image.size.height +newDeltaHeight;
						
						
											
						//NSLog(@"newsize :%f, %f %f %f", newRect.size.width, newRect.size.height,
						//	  newDeltaWidth, newDeltaHeight);
						image = [self imageWithImage:image scaledToRect:newRect];
						
						
						
					}
#endif 
					camView.oneCamView.videoView.image = image;
					
					
					
					if (self.toTakeSnapShot == YES)
					{
						[self takeSnapShot:image];
						self.toTakeSnapShot = NO;
					}

					
					if (self.recordInProgress == YES)
					{
					
						[iRecorder GetImage:imageData imgIndex:imageIndex];
						if([iRecorder GetCurrentRecordSize] >= iMaxRecordSize) {
							[self stopRecording];
							//[self startRecording];
						}

					}
					
					
					

					//[actualData release];
				} else {
					//TPtrC8 actualData = data;
				}
			} else {
				// for initial condition
				// we will skip the boundary
				index = [boundaryString length];
				totalOffset = index;
			}
		} else {
			// no match
			// break the loop and wait for the next data chunk
			[responseData setLength:[ptr length]];
			[responseData setData:ptr];
			//[ptr release];
			break;
		}
	}
	
	[buffer release];
}


- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"Socket will disconnect with err:%@", err);
	
	NSLog(@"TCP error code: %d  des: %@", [err code], [err localizedDescription]);
	switch ([err code]) {
		case AsyncSocketConnectTimeoutError:
			if ( [sock userData] == SOCKET_ID_LISTEN)
			{
				//NSLog(@"listen sock timeout");
			}
			if ( [sock userData] == SOCKET_ID_SEND)
			{
				

			}
			
			
			break;
		default:
			break;
	}
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Connection Error"
						  message:[err localizedDescription] 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];

	[self.camView.oneCamView.progressView stopAnimating];
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	{ // port should be 80 here
		
		[self startReceivingVideoAudio ];
		
#if 0
		//differentiate b/w reconnect due to disable->enable video or...
		if (video_audio_reconnect == TRUE)
		{
			video_audio_reconnect = FALSE;
			[self startReceivingVideoAudio ];
		}
		else //firsttime connecting
		{
			[firstView setConnectionStatus:YES];
		}
#endif //0 
	}
	
	
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	
	if ([sock userData] == SOCKET_ID_LISTEN)
		
	{

		
		//[self force_disconnect];
		
	}
	

}



#pragma mark -- UDP delegate
/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	//NSLog(@"UDP Socket sendDone  enable receiving %d", [sock localPort]);
	
	/* close socket */
	[sock close];

}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
	NSLog(@"UDP Socket error: %d  localhost:%@", error, [sock localHost]);
	
}






/**
 * Called when the socket has received the requested datagram.
  * Under normal circumstances, you simply return YES from this method.
 **/
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
	
	NSString * data_str ; 
	
	data_str = [NSString stringWithUTF8String:[data bytes]];

	//NSLog(@"000 rcv fr: %@ : msg: %@", host, data_str);

	/* verify signature */
	if ([data_str hasPrefix:@"Mot-Cam"])
	{
		CamProfile * newProfile = [CamProfile alloc];
		
		NSLog(@"rcv fr: %@", host);
		
		[newProfile initWithResponse:data_str andHost:host];
		
		
		BOOL isFound  = NO;
		int i;
		for (i =0; i < self.next_profile_index; i++)
		{
			CamProfile * bb = (CamProfile *)[self.scan_results objectAtIndex:i];

			if ( [bb.mac_address isEqualToString:newProfile.mac_address])
			{
				isFound = YES; 
				break;
			}
		}
		
		if (isFound == NO)
		{
			

			[self.scan_results insertObject:newProfile atIndex:self.next_profile_index];
			self.next_profile_index++;
		}
		else {
			[newProfile release];
		}



	}
	
	if (self.next_profile_index <5)
	{
		/* try again until we failed */
		[sock receiveWithTimeout:2 tag:1];
	}
	
	return YES;
}

/**
 * Called if an error occurs while trying to receive a requested datagram.
 * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	//NSLog(@"RCV data err: %x (%@)", [error code], [error localizedDescription]);
	
	/* close socket */
	[sock close];
	
	
	@synchronized (self)
	{
		deviceScanInProgress = NO;
	}
	
	
	[self startConnect];
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
}
#import <sys/socket.h>
#import <netinet/in.h>
#import  "IpAddress.h"

+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip
{
	
	int ret; 
	//Free & re-init Addresses 
	FreeAddresses();

	ret = GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
	
	NSString * log = @"";
	

	int i;
	
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
		
		theAddr = ip_addrs[i];
		
		if (theAddr == INVALID_IP)
		{

			break;
		}

		if (theAddr == localHost) continue;
		
		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
		}
		
		
		
		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
		// broadcast_addrs[i]);
		
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
		 broadcast_addrs[i]];
		
	}
	 
	
	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];
	
	NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	NSLog(@"own iP: %d %@",i, deviceIP);
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}
	
	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
	
#if 0	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"bc addr:"
						  message:log
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	

	
	if (deviceBroadcastIP == nil)
	{
	
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"bc addr:"
							  message:@"Wifi is not enabled please enable wifi and restart the application"
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
 
	
#endif	
	return ;
}


#pragma mark -
#pragma mark Audio Playback

- (void) PlayPCM:(NSData*)pcm {
	
	//Start play back 
	[[pcmPlayer player] setPlay_now:TRUE];
	
	[pcmPlayer WritePCM:(unsigned char *)[pcm bytes] length:[pcm length]];
}



//---------------------------------------------
//------- Walkie Talkie 
//---------------------------------------------
#pragma mark -
#pragma mark Walkie Talkie - Stream audio from iphone

- (BOOL) toggle_walkie_talkie
{
	NSLog(@"talk: %d", walkie_talkie_enabled);
	@synchronized (self)
	{
		if ( walkie_talkie_enabled == YES)
		{
			walkie_talkie_enabled = NO;
			
			
			[self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:) 
								   withObject:[NSString stringWithFormat:@"%d",walkie_talkie_enabled]];
					
			
			if (audioOut != nil)
			{
				[audioOut disconnectFromAudioSocket];
				[audioOut release];
			}
			
			
		}
		else 
		{
			walkie_talkie_enabled = YES;
			
			[self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:) 
								   withObject:[NSString stringWithFormat:@"%d",walkie_talkie_enabled]];

			audioOut = [[AudioOutStreamer alloc] initWithDeviceIp:comm.device_ip 
													   andPTTport:IRABOT_AUDIO_RECORDING_PORT];
			[audioOut connectToAudioSocket];

		}
		
	}
	return walkie_talkie_enabled ;
	
}


- (void) set_Walkie_Talkie_bg: (NSString *) status
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
	NSString * command = [NSString stringWithFormat:@"%@%@",SET_PTT,status];
	
	if(comm != nil)
	{
		[comm sendCommandAndBlock:command];
	}
	
	[pool release];
}

#pragma mark -
#pragma mark wifi level 

/* When video is on, batt and wifi are stored in video data, 
 use this function to update the UI
 */
- (void) update_battery_and_wifi:(Byte) wifi_and_battery 
{
	/* bit:0-3: battery
	 bit:4-7: wifi
	 */
	

	int wifi = (wifi_and_battery & 0xF0)>>4 ;
	UIImage *wifi_img = nil;
	
	//NSLog(@"battery: %d, wifi: %d", battery, wifi);

	
	// UPdate wifi status
	
	switch (wifi) {
		case 0: 
			wifi_img = [UIImage imageNamed:@"Wifi_0_icon.png"];
			break;
		case 1: //25% 
			wifi_img = [UIImage imageNamed:@"Wifi_1_icon.png"];
			break;
			
		case 2: //50%
			wifi_img = [UIImage imageNamed:@"Wifi_2_icon.png"];
			break;
		case 3: //75%
			wifi_img = [UIImage imageNamed:@"Wifi_3_icon.png"];
			break;
		case 4: //~100%
			wifi_img = [UIImage imageNamed:@"Wifi_full_icon.png"];
			break;
		default:
			break;
	}

	[self.camView.statusBar.wifi_status_icon setImage:wifi_img];
	
}

#pragma mark - 
#pragma mark Melody control



- (void) onMelody:(UIButton*)sender
{
	
	NSString * imageName = @"large_icon3_5.png";
	switch (melody_index) {
		case 0:
			melody_index = 1;
			imageName = @"large_icon3_1.png";
			break;
		case 1:
			melody_index = 2;
			imageName = @"large_icon3_2.png";
			break;
		case 2:
			melody_index  = 3;
			imageName = @"large_icon3_3.png";
			break;
		case 3:
		default:
			imageName = @"large_icon3_5.png";
			melody_index = 0;
			break;
	}
	
	
	UIImage * image = [UIImage imageNamed:imageName];
	[sender setImage:image forState:UIControlStateNormal];
	[self performSelectorInBackground:@selector(set_Melody_bg:) 
						   withObject:[NSString stringWithFormat:@"%d",melody_index]];
	
}

- (void) set_Melody_bg: (NSString *) status
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	@synchronized(self)
	{
		[self requestURLSync:[Util getMelodyURL:status]
				 withTimeOut:1.0];
		
		if ( [status isEqualToString:@"0"])
		{
			/* send audio_out0 */
			[self requestURLSync:[Util getWalkieTalkieURL:@"0"]
					 withTimeOut:1.0];
		}
	}
	
	
	[pool release];
	
}

- (void) set_current_melody_status:  (UIImageView*)sender updateIcons: (NSArray*) img_array
{
	
	NSString * response = nil;
	NSString * melody_hdr = @"value_melody: ";
	NSRange melody_hdr_range = {0, [melody_hdr length]};
	@synchronized(self)
	{
		response = [self requestURLSync:[Util getMelodyValueURL]
							withTimeOut:1.0];
		
		
		NSLog(@"response: %@", response);
	}
    if ( (response != nil) && 
		[response compare:melody_hdr 
				  options:NSCaseInsensitiveSearch 
					range:melody_hdr_range] == NSOrderedSame )
	{
		NSString * melody_val = [response substringFromIndex:[melody_hdr length]];
		
		
		NSString * imageName = [img_array objectAtIndex:0];
		switch ([melody_val intValue]) {
			case 1:
				melody_index = 1;
				imageName =  [img_array objectAtIndex:melody_index];
				break;
			case 2:
				melody_index = 2;
				imageName = [img_array objectAtIndex:melody_index];
				break;
			case 3:
				melody_index  = 3;
				imageName = [img_array objectAtIndex:melody_index];
				break;
			case 0:
			default:
				imageName =[img_array objectAtIndex:0];
				melody_index = 0;
				break;
		}
		
		UIImage * image = [UIImage imageNamed:imageName];
		[sender setImage:image];
	}
	
	
	
}

- (void) get_current_melody:  (UIButton*)sender updateIcons: (NSArray*) img_array
{
	NSString * response = nil;
	NSString * melody_hdr = @"value_melody: ";
	NSRange melody_hdr_range = {0, [melody_hdr length]};
	@synchronized(self)
	{
		response = [self requestURLSync:[Util getMelodyValueURL]
				 withTimeOut:1.0];
		

		NSLog(@"response: %@", response);
	}
    if ( (response != nil) && 
		[response compare:melody_hdr 
				  options:NSCaseInsensitiveSearch 
					range:melody_hdr_range] == NSOrderedSame )
	{
		NSString * melody_val = [response substringFromIndex:[melody_hdr length]];
		
		
		NSString * imageName = [img_array objectAtIndex:0];
		switch ([melody_val intValue]) {
			case 1:
				melody_index = 1;
				imageName =  [img_array objectAtIndex:melody_index];
				break;
			case 2:
				melody_index = 2;
				imageName = [img_array objectAtIndex:melody_index];
				break;
			case 3:
				melody_index  = 3;
				imageName = [img_array objectAtIndex:melody_index];
				break;
			case 0:
			default:
				imageName =[img_array objectAtIndex:0];
				melody_index = 0;
				break;
		}
		
		UIImage * image = [UIImage imageNamed:imageName];
		[sender setImage:image forState:UIControlStateNormal];
	}
	
}


#pragma mark -
#pragma mark SnapShot- NOT USED -- to be removed soon 

- (void) takeSnapShot:(UIImage *) image 
{
#if 0
	NSString *savedImagePath = [Util getSnapshotFileName];
	
	/* get it as PNG format */
	NSData *imageData = UIImagePNGRepresentation(image);
	[imageData writeToFile:savedImagePath atomically:NO]; 
#else

	/* save to photo album */
	UIImageWriteToSavedPhotosAlbum(image, 
								   self,
								   @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),
								   nil);

#endif
	
	
		
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	NSString *message;
	NSString *title;
	//self.statusLabel.text = @"";
	
	if (!error)
	{
		title = @"Snapshot";
		message = @"saved to the photo album";
		
	}
	else
	{
		title = @"Error";
		message = [error description];
		NSLog(@"Error when writing file to image library: %@", [error localizedDescription]);
        NSLog(@"Error code %d", [error code]);
		
	}
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
						  message:message 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

#pragma mark -
#pragma mark Video Recording - not used -- to be removed soon



- (void) startRecording
{
	
	
	iMaxRecordSize = [Util getMaxRecordSize] * 1024 * 1024;
	
	iFileName = [Util getRecordFileName];
	
	NSLog(@"Recording started: %@ max:%d",iFileName, iMaxRecordSize);

	if(iRecorder == NULL) {
		iRecorder = [[AviRecord alloc] init];
	}
	//[iRecorder Init:iFileName];
	
	[iRecorder InitWithFilename:iFileName video_width:320 video_height:240];



#if 0
	self.startRecordButton.enabled = NO;
	self.snapshotButton.enabled = NO;
	self.stopRecordButton.enabled = YES;
#endif
	

}

- (void) stopRecording
{
#if 0
	self.startRecordButton.enabled = YES;
	self.snapshotButton.enabled = YES;
	self.stopRecordButton.enabled = NO;
#endif
	
	
	[iRecorder Close];

	
	
}

#pragma mark -
#pragma mark HTTP Request 



- (void ) requestURLSync_bg:(NSString*)url {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//incase of demo, don't send the request
	
	{
		NSLog(@"url : %@", url);
		
		/* use a small value of timeout in this case */
		[self requestURLSync:url withTimeOut:IRABOT_HTTP_REQ_TIMEOUT];
	}
	
	[pool release];
}

/* Just use in background only */
- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout 
{
	
	//NSLog(@"send request: %@", url);
	
	NSURLResponse* response;
	NSError* error = nil;
	NSData *dataReply = nil;
	NSString * stringReply = nil;
	
	
	@synchronized(self)
	{
		
		// Create the request.
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:timeout];
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getCredentials]];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
		
		if (error != nil)
		{
			//NSLog(@"error: %@\n", error);
		}
		else {
			
			// Interpret the response
			stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
			[stringReply autorelease];
		}
		
		
	}
	
	
	return stringReply ;
}

#pragma mark -
#pragma mark Image scaling -- not used 

- (UIImage*)imageWithImage:(UIImage*)image scaledToRect:(CGRect)newRect
{
	UIGraphicsBeginImageContext(image.size);
	
	[image drawInRect:newRect];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}





//---------------------------------------------
//---------- direction stuff ------------------
//---------------------------------------------
#pragma mark -
#pragma mark Direction 

#define CMD_SENDING_INTERVAL 0.2 /*sec*/

/* call when touch begin */
- (void) updateVerticalDirection_begin:(int)dir inStep: (uint) step
{
	unsigned int newDirection = 0;
	//NSLog(@"updateVdir begin: %d", dir);
	if (dir == 0)
	{
		newDirection = DIRECTION_V_NON;
		
	}
	else //Dir is either V_UP or V_DN
	{
		if (dir >0)
		{
			newDirection = DIRECTION_V_DN;
		}
		else
		{
			newDirection = DIRECTION_V_UP;
			
		}
	}
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		currentDirUD = newDirection;
	}

	
	//Adjust the fire date to now 
	NSDate * now = [NSDate date];
	[send_UD_dir_req_timer setFireDate:now ];
	//Ask the timer to fire now ... 
	//[send_UD_dir_req_timer fire];
	
}

- (void) updateVerticalDirection_end:(int)dir inStep: (uint) step
{	
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		currentDirUD = DIRECTION_V_NON;
	}

	
	
}
/* called when user move finger on the screen */
- (void) updateVerticalDirection:(int)dir inStep: (uint) step withAnimation:(BOOL)animate
{
	
	
	unsigned int newDirection = 0;
	
	if (dir == 0)
	{
		newDirection = DIRECTION_V_NON;
		
	}
	else //Dir is either V_UP or V_DN
	{
		if (dir >0)
		{
			newDirection = DIRECTION_V_DN;
		}
		else
		{
			newDirection = DIRECTION_V_UP;
			
		}
	}
	
	//NSLog(@"newDir: %x", newDirection);
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		currentDirUD = newDirection;
	}

	
}




/* Periodically called every 200ms */
- (void) v_directional_change_callback:(NSTimer *) timer_exp
{
	
	
	
	/* currentDirUD holds the LATEST direction,
	 lastDirUD holds the LAST direction that we have seen
	 - this is called every 100ms
	 */
	@synchronized(self.camView.oneCamView.directionPad)
	{
		
		if (currentDirUD != lastDirUD)
		{
			//NSLog(@"vdir callback : %d  %d", currentDirUD, lastDirUD);
			[self send_UD_dir_to_rabot:currentDirUD];
		}
		
		//Update directions
		lastDirUD = currentDirUD;

	}
	
	return;
}






- (void) updateHorizontalDirection_begin:(int)dir inStep: (uint) step
{
	
	
	unsigned int newDirection = 0;
	
	
	
	if (dir == 0)
	{
		newDirection = DIRECTION_H_NON;
		
		
	}
	else
	{
		if (dir >0)
		{
			newDirection = DIRECTION_H_RT;
		}
		else
		{
			newDirection = DIRECTION_H_LF;	
			
		}	
		
	}
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		currentDirLR = newDirection;
		
	}

	
	
	//Adjust the fire date to now 
	NSDate * now = [NSDate date];
	[send_LR_dir_req_timer setFireDate:now ];
	
	
}

- (void) updateHorizontalDirection_end:(int)dir inStep: (uint) step
{
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		currentDirLR = DIRECTION_H_NON;
	}		

}


- (void) updateHorizontalDirection:(int)dir inStep: (uint) step withAnimation:(BOOL) animate
{
	
	unsigned int newDirection = 0;
	
	if (dir == 0)
	{
		newDirection = DIRECTION_H_NON;
		
	}
	else
	{
		if (dir >0)
		{
			newDirection = DIRECTION_H_RT;
		}
		else
		{
			newDirection = DIRECTION_H_LF;	
		}	
	}//if (currentDirLR != newDirection)
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		currentDirLR = newDirection;
	}
	

}



/* Periodically called every 200ms */
- (void) h_directional_change_callback:(NSTimer *) timer_exp
{
	
	@synchronized(self.camView.oneCamView.directionPad)
	{
		if (currentDirLR != lastDirLR)
		{
			[self send_LR_dir_to_rabot:currentDirLR];
		}
		//Update directions
		lastDirLR = currentDirLR;
	}
	
	return;
}




- (void) send_UD_dir_to_rabot:(int ) direction
{
	
	NSString * dir_str = nil;
	float duty_cycle = 0;
	
	switch (direction) {
		case DIRECTION_V_NON:
			
			dir_str= FB_STOP;
			break;

		case DIRECTION_V_DN	:


			duty_cycle = IRABOT_DUTYCYCLE_MAX +0.1;
			dir_str= MOVE_DOWN;
			dir_str = [NSString stringWithFormat:@"%@%.1f", dir_str, duty_cycle];
			
			break;
		case DIRECTION_V_UP	:

			duty_cycle = IRABOT_DUTYCYCLE_MAX ;
			dir_str= MOVE_UP;
			dir_str = [NSString stringWithFormat:@"%@%.1f", dir_str, duty_cycle];	
			break;
		default:
			break;
	}
	
	
	
	if (dir_str != nil)
	{
		// - Send direction update to device 
	//NSLog(@"send :%@ %f", dir_str, duty_cycle);
		//[self performSelectorInBackground:@selector(requestURLSync_bg:) 
		//					   withObject:[Util getMotorControlURL:dir_str 
		//												wDutyCycle:duty_cycle]];

		//Non block send-
		[comm sendCommand:dir_str];
		
		

	}
}




- (void) send_LR_dir_to_rabot:(int ) direction
{
	
	NSString * dir_str = nil;
	
	switch (direction) {
		case DIRECTION_H_NON:
			
			dir_str= LR_STOP;
			break;
		case DIRECTION_H_LF	:

			dir_str= MOVE_LEFT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str, IRABOT_DUTYCYCLE_LR_MAX];
			
			break;
		case DIRECTION_H_RT	:

			dir_str= MOVE_RIGHT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str, IRABOT_DUTYCYCLE_LR_MAX];
			
			break;
		default:
			break;
	}
	
	if (dir_str != nil)
	{
		
		[comm sendCommand:dir_str];
		//NSLog(@"send: %@", dir_str);
		//[self performSelectorInBackground:@selector(requestURLSync_bg:) 
//							   withObject:[Util getMotorControlURL:dir_str 
//														wDutyCycle:IRABOT_DUTYCYCLE_LR_MAX]];

	}
	
}

#pragma mark -
#pragma mark SetupHTTPDelegate




- (void)sendConfiguration:(DeviceConfiguration *) conf
{
	//get configuration string from conf and send over HTTP with default IP 
	NSString * device_configuration = [conf getDeviceConfString];
	
	NSString * setup_cmd = [NSString stringWithFormat:@"%@%@%@", 
							DEFAULT_AIBALL_SERVER, SETUP_HTTP_CMD,device_configuration];
	NSString * restart_cmd = [NSString stringWithFormat:@"%@%@", 
							  DEFAULT_AIBALL_SERVER,RESTART_HTTP_CMD];
	NSLog(@"before send: %@", setup_cmd);
	
	//- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout
	NSString * response = [self requestURLSync:setup_cmd withTimeOut:5];
	//TODO: check responses ..?
	response = [self requestURLSync:restart_cmd withTimeOut:5];
	
}

#pragma mark -
#pragma mark ConnectionMethodDelegate

/**** Main program entry point is here *****/ 
- (void)sendStatus:(int) method
{
	//TODO: #define all this constants
	switch (method) {
		case 1:
			//GOTO Direct mode
			NSLog(@"GO to direct mode");
			[self startDirectConnect];
			break;
		case 2: 
			//GOTO ROUTER mode
		{
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setBool:TRUE forKey:_AutoLogin];
			
			
			[NSTimer scheduledTimerWithTimeInterval:0.01
											 target:self
										   selector:@selector(show_login_or_reg:)
										   userInfo:nil
											repeats:NO];
						break;
		}
		case 3:
			
			[self dismissModalViewControllerAnimated:NO];
			self.progressView.hidden = NO;
			[self scan_for_devices];
			break; 
		case 4:
			NSLog(@" back from adding cam. relogin -- to get the new cam data"); 
			[NSTimer scheduledTimerWithTimeInterval:0.01
											 target:self
										   selector:@selector(show_login_or_reg:)
										   userInfo:nil
											repeats:NO];

			break; 
		case 5: //Just remove camera, currently in CameraMenu page 
		{
			NSLog(@"remove cam done");
			[self dismissModalViewControllerAnimated:NO];
			
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setBool:TRUE forKey:_AutoLogin];

			[NSTimer scheduledTimerWithTimeInterval:0.01
											 target:self
										   selector:@selector(show_login_or_reg:)
										   userInfo:nil
											repeats:NO];
			
			break;
		}
		default:
			break;
	}

}

-(void) show_login_or_reg:(NSTimer*) exp
{

	MBP_LoginOrRegistration * loginOrReg;
	loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration"
														   bundle:nil
												 withConnDelegate:self];
	
	[self presentModalViewController:loginOrReg animated:NO];
}



#pragma mark -
#pragma mark Read Configure data 




- (BOOL) restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
	if ([savedData restore_session_data] ==TRUE)
	{
		//NSLog(@"restored data done");
		self.channel_array = savedData.channels;
		
		
		self.restored_profiles = savedData.configured_cams;
	}
	
	return TRUE;
}

@end
