//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "H264PlayerViewController.h"


#define D1 @"480p"
#define HD1 @"720p-10"
#define HD15 @"720p-15"

#define DIRECTION_V_NON  0x01
#define DIRECTION_V_UP   0x02
#define DIRECTION_V_DN   0x04
#define DIRECTION_V_MASK 0xF0

#define DIRECTION_H_NON 0x10
#define DIRECTION_H_LF  0x20
#define DIRECTION_H_RT  0x40
#define DIRECTION_H_MASK 0x0F



#define CAM_IN_VEW @"string_Camera_Mac_Being_Viewed"

@implementation H264PlayerViewController

@synthesize  alertTimer;
@synthesize  selectedChannel;
@synthesize  askForFWUpgradeOnce;


#pragma mark - View
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
//                                                       @"Back", nil);
//    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:[self stackViewController]
//                                                                  action:@selector(toggleLeftViewController)];
    
    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(preToggleLeftViewController)];

    self.navigationItem.leftBarButtonItem = revealIcon;
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
//	self.navigationItem.backBarButtonItem =
//    [[[UIBarButtonItem alloc] initWithTitle:msg
//                                      style:UIBarButtonItemStyleBordered
//                                     target:nil
//                                     action:nil] autorelease];
    
    self.pickerHQOptions.delegate = self;
    self.pickerHQOptions.dataSource = self;
    
    //self.barBntItemReveal.target = [self stackViewController];
    
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    //[self scan_for_missing_camera];
    
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self checkOrientation];
    
//    if (self.mpFlag) {
//        self.progressView.hidden = NO;
//        //[self.view bringSubviewToFront:self.progressView];
//        [self setupCamera];
//        //[self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];
//        [self loadEarlierList];
//        self.mpFlag = FALSE;
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:CAM_IN_VEW];
	[userDefaults synchronize];
}

#pragma mark - Action

- (IBAction)segCtrlAction:(id)sender {
    
    if (self.segCtrl.selectedSegmentIndex == 0) // Live
    {
        self.disableAutorotateFlag = FALSE;
        
        self.playlistViewController.tableView.hidden = YES;
        
        NSLog(@"h264StreamerIsInStopped: %d, h264Streamer==null: %d", _h264StreamerIsInStopped, h264Streamer == NULL);
        
        if (self.h264StreamerIsInStopped == TRUE &&
            h264Streamer == NULL)
        {
            self.activityIndicator.hidden = NO;
            [self.view bringSubviewToFront:self.activityIndicator];
            [self.activityIndicator startAnimating];
            
            [self setupCamera];
            self.h264StreamerIsInStopped = FALSE;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:selectedChannel.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
        }
        else
        {
            // Streamer is showing live view
        }
    }
    else if (self.segCtrl.selectedSegmentIndex == 1) // Earlier
    {
        self.disableAutorotateFlag = TRUE;
        
        [self.view bringSubviewToFront:self.playlistViewController.tableView];
        self.playlistViewController.tableView.hidden = NO;
        
        self.playlistViewController.navController = self.navigationController;
        self.playlistViewController.playlistDelegate = self;
    }
    
    NSLog(@"self.segCtrl.selectedSegmentIndex = %d", self.segCtrl.selectedSegmentIndex);
}
- (IBAction)hqPressAction:(id)sender
{
    self.pickerHQOptions.hidden = NO;
    [self.view bringSubviewToFront:self.pickerHQOptions];
}

- (IBAction)iFrameOnlyPressAction:(id)sender
{
}

- (IBAction)recordingPressAction:(id)sender
{
    self.recordingFlag = !self.recordingFlag;
    
    NSString *modeRecording = @"";
    
    if (self.recordingFlag == TRUE)
    {
        modeRecording = @"on";
    }
    else
    {
        modeRecording = @"off";
    }
    
    [self performSelectorInBackground:@selector(setTriggerRecording_bg:)
                           withObject:modeRecording];
}

- (IBAction)barBntItemRevealAction:(id)sender
{
//    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:[self stackViewController]
//                                                                 action:@selector(toggleLeftViewController)];
    //[self.stackViewController toggleLeftViewController];
}

- (void)preToggleLeftViewController
{
    [self.stackViewController toggleLeftViewController];
}

#pragma mark - Delegate Stream callback

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2
{
    //NSLog(@"Got msg: %d ext1:%d ext2:%d ", msg, ext1, ext2);
    
    [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:) withObject:[NSNumber numberWithInt:msg] waitUntilDone:NO];
}

- (void)handleMessageOnMainThread: (NSNumber *)numberMsg
{
    int msg = [numberMsg integerValue];
    
    NSLog(@"currentMediaStatus: %d", msg);
    
    switch (msg)
    {
        case MEDIA_INFO_HAS_FIRST_IMAGE:
        {
            NSLog(@"[MEDIA_PLAYER_HAS_FIRST_IMAGE]");
            
            self.currentMediaStatus = msg;
            
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            self.backBarBtnItem.enabled = YES;
            
            
            [self stopPeriodicPopup];
            
            
            if (userWantToCancel == TRUE)
            {
                
                NSLog(@"*[MEDIA_PLAYER_HAS_FIRST_IMAGE] *** USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
            }
            else
            {
                
                if ( self.selectedChannel.profile.isInLocal && (self.askForFWUpgradeOnce == YES))
                {
                    [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
                    self.askForFWUpgradeOnce = NO;
                }
                
                //NSLog(@"Got MEDIA_PLAYER_HAS_FIRST_IMAGE") ;
                
                if ( self.selectedChannel.profile.isInLocal == NO)
                {
                    [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"View Camera Remote"
                                                                       withAction:@"Start Stream Success"
                                                                        withLabel:@"Start Stream Success"
                                                                        withValue:nil];
                }
                
                [self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
                [self performSelectorInBackground:@selector(getTriggerRecording_bg) withObject:nil];
            }
        }
            break;
            
        case MEDIA_PLAYER_STARTED:
        {
            self.currentMediaStatus = msg;
            
            if (userWantToCancel == TRUE)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
            }
            
            if (self.h264StreamerIsInStopped == TRUE)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
            }
        }
            break;

        case MEDIA_ERROR_SERVER_DIED:
    	case MEDIA_ERROR_TIMEOUT_WHILE_STREAMING:
        {
            self.currentMediaStatus = msg;
            
    		NSLog(@"Timeout While streaming");
            
    		//mHandler.dispatchMessage(Message.obtain(mHandler, Streamer.MSG_VIDEO_STREAM_HAS_STOPPED_UNEXPECTEDLY));
            
            NSLog(@"userWantToCancel: %d", userWantToCancel);
    		
            if (userWantToCancel == TRUE)
            {
                
                NSLog(@"*[MEDIA_ERROR_TIMEOUT_WHILE_STREAMING] *** USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
                return;

            }
            
            if (self.h264StreamerIsInStopped == TRUE)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
                return;
            }
            
    		/* TODO:
    		 *
    		 * Why are we failling?
    		 *    Our issue: Switch WIFIs, or WIFI <--> 3g
    		 *               Going out of range
    		 *
    		 *    Camera issue: Camera turn off/ restarted / Ip changed
    		 *
    		 * What mode are we in
    		 * - Local -> Recovery in local
    		 * - Remote -> Recovery in REMOTE (UPNP or Wowza)
    		 *
             */
            
            //Perform connectivity check - wifi?
            NSString * currSSID = [CameraPassword fetchSSIDInfo];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString * streamSSID =  (NSString *) [userDefaults objectForKey:_streamingSSID];
            
            
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"network_lost_link",nil, [NSBundle mainBundle],
                                                               @"Camera disconnected due to network connectivity problem. Trying to reconnect...", nil);
            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"View Remote Camera"
                                                               withAction:@"Connect to Cam Failed"
                                                                withLabel:@"Can't connect to network"
                                                                withValue:nil];
            
            
            if (currSSID != nil && streamSSID != nil)
            {
                
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
            [self stopStream];
            
            
            
            if (self.selectedChannel.profile.isInLocal == TRUE)
            {
                /* re-scan for the camera */
                [self scan_for_missing_camera];
            }
            else //Remote connection -> go back and retry
            {
                //Restart streaming..
                NSLog(@"Re-start Remote streaming for : %@", self.selectedChannel.profile.mac_address);
                [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(setupCamera)
                                               userInfo:nil
                                                repeats:NO];
            }
            
            
    		
        }
    		break;
            
        default:
            break;
    }
    
    
    
    
#if 0
    switch (status) {
        case STREAM_STARTED:
        {
            self.enableControls = TRUE;
            progressView.hidden = YES;
            
            [self stopPeriodicPopup];
            
            
            if (userWantToCancel == TRUE)
            {
                
                NSLog(@"*[STREAM_STARTED] *** USER want to cancel **.. cancel after .1 sec...");
                self.selected_channel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
            }
            else
            {
                if ( self.selected_channel.profile.isInLocal && (self.askForFWUpgradeOnce == YES))
                {
                    [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
                    self.askForFWUpgradeOnce = NO;
                }
                
                //NSLog(@"Got STREAM_STARTED") ;
                
                if ( self.selected_channel.profile.isInLocal == NO)
                {
                    
                    
                    
                    [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"View Camera Remote"
                                                                       withAction:@"Start Stream Success"
                                                                        withLabel:@"Start Stream Success"
                                                                        withValue:nil];
                }
            }
            break;
        }
		case STREAM_STOPPED:
            
			break;
		case STREAM_STOPPED_UNEXPECTEDLY:
        {
            [UIApplication sharedApplication].idleTimerDisabled=  NO;
            
            break;
        }
		case REMOTE_STREAM_STOPPED_UNEXPECTEDLY:
        {
            
            NSString * msg = NSLocalizedStringWithDefaultValue(@"network_lost_link",nil, [NSBundle mainBundle],
                                                               @"Camera disconnected due to network connectivity problem. Trying to reconnect...", nil);
            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"View Remote Camera"
                                                               withAction:@"Connect to Cam Failed"
                                                                withLabel:@"Can't connect to network"
                                                                withValue:nil];
            
#if 1
            msg = [NSString stringWithFormat:@"%@ (%d)", msg, self.selected_channel.remoteConnectionError];
            if (self.streamer != nil)
            {
                msg = [NSString stringWithFormat:@"%@(%d)",msg,
                       self.streamer.latest_connection_error ];
            }
#endif
            
            
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
            
            //nil all comm object
            self.scomm = nil; //STUN
            self.comm = nil;// UPNP/local
            
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
            NSString * msg = NSLocalizedStringWithDefaultValue(@"cant_start_stream",nil, [NSBundle mainBundle],
                                                               @"Can't start video stream, the Monitor is busy, try again later." , nil);
            msg = [NSString stringWithFormat:@"%@ (%d)", msg, self.selected_channel.remoteConnectionError];
            
            if (self.selected_channel.remoteConnectionError == REQUEST_TIMEOUT)
            {
                msg = NSLocalizedStringWithDefaultValue(@"cant_start_stream2",nil, [NSBundle mainBundle],
                                                        @"Server request timeout, try again later", nil);
                
                
            }
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:msg
                                   delegate:self
                                   cancelButtonTitle:ok
                                   otherButtonTitles:nil];
            _alert.tag = REMOTE_VIDEO_CANT_START ;
            [_alert show];
            [_alert release];
            
            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"View Remote Camera"
                                                               withAction:@"Connect to Cam Failed"
                                                                withLabel:@"Can't connect to network"
                                                                withValue:nil];
            
            
            break;
        }
        case REMOTE_STREAM_SSKEY_MISMATCH:
        {
            //Stop stream - clean up all resources
            [self.streamer stopStreaming];
            self.selected_channel.stopStreaming = TRUE;
            
            //simply popup and ask to retry and show camera list
            NSString * msg = NSLocalizedStringWithDefaultValue(@"cant_start_stream_01",nil, [NSBundle mainBundle],
                                                               @"The session key on camera is mis-matched. Please reset the camera and add the camera again.(%d)" , nil);
            msg = [NSString stringWithFormat:msg, self.streamer.latest_connection_error];
            
            NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                              @"Ok", nil);
            UIAlertView *_alert = [[UIAlertView alloc]
                                   initWithTitle:@""
                                   message:msg
                                   delegate:self
                                   cancelButtonTitle:ok
                                   otherButtonTitles:nil];
            _alert.tag = REMOTE_SSKEY_MISMATCH ;
            [_alert show];
            [_alert release];
            [[[GAI sharedInstance] defaultTracker] trackEventWithCategory:@"View Remote Camera"
                                                               withAction:@"Connect to Cam Failed"
                                                                withLabel:@"SESSION KEY MISMATCH"
                                                                withValue:nil];
            break;
        }
        case SWITCHING_TO_RELAY_SERVER:// just update the dialog
        {
            
            //change the message being shown on progress bar -- NEED to take of rotation
            
            if (progressView != nil)
            {
                UITextView * message = (UITextView *)[progressView viewWithTag:155] ;//textview
                NSString * msg = NSLocalizedStringWithDefaultValue(@"udt_relay_connect",nil, [NSBundle mainBundle],
                                                                   @"Connecting through relay... please wait..." , nil);
                message.text = msg;
                
            }
            
            
            
            
            
            break;
        }
        case REMOTE_STREAM_STOPPED:
        {
#if 1 //dont close_session
            
            if ( streamer.communication_mode == COMM_MODE_STUN )
            {
                if (self.scomm != nil)
                {
                    
                    NSLog(@"Send close session");
                    [self.scomm sendCloseSessionThruBMS:self.selected_channel.profile.mac_address
                                             AndChannel:self.selected_channel.channID
                                               forRelay:NO];
                }
            }
            if (streamer.communication_mode == COMM_MODE_STUN_RELAY2)
                
                
            {
                
                if (self.scomm != nil)
                {
                    
                    NSLog(@"Send close relay session");
                    [self.scomm sendCloseSessionThruBMS:self.selected_channel.profile.mac_address
                                             AndChannel:self.selected_channel.channID
                                               forRelay:YES];
                }
            }
            
#endif
            
            break;
        }
        case  SWITCHING_TO_RELAY2_SERVER: //do the switching..
        {
            
            if ([self.selected_channel.profile isNewerThan08_038])
            {
                
                
                
                //close pcm player as well.. we don't need it any longer
                //  Will open again once the relay2 is up
                [streamer stopStreaming:TRUE];
                
                if (scanner != nil)
                {
                    [scanner cancel];
                }
                [self.selected_channel abortViewTimer];
                
                NSLog(@"FW version is newer thang 08_038 ->NEW -RELAY");
                [self switchToRelay2ForNonSymmetricNatApp];
            }
            
        }
		default:
			break;
	}
#endif
}


#pragma mark - Delegate Playlist

- (void)stopStreamWhenPushPlayback
{
    self.h264StreamerIsInStopped = TRUE;
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
        self.currentMediaStatus == MEDIA_PLAYER_STARTED ||
        (self.currentMediaStatus == 0 && h264Streamer == NULL)) // Media player haven't start yet.
    {
        [self stopStream];
    }
    else
    {
        h264Streamer->suspend();
    }
}

#pragma mark - Method

- (void)handleBecomeActive
{
    if (userWantToCancel == TRUE)
    {
        return;
    }
    
    if(selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"Become ACTIVE _  .. Local ");
        [self becomeActive];
    }
    else if ( selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
    {
        [self becomeActive];
    }
}

- (void)handleEnteredBackground
{
    if (userWantToCancel == TRUE)
    {
        return;
    }
    
    if (selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"Enter Background.. Local ");
        selectedChannel.stopStreaming = TRUE;
        
        //[self stopPeriodicPopup];
        
        if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
            self.currentMediaStatus == MEDIA_PLAYER_STARTED ||
            (self.currentMediaStatus == 0 && h264Streamer == NULL)) // Media player haven't start yet.
        {
            [self stopStream];
        }
        else
        {
            h264Streamer->suspend();
        }
        
        self.h264StreamerIsInStopped = TRUE;
        
        self.imageViewVideo.backgroundColor = [UIColor blackColor];
    }
    else if (selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
    {
        selectedChannel.stopStreaming = TRUE;
        
        //[self stopPeriodicPopup];
        
        [self stopStream];
        
        //NSLog(@"abort remote timer ");
        [selectedChannel abortViewTimer];
    }
}

- (void)becomeActive
{
    CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(prepareGoBackToCameraList);
    //self.backBarBtnItem.enabled = NO;

//SLIDE MENU
//    self.backBarBtnItem.target = self.stackViewController;
//    self.backBarBtnItem.action = @selector(toggleLeftViewController);
    
    self.pickerHQOptions.hidden = YES;
    
    self.activityIndicator.hidden = NO;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.viewStopStreamingProgress.hidden = YES;
    
    NSLog(@"self.segCtrl.selectedSegmentIndex = %d", self.segCtrl.selectedSegmentIndex);
    
    [self setupCamera];
    
    [self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];

    if (self.segCtrl.selectedSegmentIndex == 0)
    {
        self.playlistViewController.tableView.hidden= YES;
    }
    
    //Direction stuf
    /* Kick off the two timer for direction sensing */
    currentDirUD = DIRECTION_V_NON;
    lastDirUD    = DIRECTION_V_NON;
    delay_update_lastDir_count = 1;
    
    send_UD_dir_req_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                             target:self
                                                           selector:@selector(v_directional_change_callback:)
                                                           userInfo:nil
                                                            repeats:YES];
    
    currentDirLR = DIRECTION_H_NON;
    lastDirLR    = DIRECTION_H_NON;
    delay_update_lastDirLR_count = 1;
    
    send_LR_dir_req_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                             target:self
                                                           selector:@selector(h_directional_change_callback:)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)setupCamera
{
    if (self.httpComm != nil)
    {
        [self.httpComm release];
        self.httpComm = nil;
    }
    
    self.httpComm = [[HttpCommunication alloc]init];
    self.httpComm.device_ip = self.selectedChannel.profile.ip_address;
    self.httpComm.device_port = self.selectedChannel.profile.port;
    
    //Support remote UPNP video as well
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"created a local streamer");
        self.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
        
        //self.progressView.hidden = YES;
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
        //[self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
        //[self performSelectorInBackground:@selector(getTriggerRecording_bg) withObject:nil];
    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        NSLog(@"created a remote streamer");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        
//        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                                                 Selector:@selector(createSesseionSuccessWithResponse:)
//                                                                             FailSelector:@selector(createSessionFailedWithResponse:)
//                                                                                ServerErr:@selector(createSessionFailedUnreachableSerever)];
//        [jsonComm createSessionWithRegistrationId:mac
//                                    andClientType:@"IOS"
//                                        andApiKey:apiKey];
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:nil
                                                                             FailSelector:nil
                                                                                ServerErr:nil] autorelease];
        NSDictionary *responseDict = [jsonComm createSessionBlockedWithRegistrationId:mac
                                                                     andClientType:@"IOS"
                                                                         andApiKey:apiKey];
        if (responseDict != nil)
        {
            if ([[responseDict objectForKey:@"status"] intValue] == 200)
            {
                self.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                
//                NSString *tempString = [[self.stream_url componentsSeparatedByString:@"/"] lastObject];
//                
//                if ([tempString isEqualToString:@"blinkhd"] ) {
//                    return;
//                }
                [self performSelector:@selector(startStream)
                           withObject:nil
                           afterDelay:0.1];
                //[self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
                //[self performSelectorInBackground:@selector(getTriggerRecording_bg) withObject:nil];
            }
        }
        else
        {
            NSLog(@"create session isn't success");
        }

    }
    else
    {
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        self.backBarBtnItem.enabled = YES;
        self.imageViewVideo.image = [UIImage imageNamed:@"camera_offline"];
        self.viewCtrlButtons.hidden = YES;
        self.imgViewDrectionPad.hidden= YES;
        self.viewStopStreamingProgress.hidden = YES;
        
        NSLog(@"Camera maybe not available.");
    }
}

-(void) startStream
{
    self.h264StreamerIsInStopped = FALSE;
    
    h264Streamer = new MediaPlayer(false);
    
    h264StreamerListener = new H264PlayerListener(self);
    h264Streamer->setListener(h264StreamerListener);
    
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
}

- (void)startStream_bg
{
    status_t status;
    
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
    
    [userDefaults synchronize];
    
    //`NSLog(@"Play with TCP Option >>>>> ") ;
    //mp->setPlayOption(MEDIA_STREAM_RTSP_WITH_TCP);
    
    NSString * url = self.stream_url;
    
    do
    {
        
        status = h264Streamer->setDataSource([url UTF8String]);
        
        if (status != NO_ERROR) // NOT OK
        {
            NSLog(@"setDataSource  failed");
            
            break;
        }
        
        h264Streamer->setVideoSurface(self.imageViewVideo);
        
        status=  h264Streamer->prepare();
        
        printf("prepare return: %d\n", status);
        
        if (status != NO_ERROR) // NOT OK
        {
            
            printf("prepare() error: %d\n", status);
            break;
        }
        
        // Play anyhow
        
        status=  h264Streamer->start();
        
        printf("start() return: %d\n", status);
        if (status != NO_ERROR) // NOT OK
        {
            
            printf("start() error: %d\n", status);
            break;
        }
    }
    while (false);
    
    if (status == NO_ERROR)
    {
        [self handleMessage:MEDIA_PLAYER_STARTED
                       ext1:0
                       ext2:0];
    }
    
    else
    {
        //Consider it's down and perform necessary action ..
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
    }
}

- (void)prepareGoBackToCameraList
{
    self.viewStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:self.viewStopStreamingProgress];
    
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    NSLog(@"self.currentMediaStatus: %d", self.currentMediaStatus);
    
    if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
        self.currentMediaStatus == MEDIA_PLAYER_STARTED ||
        (self.currentMediaStatus == 0 && h264Streamer == NULL)) // Media player haven't start yet.
    {
        [self goBackToCameraList];
    }
    else
    {
        h264Streamer->suspend();
        userWantToCancel = TRUE;
    }
}

- (void)goBackToCameraList
{
    [self stopStream];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:CAM_IN_VEW];
	[userDefaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void) cleanUpDirectionTimers
{
    
    /* Kick off the two timer for direction sensing */
    currentDirUD = DIRECTION_V_NON;
    lastDirUD    = DIRECTION_V_NON;
    delay_update_lastDir_count = 1;
    
    if ( send_UD_dir_req_timer !=nil)
    {
        if ([send_UD_dir_req_timer isValid] )
        {
            [send_UD_dir_req_timer invalidate];
            //[send_UD_dir_req_timer release];
            send_UD_dir_req_timer = nil;
        }
    }
    
    
    currentDirLR = DIRECTION_H_NON;
    lastDirLR    = DIRECTION_H_NON;
    delay_update_lastDirLR_count = 1;
    
    
    if ( send_LR_dir_req_timer != nil)
    {
        if ([send_LR_dir_req_timer isValid])
        {
            [send_LR_dir_req_timer invalidate];
            //[send_LR_dir_req_timer release];
            send_LR_dir_req_timer = nil;
        }
    }
    
}
- (void)stopStream
{
    @synchronized(self)
    {
        if (h264Streamer != NULL)
        {
            if (h264Streamer->isPlaying())
            {
                h264Streamer->suspend();
                h264Streamer->stop();
            }
            else
            {
                h264Streamer->suspend();
                h264Streamer->stop();
            }
            free(h264Streamer);
        }
        
        h264Streamer = NULL;
        
        [self cleanUpDirectionTimers];
        if (scanner != nil)
        {
            [scanner cancel];
        }
        
    }
    
    //[self.activityStopStreamingProgress stopAnimating];
}

- (void)loadEarlierList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
//    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
//                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
//                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)];
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
//    [jsonComm getAllRecordedFilesWithRegistrationId:mac
//                                           andEvent:@"04"
//                                          andApiKey:apiKey];
    NSDictionary *responseDict = [jsonComm getAllRecordedFilesBlockedWithRegistrationId:mac
                                                  andEvent:@"04"
                                                 andApiKey:apiKey];
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSArray *eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            self.playlistViewController.playlistArray = [NSMutableArray array];
            
            for (NSDictionary *playlist in eventArr) {
                NSDictionary *clipInfo = [[playlist objectForKey:@"playlist"] objectAtIndex:0];
                
                PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init] autorelease];
                playlistInfo.mac_addr = mac;
                playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                
                [self.playlistViewController.playlistArray addObject:playlistInfo];
            }
            
            [self.playlistViewController.tableView reloadData];
            NSLog(@"reloadData %d", self.playlistViewController.playlistArray.count);
        }
    }
    
    //self.activityIndicator.hidden = YES;
    //[self.activityIndicator stopAnimating];
}

-(void) getVQ_bg
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *responseDict  = nil;
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSLog(@"mac %@, apikey %@", mac, apiKey);
   
    
    if (self.selectedChannel.profile.isInLocal ) // Replace with httpCommunication after
	{
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:@"action=command&command=get_resolution"
                                                                    andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
	{
		self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:[NSString stringWithFormat:@"action=command&command=get_resolution"] andApiKey:apiKey];
		}
	}

	if (responseDict != nil)
	{
        
        NSInteger status = [[responseDict objectForKey:@"status"] intValue];
		if (status == 200)
		{
			NSString *bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            NSString *modeVideo = [[bodyKey componentsSeparatedByString:@": "] objectAtIndex:1];
			
            [self performSelectorOnMainThread:@selector(setVQForground:)
                                   withObject:modeVideo waitUntilDone:NO];
		}
        //[self performSelectorOnMainThread:@selector(setVQ_fg:) withObject:responseDict waitUntilDone:NO];
	}
    
    NSLog(@"getVQ_bg responseDict = %@", responseDict);
}

- (void)setVQForground: (NSString *)modeVideo
{
    if ([modeVideo isEqualToString:@"480p"]) // ok
    {
        [self.hqViewButton setImage:[UIImage imageNamed:@"hq_d.png" ]
                           forState:UIControlStateNormal];
    }
    else if([modeVideo isEqualToString:@"720p_10"] || [modeVideo isEqualToString:@"720p_15"])
    {
        [self.hqViewButton setImage:[UIImage imageNamed:@"hq.png" ]
                           forState:UIControlStateNormal];
    }
}

- (void)getTriggerRecording_bg
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *responseDict  = nil;
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSLog(@"mac %@, apikey %@", mac, apiKey);
    
    
    if (self.selectedChannel.profile.isInLocal == TRUE) // Replace with httpCommunication after
	{
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:@"action=command&command=get_recording_stat"
                                                                    andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
	{
		self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:[NSString stringWithFormat:@"action=command&command=get_recording_stat"] andApiKey:apiKey];
		}
	}
    
	if (responseDict != nil)
	{
        [self performSelectorOnMainThread:@selector(setTriggerRecording_fg:) withObject:responseDict waitUntilDone:NO];
	}
    
    NSLog(@"getTriggerRecording_bg responseDict = %@", responseDict);
}

- (void)setTriggerRecording_bg:(NSString *) modeRecording
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSDictionary *responseData  = nil;
    if (  self.selectedChannel.profile.isInLocal == TRUE)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
        
		if (self.jsonComm != nil) // This is httpComm. Replace after
		{
            
            
            //            [self.jsonComm sendCommandWithRegistrationId:mac
            //                                             andCommand:[NSString stringWithFormat:@"action=command&command=%@", modeVideo]
            //                                              andApiKey:apiKey];
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                    andCommand:[NSString stringWithFormat:@"action=command&command=set_recording_stat&mode=%@", modeRecording]
                                                                     andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
        
        if (self.jsonComm != nil)
		{
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                    andCommand:[NSString stringWithFormat:@"action=command&command=set_recording_stat&mode=%@", modeRecording]
                                                                     andApiKey:apiKey];
		}
	}
    
	if (responseData != nil)
	{
		[self performSelectorOnMainThread:@selector(setTriggerRecording_fg:)
                               withObject:responseData waitUntilDone:NO];
	}
}

-(void) setTriggerRecording_fg: (NSDictionary *)responseDict
{
    NSLog(@"setTriggerRecording_fg responseData = %@", responseDict);
    
    NSInteger status = [[responseDict objectForKey:@"status"] intValue];
    
    if (status == 200) // ok
    {
        NSString *bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
        NSString *modeRecording = [[bodyKey componentsSeparatedByString:@": "] objectAtIndex:1];
        
        if ([modeRecording isEqualToString:@"on"])
        {
            self.recordingFlag = TRUE;
            [self.triggerRecordingButton setImage:[UIImage imageNamed:@"bb_rec_icon.png" ]
                                         forState:UIControlStateNormal];
        }
        else if([modeRecording isEqualToString:@"off"])
        {
            self.recordingFlag = FALSE;
            [self.triggerRecordingButton setImage:[UIImage imageNamed:@"bb_rec_icon_d.png" ]
                                         forState:UIControlStateNormal];
        }
    }
    else
    {
        self.recordingFlag = !self.recordingFlag;
    }
}

#pragma mark -
#pragma mark - DirectionPad

/* Periodically called every 200ms */
- (void) v_directional_change_callback:(NSTimer *) timer_exp
{
	/* currentDirUD holds the LATEST direction,
     lastDirUD holds the LAST direction that we have seen
     - this is called every 100ms
	 */
	@synchronized(_imgViewDrectionPad)
	{
        
		if (lastDirUD != DIRECTION_V_NON)
        {
			[self send_UD_dir_to_rabot:currentDirUD];
		}
        
		//Update directions
		lastDirUD = currentDirUD;
	}
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
        if (selectedChannel.profile.isInLocal)
		{
            _httpComm = [[[HttpCommunication alloc] init] autorelease];
				//Non block send-
				[_httpComm sendCommand:dir_str];
                //[_httpComm sendCommandAndBlock:dir_str];
		}
		else if(selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            NSString *mac = [Util strip_colon_fr_mac:selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            _jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
            NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                              andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                               andApiKey:apiKey];
            NSLog(@"send_UD_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void) h_directional_change_callback:(NSTimer *) timer_exp
{
    BOOL need_to_send = FALSE;
    
    @synchronized(_imgViewDrectionPad)
	{
		if ( lastDirLR != DIRECTION_H_NON)
        {
			need_to_send = TRUE;
		}
        
        if (need_to_send)
        {
            [self send_LR_dir_to_rabot: currentDirLR];
        }
        
		//Update directions
		lastDirLR = currentDirLR;
	}
}

- (void) send_LR_dir_to_rabot:(int ) direction
{
	NSString * dir_str = nil;
    
	switch (direction)
    {
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
    
    NSLog(@"dir_str: %@", dir_str);
    
	if (dir_str != nil)
	{
        if (selectedChannel.profile.isInLocal)
        {
            _httpComm = [[[HttpCommunication alloc] init] autorelease];
				//Non block send-
				[_httpComm sendCommand:dir_str];
                
                //[_httpComm sendCommandAndBlock:dir_str];
		}
		else if ( selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            NSString *mac = [Util strip_colon_fr_mac:selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            _jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
            NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                              andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                               andApiKey:apiKey];
            NSLog(@"send_LR_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void) updateVerticalDirection_begin:(int)dir inStep: (uint) step
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
    
	@synchronized(_imgViewDrectionPad)
	{
		currentDirUD = newDirection;
	}
    
	//Adjust the fire date to now
	NSDate * now = [NSDate date];
	[send_UD_dir_req_timer setFireDate:now ];    
}

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
    
	@synchronized(_imgViewDrectionPad)
	{
		currentDirUD = newDirection;
	}
}

- (void) updateVerticalDirection_end:(int)dir inStep: (uint) step
{
	@synchronized(_imgViewDrectionPad)
	{
		currentDirUD = DIRECTION_V_NON;
	}
}

- (void) updateHorizontalDirection_end:(int)dir inStep: (uint) step
{
	@synchronized(_imgViewDrectionPad)
	{
		currentDirLR = DIRECTION_H_NON;
	}
}

- (void)updateHorizontalDirection_begin:(int)dir inStep: (uint) step
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
    
	@synchronized(_imgViewDrectionPad)
	{
		currentDirLR= newDirection;
	}
    
	//Adjust the fire date to now
	NSDate * now = [NSDate date];
	[send_LR_dir_req_timer setFireDate:now ];
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
	}
    
	@synchronized(_imgViewDrectionPad)
	{
		currentDirLR = newDirection;
	}
}

#pragma  mark -
#pragma mark Touches

//----- handle all touches here then propagate into directionview

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 999)
        {
            NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 999)
        {
            NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{        
	NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 999)
        {
            NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase
{
	switch (phase)
    {
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
	/*when moved, the new point may change from vertical to Horizontal plane ,
     thus reset it here,
     later the point will be re-evaluated  and set to the corrent command*/
    
    [self updateVerticalDirection_end:0 inStep:0];
    
	[self updateHorizontalDirection_end:0 inStep:0];
    
    [self validatePoint:location newMovement:NO ];
}

- (void) _touchesended: (CGPoint) location
{
	CGPoint beginLocation = CGPointMake(_imgViewDrectionPad.center.x - _imgViewDrectionPad.frame.origin.x,
                                        _imgViewDrectionPad.center.y - _imgViewDrectionPad.frame.origin.y);
    
	[self validatePoint:beginLocation newMovement:NO ];
    
    
	[self updateVerticalDirection_end:0 inStep:0];
    
	[self updateHorizontalDirection_end:0 inStep:0];
}

- (void) validatePoint: (CGPoint)location newMovement:(BOOL) isBegan
{
	CGPoint translation ;
    
	BOOL is_vertical;
    
	CGPoint beginLocation = CGPointMake(_imgViewDrectionPad.center.x - _imgViewDrectionPad.frame.origin.x,
                                        _imgViewDrectionPad.center.y - _imgViewDrectionPad.frame.origin.y);
    
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
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_dn.png"]];
		}
		else if (translation.y <0)
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_up.png"]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_2.png"]];
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
            
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_rt.png"]];
		}
		else if (translation.x < 0){
            
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_lf.png"]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_2.png"]];
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

#pragma mark - JSON Callback

- (void)createSesseionSuccessWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"createSesseionSuccessWithResponse %@", responseDict);
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            self.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
            
//            NSString *tempString = [[self.stream_url componentsSeparatedByString:@"/"] lastObject];
//            
//            if ([tempString isEqualToString:@"blinkhd"] )
//            {
//                return;
//            }
            [self performSelector:@selector(startStream)
                       withObject:nil
                       afterDelay:0.1];
            [self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
        }
    }
}

- (void)createSessionFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"createSessionFailedWith code %d", [[responseDict objectForKey:@"status"] intValue]);
}

- (void)createSessionFailedUnreachableSerever
{
    NSLog(@"createSessionFailedUnreachableSerever");
}

#pragma mark - Rotation screen
- (BOOL)shouldAutorotate
{
    NSLog(@"Should Auto Rotate");
    
    if (userWantToCancel == TRUE)
    {
        return NO;
    }
    
	return !self.disableAutorotateFlag;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame]; // Get status bar frame dimensions
    NSLog(@"1 Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
          rect.origin.y, rect.size.width, rect.size.height);
    //HACK : incase hotspot is turned on
    if (rect.size.height>21 &&  rect.size.height<50)
    {

    }

    else
    {
        
    }
}

-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land_ipad"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 1024, 576);
            self.imageViewVideo.frame = newRect;
        }
        else
        {
            
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 32, 480, 256);
            self.imageViewVideo.frame = newRect;
            self.viewCtrlButtons.frame = CGRectMake(0, 106, _viewCtrlButtons.frame.size.width, _viewCtrlButtons.frame.size.height);
            self.imgViewDrectionPad.frame = CGRectMake(180, 180, _imgViewDrectionPad.frame.size.width, _imgViewDrectionPad.frame.size.height);
             self.activityIndicator.frame = CGRectMake(221, 141, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
            
            self.view.backgroundColor = [UIColor blackColor];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            self.topToolbar.hidden = YES;
            self.imgViewDrectionPad.hidden = YES;
            self.viewCtrlButtons.hidden = YES;
        }        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_ipad"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 768, 432);
            self.imageViewVideo.frame = newRect;
        }
        else
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 320, 180);
            self.imageViewVideo.frame = newRect;
            self.viewCtrlButtons.frame = CGRectMake(0, 224, _viewCtrlButtons.frame.size.width, _viewCtrlButtons.frame.size.height);
            self.imgViewDrectionPad.frame = CGRectMake(100, 340, _imgViewDrectionPad.frame.size.width, _imgViewDrectionPad.frame.size.height);
            self.activityIndicator.frame = CGRectMake(141, 124, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);

            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_background"]];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
            self.topToolbar.hidden = NO;
            self.imgViewDrectionPad.hidden = NO;
            self.viewCtrlButtons.hidden = NO;
        }
	}
    
    [self checkIphone5Size:orientation];

    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(prepareGoBackToCameraList);
// SLIDE MENU
//    self.backBarBtnItem.target = self.stackViewController;
//    self.backBarBtnItem.action = @selector(toggleLeftViewController);
}

- (void) checkIphone5Size: (UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"iphone5 SHift right...");
//            CGAffineTransform translate = CGAffineTransformMakeTranslation(44, 0);
//            self.imageViewVideo.transform = translate;
            CGRect newRect = CGRectMake(0, 0, 568, 320);
            self.imageViewVideo.frame = newRect;
            
            self.activityIndicator.frame = CGRectMake(274, 150, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        }
        else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            self.viewStopStreamingProgress.frame = CGRectMake(0, 0, 320, 568);
        }
    }
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSString *textRow;
    switch (row)
    {
        case 0:
            textRow = @"D1";
            break;
        case 1:
            textRow = @"HD 1 Mbps";
            break;
        case 2:
            textRow = @"HD 1.5 Mbps";
            break;
            
        default:
            break;
    }
    return textRow;
} 


#pragma mark -
#pragma mark PickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    // send command here
    pickerView.hidden = YES;
    
    [self performSelectorInBackground:@selector(setVQ_bg:)
                           withObject:[NSNumber numberWithInt:row]];
}

- (void)setVQ_bg:(NSNumber *) row
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	//int videoQ =[userDefaults integerForKey:@"int_VideoQuality"];
    
    NSString *modeVideo = @"";
    switch ([row intValue])
    {
        case 0:
            modeVideo = @"480p";
            break;
        case 1:
            modeVideo = @"720p_10";
            break;
        case 2:
            modeVideo = @"720p_15";
            break;
        default:
            break;
    }
    
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSDictionary *responseData  = nil;
    if (  self.selectedChannel.profile.isInLocal == TRUE)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
        
		if (self.jsonComm != nil) // This is httpComm. Replace after
		{
            
            
//            [self.jsonComm sendCommandWithRegistrationId:mac
//                                             andCommand:[NSString stringWithFormat:@"action=command&command=%@", modeVideo]
//                                              andApiKey:apiKey];
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                     andCommand:[NSString stringWithFormat:@"action=command&command=set_resolution&mode=%@", modeVideo]
                                                      andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // remote
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
        
        if (self.jsonComm != nil)
		{
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                    andCommand:[NSString stringWithFormat:@"action=command&command=set_resolution&mode=%@", modeVideo]
                                                                     andApiKey:apiKey];
		}
	}
    
	if (responseData != nil)
	{
        NSInteger status = [[responseData objectForKey:@"status"] intValue];
        if (status == 200)
        {
            [self performSelectorOnMainThread:@selector(setVQ_fg:)
                                   withObject:row waitUntilDone:NO];
        }
		else
        {
            NSLog(@"set resolution: status = %d", [[responseData objectForKey:@"stats"] intValue]);
        }
	}
}

-(void) setVQ_fg: (NSNumber *)row
{
    switch ([row intValue])
    {
        case 0:
            [self.hqViewButton setImage:[UIImage imageNamed:@"hq_d.png" ]
                               forState:UIControlStateNormal];
            break;
        case 1:
        case 2:
            [self.hqViewButton setImage:[UIImage imageNamed:@"hq.png" ]
                               forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark Scan cameras

- (void) scan_for_missing_camera
{
    if (userWantToCancel == TRUE)
    {
        return;
    }
    
    NSLog(@"scanning for : %@", self.selectedChannel.profile.mac_address);
    
	scanner = [[ScanForCamera alloc] initWithNotifier:self];
	[scanner scan_for_device:self.selectedChannel.profile.mac_address];
    
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
        CamProfile * cp = self.selectedChannel.profile;
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
            NSLog(@"Re- scan for : %@", self.selectedChannel.profile.mac_address);
            [self scan_for_missing_camera];
        }
        else
        {
            //Restart streaming..
            NSLog(@"Re-start streaming for : %@", self.selectedChannel.profile.mac_address);
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(setupCamera)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    
}
#pragma mark -

#pragma mark Alertview delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	int tag = alertView.tag;
	
	if (tag == LOCAL_VIDEO_STOPPED_UNEXPECTEDLY)
	{
		switch(buttonIndex) {
			case 0: //Stop monitoring
                
                [self.activityIndicator stopAnimating];
                self.viewStopStreamingProgress.hidden = NO;
                [self.view bringSubviewToFront:self.viewStopStreamingProgress];
                
                userWantToCancel =TRUE;
                [self stopPeriodicPopup];
                
                self.selectedChannel.stopStreaming = TRUE;
                
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
	
}

#pragma mark -
#pragma mark Beeping

-(void)periodicBeep:(NSTimer*) exp
{
    [self playSound];
}

-(void) stopPeriodicBeep
{
	if (self.alertTimer != nil)
	{
		if ([self.alertTimer isValid])
		{
			[self.alertTimer invalidate];
		}
        
	}
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
			NSLog(@"alert not visible -- dismiss it & release.. ");
            
            [alert dismissWithClickedButtonIndex:1 animated:NO];
		}
        
		[alert release];
		alert = nil;
        
	}
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
    
	alert = [[UIAlertView alloc]
             initWithTitle:@"" //empty on purpose
             message:msg
             delegate:self
             cancelButtonTitle:cancel
             otherButtonTitles:nil];
    
	alert.tag = LOCAL_VIDEO_STOPPED_UNEXPECTEDLY;
	[alert show];
    
	[alert retain];

    //[self performSelectorOnMainThread:@selector(showAlertView:) withObject:msg waitUntilDone:YES];
}

//- (void)showAlertView: (NSString *)msg
//{
//    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
//                                                          @"Cancel", nil);
//    
//    
//	alert = [[UIAlertView alloc]
//             initWithTitle:@"" //empty on purpose
//             message:msg
//             delegate:self
//             cancelButtonTitle:cancel
//             otherButtonTitles:nil];
//    
//	alert.tag = LOCAL_VIDEO_STOPPED_UNEXPECTEDLY;
//	[alert show];
//    
//	[alert retain];
//}

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
		//if ([alert isVisible])
		{
            NSLog(@"dissmis alert");
			[alert dismissWithClickedButtonIndex:1 animated:NO ];
		}
        
		[alert release];
		alert = nil;
        
	}
}
-(void) playSound
{
	
    
	//NSLog(@"Play the B");
    
    
	//201201011 This is needed to play the system sound on top of audio from camera
	UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;    // 1
	AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,                        // 2
                             sizeof (sessionCategory),                                   // 3
                             &sessionCategory                                            // 4
                             );
    
	//Play beep
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AudioServicesPlaySystemSound(soundFileObject);
    }
    else
    {
        AudioServicesPlayAlertSound(soundFileObject);
    }
    
    
    
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageViewVideo release];
    [_topToolbar release];
    [_backBarBtnItem release];
    [_progressView release];
    [_cameraNameBarBtnItem release];
    [_segCtrl release];
    [_tableViewPlaylist release];
    
    [_stream_url release];
    [selectedChannel release];
    [_playlistArray release];
    [_httpComm release];
    
    [_barBntItemReveal release];
    [_viewCtrlButtons release];
    [_pickerHQOptions release];
    [_hqViewButton release];
    [_triggerRecordingButton release];
    [_imgViewDrectionPad release];
    [send_UD_dir_req_timer invalidate];
    [send_LR_dir_req_timer invalidate];
    [_playlistViewController release];
    [_activityIndicator release];
    [_viewStopStreamingProgress release];
    [_activityStopStreamingProgress release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setImageViewVideo:nil];
    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    [self setCameraNameBarBtnItem:nil];
    [self setSegCtrl:nil];
    [self setTableViewPlaylist:nil];
    
    [self setStream_url:nil];
    [self setSelectedChannel:nil];
    [self setPlaylistArray:nil];
    [self setHttpComm:nil];
    
    [super viewDidUnload];
}
@end
