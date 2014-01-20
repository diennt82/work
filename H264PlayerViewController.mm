//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "H264PlayerViewController.h"
#import "EarlierViewController.h"
#import "TimelineViewController.h"
#import <CoreText/CTStringAttributes.h>

#define DISABLE_VIEW_RELEASE_FLAG 0

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
//define for zooming
#define MAXIMUM_ZOOMING_SCALE   6.0
#define MINIMUM_ZOOMING_SCALE   1.0f
#define ZOOM_SCALE              1.5f
#define CONTENT_SIZE_W_PORTRAIT 320
#define CONTENT_SIZE_H_PORTRAIT 180
#define CONTENT_SIZE_W_PORTRAIT_IPAD 768
#define CONTENT_SIZE_H_PORTRAIT_IPAD 432
//width and height of indicator
#define INDICATOR_SIZE               37

#define CAM_IN_VEW @"string_Camera_Mac_Being_Viewed"
#define HIGH_STATUS_BAR 20;

//define for Control Panel button
#define INDEX_PAN_TILT      0
#define INDEX_MICRO         1
#define INDEX_RECORDING     2
#define INDEX_MELODY        3
#define INDEX_TEMP          4

#define PTT_ENGAGE_BTN 711

@interface H264PlayerViewController () <TimelineVCDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *imageViewHandle;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewKnob;
@property (retain, nonatomic) EarlierViewController *earlierVC;
@property (retain, nonatomic) TimelineViewController *timelineVC;
@property (retain, nonatomic) UIImageView *imageViewStreamer;
@property (nonatomic) BOOL isHorizeShow;
@property (nonatomic, retain) NSTimer *timerHideMenu;
@property (nonatomic) BOOL isEarlierView;
@property (nonatomic) NSInteger numberOfSTUNError;
@property (nonatomic, retain) NSString *stringTemperature;
//@property (nonatomic, retain) NSTimer *timerGetTemperature;
@property (nonatomic) BOOL existTimerTemperature;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation H264PlayerViewController

@synthesize  alertTimer;
@synthesize  askForFWUpgradeOnce;
@synthesize   client = _client;
@synthesize horizMenu = _horizMenu;
@synthesize itemImages = _itemImages;
@synthesize itemSelectedImages = _itemSelectedImages;
@synthesize selectedItemMenu = _selectedItemMenu;
@synthesize walkieTalkieEnabled;
@synthesize httpComm = _httpComm;

static int fps = 0;
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
    // only is called in viewDidLoad, make sure it is called once.
    
    /*
     //create list image for display horizontal scroll view menu
     1.Pan, Tilt & Zoom (bb_setting_icon.png)
     2.Microphone (for two way audio) bb_setting_icon.png
     3.Take a photo/Record Video ( bb_rec_icon_d.png )
     4.Lullaby          bb_melody_off_icon.png
     5.Camera List          bb_camera_slider_icon
     6.Temperature display        temp_alert
     */
    self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan.png", @"video_action_mic.png", @"video_action_video.png", @"video_action_music.png", @"video_action_temp.png", nil];
    self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed.png", @"video_action_mic_pressed.png", @"video_action_video_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
    [self.horizMenu reloadData];
    self.selectedItemMenu = -1;
    [self updateBottomView];

    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleEnteredBackground)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    self.pickerHQOptions.delegate = self;
    self.pickerHQOptions.dataSource = self;
    self.pickerHQOptions.hidden = YES;
    self.pickerHQOptions.userInteractionEnabled = NO;
    
    //self.barBntItemReveal.target = [self stackViewController];
    
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    CFRelease(soundFileURLRef);
    
    //TODO: check if IPAD -> load IPAD
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.zoneViewController = [[[ZoneViewController alloc] initWithNibName:@"ZoneViewController_ipad" bundle:nil] autorelease];
    }
    else
    {
        self.zoneViewController = [[[ZoneViewController alloc] initWithNibName:@"ZoneViewController" bundle:nil] autorelease];

    }
    
    self.zoneViewController.selectedChannel = self.selectedChannel;
    self.zoneViewController.zoneVCDelegate = self;
    
    self.zoneButton.enabled = NO;
    
    self.melodyViewController = [[[MelodyViewController alloc] initWithNibName:@"MelodyViewController" bundle:nil] autorelease];
    
    self.melodyViewController.selectedChannel = self.selectedChannel;
    self.melodyViewController.melodyVcDelegate = self;
    self.melodyButton.enabled = NO;
    
    self.hqViewButton.enabled = NO;
    self.triggerRecordingButton.enabled = NO;
    UIButton *iFrameBtn = (UIButton *)[self.viewCtrlButtons viewWithTag:705];
    iFrameBtn.enabled = NO;
    
    [self addGesturesPichInAndOut];
    [self updateNavigationBarAndToolBar];
    
    self.imageViewStreamer = [[UIImageView alloc] initWithFrame:_imageViewVideo.frame];
    //[self.imageViewStreamer setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageViewStreamer setBackgroundColor:[UIColor blackColor]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapGestureCaptured:)];
    [self.imageViewStreamer addGestureRecognizer:singleTap];
    [singleTap release];
    [self.imageViewStreamer setUserInteractionEnabled:YES];

    [self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
    
    if (self.selectedChannel.profile.modelID != 6) // CameraHD
    {
        self.timelineVC = [[TimelineViewController alloc] init];
        [self.view addSubview:_timelineVC.view];
        self.timelineVC.timelineVCDelegate = self;
        self.timelineVC.camChannel = self.selectedChannel;
        self.timelineVC.navVC = self.navigationController;
        self.timelineVC.parentVC = self;
        
        [self.timelineVC loadEvents:self.selectedChannel];
    }
    
    NSLog(@"Model of Camera is: %d", self.selectedChannel.profile.modelID);
    
    [self becomeActive];
    //[self showMenuControlPanel];
    //[self tryToHideMenuControlPanel];
    [self hideControlMenu];
    
    NSLog(@"Check selectedChannel is %@ and ip of deviece is %@", self.selectedChannel, self.selectedChannel.profile.ip_address);
    [self setupHttpPort];
    [self setupPtt];
    
    self.stringTemperature = @"0";
}

- (void) setupHttpPort
{
    NSLog(@"Self.selcetedChangel is %@",self.selectedChannel);
    _httpComm = [[HttpCommunication alloc] init];
    
    NSString* ip = self.selectedChannel.profile.ip_address;
	int port = self.selectedChannel.profile.port;
    _httpComm.device_ip  = ip;
    _httpComm.device_port = port;
    
    //init the ptt port to default
    self.selectedChannel.profile.ptt_port = IRABOT_AUDIO_RECORDING_PORT;
}
- (void)addGesturesPichInAndOut
{
    //set background for scrollView
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    //processing for pinch gestures
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = MAXIMUM_ZOOMING_SCALE;
    self.scrollView.minimumZoomScale = MINIMUM_ZOOMING_SCALE;
    [self centerScrollViewContents];
    [self resetZooming];
    //Add action for touch
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

/*
 setTitle for iOS7, purpose to change color for text, iOS6 default color is white
 */
- (void)setTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
//        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        
        titleView.textColor = [UIColor blueColor]; // Change to desired color
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void) updateNavigationBarAndToolBar
{
    // change the back button to cancel and add an event handler
    UIImage *headerLogo = [UIImage imageNamed:@"hubble_s"];
    UIBarButtonItem *headerLogoButton = [[UIBarButtonItem alloc] initWithImage:headerLogo
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(prepareGoBackToCameraList:)];
    [headerLogoButton setTintColor:[UIColor colorWithPatternImage:headerLogo]];

    self.navigationItem.leftBarButtonItem = headerLogoButton;

    UIBarButtonItem *nowButton = [[UIBarButtonItem alloc] initWithTitle:@"Now"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(nowButtonAciton:)];
    UIBarButtonItem *earlierButton = [[UIBarButtonItem alloc] initWithTitle:@"Earlier"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(earlierButtonAction:)];
    
    if (self.selectedChannel.profile.modelID == 6) // SharedCam
    {
        earlierButton.enabled = NO;
    }
    
    NSArray *actionRightButtonItems = @[earlierButton, nowButton];
    self.navigationItem.rightBarButtonItems = actionRightButtonItems;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CamProfile *cp = self.selectedChannel.profile;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            [self setTitle:cp.name];
            [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        }
        else
        {
            [self.navigationItem setTitle:cp.name];
            [self.topToolbar setHidden:YES];
        }
    }
#if DISABLE_VIEW_RELEASE_FLAG
    self.navigationItem.rightBarButtonItem.enabled = NO;
#endif
}

- (void)nowButtonAciton:(id)sender
{
    if (_isEarlierView == TRUE)
    {
        self.isEarlierView = FALSE;
        
        self.earlierVC.view.hidden = YES;
        
        NSLog(@"h264StreamerIsInStopped: %d, h264Streamer==null: %d", _h264StreamerIsInStopped, h264Streamer == NULL);
        
        if (self.h264StreamerIsInStopped == TRUE &&
            h264Streamer == NULL)
        {
            self.activityIndicator.hidden = NO;
            [self.view bringSubviewToFront:self.activityIndicator];
            [self.activityIndicator startAnimating];
            
            //[self setupCamera];
            [self performSelectorInBackground:@selector(waitingScanAndStartSetupCamera_bg) withObject:nil];
            self.h264StreamerIsInStopped = FALSE;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:_selectedChannel.profile.mac_address forKey:CAM_IN_VEW];
            [userDefaults synchronize];
        }
        else
        {
            // Streamer is showing live view
        }
    }
    else
    {
        NSLog(@"Already on NOW view!");
    }
}

- (void)earlierButtonAction:(id)sender
{
    if (_isEarlierView == FALSE)
    {
        self.isEarlierView = TRUE;
        
        if (_earlierVC == Nil)
        {
            self.earlierVC = [[EarlierViewController alloc] initWithCamChannel:self.selectedChannel];
            [self.view addSubview:_earlierVC.view];
        }
        
        if (!(_earlierVC.isViewLoaded &&
              self.view.window))
        {
            [self.view bringSubviewToFront:_earlierVC.view];
        }
        
        self.earlierVC.view.hidden = NO;
        [self.earlierVC setCamChannel:self.selectedChannel];
        self.earlierVC.timelineVC.navVC = self.navigationController;
    }
    else
    {
        NSLog(@"Already on earlier view!");
    }
    
}

#pragma mark - Action
- (IBAction)hqPressAction:(id)sender
{
    self.pickerHQOptions.hidden = NO;
    [self.view bringSubviewToFront:self.pickerHQOptions];
}

- (IBAction)iFrameOnlyPressAction:(id)sender
{
    if (h264Streamer != NULL)
    {
        if (h264Streamer->isPlaying())
        {
            self.iFrameOnlyFlag = ! self.iFrameOnlyFlag;
            
            if(self.iFrameOnlyFlag == TRUE)
            {
                h264Streamer->setPlayOption(MEDIA_STREAM_IFRAME_ONLY);
            }
            else
            {
                h264Streamer->setPlayOption(MEDIA_STREAM_ALL_FRAME);
            }
        }
    }
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
- (IBAction)zoneTouchedAction:(id)sender
{
    if (self.zoneViewController != nil)
    {
        
//        [self.navigationController  pushViewController:self.zoneViewController
//                                              animated:NO];
        [self.view addSubview:self.zoneViewController.view];
        
        [self.view bringSubviewToFront:self.zoneViewController.view];
        
    }
   
}

- (IBAction)melodyTouchAction:(id)sender
{
    if (self.melodyViewController != nil)
    {
        [self.view addSubview:self.melodyViewController.view];
        [self.view bringSubviewToFront:self.melodyViewController.view];
    }
}

- (IBAction)settingsTouchAction:(id)sender
{
    DeviceSettingsViewController *deviceSettings = [[DeviceSettingsViewController alloc] init];
    deviceSettings.camChannel = self.selectedChannel;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:deviceSettings];
    [deviceSettings release];
    [self presentViewController:nav animated:YES completion:^{}];
    [nav release];
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
    
    NSArray * args = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:msg],
                      [NSNumber numberWithInt:ext1],
                      [NSNumber numberWithInt:ext2], nil];
    
    [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:) withObject:args waitUntilDone:NO];
}

- (void)handleMessageOnMainThread: (NSArray * )args
{
    
    NSNumber *numberMsg =(NSNumber *) [args objectAtIndex:0];
   
    int ext1 = -1, ext2=-1;
    int msg = [numberMsg integerValue];
    
    if ([args count] >= 3)
    {
        ext1 = [[args objectAtIndex:1] integerValue];
        
        ext2 = [[args objectAtIndex:2] integerValue];
    }
    
    //NSLog(@"currentMediaStatus: %d", msg);
    
    switch (msg)
    {
        case MEDIA_INFO_FRAMERATE_VIDEO:
        {
            fps = ext1;
            [self addingLabelInfosForDebug];
            break;
        }
        case MEDIA_INFO_VIDEO_SIZE:
        {
            NSLog(@"video size: %d x %d", ext1, ext2);
            float top =0 , left =0;
            float destWidth;
            float destHeight;
            /*
             * Maintain Aspect Ratio
             */
            if (ext1 == 0 ||
                ext2 == 0)
            {
                break;
            }
            
            float ratio = (float) ext1/ (float)ext2;
            
            float fw = self.imageViewVideo.frame.size.height * ratio;
            float fh = self.imageViewVideo.frame.size.width  / ratio;
            
            NSLog(@"video adjusted size:r= %f    fw=%f  fh=%f", ratio, fw, fh);
            
            
            if ( fw > self.imageViewVideo.frame.size.width)
            {
                // Use the current width with new-height
                destWidth = self.imageViewVideo.frame.size.width ;
                destHeight = fh;
                
                // so need to adjust the origin
                left = self.imageViewVideo.frame.origin.x;
                top = 0;  
            }
            else
            {
                // Use the new-width with current height
                
                destWidth =  fw;
                destHeight = self.imageViewVideo.frame.size.height;
                
                // so need to adjust the origin
                if (self.imageViewVideo.frame.size.width > fw)
                {
                    left = (self.imageViewVideo.frame.size.width - fw)/2;
                }
                else
                {
                    left = self.imageViewVideo.frame.origin.x;
                }
                
                top = 0;

            }
             NSLog(@"video adjusted size: %f x %f", destWidth, destHeight);
            
            
            
//            self.imageViewVideo.frame = CGRectMake(left,
//                                                   top,
//                                                   destWidth, destHeight);
            //re-set the size
//            if (h264Streamer != NULL)
//            {
//                h264Streamer->setVideoSurface(self.imageViewVideo);
//            }
            self.imageViewStreamer.frame = CGRectMake(left,
                                                      top,
                                                      destWidth, destHeight);

            break;
        }
        case MEDIA_INFO_BITRATE_BPS:
        {
            if (userWantToCancel == TRUE)
            {
                
                NSLog(@"*[MEDIA_INFO_BITRATE_BPS] **SHOULD NOT HAPPEN FREQUENTLY* USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
                break;
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
            
        case MEDIA_INFO_HAS_FIRST_IMAGE:
        {
            NSLog(@"[MEDIA_PLAYER_HAS_FIRST_IMAGE]");
            
            self.currentMediaStatus = msg;
            
            if (self.selectedChannel.communication_mode == COMM_MODE_STUN)
            {
                self.numberOfSTUNError = 0;
            }
            
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            
            if (self.probeTimer != nil && [self.probeTimer isValid])
            {
                [self.probeTimer invalidate];
                self.probeTimer = nil;
            }
            
//            self.backBarBtnItem.enabled = YES;
            
            
            [self stopPeriodicPopup];
            
            if (self.h264StreamerIsInStopped == TRUE)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
                break;
            }
            
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
                
                //[self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
                //[self performSelectorInBackground:@selector(getTriggerRecording_bg) withObject:nil];
                //[self performSelectorInBackground:@selector(getZoneDetection_bg) withObject:nil];
                [self performSelectorInBackground:@selector(getMelodyValue_bg) withObject:nil];
                self.imgViewDrectionPad.userInteractionEnabled = YES;
                self.imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg.png"];
//                NSTimer *getTemperatureTimer = [NSTimer scheduledTimerWithTimeInterval:10
//                                                                                target:self
//                                                                              selector:@selector(getCameraTemperature_bg:)
//                                                                              userInfo:nil
//                                                                               repeats:YES];
//                [getTemperatureTimer fire];
                [self performSelectorInBackground:@selector(getCameraTemperature_bg:) withObject:nil];
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
                break;
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
            
    		NSLog(@"Timeout While streaming  OR server DIED - userWantToCancel: %d", userWantToCancel);
            
    		//mHandler.dispatchMessage(Message.obtain(mHandler, Streamer.MSG_VIDEO_STREAM_HAS_STOPPED_UNEXPECTEDLY));
            
            if (self.selectedChannel.communication_mode == COMM_MODE_STUN)
            {
                self.numberOfSTUNError++;
            }
            
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
            
            
    		break;
        }
    		
        case H264_SWITCHING_TO_RELAY_SERVER:// just update the dialog
        {
            NSLog(@"switching to relay server");
            
            //TODO: Make sure we have closed all stream
            //Assume we are connecting via Symmetrict NAT
            [self remoteConnectingViaSymmectric];
            
            break;
        }
            
            
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
            

            msg = [NSString stringWithFormat:@"%@ (%d)", msg, self.selected_channel.remoteConnectionError];
            if (self.streamer != nil)
            {
                msg = [NSString stringWithFormat:@"%@(%d)",msg,
                       self.streamer.latest_connection_error ];
            }

            
            
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
    else if (h264Streamer != NULL)
    {
        h264Streamer->sendInterrupt(); // Assuming h264Streamer stop itself.
    }
}

#pragma mark Delegate Timeline

- (void)stopStreamToPlayback
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
    else if (h264Streamer != NULL)
    {
        h264Streamer->sendInterrupt(); // Assuming h264Streamer stop itself.
    }
}

#pragma mark - Delegate Zone view controller

- (void)beginProcessing
{
    self.viewStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:self.viewStopStreamingProgress];
}

- (void)endProcessing
{
    self.viewStopStreamingProgress.hidden = YES;
}

#pragma mak - Delegate Melody
- (void)setMelodyWithIndex:(NSInteger)molodyIndex
{
    
//    if (molodyIndex == 0)
//    {
//        //set icon off
//        [self.melodyButton setImage:[UIImage imageNamed:@"bb_melody_off_icon.png"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        //set icon on
//        [self.melodyButton setImage:[UIImage imageNamed:@"bb_melody_icon.png"] forState:UIControlStateNormal];
//    }
}

#pragma mark - Method

- (void)singleTapGestureCaptured:(id)sender
{
    if (_isHorizeShow == TRUE)
    {
        [self hideControlMenu];
    }
    else
    {
        [self showControlMenu];
    }
    
    //self.isHorizeShow = !_isHorizeShow;
}

- (void)hideControlMenu
{
    self.isHorizeShow = FALSE;
    self.horizMenu.hidden = YES;
    
    [self hidenAllBottomView];
    
    //[self showTimelineView];
}

- (void)showControlMenu
{
    self.isHorizeShow = TRUE;
    self.horizMenu.hidden = NO;
    [self.view bringSubviewToFront:_horizMenu];
    
    [self updateBottomView];
    
    [self hideTimelineView];
    
    if (_timerHideMenu != nil)
    {
        [self.timerHideMenu invalidate];
        self.timerHideMenu = nil;
    }
    
    self.timerHideMenu = [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(hideControlMenu)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)hideTimelineView
{
    if (_timelineVC != nil)
    {
        self.timelineVC.view.hidden = YES;
    }
}

- (void)showTimelineView
{
    if (_timelineVC != nil)
    {
        self.timelineVC.view.hidden = NO;
    }
}

- (void)h264_HandleBecomeActive
{
        
        if (userWantToCancel == TRUE)
        {
            return;
        }
        
        self.h264StreamerIsInStopped = FALSE;
        
        if(_selectedChannel.profile.isInLocal == TRUE)
        {
            NSLog(@"Become ACTIVE _  .. Local ");
            [self becomeActive];
        }
        else if ( _selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
        {
            [self becomeActive];
        }
}

- (void)h264_HandleEnteredBackground
{
    
    if (userWantToCancel == TRUE)
    {
        return;
    }
    
    _selectedChannel.stopStreaming = TRUE;
    
    //[self stopPeriodicPopup];
    
    if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
        self.currentMediaStatus == MEDIA_PLAYER_STARTED ||
        (self.currentMediaStatus == 0 && h264Streamer == NULL)) // Media player haven't start yet.
    {
        NSLog(@"H264VC - handleEnteredBackground - IF()");
        
        [self stopStream];
    }
    else
        if(h264Streamer != NULL)
    {
        NSLog(@"H264VC - handleEnteredBackground - else if(h264Streamer != nil)");
        
        h264Streamer->sendInterrupt();
    }
    
    self.h264StreamerIsInStopped = TRUE;
    
    //self.imageViewVideo.backgroundColor = [UIColor blackColor];
    self.imageViewStreamer.backgroundColor = [UIColor blackColor];
    if (_selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"Enter Background.. Local ");
    }
    else if (_selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
    {
        //NSLog(@"abort remote timer ");
        [_selectedChannel abortViewTimer];
    }
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}


- (void)becomeActive
{
    self.pickerHQOptions.hidden = YES;
    
    self.selectedChannel.stopStreaming = NO;
    self.activityIndicator.hidden = NO;
    self.activityIndicator.color = [UIColor whiteColor];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.viewStopStreamingProgress.hidden = YES;
    
    
    [self performSelectorInBackground:@selector(waitingScanAndStartSetupCamera_bg) withObject:nil];
    //[self setupCamera];
    
    //set value default for table view
    self.playlistViewController.tableView.hidden= YES;
    // loading earlierlist in background
#if DISABLE_VIEW_RELEASE_FLAG
#else
    //[self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];
    [self performSelectorInBackground:@selector(loadTimelineEvents_bg) withObject:nil];
#endif
    
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
    
    self.imageViewHandle.hidden = YES;
    self.imageViewKnob.center = self.imgViewDrectionPad.center;
    self.imageViewHandle.center = self.imgViewDrectionPad.center;
}

#pragma mark - Setup camera

- (void)waitingScanAndStartSetupCamera_bg
{
    while (self.selectedChannel.profile.hasUpdateLocalStatus == FALSE ||
           self.selectedChannel.waitingForStreamerToClose == TRUE)
    {
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
    }
    
    // Make sure Camera is available (minuteSinceLastComm == 1)
    if (self.selectedChannel.profile.isInLocal == FALSE &&
        self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        // Scan Camera again
        NSLog(@"H264PlayerVC - Scan for missing camera: %@", self.selectedChannel.profile.ip_address);
        [self performSelectorOnMainThread:@selector(scan_for_missing_camera) withObject:nil waitUntilDone:NO];
    }
    else
    {
        // Camera in Local
        [self performSelectorOnMainThread:@selector(setupCamera) withObject:nil waitUntilDone:NO];
    }
}

- (void)setupCamera
{
    if (self.selectedChannel.stream_url != nil)
    {
        self.selectedChannel.stream_url = nil;
    }
    _httpComm.device_ip = self.selectedChannel.profile.ip_address;
    _httpComm.device_port = self.selectedChannel.profile.port;

    
    NSLog(@"device_ip is %@ and device_port is %d", self.selectedChannel.profile.ip_address, self.selectedChannel.profile.port);
    //Support remote UPNP video as well
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"created a local streamer");
        self.selectedChannel.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
        
#if 0
      
        self.selectedChannel.stream_url = @"rtsp://user:pass@%@:6667/blinkhd";
#endif
        
        //self.progressView.hidden = YES;
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
        _viewVideoIn = @"L";

    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"Log - created a remote streamer - {enabled_stun}: %@", [userDefaults objectForKey:@"enabled_stun"]);
        
        // This value is setup on Account view
        if([userDefaults boolForKey:@"enabled_stun"] == FALSE)
        {
            // Force APP_IS_ON_SYMMETRIC_NAT to use RELAY mode
            [self symmetric_check_result:TRUE];
        }
        else
        {
            if (_client == nil)
            {
                _client = [[StunClient alloc] init];
            }
            
            int symmetric_nat_status = [userDefaults integerForKey:APP_IS_ON_SYMMETRIC_NAT];
            
            //For any reason it fails to check earlier, we try checking now.
            if (symmetric_nat_status == TYPE_UNKNOWN)
            {
                //Non Blocking call
                [self.client test_start_async:self];
            }
            else
            {
                //call direct the callback
                
                [self symmetric_check_result: (symmetric_nat_status == TYPE_SYMMETRIC_NAT)];
                
            }
        }

    }
    else
    {
        _isCameraOffline = YES;
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
//        self.backBarBtnItem.enabled = YES;
        self.imageViewStreamer.image = [UIImage imageNamed:@"ImgNotAvailable"];
        self.viewCtrlButtons.hidden = YES;
        self.imgViewDrectionPad.hidden= YES;
        self.viewStopStreamingProgress.hidden = YES;
        self.horizMenu.userInteractionEnabled = NO;
        
        NSLog(@"Camera maybe not available.");
    }
}
-(void) startStunStream
{
    self.selectedChannel.communication_mode = COMM_MODE_STUN;
    
    NSDate * timeout;

    NSRunLoop * mainloop = [NSRunLoop currentRunLoop];
    do
    {
        
        //send probes
        
        [self.client sendAudioProbesToIp: self.selectedChannel.profile.camera_mapped_address
                                 andPort:self.selectedChannel.profile.camera_stun_audio_port];
        [NSThread sleepForTimeInterval:0.3];
        
        [self.client sendVideoProbesToIp: self.selectedChannel.profile.camera_mapped_address
                                 andPort:self.selectedChannel.profile.camera_stun_video_port];
        //[NSThread sleepForTimeInterval:0.3];
        
        
        timeout = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [mainloop runUntilDate:timeout];
        
        if (userWantToCancel== TRUE)
        {
            NSLog(@"startStunStream: userWantToCancel >>>>");
            break;
            
        }
        
    }
    while ( (self.selectedChannel.stream_url == nil) ||
             (self.selectedChannel.stream_url.length == 0) );

    
    if (userWantToCancel != TRUE)
    {
        self.probeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(periodicProbe:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    NSLog(@"--URL: %@", self.selectedChannel.stream_url);
    
    [self startStream];
}

-(void) startStream
{
    self.h264StreamerIsInStopped = FALSE;
    
    
    
    if (userWantToCancel== TRUE)
    {
        NSLog(@"startStream: userWantToCancel >>>>");
        //force this to gobacktoCameralist
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    while (h264Streamer != NULL)
    {
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
    }
    
    h264Streamer = new MediaPlayer(false);
    
    h264StreamerListener = new H264PlayerListener(self);
    h264Streamer->setListener(h264StreamerListener);
    
    
#if 1
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
#else
    dispatch_async(player_func_queue, ^{
        [self startStream_bg];
    });
#endif
    
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    
    //Store current SSID - to check later
	NSString * streamingSSID = [CameraPassword fetchSSIDInfo];
	if (streamingSSID == nil)
	{
		NSLog(@"Error: streamingSSID is nil before streaming");
	}
    
	NSLog(@"Current SSID is: %@", streamingSSID);
    
    
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
    
    NSString * url = self.selectedChannel.stream_url;
    NSLog(@"startStream_bg url = %@", url);
    do
    {
        if (url == nil)
        {
            break;
        }
        status = h264Streamer->setDataSource([url UTF8String]);
        
        if (status != NO_ERROR) // NOT OK
        {
            NSLog(@"setDataSource  failed");
            
            break;
        }
        
        //h264Streamer->setVideoSurface(self.imageViewVideo);
        //[self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
        h264Streamer->setVideoSurface(_imageViewStreamer);
        
        status=  h264Streamer->prepare();
        
        if (status != NO_ERROR) // NOT OK
        {
            break;
        }
        
        // Play anyhow
        
        status=  h264Streamer->start();
        
       
        if (status != NO_ERROR) // NOT OK
        {
            
            
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

- (void)prepareGoBackToCameraList:(id)sender
{
    self.viewStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:self.viewStopStreamingProgress];
    
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    NSLog(@"self.currentMediaStatus: %d", self.currentMediaStatus);
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
        self.currentMediaStatus == MEDIA_PLAYER_STARTED       ||
        (self.currentMediaStatus == 0 && h264Streamer == NULL)) // Media player haven't start yet.
    {
        
        //TODO: Check for stun mode running...
        [self goBackToCameraList];
    }
    else if(h264Streamer != nil)
    {
        h264Streamer->sendInterrupt();
    }
    else
    {
        [self goBackToCameraList];
    }
    
    
}

- (void)goBackToCameraList
{
    //no need call stopStream in offline mode
    if (!_isCameraOffline)
    {
        [self stopStream];
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
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

-(void) stopStunStream
{
    if (self.probeTimer != nil && [self.probeTimer isValid])
    {
        [self.probeTimer invalidate];
        self.probeTimer = nil;
    }
    
    if (self.selectedChannel.communication_mode == COMM_MODE_STUN)
    {
        if ( (self.selectedChannel != nil)  &&
            (self.selectedChannel.profile.camera_mapped_address != nil) &&
            (self.selectedChannel.profile.camera_stun_audio_port != 0) &&
            (self.selectedChannel.profile.camera_stun_video_port != 0)
            )
        { // Make sure we are connecting via STUN
            
            if (self.h264PlayerVCDelegate != nil)
            {
                self.selectedChannel.waitingForStreamerToClose = YES;
                NSLog(@"waiting for close STUN stream from server");
            }
            
            H264PlayerViewController *vc = (H264PlayerViewController *)[self retain];
            [self performSelectorInBackground:@selector(closeStunStream_bg:) withObject:vc];
            
        }
    }
    
    
    if (_client != nil)
    {
        [_client shutdown];
        [_client release];
        _client = nil;
    }
    

}

- (void)closeStunStream_bg: (id)vc
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:nil
                                                                          FailSelector:nil
                                                                             ServerErr:nil] autorelease];
    
    NSString * cmd_string = @"action=command&command=close_p2p_rtsp_stun";
    
    //NSDictionary *responseDict =
    [jsonComm  sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                         andCommand:cmd_string
                                          andApiKey:apiKey];
    H264PlayerViewController *thisVC = (H264PlayerViewController *)vc;
    if (userWantToCancel == TRUE)
    {
        [thisVC.h264PlayerVCDelegate stopStreamFinished: thisVC.selectedChannel];
        thisVC.h264PlayerVCDelegate = nil;
    }
    else
    {
        self.selectedChannel.waitingForStreamerToClose = NO;
    }
    
    [thisVC release];
}

- (void)stopRelayStream
{
    if (self.selectedChannel.communication_mode == COMM_MODE_STUN_RELAY2) // Temp solution
    {
        if (self.h264PlayerVCDelegate != nil)
        {
            self.selectedChannel.waitingForStreamerToClose = YES;
            NSLog(@"waiting for close RELAY stream from server");
        }
        
        H264PlayerViewController *vc = (H264PlayerViewController *)[self retain];
        [self performSelectorInBackground:@selector(closeRelayStream_bg:) withObject:vc];
        
    }
}

- (void)closeRelayStream_bg: (id)vc
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:nil
                                                                          FailSelector:nil
                                                                             ServerErr:nil];
    
    NSString * cmd_string = @"action=command&command=close_relay_rtmp";
    
    //NSDictionary *responseDict =
    [jsonComm  sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                         andCommand:cmd_string
                                          andApiKey:apiKey];
    [jsonComm release];
    
    H264PlayerViewController *thisVC = (H264PlayerViewController *)vc;
    if (userWantToCancel == TRUE)
    {
        [thisVC.h264PlayerVCDelegate stopStreamFinished: thisVC.selectedChannel];
        thisVC.h264PlayerVCDelegate = nil;
    }
    else
    {
        self.selectedChannel.waitingForStreamerToClose = NO;
    }
    
    [thisVC release];
}

- (void)stopStream
{

#if 0
    dispatch_async(player_func_queue, ^{
        
        if (h264Streamer != NULL)
        {
            
            h264Streamer->suspend();
            h264Streamer->stop();
            
            delete h264Streamer ;
            h264Streamer = NULL;
        }
        
        
        
        [self cleanUpDirectionTimers];
        if (scanner != nil)
        {
            [scanner cancel];
        }
        
        [self performSelectorOnMainThread:@selector(stopStunStream)
                               withObject:nil
                            waitUntilDone:NO];


    });
#else
    
    NSLog(@"Calling suspend() on thread: %@", [NSThread currentThread]);
    
    @synchronized(self)
    {
        if (h264Streamer != NULL)
        {
            //h264Streamer->setListener(NULL);
            
            h264Streamer->suspend();
            h264Streamer->stop();
            
            delete h264Streamer ;
            h264Streamer = NULL;
        }

        
        [self cleanUpDirectionTimers];
        if (scanner != nil)
        {
            [scanner cancel];
        }
        [self  stopStunStream];
        
        [self stopRelayStream];
    }
#endif
    //[self.activityStopStreamingProgress stopAnimating];
}

#if 1
- (void)loadTimelineEvents_bg
{
    
}
#else

- (void)loadEarlierList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
//    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
//                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
//                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)];
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil] autorelease];
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
}
#endif

-(void) getVQ_bg
{
    NSString *bodyKey = @"";
    
    if (self.selectedChannel.profile.isInLocal )
	{
//        HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
        _httpComm.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:@"get_resolution"];
        
        if (responseData != nil)
        {
            bodyKey = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"getVQ_bg response string: %@", bodyKey);
        }
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
	{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSLog(@"Log - registrationID %@, apikey %@", self.selectedChannel.profile.registrationID, apiKey);
        
		BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                  andCommand:[NSString stringWithFormat:@"action=command&command=get_resolution"]
                                                                                   andApiKey:apiKey];
        if (responseDict != nil)
        {
            
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
        
        NSLog(@"getVQ_bg responseDict = %@", responseDict);
	}
    
    if (![bodyKey isEqualToString:@""])
    {
        NSArray * tokens = [bodyKey componentsSeparatedByString:@": "];
        if ([tokens count] >=2 )
        {
            NSString *modeVideo = [tokens objectAtIndex:1];
            
            [self performSelectorOnMainThread:@selector(setVQForground:)
                                   withObject:modeVideo waitUntilDone:NO];
        }
    }
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
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
//        HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
        _httpComm.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:@"get_recording_stat"];
        
        if (responseData != nil)
        {
            
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"getTriggerRecording_bg response string: %@", responseString);
        }
    }
    else
    {
        BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil] autorelease];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                  andCommand:@"action=command&command=get_recording_stat"
                                                                                   andApiKey:apiKey];
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    if (![responseString isEqualToString:@""])
    {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        
        if (tmpRange.location != NSNotFound)
        {
            NSArray * tokens = [responseString componentsSeparatedByString:@": "];
            
            if (tokens.count > 1 )
            {
                NSString *modeRecording = [tokens  objectAtIndex:1];
                
                [self performSelectorOnMainThread:@selector(setTriggerRecording_fg:)
                                       withObject:modeRecording
                                    waitUntilDone:NO];
            }
        }
    }
    else
    {
        self.recordingFlag = !self.recordingFlag;
    }
}

- (void)setTriggerRecording_bg:(NSString *) modeRecording
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
//        HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
        _httpComm.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:[NSString stringWithFormat:@"set_recording_stat&mode=%@", modeRecording]];
        
        if (responseData != nil)
        {
            
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"setTriggerRecording_bg response string: %@", responseString);
        }
    }
    else
    {
        BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil] autorelease];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                  andCommand:[NSString stringWithFormat:@"action=command&command=set_recording_stat&mode=%@", modeRecording]
                                                                                   andApiKey:apiKey];
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    if (![responseString isEqualToString:@""])
    {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        
        if (tmpRange.location != NSNotFound)
        {
            NSArray * tokens = [responseString componentsSeparatedByString:@": "];
            
            if (tokens.count > 1 )
            {
                NSString *modeRecording = [tokens  objectAtIndex:1];
                
                [self performSelectorOnMainThread:@selector(setTriggerRecording_fg:)
                                       withObject:modeRecording
                                    waitUntilDone:NO];
            }
        }
    }
    else
    {
        self.recordingFlag = !self.recordingFlag;
    }
}

-(void) setTriggerRecording_fg: (NSString *)modeRecording
{
            
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

#pragma mark - Zone Detection

- (void)getZoneDetection_bg
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
//        HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
//        httpCommunication.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:@"get_motion_area"];
        
        if (responseData != nil)
        {
            
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"getZoneDetection_bg response string: %@", responseString);
        }
    }
    else
    {
        BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil] autorelease];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                  andCommand:@"action=command&command=get_motion_area"
                                                                                   andApiKey:apiKey];
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    if (![responseString isEqualToString:@""])
    {
        NSRange tmpRange = [responseString rangeOfString:@"="];
        
        if (tmpRange.location != NSNotFound)
        {
            NSArray * tokens = [responseString componentsSeparatedByString:@"="];
            
            if (tokens.count > 1 )
            {
                NSString *zoneString = [tokens lastObject];
                
                if ([zoneString isEqualToString:@""])
                {
                    NSLog(@" NO zone being set");
                    
                    NSArray *zoneArr = [NSArray array];
                    
                    [self performSelectorOnMainThread:@selector(setZoneDetection_fg:)
                                           withObject:zoneArr
                                        waitUntilDone:NO];
                    
                }
                else
                {
                    NSRange range = [zoneString rangeOfString:@","];
                    
                    NSArray *zoneArr;// = [NSArray array];
                    
                    if (range.location != NSNotFound)
                    {
                        zoneArr = [NSArray arrayWithArray: [zoneString componentsSeparatedByString:@","]];
                        
                        NSLog(@"getZoneDetection_bg: %@", zoneArr);
                    }
                    else
                    {
                        zoneArr = [NSArray arrayWithObject:zoneString];
                    }
                    
                    [self performSelectorOnMainThread:@selector(setZoneDetection_fg:)
                                           withObject:zoneArr
                                        waitUntilDone:NO];
                }
            }
        }
    }
    else
    {
        self.zoneButton.enabled = YES;
    }
    
    //get_motion_area: grid=AxB,zone=00,11
}

- (void)setZoneDetection_fg: (NSArray *)zoneArray
{
    if (self.zoneViewController != nil)
    {
        [self.zoneViewController parseZoneStrings:zoneArray];
    }
    else
    {
        //create new
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.zoneViewController = [[[ZoneViewController alloc] initWithNibName:@"ZoneViewController_ipad" bundle:[NSBundle mainBundle]] autorelease];
        }
        else
        {
            self.zoneViewController = [[[ZoneViewController alloc] initWithNibName:@"ZoneViewController" bundle:[NSBundle mainBundle]] autorelease];
            
        }
        
        self.zoneViewController.selectedChannel = self.selectedChannel;
        self.zoneViewController.zoneVCDelegate = self;
        
    }
    
    [self.zoneViewController parseZoneStrings:zoneArray];
    
    
    self.zoneButton.enabled = YES;
}

#pragma mark - Melody Control

- (void)getMelodyValue_bg
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
//        HttpCommunication *httpCommunication = [[HttpCommunication alloc] init];
//        httpCommunication.device_ip = self.selectedChannel.profile.ip_address;
//        httpCommunication.device_port = self.selectedChannel.profile.port;
        
        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
        _httpComm.device_port = 80;
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:@"value_melody"];
        
        if (responseData != nil)
        {
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
        }
    }
    else
    {
        BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil] autorelease];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                  andCommand:@"action=command&command=value_melody"
                                                                                   andApiKey:apiKey];
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    NSLog(@"getMelodyValue_bg: %@", responseString);
    
    if (![responseString isEqualToString:@""])
    {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        
        if (tmpRange.location != NSNotFound)
        {
            NSArray *tokens = [responseString componentsSeparatedByString:@": "];
            
            if (tokens.count > 1 )
            {
                NSString *melodyIndex = [tokens lastObject];
                    
                [self performSelectorOnMainThread:@selector(setMelodyState_Fg:)
                                       withObject:melodyIndex
                                    waitUntilDone:NO];
            }
        }
    }
    else
    {
        self.melodyButton.enabled = YES;
    }
}

- (void)setMelodyState_Fg: (NSString *)melodyIndex
{
    int melody_index  = [melodyIndex intValue];
    
    if (melody_index == 0)
    {
        //set icon off
        [self.melodyButton setImage:[UIImage imageNamed:@"bb_melody_off_icon.png"] forState:UIControlStateNormal];
    }
    else
    {
        //set icon on
        [self.melodyButton setImage:[UIImage imageNamed:@"bb_melody_icon.png"] forState:UIControlStateNormal];
    }
    
    if (self.melodyViewController == nil)
    {
        //create new
        self.melodyViewController = [[[MelodyViewController alloc] initWithNibName:@"MelodyViewController" bundle:[NSBundle mainBundle]] autorelease];
        
        self.melodyViewController.selectedChannel = self.selectedChannel;
        self.melodyViewController.melodyVcDelegate = self;
    }
    
    [self.melodyViewController setMelodyState_fg:melody_index];
    
    self.melodyButton.enabled = YES;
}

#pragma mark - Temperature

- (void)getCameraTemperature_bg: (id)sender
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {

        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
        _httpComm.device_port = self.selectedChannel.profile.port;
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:@"value_temperature"];

        if (responseData != nil)
        {
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
        }
    }
    else
    {
        BMS_JSON_Communication *jsonCommunication = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                           Selector:nil
                                                                                       FailSelector:nil
                                                                                          ServerErr:nil];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                  andCommand:@"action=command&command=value_temperature"
                                                                                   andApiKey:apiKey];
        [jsonCommunication release];
        
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                responseString = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"]; // value_temperature: 29.2
            }
        }
    }
    
    NSLog(@"Reponse - getCameraTemperature_bg: %@", responseString);
    
    if (![responseString isEqualToString:@""]   && // Get temperature failed!
        ![responseString isEqualToString:@"NA"] && // Received temperature wrong format
        ![responseString hasSuffix:@"null"])       // Received temperature {status code} null
    {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        
        if (tmpRange.location != NSNotFound)
        {
            NSArray *arrayBody = [responseString componentsSeparatedByString:@": "];
            
            if (arrayBody != nil &&
                arrayBody.count == 2)
            {
                self.stringTemperature = [arrayBody objectAtIndex:1];
                
                [self performSelectorOnMainThread:@selector(setTemperatureState_Fg:)
                                       withObject:_stringTemperature
                                    waitUntilDone:NO];
            }
            else
            {
                //NSLog(@"Error - Command is not found or wrong format: %@", responseString);
            }
        }
        else
        {
            //NSLog(@"Error - Command is not found or wrong format: %@", responseString);
        }
    }
    else
    {
        // Do nothings | reset UI
        //NSLog(@"Error - Command is not found or wrong format: %@", responseString);
    }
    
    // Make sure Update temperature once after that check condition
    if (sender != nil &&
        [sender isKindOfClass:[NSTimer class]])
    {
        if (self.ib_temperature.hidden == YES || // Label tmperature was hidden
            userWantToCancel == TRUE ||          // Back out
            self.h264StreamerIsInStopped == TRUE)
        {
            [((NSTimer *)sender) invalidate];
            sender = nil;
            self.existTimerTemperature = FALSE;
            
            NSLog(@"Log - Invalidate Timer get temperature");
            
            return;
        }
    }
}

- (void)setTemperatureState_Fg: (NSString *)temperature
{
    // Update UI
    
    NSString *stringTemperature = [NSString stringWithFormat:@"%d˚c", (int)roundf([temperature floatValue])];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:stringTemperature];
    
    UIFont *smallFont = [UIFont systemFontOfSize:40.0f];
    [attrString addAttribute:NSFontAttributeName value:(smallFont) range:NSMakeRange(stringTemperature.length - 1, 1)];
    [attrString addAttribute:(id)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(stringTemperature.length - 1, 1)];

    self.ib_temperature.attributedText = attrString;
    [attrString release];
}

#pragma mark -
#pragma mark - Stun probe timer

-(void) periodicProbe:(NSTimer *) exp
{
    if (userWantToCancel == TRUE  ||
        _selectedChannel.stopStreaming == TRUE)
    {
        NSLog(@"Stop probing ... ");
    }
    else if (self.client != nil)
    {
        NSDate * timeout;
        
        NSRunLoop * mainloop = [NSRunLoop currentRunLoop];
        NSLog(@"send probes ... ");
        //send probes

        [self.client sendVideoProbesToIp: self.selectedChannel.profile.camera_mapped_address
                                 andPort:self.selectedChannel.profile.camera_stun_video_port];
        
        timeout = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [mainloop runUntilDate:timeout];
        
        
        
        [self.client sendAudioProbesToIp: self.selectedChannel.profile.camera_mapped_address
                                 andPort:self.selectedChannel.profile.camera_stun_audio_port];
        timeout = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [mainloop runUntilDate:timeout];
        
        
        
        
    }
}

#pragma mark -
#pragma mark - Stun client delegate

-(void)symmetric_check_result: (BOOL) isBehindSymmetricNat
{
    NSInteger result = (isBehindSymmetricNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"enabled_stun"] == TRUE)
    {
        [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
        [userDefaults synchronize];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                   ^{
                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                       NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                       //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
                       NSString *stringUDID = self.selectedChannel.profile.registrationID;
                       
                       BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                                 Selector:nil
                                                                                             FailSelector:nil
                                                                                                ServerErr:nil] autorelease];
                       NSDictionary *responseDict;
                       //NSLog(@"%@", responseDict);
                       
                       
                       if (isBehindSymmetricNat == TRUE) // USE RELAY
                       {
                           NSLog(@"USE RELAY TO VIEW***********************");
                           _viewVideoIn = @"R";
                           responseDict = [jsonComm createSessionBlockedWithRegistrationId:stringUDID
                                                                             andClientType:@"BROWSER"
                                                                                 andApiKey:apiKey];
                           if (responseDict != nil)
                           {
                               if ([[responseDict objectForKey:@"status"] intValue] == 200)
                               {
                                   //self.selectedChannel.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                                   
                                   NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                                   
                                   NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
                                
                                   if ([urlResponse hasPrefix:ME_WOWZA] &&
                                       [userDefalts boolForKey:VIEW_NXCOMM_WOWZA] == TRUE)
                                   {
                                        self.selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                                   }
                                   else
                                   {
                                       self.selectedChannel.stream_url = urlResponse;
                                   }
                                   
                                   self.selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                                   
                                   [self performSelectorOnMainThread:@selector(startStream)
                                                          withObject:nil
                                                       waitUntilDone:NO];
                                   
                                   
                               }
                               else
                               {
                                   //handle Bad response
                                   
                                   NSArray * args = [NSArray arrayWithObjects:
                                                     [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];
                                   //force server died
                                   [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                          withObject:args
                                                       waitUntilDone:NO];
                               }
                           }
                           else
                           {
                               NSLog(@"SERVER unreachable (timeout) ");
                               //TODO : handle SERVER unreachable (timeout)
                           }
                           
                           
                       }
                       else // USE RTSP/STUN
                       {
                           
                           //Set port1, port2
                           NSLog(@"USE RTSP/STUN TO VIEW***********************");
                           _viewVideoIn = @"S";
                           if ([self.client create_stun_forwarder:self.selectedChannel] != 0 )
                           {
                               //TODO: Handle error
                           }
                           NSString * cmd_string = [NSString stringWithFormat:@"action=command&command=get_session_key&mode=p2p_stun_rtsp&port1=%d&port2=%d&ip=%@",
                                                    self.selectedChannel.local_stun_audio_port,
                                                    self.selectedChannel.local_stun_video_port,
                                                    self.selectedChannel.public_ip];
                           
                           responseDict =  [jsonComm  sendCommandBlockedWithRegistrationId:stringUDID
                                                                                andCommand:cmd_string
                                                                                 andApiKey:apiKey];
                           
                           if (responseDict != nil)
                           {
                               NSLog(@"symmetric_check_result, responseDict: %@", responseDict);
                               
                               NSString *body = [[[responseDict objectForKey: @"data"] objectForKey: @"device_response"] objectForKey: @"body"];
                               //"get_session_key: error=200,port1=37171&port2=47608&ip=115.77.250.193,mode=p2p_stun_rtsp"
                               
                                NSLog(@"Respone - camera response : %@, Number of STUN error: %d", body, _numberOfSTUNError);
                               if (body != nil )
                               {
                                   NSArray * tokens = [body componentsSeparatedByString:@","];
                                   

                                   if ( [[tokens objectAtIndex:0] hasSuffix:@"error=200"]) //roughly check for "error=200"
                                   {
                                       if (_numberOfSTUNError >= 3) // Switch to RELAY because STUN try probe & failed many times
                                       {
                                           NSLog(@"Switch to RELAY - Number of STUN error: %d", _numberOfSTUNError);
                                           
                                           /* close current session  before continue*/
                                           cmd_string = @"action=command&command=close_p2p_rtsp_stun";
                                           
                                           //responseDict =
                                           [jsonComm  sendCommandBlockedWithRegistrationId:stringUDID
                                                                                andCommand:cmd_string
                                                                                 andApiKey:apiKey];
                                           
                                           if (userWantToCancel == FALSE)
                                           {
                                               self.numberOfSTUNError = 0;
                                               
                                               //[self handleMessage:H264_SWITCHING_TO_RELAY_SERVER ext1:0 ext2:0];
                                               NSArray * args = [NSArray arrayWithObjects:
                                                                 [NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER],nil];
                                               
                                               //relay
                                               [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                                      withObject:args
                                                                   waitUntilDone:NO];
                                           }
                                       }
                                       else
                                       {
                                           NSString * ports_ip = [tokens objectAtIndex:1];
                                           
                                           NSArray * token1s = [ports_ip componentsSeparatedByString:@"&"];
                                           NSString * port1_str = [token1s objectAtIndex:0];
                                           NSString * port2_str = [token1s objectAtIndex:1];
                                           NSString * cam_ip = [token1s objectAtIndex:2];
                                           
                                           
                                           
                                           self.selectedChannel.profile.camera_mapped_address = [[cam_ip componentsSeparatedByString:@"="] objectAtIndex:1];
                                           self.selectedChannel.profile.camera_stun_audio_port = [(NSString *)[[port1_str componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
                                           self.selectedChannel.profile.camera_stun_video_port =[(NSString *)[[port2_str componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
                                           
                                           if (userWantToCancel == FALSE)
                                           {
                                               [self performSelectorOnMainThread:@selector(startStunStream)
                                                                      withObject:nil
                                                                   waitUntilDone:NO];
                                           }
                                       }
                                   }
                                   else
                                   {
                                       NSLog(@"Respone error - camera response error: %@", body);
                                       
                                       
                                       /* close current session  before continue*/
                                       cmd_string = @"action=command&command=close_p2p_rtsp_stun";
                                       
                                       //responseDict =
                                       [jsonComm  sendCommandBlockedWithRegistrationId:stringUDID
                                                                            andCommand:cmd_string
                                                                             andApiKey:apiKey];
                                       
                                       if (userWantToCancel == FALSE)
                                       {
                                           NSArray * args = [NSArray arrayWithObjects:
                                                             [NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER],nil];
                                           
                                           //relay
                                           [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                                  withObject:args
                                                               waitUntilDone:NO];
                                       }
                                       
                                   }
                               }
                               else
                               {
                                   NSLog(@"Respone error - can't parse \"body\"field from: %@", responseDict);
                                   
                                   NSArray * args = [NSArray arrayWithObjects:
                                                     [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];
                                   //force server died
                                   [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                          withObject:args
                                                       waitUntilDone:NO];

                               }
                               
                           }
                           else
                           {
                               NSLog(@"SERVER unreachable (timeout) - responseDict == nil --> Need test this more");
                               
                               NSArray * args = [NSArray arrayWithObjects:
                                                 [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];

                               [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                      withObject:args
                                                   waitUntilDone:NO];
                           }
                       }
    
                   }
                   
                   
                   );
    
    
    if (isBehindSymmetricNat != TRUE)
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           NSString *bodyKey = @"";
                           
                           if (self.selectedChannel.profile.isInLocal )
                           {
//                               HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
                               _httpComm.device_ip = self.selectedChannel.profile.ip_address;
                               _httpComm.device_port = self.selectedChannel.profile.port;
                               
                               NSData *responseData = [_httpComm sendCommandAndBlock_raw:@"get_resolution"];
                               
                               if (responseData != nil)
                               {
                                   bodyKey = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
                                   
                                   NSLog(@"symmetric_check_result response string: %@", bodyKey);
                               }
                           }
                           else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
                           {
                               NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                               
                               //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
                               NSString *stringUDID = self.selectedChannel.profile.registrationID;
                               NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                               NSLog(@"Log - registrationID: %@, apikey: %@", stringUDID, apiKey);
                               
                               BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                                                  Selector:nil
                                                                                                              FailSelector:nil
                                                                                                                 ServerErr:nil] autorelease];
                               
                               NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:stringUDID
                                                                                                         andCommand:[NSString stringWithFormat:@"action=command&command=get_resolution"]
                                                                                                          andApiKey:apiKey];
                               if (responseDict != nil)
                               {
                                   
                                   NSInteger status = [[responseDict objectForKey:@"status"] intValue];
                                   if (status == 200)
                                   {
                                       bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
                                   }
                               }
                               
                               NSLog(@"symmetric_check_result responseDict = %@", responseDict);
                           }
                           
                           if (![bodyKey isEqualToString:@""])
                           {
                               NSArray * tokens = [bodyKey componentsSeparatedByString:@": "];
                               if ([tokens count] >=2 )
                               {
                                   NSString *modeVideo = [tokens objectAtIndex:1];
                                   
                                   
                                   if ([modeVideo isEqualToString:@"480p"]) // ok
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"stream480p" ofType:@"sdp"];
                                   }
                                   else if ([modeVideo isEqualToString:@"VGA640_480"]) // Camera server resolution
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"streamvga" ofType:@"sdp"];
                                   }
                                   else if ([modeVideo isEqualToString:@"QVGA320_240"]) // Camera server resolution
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"streamqvga" ofType:@"sdp"];
                                   }
                                   else if ([modeVideo isEqualToString:@"720p_926"])
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"blink11hd720p" ofType:@"sdp"];
                                   }
                                   else if ([modeVideo isEqualToString:@"480p_926"])
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"blink11hd480p" ofType:@"sdp"];
                                   }
                                   else if ([modeVideo isEqualToString:@"360p_926"] )
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"blink11hd360p" ofType:@"sdp"];
                                   }
                                   else //if([modeVideo isEqualToString:@"720p_10"] || [modeVideo isEqualToString:@"720p_15"])
                                   {
                                       self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"stream720p" ofType:@"sdp"];
                                   }
                               }
                               else
                               {
                                   self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"stream720p_10_926" ofType:@"sdp"];
                               }
                           }
                           else
                           {
                               
                               self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"stream720p" ofType:@"sdp"];
                           }
                           
                       });
        
    } //if (isBehindSymmetricNat != TRUE)
}

- (void)remoteConnectingViaSymmectric
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                   ^{
                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                       NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                       //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
                       NSString *stringUDID = self.selectedChannel.profile.registrationID;
                       
                       BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                                 Selector:nil
                                                                                             FailSelector:nil
                                                                                                ServerErr:nil] autorelease];
                       NSDictionary *responseDict = [jsonComm createSessionBlockedWithRegistrationId:stringUDID
                                                                         andClientType:@"BROWSER"
                                                                             andApiKey:apiKey];
                       NSLog(@"remoteConnectingViaSymmectric: %@", responseDict);
                       if (responseDict != nil)
                       {
                           if ([[responseDict objectForKey:@"status"] intValue] == 200)
                           {
                               NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                               
                               NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
                               
                               if ([urlResponse hasPrefix:ME_WOWZA] &&
                                   [userDefalts boolForKey:VIEW_NXCOMM_WOWZA] == TRUE)
                               {
                                   self.selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                               }
                               else
                               {
                                   self.selectedChannel.stream_url = urlResponse;
                               }
                               
                               if (userWantToCancel == FALSE)
                               {
                                   self.selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                                   [self performSelectorOnMainThread:@selector(startStream)
                                                          withObject:nil
                                                       waitUntilDone:NO];
                               }
                               
                           }
                           else
                           {
                               //handle Bad response
                               NSArray * args = [NSArray arrayWithObjects:
                                                 [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];
                               //force server died
                               [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                      withObject:args
                                                   waitUntilDone:NO];
                           }
                       }
                       else
                       {
                           NSLog(@"SERVER unreachable (timeout) ");
                           //TODO : handle SERVER unreachable (timeout)
                       }
                   });
}

#pragma mark -
#pragma mark - DirectionPad

- (void)updateKnobUI: (NSInteger )direction
{
    CGFloat transformX = 0;
    CGFloat transformY = 0;
    
    switch (direction)
    {
        case DIRECTION_H_NON:
        case DIRECTION_V_NON:
            
            //self.imageViewKnob.center = _imgViewDrectionPad.center;
            //self.imageViewKnob.transform = CGAffineTransformMakeTranslation(_imgViewDrectionPad.center.x - sizeKnob, _imgViewDrectionPad.center.y - sizeKnob);
            transformX = 0;
            transformY = 0;
            break;
            
        case DIRECTION_H_LF:
        {
            transformX =  - _imageViewKnob.frame.size.width;
            transformY = 0;
        }
            break;
            
        case DIRECTION_H_RT:
        {
            transformX = _imageViewKnob.frame.size.width;
            transformY = 0;
        }
            break;
            
        case DIRECTION_V_DN:
        {
            transformX = 0;
            transformY = _imageViewKnob.frame.size.width;
        }
            break;
            
        case DIRECTION_V_UP:
        {
            transformX = 0;
            transformY = - _imageViewKnob.frame.size.width;
        }
            break;
            
        default:
            break;
    }
    
    self.imageViewKnob.transform = CGAffineTransformMakeTranslation(transformX, transformY);
    
    //NSLog(@"%f, %f", transformX, transformY);
}

- (void)updateHandleUI: (NSInteger)direction
{
    CGFloat transformX = 0;
    CGFloat transformY = 0;
    CGFloat angleRotation = 0;
    
    switch (direction)
    {
        case DIRECTION_H_NON:
        case DIRECTION_V_NON:
            
            transformX = 0;
            transformY = 0;
            
            self.imageViewHandle.hidden = YES;
            angleRotation = 0;
            break;
            
        case DIRECTION_H_LF:
        {
            self.imageViewHandle.hidden = NO;
            transformX =  - _imageViewHandle.frame.size.height / 2;
            transformY = 0;
            angleRotation = -M_PI_2;

        }
            break;
            
        case DIRECTION_H_RT:
        {
            self.imageViewHandle.hidden = NO;
            transformX = _imageViewHandle.frame.size.height / 2;
            transformY = 0;
            angleRotation = M_PI_2;
        }
            break;
            
        case DIRECTION_V_DN:
        {
            self.imageViewHandle.hidden = NO;
            transformX = 0;
            transformY = _imageViewHandle.frame.size.height / 2;
            angleRotation = 0;
        }
            break;
            
        case DIRECTION_V_UP:
        {
            self.imageViewHandle.hidden = NO;
            transformX = 0;
            transformY = - _imageViewHandle.frame.size.height / 2;
            angleRotation = 0;
        }
            break;
            
        default:
            break;
    }

    self.imageViewHandle.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(transformX, transformY), angleRotation);
    
    //NSLog(@"%f, %f", transformX, transformY);
}

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
            
			duty_cycle = IRABOT_DUTYCYCLE_MAX;// +0.1;
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
        if (_selectedChannel.profile.isInLocal)
		{
//            HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
            _httpComm.device_ip = _selectedChannel.profile.ip_address;
            _httpComm.device_port = _selectedChannel.profile.port;
            
            //Non block send-
            NSLog(@"device_ip: %@, device_port: %d", _selectedChannel.profile.ip_address, _selectedChannel.profile.port);
            
            [_httpComm sendCommand:dir_str];
            //[_httpComm sendCommandAndBlock:dir_str];
		}
		else if(_selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            //NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
            NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
        if (_selectedChannel.profile.isInLocal)
        {
//            _httpComm *_httpComm = [[[HttpCommunication alloc] init] autorelease];
            _httpComm.device_ip = _selectedChannel.profile.ip_address;
            _httpComm.device_port = _selectedChannel.profile.port;
				//Non block send-
				[_httpComm sendCommand:dir_str];
                
                //[httpCommunication sendCommandAndBlock:dir_str];
		}
		else if ( _selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            //NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            BMS_JSON_Communication *jsonCommunication = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
            NSDictionary *responseDict = [jsonCommunication sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
        
        [self updateKnobUI:currentDirUD]; // Update ui for Knob & Handle
        [self updateHandleUI:currentDirUD];
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
        
        [self updateKnobUI:currentDirUD];
        [self updateHandleUI:currentDirUD];
	}
}

- (void) updateVerticalDirection_end:(int)dir inStep: (uint) step
{
	@synchronized(_imgViewDrectionPad)
	{
		currentDirUD = DIRECTION_V_NON;
        
        [self updateKnobUI:DIRECTION_V_NON];
        [self updateHandleUI:DIRECTION_V_NON];
	}
}

- (void) updateHorizontalDirection_end:(int)dir inStep: (uint) step
{
	@synchronized(_imgViewDrectionPad)
	{
		currentDirLR = DIRECTION_H_NON;
        
        [self updateKnobUI:DIRECTION_H_NON];
        [self updateHandleUI:DIRECTION_H_NON];
	}
}

- (void)updateHorizontalDirection_begin:(int)dir inStep: (uint) step
{
    if (_timerHideMenu != nil)
    {
        [self.timerHideMenu invalidate];
        self.timerHideMenu = nil;
    }
    
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
        
        [self updateKnobUI:currentDirLR];
        [self updateHandleUI:currentDirLR];
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
        
        [self updateKnobUI:currentDirLR];
        [self updateHandleUI:currentDirLR];
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
            if (_timerHideMenu != nil)
            {
                [self.timerHideMenu invalidate];
                self.timerHideMenu = nil;
            }
            
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
            if (_timerHideMenu != nil)
            {
                [self.timerHideMenu invalidate];
                self.timerHideMenu = nil;
            }
            
            self.timerHideMenu = [NSTimer scheduledTimerWithTimeInterval:10
                                                                  target:self
                                                                selector:@selector(hideControlMenu)
                                                                userInfo:nil
                                                                 repeats:NO];
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
            //NSLog(@"ok");
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
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"camera_action_pan_bg"]];
		}
		else if (translation.y <0)
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"camera_action_pan_bg"]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"camera_action_pan_bg.png"]];
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
            
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"camera_action_pan_bg"]];
		}
		else if (translation.x < 0){
            
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"camera_action_pan_bg"]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"camera_action_pan_bg.png"]];
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



#pragma mark - Rotation screen
- (BOOL)shouldAutorotate
{
    
    if (userWantToCancel == TRUE)
    {
        return NO;
    }
    
	return YES;//!self.disableAutorotateFlag;
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

}

-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    [self resetZooming];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width;
    CGFloat screenHeight = screenBounds.size.height;
    //CGSize activitySize = _activityIndicator.frame.size;
    
    NSInteger deltaY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        deltaY = HIGH_STATUS_BAR;
    }
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        //load new nib for landscape iPad
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land_iPad"
                                          owner:self
                                        options:nil];

                self.melodyViewController.view.frame = CGRectMake(808, 434, 236, 284);


        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
                                          owner:self
                                        options:nil];

            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                self.melodyViewController.view.frame = CGRectMake(340, 60, 159, 204);
            }
            else
            {
                self.melodyViewController.view.frame = CGRectMake(320, 60, 159, 204);
            }

        }
        
        
        //landscape mode
        [self.navigationController setNavigationBarHidden:YES];
        
        // I don't know why remove it.
        [self.melodyViewController.view removeFromSuperview];
        
        CGFloat imageViewHeight = screenHeight * 9 / 16;
        CGRect newRect = CGRectMake(0, (screenWidth - imageViewHeight) / 2, screenHeight, imageViewHeight);
        self.imageViewVideo.frame = CGRectMake(0, 0, screenHeight, imageViewHeight);
        self.scrollView.frame = newRect;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.scrollView.contentSize = CGSizeMake(screenWidth, CONTENT_SIZE_W_PORTRAIT_IPAD);
            self.activityIndicator.frame = CGRectMake((screenHeight - INDICATOR_SIZE)/2, (screenWidth - INDICATOR_SIZE)/2 , INDICATOR_SIZE, INDICATOR_SIZE);
            
        }
        else
        {
            self.scrollView.contentSize = CGSizeMake(screenWidth, CONTENT_SIZE_W_PORTRAIT);
        }
        

        self.viewStopStreamingProgress.frame = CGRectMake((screenHeight - INDICATOR_SIZE)/2, (screenWidth - INDICATOR_SIZE)/2 , INDICATOR_SIZE, INDICATOR_SIZE);
        
        if (_timelineVC != nil)
        {
            [self.timelineVC.view removeFromSuperview];
        }
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        //load new nib
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_ipad"
                                          owner:self
                                        options:nil];
            self.melodyViewController.view.frame = CGRectMake(0, 496, 768, 482);
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
                                          owner:self
                                        options:nil];
            self.melodyViewController.view.frame = CGRectMake(0, 240, screenWidth, screenHeight - 240);
        }
        
        //portrait mode

        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.view.backgroundColor = [UIColor whiteColor];
        self.viewCtrlButtons.hidden = NO;
        self.viewStopStreamingProgress.hidden = YES;
        
        CGFloat imageViewHeight = screenWidth * 9 / 16;
        CGRect destRect = CGRectMake(0, 44 + deltaY, screenWidth, imageViewHeight);
        self.scrollView.frame = destRect;
        self.imageViewVideo.frame = CGRectMake(0, 0, screenWidth, imageViewHeight);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE_W_PORTRAIT_IPAD, CONTENT_SIZE_H_PORTRAIT_IPAD);
            self.activityIndicator.frame = CGRectMake((screenWidth - INDICATOR_SIZE)/2, imageViewHeight/2 + 44 + deltaY , INDICATOR_SIZE, INDICATOR_SIZE);
        }
        else
        {
            self.scrollView.contentSize = CGSizeMake(CONTENT_SIZE_W_PORTRAIT, CONTENT_SIZE_H_PORTRAIT);
        }

        self.viewCtrlButtons.frame = CGRectMake(0, imageViewHeight + 44 + deltaY, _viewCtrlButtons.frame.size.width, _viewCtrlButtons.frame.size.height);
        self.viewStopStreamingProgress.frame = CGRectMake((screenWidth - INDICATOR_SIZE)/2, (screenHeight - INDICATOR_SIZE)/2 , INDICATOR_SIZE, INDICATOR_SIZE);
        
        // Control display for TimelineVC
        if (_timelineVC != nil)
        {
            self.timelineVC.view.frame = CGRectMake(0, imageViewHeight + deltaY + 64, screenWidth, screenHeight - imageViewHeight - 100);
            self.timelineVC.view.hidden = NO;
            self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
            [self.view addSubview:_timelineVC.view];
        }
	}
    
    // Set position for Image Knob & Handle
    self.imageViewKnob.center = _imgViewDrectionPad.center;
    self.imageViewHandle.center = _imgViewDrectionPad.center;
    self.imageViewHandle.hidden = YES;

//    self.backBarBtnItem.target = self;
//    self.backBarBtnItem.action = @selector(prepareGoBackToCameraList:);
// SLIDE MENU
//    self.backBarBtnItem.target = self.stackViewController;
//    self.backBarBtnItem.action = @selector(toggleLeftViewController);
    
    self.earlierVC.view.hidden = !_isEarlierView;
    
    if (_isEarlierView == TRUE)
    {
        [self.view addSubview:_earlierVC.view];
        [self.view bringSubviewToFront:_earlierVC.view];
    }
    
    self.imageViewStreamer.frame = _imageViewVideo.frame;
    [self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
    [self setTemperatureState_Fg:_stringTemperature];
    
    [self hideControlMenu];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:_activityIndicator];
    
    if (self.selectedChannel.profile.isInLocal == FALSE &&
        self.selectedChannel.profile.minuteSinceLastComm > 5) // Not available
    {
        if (self.selectedChannel.profile.hasUpdateLocalStatus == TRUE)
        {
            [self.activityIndicator stopAnimating];
            self.horizMenu.userInteractionEnabled = NO;
        }
    }
    
    if (h264Streamer != NULL)
    {
        //trigger re-cal of videosize
        if (h264Streamer->isPlaying())
        {
            [self.activityIndicator stopAnimating];
        }
        
        h264Streamer->videoSizeChanged();
       
    }
    
    self.pickerHQOptions.hidden = YES;
    self.pickerHQOptions.userInteractionEnabled = NO;
    self.playlistViewController.view.hidden = YES;
    
#if DISABLE_VIEW_RELEASE_FLAG
    
#endif
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
    NSString *textRow = @"";
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
    
    //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString *bodyKey = @"";
    
    if (  self.selectedChannel.profile.isInLocal == TRUE)
	{
//        HttpCommunication *httpCommunication = [[[HttpCommunication alloc] init] autorelease];
        _httpComm.device_ip = self.selectedChannel.profile.ip_address;
        _httpComm.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [_httpComm sendCommandAndBlock_raw:[NSString stringWithFormat:@"set_resolution&mode=%@", modeVideo]];
        
        if (responseData != nil)
        {
            bodyKey = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"setVQ_bg response string: %@", bodyKey);
        }
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // remote
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
        
        NSDictionary *responseDict = [self.jsonComm sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                              andCommand:[NSString stringWithFormat:@"action=command&command=set_resolution&mode=%@", modeVideo]
                                                                               andApiKey:apiKey];
        NSLog(@"setVQ_bg %@", responseDict);
        
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
            else
            {
                NSLog(@"set resolution: status = %d", [[responseDict objectForKey:@"stats"] intValue]);
            }
        }
	}
    
    if (![bodyKey isEqualToString:@""])
    {
        NSArray * tokens = [bodyKey componentsSeparatedByString:@": "];
        if ([tokens count] >=2 )
        {
            NSString *resultCode = [tokens objectAtIndex:1];
            
            if ([resultCode isEqualToString:@"0"]) // whatever this is the result app receive after send command
            {
                [self performSelectorOnMainThread:@selector(setVQ_fg:)
                                       withObject:row waitUntilDone:NO];
            }
            else
            {
                NSLog(@"setVQ_bg failed! Contact fw team or server team");
            }
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
            {
                [self.activityIndicator stopAnimating];
                self.viewStopStreamingProgress.hidden = NO;
                [self.view bringSubviewToFront:self.viewStopStreamingProgress];
                
                userWantToCancel =TRUE;
                [self stopPeriodicPopup];
                
                
                /*
                 
                 If cancel is pressed while setup streamming, the setup will failed and  MEDIA_ERROR_SERVER_DIED
                 will be sent to handler. Provided that userWantToCancel = TRUE, handler will set
                    self.selectedChannel.stopStreaming = TRUE;
                    & Call  [self goBackToCameraList]   
                 
                 
                 if cancel is press when the player is about to play (stream started but not display (or maybe is displaying)) 
                 1) MEDIA_PLAYER_STARTED is not sent. Thus when it's sent, Handler will check for (userWantToCancel =TRUE) and do accordingly
                 2) MEDIA_PLAYER_STARTED is ALREADY sent But no first Image yet, i.e. MEDIA_INFO_HAS_FIRST_IMAGE is not sent
                          When MEDIA_INFO_HAS_FIRST_IMAGE is sent, the closing will be handled
                 3) MEDIA_INFO_HAS_FIRST_IMAGE is sent. This popup would already be dissmissed by then. 
                          But for some reasons, if user is able to press the Cancel during this time.
                 
                 
                 
                 Thus, no need to explicityly call  " self.selectedChannel.stopStreaming = TRUE & [self goBackToCameraList]" here.
                 
                 What needs to be done is to send a signal to interrupt the player.
                 
                 
                 */
                NSLog(@"[--- h264Streamer: %p]", h264Streamer);
                
                if (h264Streamer != NULL)
                {
                    h264Streamer->sendInterrupt();
                }
                else // if this happen, the activity rotates forever (by right: go back to camera list)
                {
                    NSArray * args = [NSArray arrayWithObjects:
                                      [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];
                    [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                           withObject:args
                                        waitUntilDone:NO];
                }
                
                
                break;
            }
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

#pragma mark - Zoom in&out
- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    //CGRect contentsFrame = self.imageViewVideo.frame;
    CGRect contentsFrame = _imageViewStreamer.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    //self.imageViewVideo.frame = contentsFrame;
    self.imageViewStreamer.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    //CGPoint pointInView = [recognizer locationInView:self.imageViewVideo];
    CGPoint pointInView = [recognizer locationInView:_imageViewStreamer];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale * ZOOM_SCALE;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / ZOOM_SCALE;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)resetZooming
{
    CGFloat newZoomScale = MINIMUM_ZOOMING_SCALE;
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    //return self.imageViewVideo;
    return _imageViewStreamer;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}


#pragma mark -
#pragma mark HorizMenu Data Source
- (UIImage *) selectedItemImageForMenu:(ScrollHorizontalMenu *) tabMenu withIndexItem:(NSInteger)index
{
    NSString *imageSelected = [self.itemSelectedImages objectAtIndex:index];
    return [UIImage imageNamed:imageSelected];
}
- (UIColor *) backgroundColorForMenu:(ScrollHorizontalMenu *)tabView
{
    return [UIColor clearColor];
}

- (int) numberOfItemsForMenu:(ScrollHorizontalMenu *)tabView
{
    return [self.itemImages count];
}

- (NSString *) horizMenu:(ScrollHorizontalMenu *)horizMenu nameImageForItemAtIndex:(NSUInteger)index
{
    return [self.itemImages objectAtIndex:index];
}
- (NSString *) horizMenu:(ScrollHorizontalMenu *)horizMenu nameImageSelectedForItemAtIndex:(NSUInteger)index
{
    return [self.itemSelectedImages objectAtIndex:index];
}
#pragma mark -
#pragma mark HorizMenu Delegate
-(void) horizMenu:(ScrollHorizontalMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    /*
     //new
     0. pan/tilt, 
     1. mic, 
     2. rec, 
     3. melody, 
     4. temp
     */
    
    //[self UpdateFullScreenTimer];
    
    
    if (index == INDEX_PAN_TILT) {
        //implement Pan, Tilt & zoom here
        _selectedItemMenu = INDEX_PAN_TILT;
        
    }
    else if (index == INDEX_MICRO)
    {
        // implement Microphone here
#if DISABLE_VIEW_RELEASE_FLAG
        return; // Disable for release test
#else
        _selectedItemMenu = INDEX_MICRO;
        [self recordingPressAction:nil];
#endif
    }
    else if (index == INDEX_RECORDING)
    {
        //implement take a photo/record video here

        _selectedItemMenu = INDEX_RECORDING;
#if DISABLE_VIEW_RELEASE_FLAG
        [self changeAction:_ib_buttonChangeAction];
#endif

    }
    else if (index == INDEX_MELODY)
    {
        _selectedItemMenu = INDEX_MELODY;
        [self melodyTouchAction:nil];
    }
    else if (index == INDEX_TEMP)
    {
#if DISABLE_VIEW_RELEASE_FLAG
        return; // Disable for release test
#else
        //implement display camera list here
        _selectedItemMenu = INDEX_TEMP;
#endif
    }
    else {
        NSLog(@"Action out of bound");
    }
    [self updateBottomView];
}

- (void)updateBottomView
{
    //first hidden all view
    [self hidenAllBottomView];
    
    if (_selectedItemMenu == INDEX_PAN_TILT)
    {
        [self.imgViewDrectionPad setHidden:NO];
        self.imageViewKnob.hidden = NO;
        self.imageViewKnob.center = _imgViewDrectionPad.center;
        self.imageViewHandle.center = _imgViewDrectionPad.center;
    }
    else if (_selectedItemMenu == INDEX_MICRO)
    {
        [self.ib_ViewTouchToTalk setHidden:NO];
    }
    else if (_selectedItemMenu == INDEX_RECORDING)
    {
        [self.ib_viewRecordTTT setHidden:NO];
    }
    else if (_selectedItemMenu == INDEX_MELODY)
    {
        [self.melodyViewController.view setHidden:NO];
    }
    else if (_selectedItemMenu == INDEX_TEMP)
    {
        [self.ib_temperature setHidden:NO];
        
        if (_existTimerTemperature == FALSE)
        {
            self.existTimerTemperature = TRUE;
            NSLog(@"Log - Create Timer to get Temperature");
            
            [NSTimer scheduledTimerWithTimeInterval:10
                                             target:self
                                           selector:@selector(getCameraTemperature_bg:)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
}

- (void)hidenAllBottomView
{
    [self.imgViewDrectionPad setHidden:YES];
    self.imageViewKnob.hidden = YES;
    self.imageViewHandle.hidden = YES;
    
    [self.ib_temperature setHidden:YES];
    [self.ib_temperature setBackgroundColor:[UIColor clearColor]];
    
    [self.ib_ViewTouchToTalk setHidden:YES];
    [self.ib_ViewTouchToTalk setBackgroundColor:[UIColor clearColor]];
    
    [self.ib_viewRecordTTT setHidden:YES];
    [self.ib_viewRecordTTT setBackgroundColor:[UIColor clearColor]];
    [self.melodyViewController.view setHidden:YES];
}

- (void)showAllBottomView
{
    [self.imgViewDrectionPad setHidden:NO];
    [self.ib_temperature setHidden:NO];
    [self.ib_ViewTouchToTalk setHidden:NO];
    [self.ib_viewRecordTTT setHidden:NO];
    [self.melodyViewController.view setHidden:NO];
    [self.scrollView setHidden:NO];
}

#pragma mark - Memory Release

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    //[self.client shutdown];


    [_imageViewVideo release];
   [_imageViewStreamer release];

    [_progressView release];

    [_segmentControl release];
    //[_tableViewPlaylist release];
    

    [_selectedChannel release];
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
    [_zoneViewController release];
    [_zoneButton release];
    [_probeTimer release];
    
    [_melodyButton release];
    [_scrollView release];
    [_ib_temperature release];
    [_ib_ViewTouchToTalk release];

    [_ib_labelTouchToTalk release];
    [_ib_viewRecordTTT release];
    [_ib_labelRecordVideo release];
    [_ib_buttonTouchToTalk release];
    [_ib_processRecordOrTakePicture release];
    [_ib_buttonChangeAction release];
    [_ib_showMenuControlPanel release];
    
    [_timelineVC release];
    [_earlierVC release];
    
    [_imageViewHandle release];
    [_imageViewKnob release];
    [super dealloc];
}
- (void)viewWillAppear:(BOOL)animated
{
    //init data for debug
    [self initFirstData];
    _isCameraOffline = NO;
    _isRecordInterface  = YES;
    _isProcessRecording = NO;
    _isListening = NO;
    [super viewWillAppear:animated];
    //[self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
    if (_timelineVC != nil)
    {
        self.timelineVC.camChannel = self.selectedChannel;
    }
    
    [self checkOrientation];
    [self setupPtt];
    
}

- (void)initFirstData
{
    _viewVideoIn = nil;
    fps = 0;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
    for (id view in self.navigationController.view.subviews)
    {
        if ([view isKindOfClass:[UIBarButtonItem class]])
        {
            [view removeFromSuperview];
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setImageViewVideo:nil];
//    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    [self setCameraNameBarBtnItem:nil];
    [self setSegCtrl:nil];
    //[self setTableViewPlaylist:nil];
    

    [self setSelectedChannel:nil];
    [self setPlaylistArray:nil];
    [self setHttpComm:nil];
    
    [super viewDidUnload];
}
#pragma  mark -
#pragma mark PTT

- (void)cleanup
{
    
    [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                           withObject:@"0"];
    
    [_audioOut release];
    _audioOut = nil;
    
//    UIButton *pttBtn = (UIButton *)[self.view viewWithTag:PTT_ENGAGE_BTN];
//    
//    [self.ib_buttonTouchToTalk setImage:[UIImage imageNamed:@"bb_vs_mike_on.png"] forState:UIControlStateNormal];
    
    self.walkieTalkieEnabled = NO;
    
}

-(void) setupPtt
{
    
	UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPress:)];
	longPress.minimumPressDuration = 1.0;
	[self.ib_buttonTouchToTalk addGestureRecognizer:longPress];
	[longPress release];
    
    [self.ib_buttonTouchToTalk addTarget:self action:@selector(holdToTalk:) forControlEvents:UIControlEventTouchDown];
    [self.ib_buttonTouchToTalk addTarget:self action:@selector(userReleaseHoldToTalk) forControlEvents:UIControlEventTouchUpInside];
    [self.ib_buttonTouchToTalk addTarget:self action:@selector(userReleaseHoldToTalk) forControlEvents:UIControlEventTouchUpOutside];
    
}

-(void)userReleaseHoldToTalk
{

    NSLog(@"Detect user cancel PTT & clean up");
    if (_audioOut != nil)
    {
        [_audioOut disconnectFromAudioSocket];
        [_audioOut release];
        _audioOut = nil;
    }
}


- (BOOL) setEnablePtt:(BOOL) walkie_talkie_enabled
{
    
    
    @synchronized (self)
    {
        if ( walkie_talkie_enabled == YES)
        {
            
            [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                                   withObject:[NSString stringWithFormat:@"%d",walkie_talkie_enabled]];
            if (_audioOut != nil)
            {
                NSLog(@"Connect to Audio Soccket in setEnablePtt function");
                [_audioOut connectToAudioSocket];
                _audioOut.audioOutStreamerDelegate = self;
            }
            else
            {
                NSLog(@" NEED to enable audioOut now BUT audioOut = nil!!!");
            }
        }
        else
        {
            if (_audioOut != nil)
            {
                NSLog(@"disconnect to audio socket###");
                [_audioOut disconnectFromAudioSocket];
                [self touchUpInsideHoldToTalk];
            }
            
        }
    }
    return walkie_talkie_enabled ;
    
}


- (void) set_Walkie_Talkie_bg: (NSString *) status
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSString * command = [NSString stringWithFormat:@"%@%@",SET_PTT,status];
    
    NSLog(@"Command send to camera is %@", command);
    
    //set port default for send command
    
    _httpComm.device_port = 80;

    if(_httpComm != nil)
    {
        [_httpComm sendCommandAndBlock:command];
    }
    
    [pool release];
}

-(void)processingHoldToTalk
{
    NSLog(@"Create AudioOutStreamer & start recording now");
    NSLog(@"Port push to talk is %d, actually is %d",self.selectedChannel.profile.ptt_port,IRABOT_AUDIO_RECORDING_PORT );
    NSLog(@"Device iP is %@", _httpComm.device_ip);
    _audioOut = [[AudioOutStreamer alloc] initWithDeviceIp:_httpComm.device_ip
                                               andPTTport:self.selectedChannel.profile.ptt_port];  //IRABOT_AUDIO_RECORDING_PORT
    [_audioOut retain];
    //Start buffering sound from user at the moment they press down the button
    //  This is to prevent loss of audio data
    [_audioOut startRecordingSound];
}




-(void) longPress:(UILongPressGestureRecognizer*) gest
{
    NSLog(@"Long press on hold to talk");
    if ([gest state] == UIGestureRecognizerStateBegan)
    {
        NSLog(@"UIGestureRecognizerStateBegan on hold to talk");
        self.walkieTalkieEnabled = YES;
        [self setEnablePtt:YES];
        UIImage *imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed.png"];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchDown];
        
    }
    else if ([gest state] == UIGestureRecognizerStateEnded ||
             [gest state] == UIGestureRecognizerStateCancelled)
    {
        NSLog(@"UIGestureRecognizerStateEnded on hold to talk");
        if ([gest state] == UIGestureRecognizerStateCancelled)
        {
            NSLog(@"detect cancelling PTT");
            
        }
        
        [self setEnablePtt:NO];
    }
    
    
}

- (void)holdToTalk:(id)sender {
    //first update UI
    UIImage *imageHoldToTalk = [UIImage imageNamed:@"camera_action_mic.png"];
    UIImage *imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed.png"];
    [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldToTalk forState:UIControlStateNormal];
    [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchDown];
    [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldToTalk forState:UIControlEventTouchUpInside];
    [self.ib_labelTouchToTalk setText:@"Listening"];
    
    //processing for PTT
    [self processingHoldToTalk];
}

- (void)touchUpInsideHoldToTalk {
    //update UI
    UIImage *imageHoldToTalk = [UIImage imageNamed:@"camera_action_mic.png"];
    [self.ib_buttonTouchToTalk setBackgroundColor:[UIColor clearColor]];
    [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldToTalk forState:UIControlStateNormal];
    [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldToTalk forState:UIControlEventTouchUpInside];
    [self.ib_labelTouchToTalk setText:@"Hold To Talk"];
    //user touch up inside and outside

}

- (IBAction)bt_showMenuControlPanel:(id)sender {
//    isShowControlPanel = YES;
    [self tryToHideMenuControlPanel];
}

- (IBAction)processingRecordingOrTakePicture:(id)sender {
    UIImage *readyRecord = [UIImage imageNamed:@"camera_action_video.png"];
    UIImage *readyRecordPressed = [UIImage imageNamed:@"camera_action_video_pressed.png"];
    UIImage *recordingImage = [UIImage imageNamed:@"camera_action_video_stop.png"];
    UIImage *recordingPressed = [UIImage imageNamed:@"camera_action_video_stop_pressed.png"];
    
    UIImage *takePictureImage = [UIImage imageNamed:@"camera_action_photo.png"];
    UIImage *takePicturePressed = [UIImage imageNamed:@"camera_action_photo_pressed.png"];
    
    NSLog(@"_isRecordInterface is %d", _isRecordInterface);
    if (_isRecordInterface)
    {
        _isProcessRecording = !_isProcessRecording;
        NSLog(@"_isProcessRecording is %d", _isProcessRecording);
        if (_isProcessRecording)
        {
            //now is interface recording
            [self.ib_labelRecordVideo setText:@"00:00:00"];
            [self.ib_processRecordOrTakePicture setBackgroundImage:recordingImage forState:UIControlStateNormal];
            [self.ib_processRecordOrTakePicture setBackgroundImage:recordingPressed forState:UIControlEventTouchDown];
            [self.ib_processRecordOrTakePicture setBackgroundImage:recordingImage forState:UIControlEventTouchUpInside];
            //process for recording

        }
        else
        {
            //here to pause
            [self.ib_processRecordOrTakePicture setBackgroundImage:readyRecord forState:UIControlStateNormal];
            [self.ib_processRecordOrTakePicture setBackgroundImage:readyRecordPressed forState:UIControlEventTouchDown];
            [self.ib_processRecordOrTakePicture setBackgroundImage:readyRecord forState:UIControlEventTouchUpInside];
            [self.ib_labelRecordVideo setText:@"Record Video"];
            //process for stop record

        }
    }
    else
    {
        //now is for take pictures
        [self.ib_labelRecordVideo setText:@"Take Picture"];
        [self.ib_processRecordOrTakePicture setBackgroundImage:takePictureImage forState:UIControlStateNormal];
        [self.ib_processRecordOrTakePicture setBackgroundImage:takePictureImage forState:UIControlEventTouchUpInside];
        [self.ib_processRecordOrTakePicture setBackgroundImage:takePicturePressed forState:UIControlEventTouchDown];
        
        //processing for take picture
        [self processingForTakePicture];
    }

}

- (IBAction)changeAction:(id)sender {
    //Image for change action
    UIImage *recordImage = [UIImage imageNamed:@"camera_action_video_s.png"];
    UIImage *takePictureImage = [UIImage imageNamed:@"camera_action_pic_s.png"];
    
    //Image change for processing button
    UIImage *recordActionImage = [UIImage imageNamed:@"camera_action_video.png"];
    UIImage *recordActionImagePressed = [UIImage imageNamed:@"camera_action_video_pressed.png"];
    
    UIImage *takePicture = [UIImage imageNamed:@"camera_action_photo.png"];
    UIImage *takePicturePressed = [UIImage imageNamed:@"camera_action_photo_pressed.png"];
    
#if DISABLE_VIEW_RELEASE_FLAG
    _isRecordInterface = FALSE;
#else
    _isRecordInterface = !_isRecordInterface;
#endif
    
    if (_isRecordInterface)
    {
        [self.ib_processRecordOrTakePicture setBackgroundImage:recordActionImage forState:UIControlStateNormal];
         [self.ib_processRecordOrTakePicture setBackgroundImage:recordActionImagePressed forState:UIControlEventTouchDown];
        [self.ib_processRecordOrTakePicture setBackgroundImage:recordActionImage forState:UIControlEventTouchUpInside];
        [self.ib_buttonChangeAction setBackgroundImage:takePictureImage forState:UIControlStateNormal];
        [self.ib_labelRecordVideo setText:@"Record Video"];
    }
    else
    {
        _isProcessRecording = NO;
        [self.ib_processRecordOrTakePicture setBackgroundImage:takePicture forState:UIControlStateNormal];
        [self.ib_processRecordOrTakePicture setBackgroundImage:takePicturePressed forState:UIControlEventTouchDown];
        [self.ib_processRecordOrTakePicture setBackgroundImage:takePicture forState:UIControlEventTouchUpInside];
        [self.ib_buttonChangeAction setBackgroundImage:recordImage forState:UIControlStateNormal];
        [self.ib_labelRecordVideo setText:@"Take Picture"];
    }
#if DISABLE_VIEW_RELEASE_FLAG
    ((UIButton *)sender).enabled = NO;
#endif
}

#pragma mark -
#pragma mark SnapShot
- (void)processingForTakePicture
{
    //[self saveSnapShot:self.imageViewVideo.image];
    [self saveSnapShot:_imageViewStreamer.image];
}


- (void) saveSnapShot:(UIImage *) image
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
	if (!error)
	{
		title = @"Snapshot";
		message = @"Saved to Photo Album";
        
	}
	else
	{
		title = @"Error";
		message = [error description];
		NSLog(@"Error when writing file to image library: %@", [error localizedDescription]);
		NSLog(@"Error code %d", [error code]);
        
	}
	UIAlertView *_alertInfo = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
	[_alertInfo show];
	[_alertInfo release];
    
}

#pragma mark -
#pragma mark Hide & Show subfunction


- (void) tryToHideMenuControlPanel
{
    
    [self.ib_showMenuControlPanel setHidden:NO];
    [self.horizMenu setHidden:NO];
    [self UpdateFullScreenTimer];

    
}

- (void) UpdateFullScreenTimer
{
    if (fullScreenTimer != nil)
	{
		//invalidate the timer ..
        if ([fullScreenTimer isValid])
        {
            [fullScreenTimer invalidate];
        }
		fullScreenTimer = nil;
	}
	fullScreenTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                       target:self
                                                     selector:@selector(hideMenuControlPanelNow:)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void) hideMenuControlPanelNow: (NSTimer*) exp
{
    fullScreenTimer = nil;
    [self.horizMenu setHidden:YES];
    [self.ib_showMenuControlPanel setHidden:NO];
}

- (void) showMenuControlPanel
{
    [self.horizMenu setHidden:NO];
    [self.view addSubview:_horizMenu];
    [self.view bringSubviewToFront:_horizMenu];
}


//
- (void)addingLabelInfosForDebug
{
    if (_viewVideoIn == nil)
    {
        return;
    }
    //remove all subviews
    NSArray *viewsToRemove = [self.imageViewStreamer subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    //Infos debug
    UILabel *infosLabel;
    UIImage *bg_image = [UIImage imageNamed:@"temp_bg.png"];
    NSInteger widthImage = bg_image.size.width;
    
    infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageViewStreamer.frame.size.width - widthImage ,20, widthImage, bg_image.size.height)];
    
    UIColor *bg_Color = [UIColor colorWithPatternImage:bg_image];
    [infosLabel setBackgroundColor:bg_Color];
    NSString *fpsView = [NSString stringWithFormat:@"%@ %d", _viewVideoIn, fps];
    infosLabel.textAlignment = NSTextAlignmentCenter;
    infosLabel.text = fpsView;
    infosLabel.textColor = [UIColor whiteColor];
    
    //Add label to view
    [self.imageViewStreamer addSubview:infosLabel];
    [self.imageViewStreamer bringSubviewToFront:infosLabel];
    [infosLabel release];
    infosLabel = nil;
}
@end
