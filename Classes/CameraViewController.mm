//
//  CameraViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/31/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize  videoView;
@synthesize  temperature_label, videoAndSnapshotTime;
@synthesize  comm, scomm;
@synthesize  streamer,selected_channel;
@synthesize  alertTimer;
@synthesize  zoombar;
@synthesize  currentZoomLvl;

@synthesize  ptt_enabled,askForFWUpgradeOnce, enableControls, firstTimeConnect;


@synthesize barBtnName;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
        
		CFBundleRef mainbundle = CFBundleGetMainBundle();
		CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
		AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
        
        
		melodies = [[NSArray alloc] initWithObjects:@"Rock a Bye Baby",
                    @"Lullaby and Goodnight", @"Lavender Blue", @"Twinkle Twinkle Little Star",
                    @"Hush Little Baby",nil];
        
		self.askForFWUpgradeOnce = YES;
	}
	return self;
}

-(void) dealloc
{
    
	[temperature_label release];
	[videoAndSnapshotTime release];
    
	[super dealloc];
}
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    //disable timeout
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
	// Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    
	self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    
	if (self.selected_channel != nil)
	{
		CamProfile * cp = selected_channel.profile;
        
		melody_index = -1;
		//Set camera name
		barBtnName.title = cp.name;
        
		//set Button handler
		barBtnCamera.target = self;
		barBtnCamera.action = @selector(goBackToCameraList);
        
		//setting button handler
		barBtnSetttings.target = self;
		barBtnSetttings.action = @selector(goToCameraSettings);
        
		progressView.hidden = NO;
		[self.view addSubview:progressView];
		[self.view bringSubviewToFront:progressView];
        
        
        
        
        
		//Direction stuf
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
        
		//PTT stuff
		[self setupPtt];
        
		//video & snapshot stuff
		[self initVideoAndSnapshotView];
        
		currentZoomLvl = 0;
        
		ptt_enabled = TRUE;
        
        self.enableControls = FALSE;
        
		self.selected_channel.stopStreaming = FALSE;
        self.firstTimeConnect = TRUE; 
        
		//init the ptt port to default
		self.selected_channel.profile.ptt_port = IRABOT_AUDIO_RECORDING_PORT;
        
        
		[NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(startCameraConnection:)
                                       userInfo:nil
                                        repeats:NO];
        
	}
    
}

-(void) handleEnteredBackground
{
	NSLog(@"Back to camera list");
	//For now just go back to camera list
	[self goBackToCameraList];
}

-(void) startCameraConnection:(NSTimer *) exp
{
	//REMOTE OR LOCAL
	if (self.selected_channel.profile.isInLocal == YES)
	{
        
		[self setupInfraCamera:self.selected_channel];
	}
	else
	{
        

        
		[self prepareToViewRemotely:self.selected_channel];
	}
    
}




-(void) viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES];
	[self checkOrientation];
}



- (void)viewWillDisappear:(BOOL)animated {
	NSArray *viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
		// View is disappearing because a new view controller was pushed onto the stack
		NSLog(@"New view controller was pushed---> Settings");
	} else if ([viewControllers indexOfObject:self] == NSNotFound) {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down.. killall video thread");
        
		if (streamer.recordInProgress == YES)
			[streamer stopRecording];
		[streamer stopStreaming];
        
		//NSLog(@"abort remote timer ");
		[self.selected_channel abortViewTimer];
        
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults removeObjectForKey:CAM_IN_VEW];
		[userDefaults synchronize];
        
        
        
	}
}

-(void) checkOrientation
{
    
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
    
    
    
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

//// DEPRECATED from IOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	if (upgradeFwView != nil && ![upgradeFwView isHidden])
	{
		//Dont rotate if we are upgrading..
		return NO;
	}
	return YES;
}

//////////////// IOS6 replacement 

-(BOOL) shouldAutorotate
{
    NSLog(@"Should Auto Rotate"); 
    if (upgradeFwView != nil && ![upgradeFwView isHidden])
	{
		//Dont rotate if we are upgrading..
		return NO;
	}
	return YES;
}

/////////////

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    
	BOOL shouldShowProgress = FALSE;
    
	if (progressView.hidden == NO)
	{
		shouldShowProgress = TRUE;
	}
    
    
    
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        
		[[NSBundle mainBundle] loadNibNamed:@"CameraViewController_land"
                                      owner:self
                                    options:nil];
        
        
		//Need to rotate the video - snashot tool bar
        
        
        
		CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
		UIView* toolbar = [videoAndSnapshotView viewWithTag:1];
		toolbar.transform = transform;
		toolbar.frame = CGRectMake(369, 20, 111, 300) ;
        
        
        
		//Rotate the slider
		zoombarView.transform = CGAffineTransformRotate(zoombarView.transform, -M_PI*0.5);
		//Initializng the slider value to zero.
		self.zoombar.value=currentZoomLvl*ZOOM_STEP;
		zoombarView.frame = CGRectMake(440, 80, 41  ,224) ;
        
		UIImage *sliderMaximum = [[UIImage alloc] init];
		[self.zoombar setMinimumTrackImage:sliderMaximum forState:UIControlStateNormal];
		[self.zoombar setMaximumTrackImage:sliderMaximum forState:UIControlStateNormal];
		[self.zoombar setThumbImage:[UIImage imageNamed:@"zoom_bar_thumb_.png"] forState:UIControlStateNormal];
        
        
        
        
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
		[[NSBundle mainBundle] loadNibNamed:@"CameraViewController"
                                      owner:self
                                    options:nil];
        
		CGRect rect = [[UIApplication sharedApplication] statusBarFrame]; // Get status bar frame dimensions
		NSLog(@"Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
              rect.origin.y, rect.size.width, rect.size.height);
		//HACK : incase hotspot is turned on
		if (rect.size.height>21 &&  rect.size.height<50)
		{
			topToolBar.frame = CGRectMake(topToolBar.frame.origin.x,topToolBar.frame.origin.y+20,
                                          topToolBar.frame.size.width, topToolBar.frame.size.height);
		}
        
		//Rotate the slider
		zoombarView.transform = CGAffineTransformRotate(zoombarView.transform, -M_PI*0.5);
		//Initializng the slider value to zero.
		self.zoombar.value=currentZoomLvl*ZOOM_STEP;
		zoombarView.frame = CGRectMake(280, 200, 41  ,224) ;
        
		UIImage *sliderMaximum = [[UIImage alloc] init];
		[self.zoombar setMinimumTrackImage:sliderMaximum forState:UIControlStateNormal];
		[self.zoombar setMaximumTrackImage:sliderMaximum forState:UIControlStateNormal];
		[self.zoombar setThumbImage:[UIImage imageNamed:@"zoom_bar_thumb_.png"] forState:UIControlStateNormal];
	}
    
    
    
	//after this the streamer need to be updated
	streamer.videoImage = videoView;
	streamer.mTempUpdater = self;
	streamer.mFrameUpdater = self;
	streamer.recTimeLabel  = videoAndSnapshotTime;
	[streamer switchToOrientation:orientation];
    
	barBtnName.title = selected_channel.profile.name;
    
	//set Button handler
	barBtnCamera.target = self;
	barBtnCamera.action = @selector(goBackToCameraList);
    
	//setting button handler
	barBtnSetttings.target = self;
	barBtnSetttings.action = @selector(goToCameraSettings);
    
    
    
	//PTT stuff
	[self setupPtt];
    
	//
	[self initVideoAndSnapshotView];
    
	[self setUIMelodyOnOff];
    
	//re-show progress if  it is being shown
	if (shouldShowProgress)
	{
		[self.view addSubview:progressView];
		[self.view bringSubviewToFront:progressView];
	}
	else
	{
		progressView.hidden = YES;
	}
    
	//make rounded edge view
	lullabyView.layer.cornerRadius = 5;
	lullabyView.layer.masksToBounds = YES;
    
    
    
	UIButton * spk = (UIButton*) [self.view viewWithTag:SPK_CONTROL_BTN];
	if (spk != nil)
	{
		spk.selected = self.streamer.disableAudio;
	}
    
    
    
	UIButton * ptt = (UIButton *) [self.view viewWithTag:PTT_CONTROL_BTN];
	if (ptt != nil &&  (ptt_enabled == FALSE ))
	{
		ptt.selected = !ptt_enabled;
	}
    
    
}


-(void) goBackAndReLogin
{
	NSLog(@"Go all the way bacK");
    //enable timeout
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
	UITabBarController * root =  (UITabBarController *)[[self.navigationController viewControllers] objectAtIndex:0];
	[self.navigationController popToRootViewControllerAnimated:NO];
    
	DashBoard_ViewController * dashBoard =  (DashBoard_ViewController *)[[root viewControllers] objectAtIndex:0];
    
	[dashBoard forceRelogin];
}


-(void) goBackToCameraList
{
	NSLog(@"goback to camera list");
    
    
    
    //enable timeout
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
	if (streamer.recordInProgress == YES)
		[streamer stopRecording];
	[streamer stopStreaming];
    
    if (scanner != nil)
    {
        [scanner cancel];
    }
    
    
	//NSLog(@"abort remote timer ");
	[self.selected_channel abortViewTimer];
    
	[self.navigationController popToRootViewControllerAnimated:NO];
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:CAM_IN_VEW];
	[userDefaults synchronize];
    
    
}

-(void) goToCameraSettings
{
    
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return; 
    }
    
	MBP_MenuViewController * menuViewCtrl;
    
    
	menuViewCtrl = [[MBP_MenuViewController alloc] initWithNibName:@"MBP_MenuViewController"
                                                            bundle:nil withConnDelegate:self modeDirect:NO];
    
	if ((self.selected_channel.communication_mode == COMM_MODE_STUN) &&
        (self.scomm != nil))
	{
		menuViewCtrl.dev_s_comm = self.scomm;
		menuViewCtrl.camChan = self.selected_channel;
	}
    
	[self.navigationController pushViewController:menuViewCtrl animated:NO];
    
	//[menuViewCtrl presentModallyOn:self];
	[menuViewCtrl release];
}


-(void) setupInfraCamera:(CamChannel *) ch
{
    
	self.temperature_label.hidden = NO;
    
	//Set camera name
	//barBtnName.title = ch.profile.name;
    
    
	NSString* ip = ch.profile.ip_address;
	int port = ch.profile.port;
    
	NSLog(@"connect to cam %@: %@:%d",ch.profile.name, ip, port);
    
	//start fullscreen timer here..
	[self tryToShowFullScreen];
    
    
	if (ch.communication_mode == COMM_MODE_STUN)
	{
        
		//special treatment
		NSLog(@"created a STUN streamer on Thread: %@ isMain? %d ", [[NSThread currentThread] name], [[NSThread currentThread] isMainThread]);
        
		streamer = [[MBP_Streamer alloc]initWithIp:ip
                                           andPort:port
                                           handler:self ];
		streamer.remoteView = TRUE;
		streamer.remoteViewKey = ch.remoteViewKey;
		streamer.communication_mode = COMM_MODE_STUN;
		streamer.local_port = ch.localUdtPort;
        
		//use timer only if it is remote view
		[ch startViewTimer:self select:@selector(remoteViewTimeout:)];
        
		streamer.streamingChannel = ch;
        
		[streamer setVideoImage:videoView];
		streamer.mTempUpdater = self;
		streamer.mFrameUpdater = self;
		[streamer setRecTimeLabel:videoAndSnapshotTime];
		[streamer performSelector:@selector(startUdtStream) withObject:nil afterDelay:0.05];
        
        
        
		if (self.scomm != nil)
		{
            
			self.scomm = nil;
		}
        
		self.scomm = [[StunCommunication alloc]init];
        
        
	}
	else
	{
        
		if (comm != nil)
		{
			[comm release];
			comm = nil;
		}
        
		comm = [[HttpCommunication alloc]init];
		comm.device_ip = ip;
		comm.device_port = port;
		//[comm sendCommand:SET_RESOLUTION_QVGA];
        
        
        
        
		if (streamer != nil)
		{
			[streamer stopStreaming];
			[streamer release];
		}
        
        
        
        
		streamer = [[MBP_Streamer alloc]initWithIp:ip
                                           andPort:port
                                           handler:self ];
        
		//Support remote UPNP video as well
		if (ch.profile.isInLocal != TRUE &&
            ch.remoteViewKey != nil )
		{
			NSLog(@"created a remote streamer");
			streamer.remoteView = TRUE;
			streamer.remoteViewKey = ch.remoteViewKey;
			streamer.communication_mode = COMM_MODE_UPNP;
			//use timer only if it is remote view
			[ch startViewTimer:self select:@selector(remoteViewTimeout:)];
		}
		else
		{
			NSLog(@"created a local streamer");
			streamer.communication_mode = COMM_MODE_LOCAL;
		}
        
		[streamer setVideoImage:videoView];
		streamer.mTempUpdater = self;
		streamer.mFrameUpdater = self;
		[streamer setRecTimeLabel:videoAndSnapshotTime];
		[streamer startStreaming];
        
	}
    
    //Provide first orientation to streamer
    [streamer switchToOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    
    
	//Store current SSID - to check later
	NSString * streamingSSID = [CameraPassword fetchSSIDInfo];
	if (streamingSSID == nil)
	{
		NSLog(@"error: streamingSSID is nil before streaming");
	}
    
	NSLog(@"current SSID is: %@", streamingSSID);
    
    
	//Store some of the info for used in menu  --
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    
	[userDefaults setBool:!(isOffline) forKey:_is_Loggedin];
	if (streamingSSID != nil)
	{
		[userDefaults setObject:streamingSSID forKey:_streamingSSID];
	}
    
	NSString * old_usr_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    
	[userDefaults setObject:old_usr_email forKey:_UserName];
	[userDefaults setObject:old_pass forKey:_UserPass];
    
	[userDefaults setBool:ch.profile.isInLocal forKey:_DeviceInLocal];
	[userDefaults setInteger:port forKey:_DevicePort];
	[userDefaults setObject:ip forKey:_DeviceIp];
	[userDefaults setObject:ch.profile.mac_address forKey:_DeviceMac];
	[userDefaults setObject:ch.profile.name forKey:_DeviceName];
	[userDefaults setInteger:ch.communication_mode forKey:_CommMode];
	[userDefaults synchronize];
    
    
    
    
	//Disable speaker for remote connections
	if (ch.profile.isInLocal != TRUE)
	{
		UIButton * spk_btn = (UIButton*) [self.view viewWithTag:SPK_CONTROL_BTN];
		if (spk_btn != nil)
		{
            spk_btn.selected = YES;
            [self setEnableSpk:spk_btn.selected];
            
		}
        
		UIButton * ptt = (UIButton *) [self.view viewWithTag:PTT_CONTROL_BTN];
		if (ptt != nil)
		{
			ptt_enabled = FALSE;
			ptt.selected = !ptt_enabled;
		}
        
	}
    
    
	NSLog(@"End of setupInfraCamera");
}

#pragma mark -
#pragma mark  Temp & frame rate update



-(void) updateTemperature:(int) tempC
{
    
	float tempF ;
	if (tempC < 1 || tempC > 60)
	{
		return;
	}
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int tempunit = [userDefaults integerForKey:_tempUnit];
    
    
	switch (tempunit) {
		case 0://F
			tempF= ((float)tempC*9 + 32*5)/5;
            
			[temperature_label performSelectorOnMainThread:@selector(setText:)
                                                withObject:[NSString stringWithFormat:@"%d \u00B0F", (int)tempF]
                                             waitUntilDone:YES];
            
			break;
		case 1:
			[temperature_label performSelectorOnMainThread:@selector(setText:)
                                                withObject:[NSString stringWithFormat:@"%d \u00B0C", tempC]
                                             waitUntilDone:YES];
			break;
		default:
			break;
	}
    
    
    
    
	if (  tempC > HIGH_TEMPERATURE_THRESHOLD_C ||
        tempC < LOW_TEMPERATURE_THRESHOLD_C)
	{
		//Go RED
		[temperature_bg performSelectorOnMainThread:@selector(setImage:)
                                         withObject:[UIImage imageNamed:@"temp_alert_bg.png"]
                                      waitUntilDone:YES];
        
	}
	else
	{
		[temperature_bg performSelectorOnMainThread:@selector(setImage:)
                                         withObject:[UIImage imageNamed:@"temp_bg.png"]
                                      waitUntilDone:YES];
	}
    
    
    
    
}

-(void) updateFrameRate:(int) frameRate
{
	if ( frameRate < 5)
	{
		lowRes_label.hidden = NO;
		lowRes_bg.hidden = NO;
	}
	else
	{
		lowRes_label.hidden = YES;
		lowRes_bg.hidden = YES;
        
	}
}


#pragma mark -
#pragma mark StreamerEventHandler

-(void) playSound
{
	
    
	NSLog(@"Play the B");
 

	//201201011 This is needed to play the system sound on top of audio from camera
	UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;    // 1
	AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,                        // 2
                             sizeof (sessionCategory),                                   // 3
                             &sessionCategory                                            // 4
                             );

	//Play beep
	//AudioServicesPlaySystemSound(soundFileObject);
    AudioServicesPlayAlertSound(soundFileObject);
    
    
}

-(void) periodicPopup:(NSTimer *) exp
{
	NSString * msg = (NSString *) [exp userInfo];
    
	[self playSound];
    
    
	if ( alert != nil)
	{
		if ([alert isVisible])
		{
			[alert setMessage:msg];
            
			return;
		}
		else
		{
			NSLog(@"alert not visible -- going to release ");
		}
        
		[alert release];
		alert = nil;
        
	}
    
    
	alert = [[UIAlertView alloc]
             initWithTitle:@"" //empty on purpose
             message:msg
             delegate:self
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:nil];
    
	alert.tag = LOCAL_VIDEO_STOPPED_UNEXPECTEDLY;
	[alert show];
    
	[alert retain];
    
    
    
    
    
}

-(void) stopPeriodicPopup
{
	if (self.alertTimer != nil)
	{
		if ([self.alertTimer isValid])
		{
			[self.alertTimer invalidate];
		}
        
	}
	if ( alert != nil)
	{
		if ([alert isVisible])
		{
			[alert dismissWithClickedButtonIndex:1 animated:NO ];
		}
        
		[alert release];
		alert = nil;
        
	}
}



-(void) statusReport:(int) status andObj:(NSObject*) obj
{
    
	switch (status) {
		case CONNECTED_TO_CAMERA:
        {
            
            //update melody ui
            [self setUIMelodyOnOff];
            
            break;
        }
		case STREAM_STARTED:
        {
            self.enableControls = TRUE;
            progressView.hidden = YES;
            
            [self stopPeriodicPopup];
            
            if ( self.selected_channel.profile.isInLocal && (self.askForFWUpgradeOnce == YES))
            {
                [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
                self.askForFWUpgradeOnce = NO;
            }
            
            break;
        }
		case STREAM_STOPPED:
            
			break;
		case STREAM_STOPPED_UNEXPECTEDLY:
        {
            //Perform connectivity check - wifi?
            NSString * currSSID = [CameraPassword fetchSSIDInfo];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString * streamSSID =  (NSString *) [userDefaults objectForKey:_streamingSSID];
            NSString * msg = @"Camera disconnected due to network connectivity problem. Trying to reconnect..." ;
            
            if (currSSID != nil && streamSSID != nil)
            {
#if 0 // use only 1 message
                if ([currSSID compare:streamSSID] == NSOrderedSame)
                {
                    //Still on the same wifi
                    msg =@"Connection to camera has been lost. Please check the camera";
                }
                else // hooked up to a different wifi already
                {
                    msg = @"Network lost link. Please mover closer to the Router or connect your phone back to Wifi: " ;
                    msg = [msg stringByAppendingString:streamSSID];
                }
                
#endif
            }
            else
            {
                //either one of them is nil we skip this check
                NSLog(@"current %@, storedSSID: %@", currSSID, streamSSID);
            }
            
            
            //popup ?
            
            if (self.alertTimer != nil && [self.alertTimer isValid])
            {
                //some periodic is running dont care
                NSLog(@"some periodic is running dont care");
                
            }
            else
            {
                
                self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                   target:self
                                                                 selector:@selector(periodicPopup:)
                                                                 userInfo:msg
                                                                  repeats:YES];
                [self.alertTimer fire] ;//fire once now
                
            }
            
            /* Stop Streamming */
            [self.streamer stopStreaming];
            
            /* re-scan for the camera */
            [self scan_for_missing_camera];
            
            
            
            
            /* Start streaming 
            
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(startCameraConnection:)
                                           userInfo:nil
                                            repeats:NO];*/
            
            
            
            
            break;
        }
		case REMOTE_STREAM_STOPPED_UNEXPECTEDLY:
        {
            NSString * msg = @"Network lost link. Please check the Phone, Camera and Wifi router or move closer to the Router" ;
            
            // signal streamer to stop
            //self.streamer.hasStoppedByCaller = TRUE;
            
            
            if (self.alertTimer != nil && [self.alertTimer isValid])
            {
                //some periodic is running dont care
                NSLog(@"some periodic is running dont care");
            }
            else
            {
                
                self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                   target:self
                                                                 selector:@selector(periodicPopup:)
                                                                 userInfo:msg
                                                                  repeats:YES];
                [self.alertTimer fire] ;//fire once now
                
            }
            
            //Stop stream - clean up all resources
            [self.streamer stopStreaming];
            
            
            
            
            //[self prepareToViewRemotely:selected_channel];
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(startCameraConnection:)
                                           userInfo:nil
                                            repeats:NO];
            
            break;
        }
		case STREAM_RESTARTED:
			break;
        case REMOTE_STREAM_CANT_CONNECT_FIRST_TIME:
        {
            //Stop stream - clean up all resources
            [self.streamer stopStreaming];
            self.selected_channel.stopStreaming = TRUE;
            
            //simply popup and ask to retry and show camera list
            NSString * msg = @"Can't start video stream, the BabyMonitor is busy, try again later." ;
            
            if (self.selected_channel.remoteConnectionError == REQUEST_TIMEOUT)
            {
                msg = @"Server request timeout, try again later" ;
            }
            
            
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:msg
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            _alert.tag = REMOTE_VIDEO_CANT_START ;
            [_alert show];
            [_alert release];
            
            
            
                       
            break;
        }
		default:
			break;
	}
}

#pragma mark -
#pragma mark REMOTE CONNECTION SUPPORT

-(void) prepareToViewRemotely:(CamChannel *) ch
{
    
	if (ch.stopStreaming == TRUE)
	{
		return;
	}
    
	//setup remote camera via upnp
    
	RemoteConnection * cameraConn;

    ch.remoteConnectionError = NO_ERROR; 
    
	cameraConn = [[RemoteConnection alloc]init];
	if ([cameraConn connectToRemoteCamera:ch
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



#pragma mark Remote Connection Callbacks


-(void) remoteConnectionSucceeded:(CamChannel *) camChannel
{
    
	//Start to display this channel
	selected_channel = camChannel;
	if (self.selected_channel.stopStreaming == TRUE)
	{
		return;
	}
    
    
  
    
	NSLog(@"Remote camera-channel is %d with cam name: %@", selected_channel.channel_index, selected_channel.profile.name);
	[self setupInfraCamera:selected_channel];

    
    
}

-(void) remoteConnectionFailed:(CamChannel *) camChannel
{
	NSLog(@"Remote connection Failed!!!");
    
	if (self.selected_channel.stopStreaming == TRUE)
	{
		return;
	}
    
    
    
	progressView.hidden = YES;
    
    if (self.firstTimeConnect == TRUE)
    {
        self.firstTimeConnect = FALSE;
        
        [self statusReport:REMOTE_STREAM_CANT_CONNECT_FIRST_TIME andObj:nil];
    }
    else
    {
    
        [self statusReport:REMOTE_STREAM_STOPPED_UNEXPECTEDLY andObj:nil];
    }
    
    
}

-(void) remoteViewTimeout:(NSTimer *) expired
{
	//View time as expired --- popup now.
	if (self.selected_channel.stopStreaming == TRUE)
	{
		return;
	}
    
	UIAlertView *_alert = [[UIAlertView alloc]
                           initWithTitle:@"Time out"
                           message:@"The video has been viewed for about 5 minutes. Do you want to continue?"
                           delegate:self
                           cancelButtonTitle:@"No"
                           otherButtonTitles:@"Yes",nil];
	_alert.tag = REMOTE_VIDEO_TIMEOUT;
	[_alert show];
	[_alert release];
}


#pragma mark -
#pragma mark Alertview delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
	int tag = alertView.tag;
    
	if (tag == REMOTE_VIDEO_TIMEOUT)
	{
		switch(buttonIndex) {
			case 0:
				NSLog(@"Stop remote view -- go back to camera list-");
                
				self.selected_channel.stopStreaming = TRUE;
				[self goBackToCameraList];
                
				break;
			case 1:
            {
                //video is still playing now-- no need to stop

                NSLog(@"start the 2nd round on isMain? %d ",[[NSThread currentThread] isMainThread]);
                //just refresh the timer..
                if (selected_channel != nil)
                {
                    [selected_channel refreshTimer];
                    
                    
                }
            }
				break;
			default:
				break;
		}
	}
	else if (tag == LOCAL_VIDEO_STOPPED_UNEXPECTEDLY)
	{
		switch(buttonIndex) {
			case 0: //Cancel
				NSLog(@"Stop monitoring  -- go back to camera list-");
				[self stopPeriodicPopup];
                
				self.selected_channel.stopStreaming = TRUE;
                
				[self goBackToCameraList];
                
				break;
                
			default:
				break;
		}
		[alert release];
		alert = nil;
	}
	else if (tag == REMOTE_VIDEO_STOPPED_UNEXPECTEDLY)
	{
		switch(buttonIndex) {
			case 0: //Stop monitoring
				NSLog(@"Stop monitoring  -- go back to camera list-");
				[self stopPeriodicPopup];
				self.selected_channel.stopStreaming = TRUE;
				[self goBackToCameraList];
                
				break;
			case 1: //continue -- streamer is connecting so we dont do anything here.
				break;
			default:
				break;
		}
        
		[alert release];
		alert = nil;
	}
	else if (tag ==FW_OTA_UPGRADE_AVAILABLE)
	{
		switch(buttonIndex) {
			case 0: //Cancel
                
                
				break;
			case 1: //OK - request_fw_upgrade.
				//Stop streaming first
				[self.streamer stopStreaming];
                
				[self startUpgradeFW];
                
                
				break;
			default:
				break;
		}
	}
    else if (tag == REMOTE_VIDEO_CANT_START)
    {
        
        [self goBackToCameraList];
    }
    
}


#pragma mark -

#pragma mark Special case -- camera removed
- (void)sendStatus:(int) method
{
    
	switch (method) {
		case 1: //this camera is going to be removed soon..do sth about it now.
        {
            NSLog(@"Stop Streaming ");
            //Stop streaming first
            [streamer stopStreaming];
            break;
        }
            
	}
}
#pragma mark -


#pragma mark -
#pragma mark Hide & Show subfunction
-(void) exitSubFunction
{
	pttButton.hidden = YES;
	[self swithVideoAndSnapshotView:NO];
    
}
-(void)hideAllFunction
{
	[self exitSubFunction];
    
	directionPad.hidden = YES;
	controlButtons.hidden = YES;
	zoombarView.hidden = YES;
	topToolBar.hidden = YES;
    
}

- (void) tryToShowFullScreen
{
    
	if ( (fullScreenTimer != nil) && [fullScreenTimer isValid])
	{
		//invalidate the timer ..
		[fullScreenTimer invalidate];
		fullScreenTimer = nil;
	}

	fullScreenTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                       target:self
                                                     selector:@selector(showFullScreenNow:)
                                                     userInfo:nil
                                                      repeats:NO];
    
}

- (void) showJoysticksOnly
{
	NSLog(@"show joystick & cancel FS timer.");
    
	directionPad.hidden = NO;
    

    if ( (fullScreenTimer != nil) && [fullScreenTimer isValid])
	{
		//invalidate the timer ..
		[fullScreenTimer invalidate];
		fullScreenTimer = nil;
	}

}



- (void) showFullScreenNow: (NSTimer*) exp
{
    
	fullScreenTimer = nil;
	topToolBar.hidden = YES;
	directionPad.hidden = YES;
	controlButtons.hidden = YES;
	zoombarView.hidden = YES;
    pttButton.hidden = YES;
    
    
}


- (void) showSideMenusAndStatus
{
	NSLog(@"111 show menus");
	topToolBar.hidden = NO;
	directionPad.hidden = NO;
	controlButtons.hidden = NO;
	zoombarView.hidden = NO;
	[self exitSubFunction];
    
	[self tryToShowFullScreen];
    
}

-(void) toggleFullScreenAndControls
{
	if ( [controlButtons isHidden] &&
        [videoAndSnapshotView isHidden] &&
        [directionPad isHidden])
	{ //currently fullscreen --> show controls
        
		[self showSideMenusAndStatus];
	}
	else
	{
        
		[self hideAllFunction];
	}
}

#pragma mark -


#pragma  mark -
#pragma mark Video And Snapshot
-(void) initVideoAndSnapshotView
{
	//set bg image
	UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"vid_snap_bg.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
	UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"vid_snap_bg.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
	[videoAndSnapshotSlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
	[videoAndSnapshotSlider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    
	//hide thumb image
	[videoAndSnapshotSlider setThumbImage:[UIImage imageNamed:@"bb_vid_snap_knob.png"] forState:UIControlStateNormal];
    
	videoAndSnapshotView.hidden = YES;
	[self.view addSubview:videoAndSnapshotView];
    
    
}

-(void) swithVideoAndSnapshotView:(BOOL) on
{
    
    
	//[self hideAllFunction];
    
	if (on == YES)
	{
		if ([videoAndSnapshotView isHidden])
		{
			[self.view bringSubviewToFront:videoAndSnapshotView];
			videoAndSnapshotView.hidden = NO;
		}
	}
	else
	{
        
		if (![videoAndSnapshotView isHidden])
		{
            
			videoAndSnapshotView.hidden = YES;
		}
        
		//Stop recording if user exit subfunction
		if (streamer.recordInProgress == YES)
		{
			[streamer toggleRecording];
		}
        
	}
}

-(IBAction)buttonCamPressed:(id)sender
{
    
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
	[self hideAllFunction];
    
	[self swithVideoAndSnapshotView:YES];
    
}
-(IBAction)buttonSnapPress:(id)sender
{
    
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	//
	if (videoAndSnapshotSlider.value == 0)
	{
        
        
		//snapshot
		if (streamer.recordInProgress == NO)
		{
			streamer.takeSnapshot = YES;
		}
	}
	else
	{
		//20121010: issue 412 : disable until we finish implementing the video app
        
		NSString * msg = @"Video recording is not supported, comming soon";
        
		UIAlertView *
        _alert = [[UIAlertView alloc]
                  initWithTitle:@"Not supported"
                  message:msg
                  delegate:self
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil];
        
		[_alert show];
		[_alert release];
        
#if 0
		//video cap
		[streamer toggleRecording ];
        
		if (streamer.recordInProgress == YES)
		{
            
			if ([videoAndSnapshotTime isHidden])
			{
				videoAndSnapshotTime.hidden = NO;
			}
            
			[videoAndSnapshotButton setImage:[UIImage imageNamed:@"bb_recording_btn_d.png" ]
                                    forState:UIControlStateNormal];
            
		}
		else
		{
			if (![videoAndSnapshotTime isHidden])
			{
				videoAndSnapshotTime.hidden = YES;
			}
            
			[videoAndSnapshotButton setImage:[UIImage imageNamed:@"bb_recording_btn.png" ]
                                    forState:UIControlStateNormal];
		}
#endif
	}
}

- (IBAction)sliderChanged:(id)sender
{
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	int sliderValue;
	sliderValue = lroundf(videoAndSnapshotSlider.value);
	[videoAndSnapshotSlider setValue:sliderValue animated:YES];
    
	if (videoAndSnapshotSlider.value == 0)
	{
		//snapshot
		[videoAndSnapshotButton setImage:[UIImage imageNamed:@"bb_cam_btn.png" ]
                                forState:UIControlStateNormal];
        
        
	}
	else
	{
		//video cap
		[videoAndSnapshotButton setImage:[UIImage imageNamed:@"bb_recording_btn.png" ]
                                forState:UIControlStateNormal];
	}
    
    
}

#pragma  mark -

#pragma  mark -
#pragma mark SPK


-(IBAction)buttonSpkPressed:(id)sender
{
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	int tag = ((UIView *) sender).tag;
    
	switch (tag)
	{
		case SPK_CONTROL_BTN:
			UIButton * btn = (UIButton *) sender;
			//toggle
			if (([btn state] &  UIControlStateSelected )== UIControlStateSelected)
			{
				btn.selected = NO;
                
			}
			else
			{
				btn.selected = YES;
			}
            
            
			[self setEnableSpk:btn.selected];
            
			break;
	}
    
}

- (void) setEnableSpk:(BOOL) enableSpk
{
	self.streamer.disableAudio = enableSpk;
}

#pragma  mark -

#pragma  mark -
#pragma mark Zoom control




-(IBAction)silderMoved:(id)sender
{
    
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	//NSLog(@"Slider moved");
	UISlider * slider = (UISlider *) sender;
	int sliderValue = (int) (slider.value/ZOOM_STEP);
    
	[slider setValue:(sliderValue*ZOOM_STEP) animated:YES];
    
	currentZoomLvl = (float)sliderValue;
	//NSLog(@"Slider moved: %f", currentZoomLvl);
	if (self.streamer != nil)
	{
        
		if (currentZoomLvl >5.0)
		{
			currentZoomLvl = 5.0;
		}
		else if (currentZoomLvl < 0.0)
		{
			currentZoomLvl =0.0 ;
		}
        
        
        
        
        
		[self.streamer setCurrentZoomLevel:self.currentZoomLvl];
        
        
	}
    
}
#pragma  mark -

#pragma  mark -
#pragma mark PTT

- (BOOL) setEnablePtt:(BOOL) walkie_talkie_enabled
{
    
    
	@synchronized (self)
	{
		if ( walkie_talkie_enabled == YES)
		{
            
			[self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                                   withObject:[NSString stringWithFormat:@"%d",walkie_talkie_enabled]];
            
			audioOut = [[AudioOutStreamer alloc] initWithDeviceIp:comm.device_ip
                                                       andPTTport:self.selected_channel.profile.ptt_port];
			[audioOut retain];
			[audioOut connectToAudioSocket];
            
            
		}
		else
		{
            
            
			[self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                                   withObject:[NSString stringWithFormat:@"%d",walkie_talkie_enabled]];
            
			if (audioOut != nil)
			{
				NSLog(@"disconnect audio out ");
				[audioOut disconnectFromAudioSocket];
				[audioOut release];
			}
            
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

-(void) setupPtt
{
    
	UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPress:)];
	longPress.minimumPressDuration = 1.0;
	[pttButton addGestureRecognizer:longPress];
	[longPress release];
    
}


-(void) longPress:(UILongPressGestureRecognizer*) gest
{
    
	UIButton * btn = (UIButton *)[gest view];
    
    
	if ([gest state] == UIGestureRecognizerStateBegan)
	{
		[btn setImage:[UIImage imageNamed:@"bb_vs_mike_off.png"] forState:UIControlStateNormal];
		NSLog(@"start PTT");
		[self setEnablePtt:YES];
        
        
	}
	else if ([gest state] == UIGestureRecognizerStateEnded)
	{
		[btn setImage:[UIImage imageNamed:@"bb_vs_mike_on.png"] forState:UIControlStateNormal];
        
		NSLog(@"stop PTT - start fullscreen timer ");
		[self setEnablePtt:NO];
        
        [self tryToShowFullScreen];
        
		UIButton * spk = (UIButton*) [self.view viewWithTag:SPK_CONTROL_BTN];
		if (spk != nil && (self.streamer.disableAudio == TRUE))
		{
			//Toggle camera audio when ptt disabled
			NSLog(@"Toggle camera audio when ptt disabled ");
			[spk sendActionsForControlEvents:UIControlEventTouchUpInside];
		}
        
	}
    
    
}

-(void) showPttButton
{
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	pttButton.hidden = NO;
	[self.view bringSubviewToFront:pttButton];
    
    //Disable fullscreen timer
    if ( (fullScreenTimer != nil) && [fullScreenTimer isValid])
	{
		//invalidate the timer ..
		[fullScreenTimer invalidate];
		fullScreenTimer = nil;
	}
    
}




-(IBAction)buttonPttPressed:(id)sender
{
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	if ( (self.selected_channel != nil) &&
        (self.selected_channel.communication_mode == COMM_MODE_STUN)
        )
	{
		//Dont support in stun mode
		NSLog(@"STUN mode -- return");
		return;
	}
    
	UIButton * pttBtn  = (UIButton *) sender;
	int tag = pttBtn.tag;
    
	if (ptt_enabled == FALSE)
	{
		ptt_enabled = TRUE;
		pttBtn.selected = FALSE;
        
        
	}
    
    
    
    
    
	switch (tag)
	{
		case PTT_CONTROL_BTN:
			directionPad.hidden = YES;
            
			[self showPttButton];
			break;
	}
}




#pragma  mark -


#pragma  mark -
#pragma mark Melody

-(void) setUIMelodyOnOff
{
	NSData * responseData  = [comm sendCommandAndBlock_raw:GET_MELODY];
    
	if (responseData != nil)
	{
		NSString *response = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
		if ( (response != nil)  && [response hasPrefix:GET_MELODY])
		{
			NSString * str_value = [response substringFromIndex:([GET_MELODY length] + 2)];
            
			int _melody_index  = [str_value intValue];
            
			if (_melody_index == 0)
			{
				//set icon off
				[lullabyButton setImage:[UIImage imageNamed:@"bb_melody_off_icon.png"] forState:UIControlStateNormal];
				[lullabyOnOff setOn:FALSE];
                
				melody_index = -1;
                
			}
			else
			{
				melody_index = (_melody_index-1) ;
                
				//set icon on
				[lullabyButton setImage:[UIImage imageNamed:@"bb_melody_icon.png"] forState:UIControlStateNormal];
				[lullabyOnOff setOn:TRUE];
                
                
				UITableView * melodies_tb = (UITableView *) [lullabyView viewWithTag:1];
				[melodies_tb reloadData];
			}
            
            
		}
        
	}
    
}

-(IBAction) buttonMelodyPressed:(id) sender
{
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
	int tag = ((UIView *) sender).tag;
    
	switch (tag)
	{
		case MEL_CONTROL_BTN:
			lullabyView.hidden = NO;
			[self.view bringSubviewToFront:lullabyView];
			break;
		case MEL_CANCEL_BTN:
		case MEL_DONE_BTN:
			lullabyView.hidden  = YES;
			break;
		case MEL_ONOFF_SW:
            
			UISwitch * onOff = (UISwitch *)sender;
			if ([onOff isOn])
			{
                
			}
			else
			{
                
				//Clear all melody
				UITableView * melodies_tb = (UITableView *) [lullabyView viewWithTag:1];
                
				NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:melody_index inSection:1];
				UITableViewCell *oldCell = [melodies_tb cellForRowAtIndexPath:oldIndexPath];
				if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
					oldCell.accessoryType = UITableViewCellAccessoryNone;
					NSLog(@"disable checkmark for index:%d", oldIndexPath.row);
				}
                
                
				melody_index = -1;
				//send melody off
				[self setMelody:[[NSNumber alloc]initWithInt:0]];
			}
            
            
			break;
            
	}
    
}

-(void) setMelody:(NSNumber *) melody
{
	NSString * command = nil;
	int melodyIdx = [melody intValue];
    
	if (melodyIdx == 0 ) //mute
	{
		command = SET_MELODY_OFF;
		[lullabyOnOff setOn:FALSE];
		[lullabyButton setImage:[UIImage imageNamed:@"bb_melody_off_icon.png"] forState:UIControlStateNormal];
	}
	else
	{
		command = [NSString stringWithFormat:@"%@%d",SET_MELODY,melodyIdx];
		[lullabyButton setImage:[UIImage imageNamed:@"bb_melody_icon.png"] forState:UIControlStateNormal];
		[lullabyOnOff setOn:TRUE];
        
	}
    
	if (selected_channel.communication_mode == COMM_MODE_STUN)
	{
		if (self.scomm != nil)
		{
			NSLog(@"sending melody");
            
            
			[self.scomm sendCommandThruUdtServer:command
                                         withMac:self.selected_channel.profile.mac_address
                                      AndChannel:self.selected_channel.channID];
		}
		else {
			NSLog(@"sending melody self.scomm == nil");
		}
	}
	else
	{
        
		if (comm != nil)
		{
			[comm sendCommandAndBlock:command];
		}
	}
    
}

#pragma mark -
#pragma mark TableView delegate



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if (section ==0 ) return 1;
    
	return [melodies count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
	return 2;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	if (indexPath.section == 0 )
	{
		return musicOnOffCell;
        
	}
	else if (indexPath.section == 1 )
	{
		static NSString *CellIdentifier = @"Cell";
        
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"SongTitleView" owner:self options:nil];
			cell = songtitleCell;
			songtitleCell = nil;
		}
        
        
		NSString * title = (NSString *) [melodies objectAtIndex:indexPath.row];
		UILabel * _stitle = (UILabel *)[cell viewWithTag:1];
		_stitle.text = title;
        
		cell.accessoryType = UITableViewCellAccessoryNone;
        
		if (indexPath.row == melody_index)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
        
        
		return cell;
	}
    
    
	return nil;
    
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	if (melody_index == indexPath.row)
	{
		return;
	}
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:melody_index inSection:1];
    
	UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
	if (newCell.accessoryType == UITableViewCellAccessoryNone) {
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
		melody_index= indexPath.row;
	}
    
    
    
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
	if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
		oldCell.accessoryType = UITableViewCellAccessoryNone;
        
	}
    
	[self performSelector:@selector(setMelody:)
               withObject:[[NSNumber alloc]initWithInt:(melody_index+1)]
               afterDelay:0.01];
    
    
}



#pragma  mark -

#pragma  mark -
#pragma mark touches



//----- handle all touches here then propagate into directionview

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	UITouch *touch;
	CGPoint location ;
	NSSet *allTouches = [event allTouches];
    
	[super touchesBegan:touches withEvent:event];
    
    
	[self toggleFullScreenAndControls];
    
	int i =0;
    
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
        
		location = [touch locationInView:touch.view];
        
        
		if (touch.view.tag == VIEW_DIRECTIONPAD_TAG)
		{
			//NSLog(@"touched view: loc: %f %f", location.x, location.y);
			[self showJoysticksOnly];
			[self touchEventAt:location phase:touch.phase];
		}
        
	}
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
	UITouch *touch;
	CGPoint location ;
	NSSet *allTouches = [event allTouches];
	[super touchesEnded:touches withEvent:event];

	int i =0;
    
	
    
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
		//NSLog(@"touched view:Tag:%d", touch.view.tag);
		location = [touch locationInView:touch.view];
        
		if (touch.view.tag == VIEW_DIRECTIONPAD_TAG)
		{
            
			[self touchEventAt:location phase:touch.phase];
            [self tryToShowFullScreen];
		}
        
        
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.enableControls == FALSE)
    {
        //siliently return;
        return;
    }
    
    
	UITouch *touch;
	CGPoint location ;
	NSSet *allTouches = [event allTouches];
    
    
	[super touchesMoved:touches withEvent:event];
	//NSLog(@" MOVED Touches count: %d", [allTouches count]);
	int i =0;
    
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
		//NSLog(@"touched view:Tag:%d", touch.view.tag);
		location = [touch locationInView:touch.view];
        
		if (touch.view.tag == VIEW_DIRECTIONPAD_TAG)
		{
            
            
            
			[self touchEventAt:location phase:touch.phase];
		}
        
        
	}
    
}





- (void) validatePoint: (CGPoint)location newMovement:(BOOL) isBegan
{
	CGPoint translation ;
    
	BOOL is_vertical;
    
	CGPoint beginLocation = CGPointMake(directionPad.center.x -directionPad.frame.origin.x,
                                        directionPad.center.y -directionPad.frame.origin.y);
    
    
	//NSLog(@"val: loc: %f %f", location.x, location.y);
	//NSLog(@"val: begin: %f %f", beginLocation.x, beginLocation.y);
    
    
	translation.x =  location.x - beginLocation.x;
	translation.y =  location.y - beginLocation.y;
	//NSLog(@"val: tran: %f %f", translation.x, translation.y);
	is_vertical = YES;
	if ( abs(translation.x) >  abs(translation.y))
	{
		is_vertical = NO;
	}
    
    
	if (is_vertical == YES)
	{
        
		///TODOO: update image
		if (translation.y > 0)
		{
            
			[directionPad setImage:[UIImage imageNamed:@"circle_buttons1_dn.png"]];
		}
		else if (translation.y <0)
		{
            
            
			[directionPad setImage:[UIImage imageNamed:@"circle_buttons1_up.png"]];
		}
		else
		{
			[directionPad setImage:[UIImage imageNamed:@"circle_buttons1_2.png"]];
		}
        
        
        
		if (isBegan)
		{
            
			[self updateVerticalDirection_begin:translation.y inStep:0];
		}
		else
		{
			[self updateVerticalDirection:translation.y inStep:0 withAnimation:FALSE];
		}
        
	}
	else
	{
		///TODOO: update image
		if (translation.x > 0)
		{
            
			[directionPad setImage:[UIImage imageNamed:@"circle_buttons1_rt.png"]];
		}
		else if (translation.x < 0){
            
			[directionPad setImage:[UIImage imageNamed:@"circle_buttons1_lf.png"]];
		}
		else
		{
			[directionPad setImage:[UIImage imageNamed:@"circle_buttons1_2.png"]];
		}
        
		if (isBegan)
		{
			[self updateHorizontalDirection_begin:translation.x inStep:0];
		}
		else {
            
			[self updateHorizontalDirection:translation.x inStep:0 withAnimation:FALSE];
		}
	}
    
}


- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase
{
    
	switch (phase) {
		case UITouchPhaseBegan:
			[self _touchesbegan:location];
			break;
		case UITouchPhaseMoved:
		case UITouchPhaseStationary:
			[self _touchesmoved:location];
			break;
		case UITouchPhaseEnded:
			[self _touchesended:location];
            
		default:
			break;
	}
}

- (void) _touchesbegan: (CGPoint) location
{
    
    
	[self validatePoint:location newMovement:YES ];
    
    
    
}

- (void) _touchesmoved: (CGPoint) location
{
	[self validatePoint:location newMovement:NO ];
    
}

- (void) _touchesended: (CGPoint) location
{
    
    
    
	CGPoint beginLocation = CGPointMake(directionPad.center.x -directionPad.frame.origin.x,
                                        directionPad.center.y -directionPad.frame.origin.y);
    
	[self validatePoint:beginLocation newMovement:NO ];
    
    
    
    
#if 1
    
	[self updateVerticalDirection_end:0 inStep:0];
    
	[self updateHorizontalDirection_end:0 inStep:0];
#endif
    
}
#pragma mark -

#pragma mark -
#pragma mark Direction


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
    
	@synchronized(directionPad)
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
    
	@synchronized(directionPad)
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
    
	@synchronized(directionPad)
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
	@synchronized(directionPad)
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
    
	@synchronized(directionPad)
	{
		currentDirLR = newDirection;
        
	}
    
    
    
	//Adjust the fire date to now 
	NSDate * now = [NSDate date];
	[send_LR_dir_req_timer setFireDate:now ];
    
    
}

- (void) updateHorizontalDirection_end:(int)dir inStep: (uint) step
{
    
	@synchronized(directionPad)
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
    
	@synchronized(directionPad)
	{
		currentDirLR = newDirection;
	}
    
    
}



/* Periodically called every 200ms */
- (void) h_directional_change_callback:(NSTimer *) timer_exp
{
    
	@synchronized(directionPad)
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
        
        
		if (selected_channel.communication_mode == COMM_MODE_STUN)
		{
			if (self.scomm != nil)
			{
				NSLog(@"sending UD Direction: ");
                
                
				[self.scomm sendCommandThruUdtServerNonBlock:dir_str 
                                             withMac:self.selected_channel.profile.mac_address
                                          AndChannel:self.selected_channel.channID];
			}
		}
		else 
		{
            
			if (comm != nil)
			{
				//Non block send-
				[comm sendCommand:dir_str];
                
			}
		}
        
        
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
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str,(float) IRABOT_DUTYCYCLE_LR_MAX];
            
			break;
		case DIRECTION_H_RT	:
            
			dir_str= MOVE_RIGHT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str,(float) IRABOT_DUTYCYCLE_LR_MAX];
            
			break;
		default:
			break;
	}
    
	if (dir_str != nil)
	{
        
		if (selected_channel.communication_mode == COMM_MODE_STUN)
		{
			if (self.scomm != nil)
			{
				NSLog(@"sending LR Direction: ");
                
                
				[self.scomm sendCommandThruUdtServerNonBlock:dir_str 
                                             withMac:self.selected_channel.profile.mac_address
                                          AndChannel:self.selected_channel.channID];
			}
		}
		else 
		{
            
			if (comm != nil)
			{
				//Non block send-
				[comm sendCommand:dir_str];
                
			}
		}
        
        
	}
    
}

#pragma mark - 
#pragma mark FW OTA UPGRADE


-(void) showFWUpgradeDialog:(NSString *) version
{
    
    
	NSString * msg = [NSString stringWithFormat:@"A camera firmware %@ is available. Do you want to upgrade now?",version];
    
	UIAlertView *
    _alert = [[UIAlertView alloc]
              initWithTitle:@"Camera Firwmare Upgrade" 
              message:msg
              delegate:self
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@"OK",nil];
    
	_alert.tag = FW_OTA_UPGRADE_AVAILABLE;
	[_alert show];
	[_alert release]; 
    
    
}

- (void) checkIfUpgradeIsPossible
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    
	NSString * command = [NSString stringWithFormat:@"%@",CHECK_FW_UPGRADE];
    
	if(comm != nil)
	{
		NSString * response = [comm sendCommandAndBlock:command];
        
		//if upgrade is not possible : return '0' or if command is not supported 'check_fw_upgrade: -1' 
        
		response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
		if ( [response isEqualToString:@"0"] || [response isEqualToString:@"check_fw_upgrade: -1"])
		{
			//NO upgrade
			//simply die off
            
			NSLog(@"NOoooo Upgrade "); 
		}
		else 
		{
            
            
			//some upgrade is available .. 
            
			NSLog(@"Upgrade possible"); 
			[self performSelectorOnMainThread:@selector(showFWUpgradeDialog:) withObject:response waitUntilDone:NO];
		}
        
        
        
	}
    
	[pool release];
}

-(void) startUpgradeFW
{
	//Load the UI 
	[[NSBundle mainBundle] loadNibNamed:@"FWUpgradeView" owner:self options:nil];
    
	//Disable all these since we will get out of here after finishing
	topToolBar.userInteractionEnabled = NO; 
	controlButtons.userInteractionEnabled = NO; 
	directionPad.userInteractionEnabled = NO; 
	temperature_label.hidden = YES;
	temperature_bg.hidden = YES; 
	self.view.userInteractionEnabled = NO; 
    
	[self.view addSubview:upgradeFwView]; 
	[self.view bringSubviewToFront:upgradeFwView]; 
    
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) 
	{
		CGAffineTransform transform = CGAffineTransformMakeTranslation(80,20);
		upgradeFwView.transform = transform;
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) 
	{
        
		CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 120);
		upgradeFwView.transform = transform;
        
	}
    
	percentageLabel.text = @"--"; 
	percentageProgress.progress = 0.0; 
    
    
    
	NSString * command = [NSString stringWithFormat:@"%@",REQUEST_FW_UPGRADE];
    
	if(comm != nil)
	{
		[comm sendCommandAndBlock:command];
	}
    
	[self performSelectorInBackground:@selector(upgradeFwProgress_bg)  withObject:nil] ;
    
    
    
}


-(void) upgradeFwProgress_ui:(NSNumber *) number
{
	int value =  [number intValue]; 
	float _value = (float) value;
	_value = _value/100.0; 
    
	if (value >=0)
	{
		percentageLabel.text = [NSString stringWithFormat:@"%d%%", value];
		percentageProgress.progress = _value; 
	}
    
}

-(void) upgradeDoneWaitForReboot
{
	UILabel * text = (UILabel*)[upgradeFwView viewWithTag:12];  
	text.text = @"Restarting Camera...";
    
	percentageLabel.text = @"--";
	percentageProgress.progress = 0.0; 
    
	[self performSelectorInBackground:@selector(upgradeFwReboot_bg)  withObject:nil] ;
}



-(void) upgradeFwReboot_bg
{
	//percentageProgress.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	//float totalTime  = 80.0; // 80 sec reboot time
    
	float sleepPeriod = 80.0 / 100; // 100 cycles
	int percentage = 0; 
	while (percentage ++ < 100)
	{
        
        
		[self performSelectorOnMainThread:@selector(upgradeFwProgress_ui:) 
                               withObject:[NSNumber numberWithInt:percentage]
                            waitUntilDone:YES];
        
		[NSThread sleepForTimeInterval:sleepPeriod];
        
	}
    
	[self performSelectorOnMainThread:@selector(goBackAndReLogin) withObject:nil waitUntilDone:NO]; 
	[pool release];
    
}

-(void) upgradeFwProgress_bg
{
	//percentageProgress.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSError * error = nil ; 
    
    
	if(comm != nil)
	{
        
        
		//[NSThread sleepForTimeInterval:5.0];
		NSString * response ;
		while (true)
		{
            
			error = nil;
			response = [comm getUpgradeProgress:&error]; 
			//NSLog(@"response: %@",response);
			if (error != nil)
			{
                
				NSLog(@"error: %@ code:%d \n", [error localizedDescription] ,[error code]);
				break; 
                
			}
			else
			{
				//show the response
                
				NSString * percentage = [response substringFromIndex:[BURNING_PROCESS length]]; 
                
				[self performSelectorOnMainThread:@selector(upgradeFwProgress_ui:) 
                                       withObject:[NSNumber numberWithInt:[percentage intValue]]
                                    waitUntilDone:YES];
                
                
			}
            
			[NSThread sleepForTimeInterval:3.0];
		}
        
        
        
        
		NSLog(@"Upgrade exiting... "); 
        
	}
    
    
	[self performSelectorOnMainThread:@selector(upgradeDoneWaitForReboot) withObject:nil waitUntilDone:NO]; 
	[pool release];
}


#pragma mark -
#pragma mark Scan cameras

- (void) scan_for_missing_camera
{
    NSLog(@"scanning for : %@", self.selected_channel.profile.mac_address);

	scanner = [[ScanForCamera alloc] initWithNotifier:self];
	[scanner scan_for_device:self.selected_channel.profile.mac_address];
    
}


- (void)scan_done:(NSArray *) _scan_results
{
	//Sync
    
    if ([_scan_results count] ==0 )
    {
        //empty result... rescan
        NSLog(@"Empty result-> Re- scan");
        [self scan_for_missing_camera];
        
    }
    else
    {
        //confirm the mac address
        CamProfile * cp = self.selected_channel.profile;
        BOOL found = FALSE;
        for (int j = 0; j < [_scan_results count]; j++)
        {
            CamProfile * cp1 = (CamProfile *) [_scan_results objectAtIndex:j];
            
            if ( [cp.mac_address isEqualToString:cp1.mac_address])
            {
                //FOUND - copy ip address.
                cp.ip_address = cp1.ip_address;
                found = TRUE;
                break;
            }
        }
        
        
        if (!found)
        {
            //Rescann...
            NSLog(@"Re- scan for : %@", self.selected_channel.profile.mac_address);
            [self scan_for_missing_camera];
        }
        else
        {
            //Restart streaming..
            NSLog(@"Re-start streaming for : %@", self.selected_channel.profile.mac_address);
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(startCameraConnection:)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    
}
#pragma mark -


@end
