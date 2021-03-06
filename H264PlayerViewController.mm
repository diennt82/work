//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "H264PlayerViewController.h"


#import <CoreText/CTStringAttributes.h>
#import "define.h"
#import <CFNetwork/CFNetwork.h>
#include <ifaddrs.h>

#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/message.h>

#define TEMP_NULL @"NIL"

@implementation H264PlayerViewController

@synthesize  alertTimer;
@synthesize   client = _client;
@synthesize horizMenu = _horizMenu;
@synthesize itemImages = _itemImages;
@synthesize itemSelectedImages = _itemSelectedImages;
@synthesize selectedItemMenu = _selectedItemMenu;

double _ticks = 0;


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
    
    _hideCustomIndicatorAndTextNotAccessble = NO;
    // update navi
    self.earlierNavi = (EarlierNavigationController *)self.navigationController;
    self.earlierNavi.isEarlierView = NO;
    _selectedItemMenu = INDEX_NO_SELECT;
    [self.ib_buttonChangeAction setHidden:NO];
    [self.view bringSubviewToFront:self.ib_buttonChangeAction];
    [self.ib_labelRecordVideo setText:NSLocalizedStringWithDefaultValue(@"record_video", nil, [NSBundle mainBundle], @"Record Video", nil)];
    [self.ib_labelTouchToTalk setText:NSLocalizedStringWithDefaultValue(@"touch_to_talk", nil, [NSBundle mainBundle], @"Touch to Talk", nil)];
    //setup Font
    [self applyFont];
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    CFRelease(soundFileURLRef);
    
    [self updateNavigationBarAndToolBar];
    [self addHubbleLogo_Back];
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:_imageViewVideo.frame];
    self.imageViewStreamer = imv;
    [imv release];
    //[self.imageViewStreamer setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageViewStreamer setBackgroundColor:[UIColor blackColor]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapGestureCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageViewStreamer addGestureRecognizer:singleTap];
    [singleTap release];
#if 1
    self.tapGestureTemperature = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeDegreeTemperatureType:)];
    self.tapGestureTemperature.numberOfTapsRequired = 1;
    self.tapGestureTemperature.numberOfTouchesRequired = 1;
#endif
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    self.imageViewStreamer.userInteractionEnabled = NO;
    self.sharedCamConnectedTo = @"";
    
    self.cameraModel = [self.selectedChannel.profile getModel];
    /*
     * Move dow SetupCamera temporarily. Need to update here!
     */
    
    //[self initHorizeMenu: _cameraModel];
    [self performSelectorInBackground:@selector(initHorizeMenu:) withObject:_cameraModel];
    
    //set text name for camera name
    [self.ib_lbCameraName setText:self.selectedChannel.profile.name];
    
    _isDegreeFDisplay = [[userDefaults objectForKey:IS_FAHRENHEIT] boolValue];
    _resolution = @"";
    
    NSString *serverInput = [userDefaults stringForKey:@"name_server1"];
    
    if([userDefaults boolForKey:@"DebugOpt"] == YES)
    {
        if ([serverInput isEqualToString:@""])
        {
            serverInput = [userDefaults stringForKey:@"name_server"];
        }
    }
    else
    {
        serverInput = [userDefaults stringForKey:@"name_server"];
    }
    
    serverInput = [serverInput substringToIndex:serverInput.length - 3];
    self.talkbackRemoteServer = [serverInput stringByReplacingOccurrencesOfString:@"api" withString:@"talkback"];
    self.talkbackRemoteServer = [_talkbackRemoteServer stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
#if 0
    self.remoteViewTimeout = [userDefaults boolForKey:@"remote_view_timeout"];
#endif
    self.disconnectAlert   = [userDefaults boolForKey:@"disconnect_alert"];

    if([userDefaults boolForKey:@"DebugOpt"] == YES)
    {
        self.btnSendingLog.enabled = YES;
        self.ib_btShowDebugInfo.enabled = YES;
    }
    
    self.enablePTT = YES;
    self.currentBitRate = @"128";
    self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
    self.timeStartingStageTwo = 0;
    
    
    self.customIndicator.image = [UIImage imageNamed:@"loader_a"];
    self.customIndicator.hidden = YES;
    
    NSLog(@"camera model is :%@", self.cameraModel);
    self.backgroundTask = UIBackgroundTaskInvalid;
    self.askForFWUpgradeOnce = YES;
    [self becomeActive];
    
    self.helpPopup = nil;
}

//At first time, we set to FALSE after call checkOrientation()
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _syncPortraitAndLandscape = NO;
    
    UITapGestureRecognizer *tapGestureTemperature = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(changeDegreeTemperatureType:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView view will appear - return from Playback: %d", _returnFromPlayback] withProperties:nil];
    NSLog(@"%s -_wantToShowTimeLine: %d, userWantToCancel: %d, returnFromPlayback: %d", __FUNCTION__, _wantToShowTimeLine, userWantToCancel, _returnFromPlayback);
    
    self.trackedViewName = GAI_CATEGORY;
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewWillAppear"
                                                     withLabel:nil
                                                     withValue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleInactivePushes)
                                                 name: PUSH_NOTIFY_BROADCAST_WHILE_APP_INACTIVE
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleActivePushes)
                                                 name: PUSH_NOTIFY_BROADCAST_WHILE_APP_INVIEW
                                               object: nil];
    
    

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleDidEnterBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleWillEnterForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
   

    
    
    //alway show custom indicator, when view appear
    _isShowCustomIndicator = YES;
    self.currentMediaStatus = 0;
    self.shouldUpdateHorizeMenu = YES;
    self.wantToShowTimeLine = YES;
    _viewVideoIn = @"R";
    
    if (_returnFromPlayback == FALSE)
    {
        _isFirstLoad = YES;
        _isRecordInterface  = YES;
        _isProcessRecording = NO;
        _isListening = NO;
        _ticks = 0.0;
        
        if (_timelineVC != nil)
        {
            self.timelineVC.camChannel = self.selectedChannel;
        }
        
        [self checkOrientation];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.returnFromPlayback = FALSE;
        
        //[self scanCamera];
        
        [self performSelectorOnMainThread:@selector(scanCamera)
                               withObject:nil
                            waitUntilDone:NO];
        self.h264StreamerIsInStopped = FALSE;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_selectedChannel.profile.mac_address forKey:CAM_IN_VEW];
        [userDefaults synchronize];
    }  
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s ********************************************************************************", __FUNCTION__);
    
    [self stopTimerRecoring];
    
    if (_timerCheckMelodyState) {
        [_timerCheckMelodyState invalidate];
        self.timerCheckMelodyState = nil;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    [super viewWillDisappear:animated];
}

- (void)applyFont
{
    if (_isLandScapeMode)
    {
        //update position text recording
        // update position button
        //Touch to Talk (size = 75, bottom align = 30
#if 0
        CGSize holdTTButtonSize = self.ib_buttonTouchToTalk.bounds.size;
        CGSize viewRecordSize   = self.ib_viewRecordTTT.bounds.size;
        CGSize directionPadSize = self.imgViewDrectionPad.bounds.size;
        
        float alignXButtonRecord        = SCREEN_HEIGHT - 15 - self.ib_viewRecordTTT.bounds.size.width;
        float alignXButtonDirectionPad  = SCREEN_HEIGHT - directionPadSize.width - 10;
        float alignYButtonRecord        = SCREEN_WIDTH - viewRecordSize.height;
        float alignYButtonDirectionPad  = (SCREEN_WIDTH - 10 - directionPadSize.height);
        //margin TTT
        float alignXTTT = SCREEN_HEIGHT - 30 - holdTTButtonSize.width;
        float alignYTTT = SCREEN_WIDTH - 30 - holdTTButtonSize.height;
        
        
        if (isiPhone4 || isiPhone5)
        {
            //alignYTTT = alignYTTT;
            //alignYButtonRecord = alignYButtonRecord;
            //alignYButtonDirectionPad = alignYButtonDirectionPad;
        }
        else
        {
            alignYTTT -= 94;
            alignYButtonRecord -= 94;
            alignYButtonDirectionPad -= 94;
        }
        
        [self.ib_ViewTouchToTalk setFrame:CGRectMake(alignXTTT, alignYTTT, holdTTButtonSize.width, holdTTButtonSize.height)];
        
        [self.ib_viewRecordTTT setFrame:CGRectMake(alignXButtonRecord, alignYButtonRecord, viewRecordSize.width, viewRecordSize.height)];
        [_imgViewDrectionPad setFrame:CGRectMake(alignXButtonDirectionPad, alignYButtonDirectionPad, directionPadSize.width, directionPadSize.height)];
#endif
        [self.ib_labelTouchToTalk setTextColor:[UIColor holdToTalkTextColor]];
    }
    else
    {
        //UIFont *font;
        //UIColor *color;
        float marginBottomText, marginBottomButton, positionYOfBottomView;
        
        CGFloat fontSize = 19;
        
        if (isiPhone5)
        {
            //for holdtotalk
            //font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:19];
            fontSize = 19;
            //color = [UIColor holdToTalkTextColor];
            marginBottomText = 42;
            marginBottomButton = 81;
            positionYOfBottomView = 255;
            
        }
        else if (isiPhone4)
        {
            //for holdtotalk
            //font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
            fontSize = 17;
            //color = [UIColor holdToTalkTextColor];
            marginBottomText = 25.0f;
            marginBottomButton = 48.0f;
            positionYOfBottomView = self.ib_viewRecordTTT.frame.origin.y;
        }
        else
        {
            //iPad
            //for holdtotalk
            //font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:50];
            fontSize = 50;
            //color = [UIColor holdToTalkTextColor];
            marginBottomText = 42.0f * 2;
            marginBottomButton = 81.0f * 2;
            positionYOfBottomView = 543.0f;
        }
        
        UIFont *font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:fontSize];
        //color = [UIColor holdToTalkTextColor];
        
        [self.ib_labelTouchToTalk setFont:font];
        //self.ib_labelTouchToTalk.textColor = color;
        self.ib_labelTouchToTalk.textColor = [UIColor holdToTalkTextColor];
        //for recordingText
        [self.ib_labelRecordVideo setFont:font];
        
        if (_isRecordInterface && _isProcessRecording)
        {
            self.ib_labelRecordVideo.textColor = [UIColor recordingTextColor];
        }
        else
        {
            self.ib_labelRecordVideo.textColor = [UIColor holdToTalkTextColor];
        }
        
        //update position text recording
        CGPoint localPoint = self.ib_viewRecordTTT.frame.origin;
        NSString *recordingString = self.ib_labelRecordVideo.text;
        CGSize recordingSize = [recordingString sizeWithAttributes:@{NSFontAttributeName: font}];
        
        float alignY = (SCREEN_HEIGHT - localPoint.y) - marginBottomText + self.ib_labelRecordVideo.bounds.size.height/2 - 3*recordingSize.height/2;
        
        
        //update position text Touch to Talk
        //CGPoint position = self.ib_viewRecordTTT.bounds.origin;
        NSString *holdTTString = self.ib_labelTouchToTalk.text;
        CGSize holdTTSize = [holdTTString sizeWithAttributes:@{NSFontAttributeName:font}];
        CGSize labelTouchToTalkSize = self.ib_labelTouchToTalk.bounds.size;
        
        //    float deltaY1 = (labelTouchToTalkSize.height + holdTTSize.height)/2.0;
        float alignY1 = (SCREEN_HEIGHT - localPoint.y) - marginBottomText + labelTouchToTalkSize.height/2 - 3*holdTTSize.height/2;
#if 1
        [self.ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY)];
        [self.ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1)];
#else
        if (isiOS7AndAbove)
        {
            [self.ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY)];
            [self.ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1)];
        }
        else
        {
            [self.ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY - 64)];
            [self.ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1 - 64)];
        }
#endif
        
        // update position button
        //Touch to Talk
        CGSize holdTTButtonSize = self.ib_buttonTouchToTalk.bounds.size;
        CGSize directionPadSize = self.imgViewDrectionPad.bounds.size;
        float alignXButton = SCREEN_WIDTH/2- holdTTButtonSize.width/2;
        float alignXButtonDirectionPad = SCREEN_WIDTH/2- directionPadSize.width/2;
        float alignYButton = SCREEN_HEIGHT - localPoint.y - marginBottomButton - holdTTButtonSize.height;
        float alignYButtonDirectionPad = (SCREEN_HEIGHT - localPoint.y - directionPadSize.height)/2;
#if 0
        if (!isiOS7AndAbove)
        {
            alignYButton = alignYButton - 64;
            alignYButtonDirectionPad = alignYButtonDirectionPad - 44 - 64;
        }
#endif
        
        [self.ib_buttonTouchToTalk setFrame:CGRectMake(alignXButton, alignYButton, holdTTButtonSize.width, holdTTButtonSize.height)];
        [self.ib_processRecordOrTakePicture setFrame:CGRectMake(alignXButton, alignYButton, holdTTButtonSize.width, holdTTButtonSize.height)];
        [_imgViewDrectionPad setFrame:CGRectMake(alignXButtonDirectionPad, alignYButtonDirectionPad + localPoint.y, directionPadSize.width, directionPadSize.height)];
    }
}

- (void) setupHttpPort
{
    NSLog(@"Self.selcetedChangel is %@", self.selectedChannel);
    
    [HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
    [HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
    
    //init the ptt port to default
    self.selectedChannel.profile.ptt_port = IRABOT_AUDIO_RECORDING_PORT;
}

- (void)addGesturesPichInAndOut
{
    [self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
    //[self.imageViewStreamer setUserInteractionEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    //set background for scrollView
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    //processing for pinch gestures
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = MAXIMUM_ZOOMING_SCALE;
    self.scrollView.minimumZoomScale = MINIMUM_ZOOMING_SCALE;
    [self centerScrollViewContents];
    //[self resetZooming];
    
    
    
    //Add action for touch
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.imageViewStreamer addGestureRecognizer:doubleTapRecognizer];
    [doubleTapRecognizer release];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.imageViewStreamer addGestureRecognizer:twoFingerTapRecognizer];
    [twoFingerTapRecognizer release];
}

/**
 remove gestures touch when at portrait
 */
- (void)removeGestureRecognizerAtPortraitMode
{
    for(UITapGestureRecognizer *gesture in [self.imageViewStreamer gestureRecognizers])
    {
        if([gesture isKindOfClass:[UITapGestureRecognizer class]])
        {
            if (gesture.numberOfTapsRequired == 2 || gesture.numberOfTouchesRequired == 2)
            {
                [self.imageViewStreamer removeGestureRecognizer:gesture];
            }
        }
    }
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

-(void)addHubbleLogo_Back
{
    UIImage *image = [UIImage imageNamed:@"Hubble_back_text"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    //[button setBackgroundImage:image forState:UIControlStateHighlighted];
    //[button setBackgroundImage:image forState:UIControlStateSelected];
    //[button setBackgroundImage:image forState:UIControlStateDisabled];
    
    //[button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(prepareGoBackToCameraList:) forControlEvents:UIControlEventTouchUpInside];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button release];
    
    //then set it.  phew.
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    [barButtonItem release];
}

- (void) updateNavigationBarAndToolBar
{
    if (![self.selectedChannel.profile isSharedCam]) // SharedCam
    {
        nowButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"now", nil, [NSBundle mainBundle], @"Now", nil)
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(nowButtonAciton:)];
        [nowButton setTitleTextAttributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:PN_SEMIBOLD_FONT size:17.0],
                                            NSForegroundColorAttributeName:[UIColor barItemSelectedColor]
                                            } forState:UIControlStateNormal];
        
        earlierButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"earlier", nil, [NSBundle mainBundle], @"Earlier", nil)
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(earlierButtonAction:)];
        [earlierButton setTitleTextAttributes:@{
                                                NSFontAttributeName:[UIFont fontWithName:PN_LIGHT_FONT size:17.0],
                                                NSForegroundColorAttributeName:[UIColor barItemSelectedColor]
                                                } forState:UIControlStateNormal];
        nowButton.enabled = NO;
        self.navigationItem.rightBarButtonItems = @[earlierButton, nowButton];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CamProfile *cp = self.selectedChannel.profile;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [self setTitle:cp.name];
            [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        }
        else
        {
            [self.navigationItem setTitle:cp.name];
        }
    }
}

- (void)nowButtonAciton:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Touch up inside NOW btn item" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"nowButtonAciton"
                                                     withLabel:@"Now"
                                                     withValue:nil];
    
    _hideCustomIndicatorAndTextNotAccessble = NO;
    
    [nowButton setEnabled:NO];
    [earlierButton setEnabled:YES];
    
    [nowButton setTitleTextAttributes:@{
                                        NSFontAttributeName: [UIFont fontWithName:PN_SEMIBOLD_FONT size:17.0],
                                        NSForegroundColorAttributeName: [UIColor barItemSelectedColor]
                                        } forState:UIControlStateNormal];
    [earlierButton setTitleTextAttributes:@{
                                            NSFontAttributeName: [UIFont fontWithName:PN_LIGHT_FONT size:17.0],
                                            NSForegroundColorAttributeName: [UIColor barItemSelectedColor]
                                            } forState:UIControlStateNormal];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:EVENT_DELETED_ID] != -1)
    {
        // At least a event has been deleted.
        NSLog(@"%s At least a event has been deleted.", __FUNCTION__);
        
        // Reset state.
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:EVENT_DELETED_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Reload events.
        [self.timelineVC loadEvents:self.selectedChannel];
    }
    
    self.earlierNavi.isEarlierView = NO;
    
    if (_wantToShowTimeLine)
    {
        [self showTimelineView];
        _wantToShowTimeLine = NO;
    }
    
    _earlierVC.view.hidden = YES;
    
    [self displayCustomIndicator];
}

- (void)earlierButtonAction:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Touch up inside EARLIER btn item" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"earlierButtonAction"
                                                     withLabel:@"Earlier"
                                                     withValue:nil];
    
    _hideCustomIndicatorAndTextNotAccessble = YES;
    
    [earlierButton setEnabled:NO];
    [nowButton setEnabled:YES];
    
    [nowButton setTitleTextAttributes:@{
                                        NSFontAttributeName: [UIFont fontWithName:PN_LIGHT_FONT size:17.0],
                                        NSForegroundColorAttributeName: [UIColor barItemSelectedColor]
                                        } forState:UIControlStateNormal];
    [earlierButton setTitleTextAttributes:@{
                                            NSFontAttributeName: [UIFont fontWithName:PN_SEMIBOLD_FONT size:17.0],
                                            NSForegroundColorAttributeName: [UIColor barItemSelectedColor]
                                            } forState:UIControlStateNormal];
    
    [self.customIndicator setHidden:YES];
    self.earlierNavi.isEarlierView = YES;
    
    if (_earlierVC == nil)
    {
        EarlierViewController *vc = [[EarlierViewController alloc] initWithParentVC:self camChannel:self.selectedChannel];
        self.earlierVC = vc;
        [vc release];
        self.earlierVC.nav = self.navigationController;
        _earlierVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:EVENT_DELETED_ID] != -1)
        {
            // At least a event has been deleted.
            NSLog(@"%s At least a event has been deleted.", __FUNCTION__);
            
            // Reset state.
            [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:EVENT_DELETED_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Reload events.
            [_earlierVC reloadEvents];
        }
    }
    
    [self.view addSubview:_earlierVC.view];
    
    _earlierVC.view.hidden = NO;
    [self.view bringSubviewToFront:_earlierVC.view];
    [_earlierVC setCamChannel:self.selectedChannel];
    
    [self stopTalkbackUnexpected];
}

#pragma mark - Action

- (IBAction)iFrameOnlyPressAction:(id)sender
{
    if (MediaPlayer::Instance()->isPlaying())
    {
        self.iFrameOnlyFlag = ! self.iFrameOnlyFlag;
        
        if(self.iFrameOnlyFlag == TRUE)
        {
            MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_IFRAME_ONLY);
        }
        else
        {
            MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_ALL_FRAME);
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

- (IBAction)melodyTouchAction:(id)sender
{
    if (self.melodyViewController != nil)
    {
        [self.view addSubview:self.melodyViewController.view];
        [self.view bringSubviewToFront:self.melodyViewController.view];
    }
}

- (IBAction)btnSendingLogTouchUpInside:(id)sender
{
    UIAlertView *alertViewSendingLog = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_request_camera_log", nil, [NSBundle mainBundle], @"Request Camera log?", nil)
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"NO"
                                                        otherButtonTitles:NSLocalizedStringWithDefaultValue(@"yes", nil, [NSBundle mainBundle], @"YES", nil), nil];
    alertViewSendingLog.tag = TAG_ALERT_SENDING_LOG;
    alertViewSendingLog.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertViewSendingLog textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alertViewSendingLog textFieldAtIndex:0].placeholder = NSLocalizedStringWithDefaultValue(@"password", nil, [NSBundle mainBundle], @"Password", nil);
    [alertViewSendingLog show];
    [alertViewSendingLog release];
}

- (IBAction)handleOpenHelpButton:(id)sender
{
    NSMutableString *html = [[NSMutableString alloc] init];
    [html appendString:@"<html>"];
    [html appendString:@"   <header>"];
    [html appendString:@"       <style>"];
    [html appendString:@"           ul.first_deep {padding-left:10px}"];
    [html appendString:@"           ul.first_deep li {list-style-type:square;}"];
    [html appendString:@"           ul.second_deep {padding-left:10px}"];
    [html appendString:@"           ul.second_deep li {list-style-type:circle;}"];
    [html appendString:@"       </style>"];
    [html appendString:@"   </header>"];
    [html appendString:@"   <body>"];
    [html appendString:@"       <div style='margin-left:5px;'>"];
    [html appendString:@"       <ul class=\"first_deep\">"];
    [html appendString:@"           <li>#h1#</li>"];
    [html appendString:@"           <li>#h2#"];
    [html appendString:@"               <ul class=\"second_deep\">"];
    [html appendString:@"                   <li>#h2c1#</li>"];
    [html appendString:@"                   <li>#h2c2#</li>"];
    [html appendString:@"                   <li>#h2c3#</li>"];
    [html appendString:@"                   <li>#h2c4#</li>"];
    [html appendString:@"                   <li>#h2c5#</li>"];
    [html appendString:@"                   <li>#h2c6#</li>"];
    [html appendString:@"               </ul>"];
    [html appendString:@"           </li>"];
    [html appendString:@"           <br/>"];
    [html appendString:@"           <li>#h3#</li>"];
    [html appendString:@"           <li>#h4#</li>"];
    [html appendString:@"       </ul>"];
    [html appendString:@"       </div>"];
    [html appendString:@"   </body>"];
    [html appendString:@"</html>"];
    
    [html replaceOccurrencesOfString:@"#h1#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_Q__why_can’t_access_my_camera", nil, [NSBundle mainBundle], @"Q. Why can’t I access my camera? Why do I keep seeing the warning message \"Low bandwidth detected\"?", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_following_reasons", nil, [NSBundle mainBundle], @"A. This could be due to one of the following reasons:", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2c1#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_network_is_too_low", nil, [NSBundle mainBundle], @"The upload bandwidth of your broadband network is too low", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2c2#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_the_minimum_upload_bandwidth", nil, [NSBundle mainBundle], @"The minimum upload bandwidth required is about 600kbps", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2c3#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_online_bandwidth_speed_test_tool", nil, [NSBundle mainBundle], @"Please check your upload bandwidth with your Internet Service Provider or use an online bandwidth speed test tool, such as <a href=\"http://www.speedtest.net\">http://www.speedtest.net</a>", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2c4#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_camera_may_be_too_far", nil, [NSBundle mainBundle], @"Your camera may be too far away from your router. Please try reducing the distance between the router and camera", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2c5#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_using_a_mobile_network_3G", nil, [NSBundle mainBundle], @"If you are using a mobile network (3G), the bandwidth may be limited", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h2c6#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_closing_any_unnecessary_applications", nil, [NSBundle mainBundle], @"If you are running other applications (eg. games), they could be consuming a lot of bandwidth. This can impact on the performance of the Hubble app. Please try closing any unnecessary applications before using the Hubble app", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h3#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_where_my_recorded", nil, [NSBundle mainBundle], @"Q. Where can I find my recorded videos and snapshots?", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"#h4#"
                          withString:NSLocalizedStringWithDefaultValue(@"help_text_go_to_photos_application", nil, [NSBundle mainBundle], @"A. Your recorded video footage and snapshots are all stored inside your Photos application. Please go to ‘Photos' application to view them", nil)
                             options:nil range:NSMakeRange(0, html.length)];
    
    CGFloat height = 280;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        height = 420;
    }
    HelpWindowPopup *popup = [[HelpWindowPopup alloc] initWithTitle:@"Video Screen Help"
                                                      andHtmlString:html
                                                          andHeight:height];
    popup.delegate = self;
    [popup show];
    self.helpPopup = popup;
    [html release];
    [popup release];
}
#pragma mark - Delegate Stream callback

- (void)forceRestartStream:(NSTimer *)timer
{
    if ([self isStopProcess] ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        NSLog(@"%s View is invisible or is in background mode --> do nothing here.", __FUNCTION__);
    }
    else
    {
        NSLog(@"%s ", __FUNCTION__);
        
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:-99 ext2:-1];
//        [self showTimelineView];
        self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"low_data_bandwidth_detected", nil, [NSBundle mainBundle], @"Low data bandwidth detected. Trying to connect...", nil);
    }
}

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
    
    switch (msg)
    {
        case MEDIA_INFO_GET_AUDIO_PACKET:
            //NSLog(@"%s Got audio packet", __FUNCTION__);
            if ( userWantToCancel == TRUE)
            {
                NSLog(@"%s MEDIA_INFO_GET_AUDIO_PACKET after streaming stopped", __FUNCTION__);
                return;
                
            }
            
            if (_timerBufferingTimeout)
            {
                [_timerBufferingTimeout invalidate];
                self.timerBufferingTimeout = nil;
            }
            self.timerBufferingTimeout = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_BUFFERING
                                                                          target:self
                                                                        selector:@selector(forceRestartStream:)
                                                                        userInfo:nil
                                                                         repeats:NO];
            
            
            break;
        case MEDIA_INFO_START_BUFFERING:
            
            if ( userWantToCancel == TRUE)
            {
                NSLog(@"%s MEDIA_INFO_GET_AUDIO_PACKET after streaming stopped", __FUNCTION__);
                return;
                
            }

            NSLog(@"%s MEDIA_INFO_START_BUFFERING", __FUNCTION__);
            
            if (_timerBufferingTimeout)
            {
                [_timerBufferingTimeout invalidate];
                self.timerBufferingTimeout = nil;
            }
            
            self.timerBufferingTimeout = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_BUFFERING
                                                                          target:self
                                                                        selector:@selector(forceRestartStream:)
                                                                        userInfo:nil
                                                                         repeats:NO];
            break;
            
        case MEDIA_INFO_STOP_BUFFERING:
            
            NSLog(@"%s MEDIA_INFO_STOP_BUFFERING", __FUNCTION__);
            
            if (_timerBufferingTimeout)
            {
                [_timerBufferingTimeout invalidate];
                self.timerBufferingTimeout = nil;
            }
            break;
#ifdef SHOW_DEBUG_INFO
        case MEDIA_INFO_FRAMERATE_VIDEO:
        {
            [self updateDebugInfoFrameRate:ext1];
        }
            break;
#endif
        case MEDIA_INFO_VIDEO_SIZE:
        {
            NSLog(@"video size: %d x %d", ext1, ext2);
            [self updateDebugInfoResolutionWidth:ext1 heigth:ext2];
            
            float top = 0 , left =0;
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
            }
            
            NSLog(@"video adjusted size: %f x %f", destWidth, destHeight);
            
            self.imageViewStreamer.frame = CGRectMake(left,
                                                      top,
                                                      destWidth, destHeight);
        }
            break;
            
        case MEDIA_INFO_BITRATE_BPS:
        {
            
#ifdef SHOW_DEBUG_INFO
            if ([self isStopProcess] ||
                [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            {
                NSLog(@"MEDIA_INFO_BITRATE_BPS:%d View is invisible or inactive mode", ext1);
            }
            else
            {
                [self updateDebugInfoBitRate:ext1];
            }
#endif
        }
            break;
            
        case MEDIA_INFO_HAS_FIRST_IMAGE:
        {
            _isShowCustomIndicator = NO;
            self.shouldBeep = TRUE;
            [self displayCustomIndicator];
            
            NSLog(@"[MEDIA_PLAYER_HAS_FIRST_IMAGE]");
            if(self.selectedChannel.profile.isInLocal == NO)
            {
                if (_timerIncreaseBitRate)
                {
                    [_timerIncreaseBitRate invalidate];
                    self.timerIncreaseBitRate = nil;
                }
                
                if ([_currentBitRate isEqualToString:@"128"])
                {
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"600"];
                }
                else if (![_currentBitRate isEqualToString:@"600"])
                {
                    self.timerIncreaseBitRate = [NSTimer scheduledTimerWithTimeInterval:60
                                                                                 target:self
                                                                               selector:@selector(increaseBitRate:)
                                                                               userInfo:nil
                                                                                repeats:NO];
                }
                
                [self createTimerKeepRemoteStreamAlive];
            }
            
            self.currentMediaStatus = msg;
            
            if (self.selectedChannel.communication_mode == COMM_MODE_STUN)
            {
                self.numberOfSTUNError = 0;
            }
            
            if (self.probeTimer != nil && [self.probeTimer isValid])
            {
                [self.probeTimer invalidate];
                self.probeTimer = nil;
            }
            
            [self stopPeriodicPopup];

            if ([self isStopProcess] ||
                [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
            {
                NSLog(@"*[MEDIA_PLAYER_HAS_FIRST_IMAGE] *** USER want to cancel **.. cancel after .1 sec...");
                NSLog(@"MEDIA_PLAYER_HAS_FIRST_IMAGE View is invisible or in background mode");
            }
            else
            {
                if (self.selectedChannel.profile.isInLocal)
                {
// 20140716: Moved to [ setupCamera]
//                    if (_askForFWUpgradeOnce)
//                    {
//                        [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
//                        self.askForFWUpgradeOnce = NO;
//                    }
                }
                else
                {
                    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartingStageTwo];
                    
                    NSString *gaiActionTime = GAI_ACTION(2, diff);
                    NSLog(@"%s gaiActionTime: %@", __FUNCTION__, gaiActionTime);
                    
                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                    withAction:gaiActionTime
                                                                     withLabel:nil
                                                                     withValue:nil];
                    self.timeStartingStageTwo = 0;
                    
#if 1
                    [self reCreateTimoutViewCamera];
#else
                    if (_remoteViewTimeout == YES)
                    {
                        [self reCreateTimoutViewCamera];
                    }
#endif
                }
                
                self.imageViewStreamer.userInteractionEnabled = YES;
                self.imgViewDrectionPad.userInteractionEnabled = YES;
                
                if (!_earlierNavi.isEarlierView) {
                    [self showControlMenu];
                }
                
                if (isiPhone4)
                {
                    self.imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg"];
                }
                else
                {
                    self.imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg_5.png"];
                }
                
                if (![_cameraModel isEqualToString:CP_MODEL_0073])
                {
                    [self performSelectorInBackground:@selector(getCameraTemperature_bg:) withObject:nil];
                }
                else
                {
                    NSLog(@"%s There is no Temperature sensor on Focus73", __FUNCTION__);
                }
                
                self.horizMenu.userInteractionEnabled = YES;
            }
        }
            break;
            
        case MEDIA_PLAYER_STARTED:
        {
            self.currentMediaStatus = msg;
#if 0
            if (userWantToCancel == TRUE)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
                break;
            }
            
            NSLog(@"%s MEDIA_PLAYER_STARTED h264StreamerIsInStopped:%d", __FUNCTION__, _h264StreamerIsInStopped);

            if (_h264StreamerIsInStopped == TRUE)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
            }
#endif
        }
            break;
            
        case MEDIA_ERROR_SERVER_DIED:
    	case MEDIA_ERROR_TIMEOUT_WHILE_STREAMING:
        {
            self.currentMediaStatus = msg;
            
            //set custom indication is TRUE when server die
            _isShowCustomIndicator = YES;
            _isShowTextCameraIsNotAccesible = YES;
            
            if (_timerBufferingTimeout)
            {
                [_timerBufferingTimeout invalidate];
                self.timerBufferingTimeout = nil;
            }
            
            if (_timerRemoteStreamKeepAlive)
            {
                [_timerRemoteStreamKeepAlive invalidate];
                self.timerRemoteStreamKeepAlive = nil;
            }
            
    		NSLog(@"Timeout While streaming  OR server DIED - userWantToCancel: %d, returnFromPlayback: %d, forceStop: %d", userWantToCancel, _returnFromPlayback, ext1);

            [self stopStream];
            
            if (userWantToCancel == TRUE) // Event comes from BackButtonItem.
            {
                NSLog(@"*[MEDIA_ERROR_TIMEOUT_WHILE_STREAMING] *** USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;
                
                [self goBack];

                return;
            }
            else
            {
                self.selectedChannel.stopStreaming = TRUE;
                
                if (_h264StreamerIsInStopped ||
                    _returnFromPlayback      ||
                    _isFWUpgradingInProgress ||
                    [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
                {
                    return;
                }
                else
                {
                    [self performSelectorInBackground:@selector(checkFwUpgradeByAnotherDevice) withObject:nil];
                    
                    if (_isFwUpgradedByAnotherDevice)
                    {
                        self.isFWUpgradingInProgress = TRUE;
                        self.fwUpgradedProgress = 9;
                        self.fwUpgradeStatus = FIRMWARE_UPGRADE_IN_PROGRESS;
                        [self createHubbleAlertView];
                    }
                    else
                    {
                        
                        if (self.selectedChannel.communication_mode == COMM_MODE_STUN)
                        {
                            self.numberOfSTUNError++;
                        }
                        else if (self.selectedChannel.communication_mode == COMM_MODE_STUN_RELAY2)
                        {
                            if (_timerIncreaseBitRate)
                            {
                                [_timerIncreaseBitRate invalidate];
                                self.timerIncreaseBitRate = nil;
                            }
                            
                            [self downgradeRemoteStreamBitRate];
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
                        
                        // Start streaming
                        if (self.selectedChannel.profile.isInLocal == TRUE)
                        {
                            [self scanCamera];
                        }
                        else //Remote connection -> go back and retry
                        {
                            //Restart streaming..
                            if (_timeStartingStageTwo > 0)
                            {
                                NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartingStageTwo];
                                
                                NSString *gaiActionTime = GAI_ACTION(2, diff);
                                NSLog(@"%s gaiActionTime: %@", __FUNCTION__, gaiActionTime);
                                
                                [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                                withAction:gaiActionTime
                                                                                 withLabel:nil
                                                                                 withValue:nil];
                                self.timeStartingStageTwo = 0;
                            }
                            
                            NSLog(@"Re-start Remote streaming for : %@", self.selectedChannel.profile.mac_address);
                            
                            [NSTimer scheduledTimerWithTimeInterval:0.1
                                                             target:self
                                                           selector:@selector(setupCamera)
                                                           userInfo:nil
                                                            repeats:NO];
                        }
                    }
                }
            }
        }
            break;
    		
        case H264_SWITCHING_TO_RELAY_SERVER:
        {
            NSLog(@"switching to relay server");
            
            //TODO: Make sure we have closed all stream
            //Assume we are connecting via Symmetrict NAT
            [self remoteConnectingViaSymmectric];
            
            break;
        }
            
        case MEDIA_INFO_RECEIVED_VIDEO_FRAME:
            _isShowCustomIndicator = NO;
            [self displayCustomIndicator];
            break;
            
        case MEDIA_INFO_CORRUPT_FRAME_TIMEOUT:
            _isShowCustomIndicator = YES;
            [self displayCustomIndicator];
            break;
            
        default:
            break;
    }
}

- (void)reCreateTimoutViewCamera
{
    if (_timerRemoteStreamTimeOut != nil && [_timerRemoteStreamTimeOut isValid])
    {
        [self.timerRemoteStreamTimeOut invalidate];
        self.timerRemoteStreamTimeOut = nil;
    }
    
    self.timerRemoteStreamTimeOut = [NSTimer scheduledTimerWithTimeInterval:270.0//4m30s
                                                                     target:self
                                                                   selector:@selector(showDialogAndStopStream:)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (void)createTimerKeepRemoteStreamAlive
{
    if (_timerRemoteStreamKeepAlive)
    {
        [_timerRemoteStreamKeepAlive invalidate];
        self.timerRemoteStreamKeepAlive = nil;
    }
    
    self.timerRemoteStreamKeepAlive = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_REMOTE_STREAMING
                                                                       target:self
                                                                     selector:@selector(sendKeepAliveCmd:)
                                                                     userInfo:nil
                                                                      repeats:NO];
}

- (void)sendKeepAliveCmd:(NSTimer *)timer
{
    [self performSelectorInBackground:@selector(createStreamSession) withObject:nil];
}

- (void)createStreamSession
{
    if (userWantToCancel        ||
        _returnFromPlayback     ||
        !MediaPlayer::Instance()->isPlaying())
    {
        return;
    }
    
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                            andClientType:@"BROWSER"
                                                                                andApiKey:_apiKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (responseDict && [[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSLog(@"%s SUCCEEDED", __FUNCTION__);
            [self createTimerKeepRemoteStreamAlive];
        }
        else
        {
            NSLog(@"%s FAILED -responseDict: %@", __FUNCTION__, responseDict);
            [self performSelector:@selector(sendKeepAliveCmd:) withObject:nil afterDelay:1];
        }
    });
}

- (void)downgradeRemoteStreamBitRate
{
    if ([_currentBitRate isEqualToString:@"600"])
    {
        self.currentBitRate = @"550";// Dont care it set succeeded or failed!
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
    }
    else if ([_currentBitRate isEqualToString:@"550"])
    {
        self.currentBitRate = @"500";// Dont care it set succeeded or failed!
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
    }
    else if ([_currentBitRate isEqualToString:@"500"])
    {
        self.currentBitRate = @"450";// Dont care it set succeeded or failed!
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
    }
    else if ([_currentBitRate isEqualToString:@"450"])
    {
        self.currentBitRate = @"400";// Dont care it set succeeded or failed!
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
    }
    else if ([_currentBitRate isEqualToString:@"400"])
    {
        self.currentBitRate = @"350";// Dont care it set succeeded or failed!
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
    }
    else if ([_currentBitRate isEqualToString:@"350"])
    {
        // Update current bit rate only set succeeded!
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"300"];
    }
    else
    {
        NSLog(@"%s curr Bit-rate; %@", __FUNCTION__, _currentBitRate);
    }
}

- (void)checkIfUpgradeIsPossible
{
    NSString *currentFwVersion = _selectedChannel.profile.fw_version;
    
    NSLog(@"%s currentFwVersion:%@", __FUNCTION__, currentFwVersion);
#if 0
    if ([currentFwVersion compare:FW_VERSION_OTA_UPGRADING_MIN] >= NSOrderedSame)
#else
    if ([currentFwVersion compare:FW_VERSION_OTA_REMOTE_UPGRADE_ENABLE] == NSOrderedSame)
#endif
    {
        NSString * response = nil ;
        
        if (self.selectedChannel.profile.isInLocal == TRUE)
        {
            response = [[HttpCom instance].comWithDevice sendCommandAndBlock:CHECK_FW_UPGRADE];
        }
        // ONLY START TO DO REMOTE UPDATE  IF VERSION IS 01.15.11
        else// if ([currentFwVersion compare:FW_VERSION_OTA_REMOTE_UPGRADE_ENABLE] == NSOrderedSame)
        {
            NSLog(@"%s DO REMOTE FW upgrade", __FUNCTION__);
            BMS_JSON_Communication * jsoncomm = [[BMS_JSON_Communication alloc]initWithCaller:self];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            NSDictionary * responseDict = [jsoncomm sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                           andCommand:[NSString stringWithFormat:@"action=command&command=%@",CHECK_FW_UPGRADE]
                                                            andApiKey:apiKey];
            [jsoncomm release];
            
            if (responseDict != nil)
            {
                NSInteger status = [[responseDict objectForKey:@"status"] intValue];
                if (status == 200)
                {
                    response = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
                }
            }
        }
        
        /*
         * 1. check_fw_upgrade: -1, check_fw_upgrade: 0 --> impossible
         * 2. check_fw_upgrade: xx.yy.zz                --> possible
         */
        
        response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"%s response:%@", __FUNCTION__, response);
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^check_fw_upgrade: \\d{2}.\\d{2}.\\d{2}$"
                                                                               options:NSRegularExpressionAnchorsMatchLines
                                                                                 error:&error];
        if (!regex)
        {
            NSLog(@"%s error:%@", __FUNCTION__, error.description);
        }
        else
        {
            if (response)
            {
                //NSString *string = @"check_fw_upgrade: 01.56.78";
                //NSString *string = nil; Exception!
                NSUInteger numberOfMatches = [regex numberOfMatchesInString:response
                                                                    options:0
                                                                      range:NSMakeRange(0, [response length])];
                NSLog(@"%s numberOfMatches:%d", __FUNCTION__, numberOfMatches);
                
                if (numberOfMatches == 1 &&
                    !userWantToCancel    &&
                    !_returnFromPlayback)
                {
                    self.fwUpgrading = [response substringFromIndex:@"check_fw_upgrade: ".length];
                    [self performSelectorOnMainThread:@selector(showFWUpgradeDialog:) withObject:_fwUpgrading waitUntilDone:NO];
                }
            }
        }
    }
}

-(void) showFWUpgradeDialog:(NSString *) version
{
    NSString *title = NSLocalizedStringWithDefaultValue(@"Camera_fw_upgrade" , nil, [NSBundle mainBundle],
                                                         @"Camera Firmware Upgrade", nil);
    
    NSString *msg = NSLocalizedStringWithDefaultValue(@"fw_upgrade", nil, [NSBundle mainBundle],
                                                       @"A camera firmware %@ is available. Press OK to upgrade now." , nil);
    NSString *ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    NSString *cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
    
	msg = [NSString stringWithFormat:msg, version];
    
	self.alertFWUpgrading = [[UIAlertView alloc]
              initWithTitle:title
              message:msg
              delegate:self
              cancelButtonTitle:cancel
              otherButtonTitles:ok, nil];
    
	_alertFWUpgrading.tag = TAG_ALERT_FW_OTA_UPGRADE_AVAILABLE;
	[_alertFWUpgrading show];
	[_alertFWUpgrading release];
}

#pragma mark Delegate Timeline

- (void)stopStreamToPlayback
{
    NSLog(@"%s _mediaProcessStatus: %d, isMT: %d", __FUNCTION__, _mediaProcessStatus, [NSThread isMainThread]);
    self.returnFromPlayback = TRUE;
    self.h264StreamerIsInStopped = TRUE;
    self.selectedChannel.stream_url = nil;
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (_jsonComm)
    {
        [_jsonComm cancel];
        [_jsonComm release];
        self.jsonComm = nil;
    }
    
    if (_audioOutStreamRemote)
    {
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
    
    if (_timerBufferingTimeout)
    {
        NSLog(@"%s Invalidate timerBufferingTimeout.", __FUNCTION__);
        [_timerBufferingTimeout invalidate];
    }

    [self stopMediaProcessGoBack:NO backgroundMode:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Method

- (void)singleTapGestureCaptured:(id)sender
{
    NSLog(@"Single tap singleTapGestureCaptured");
    if (self.isHorizeShow)
    {
        [self hideControlMenu];
    }
    else
    {
        [self showControlMenu];
    }
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView single tap on video image view: %d", _isHorizeShow] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"single tap on video image view"
                                                     withLabel:@"Vide image view"
                                                     withValue:[NSNumber numberWithDouble:!self.horizMenu.hidden]];
}

- (void)hideControlMenu
{
    self.isHorizeShow = NO;
    self.horizMenu.userInteractionEnabled = NO;
    if (!self.horizMenu.hidden && self.horizMenu.alpha == 1.0)
    {
        [UIView animateWithDuration:5.0
                         animations:^{
                             self.horizMenu.alpha = 0.0;
                             self.ib_lbCameraName.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             self.horizMenu.hidden = YES;
                             [self.ib_lbCameraName setHidden:YES];
                         }];
    }
}

- (void)showControlMenu
{
    self.isHorizeShow = YES;
    self.horizMenu.userInteractionEnabled = YES;
    static NSTimeInterval animationDuration = 0.0;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.horizMenu.alpha = 1.0;
                         self.ib_lbCameraName.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         self.horizMenu.hidden = NO;
                         [self.view bringSubviewToFront:_horizMenu];
                         [self.ib_lbCameraName setHidden:NO];
                     }];
    
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
    [_timerHideMenu release];
    _timerHideMenu = nil;
    
}

- (void)showTimelineView
{
    if (_timelineVC != nil)
    {
        self.timelineVC.view.hidden = NO;
        [self.view bringSubviewToFront:self.timelineVC.view];
    }
    
    //reset selected menu;
    if (self.selectedItemMenu != -1)
    {
        _selectedItemMenu = -1;
        [self.horizMenu resetStatus];
    }
}

/*
  This is triggered if app has just received a push notification 
 AND it is from the same camera being view at the moment
  we will try to re-load the timeline to reflect this new event
 */

-(void) h264_HandleActivePushes
{
    NSLog(@"%s enter >>>>>>>>>>>>>>>>>> reload timeline 1",__FUNCTION__);
    if (self.timelineVC != nil)
    {
        
        [self.timelineVC performSelectorInBackground:@selector(getExtraEvent_bg) withObject:nil];

    }
    
}


//This is triggered if app has just received a push notification
//   from an inactive stage : for eg: just comeback from background
//   in this case, we should stop streaming right away.
-(void)h264_HandleInactivePushes
{
    NSLog(@"%s enter >>>>>>>>>>>>>>>>>> call prepareGoBackToCameraList ", __FUNCTION__);
    
    [self prepareGoBackToCameraList:self.navigationItem.leftBarButtonItem];
}

- (void)h264_HandleDidEnterBackground
{
    NSLog(@"%s userWantToCancel:%d, returnFromPlayback:%d, mediaProcessStatus: %d, _timerBufferingTimeout:%p", __FUNCTION__, userWantToCancel, _returnFromPlayback, _mediaProcessStatus, _timerBufferingTimeout);

    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Enter background"
                                                     withLabel:@"Homekey"
                                                     withValue:[NSNumber numberWithDouble:userWantToCancel]];
    
    if (userWantToCancel == TRUE || _returnFromPlayback || _isFWUpgradingInProgress)
    {
        return;
    }
    
    if (_timerBufferingTimeout)
    {
        [_timerBufferingTimeout invalidate];
        self.timerBufferingTimeout = nil;
    }
    
    _selectedChannel.stopStreaming = TRUE;
    
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (_alertViewTimoutRemote)
    {
        [_alertViewTimoutRemote dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    // turnoff audio recode in remote state
    if (_audioOutStreamRemote)
    {
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
    // turnoff audio recode in local state
    if (_audioOut != nil)
    {
        [_audioOut disconnectFromAudioSocket];
        self.audioOut = nil;
    }
    
    if (_jsonComm)
    {
        [_jsonComm cancel];
        self.jsonComm = nil;
    }
    
    if (_timerCheckMelodyState) {
        [_timerCheckMelodyState invalidate];
    }
    
    [self stopMediaProcessGoBack:NO backgroundMode:YES];
    
    self.h264StreamerIsInStopped = TRUE;
    self.imageViewVideo.backgroundColor = [UIColor blackColor];
    self.imageViewStreamer.backgroundColor = [UIColor blackColor];
    
    if (_selectedChannel.profile.isInLocal)
    {
        NSLog(@"Enter Background.. Local ");
    }
    else if (_selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
    {
        //NSLog(@"abort remote timer ");
        [_selectedChannel abortViewTimer];
    }
    
    if (_alertFWUpgrading && [_alertFWUpgrading isVisible])
    {
        if (_alertFWUpgrading.tag == TAG_ALERT_FW_OTA_UPGRADE_AVAILABLE)
        {
            NSLog(@"%s Dismiss TAG_ALERT_FW_OTA_UPGRADE_AVAILABLE & askForFWUpgradeOnce", __FUNCTION__);
            self.askForFWUpgradeOnce = YES;
            
            [_alertFWUpgrading dismissWithClickedButtonIndex:0 animated:NO];
        }
        else
        {
            NSLog(@"%s alertFWUpgrading is changed tag", __FUNCTION__);
        }
    }
}

- (void)h264_HandleWillEnterForeground
{
    NSLog(@"%s userWantToCancel:%d, returnFromPlayback:%d, mediaProcessStatus: %d, UIBackgroundTaskInvalid:%d, isFWUpgradingInProgress:%d",
          __FUNCTION__, userWantToCancel, _returnFromPlayback, _mediaProcessStatus, UIBackgroundTaskInvalid, _isFWUpgradingInProgress);
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Become Active"
                                                     withLabel:nil
                                                     withValue:[NSNumber numberWithDouble:userWantToCancel]];
    if (userWantToCancel == TRUE || _returnFromPlayback || _isFWUpgradingInProgress)
    {
        return;
    }
    
    if (_timerBufferingTimeout)
    {
        [_timerBufferingTimeout invalidate];
        self.timerBufferingTimeout = nil;
    }
    
    self.h264StreamerIsInStopped = FALSE;
    self.currentMediaStatus = 0;
    self.wantToShowTimeLine = YES;
    
    if (!_earlierNavi.isEarlierView)
    {
        [self showTimelineView];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL cancelBecauseOfPn = [userDefaults boolForKey:HANDLE_PN];
    
    if (cancelBecauseOfPn == TRUE)
    {
        NSLog(@"&(*&(&(*&(& set user = true && CLEAR it");
        userWantToCancel = TRUE;
        [userDefaults removeObjectForKey:HANDLE_PN];
        [userDefaults synchronize];
        
        return;
    }
    
    //this func gets call even after app enter inactive state -> we don't stop player then..thus do not restart player here
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        NSLog(@"%s Waiting for stop streaming process.", __FUNCTION__);
        MediaPlayer::Instance()->sendInterrupt();
    }
    else
    {
        [self scanCamera];
    }
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}


- (void)becomeActive
{
    if (![_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]) // CameraHD
    {
        TimelineViewController *vc = [[TimelineViewController alloc] init];
        self.timelineVC = vc;
        [vc release];
        [self.view addSubview:_timelineVC.view];
        self.timelineVC.timelineVCDelegate = self;
        self.timelineVC.camChannel = self.selectedChannel;
        self.timelineVC.navVC = self.navigationController;
        self.timelineVC.parentVC = self;
        
        [self.timelineVC loadEvents:self.selectedChannel];
    }
    
    self.selectedChannel.stopStreaming = NO;
    
    //TODO: Don't call it here.. too many calls to this
    //[self displayCustomIndicator];

    

    [self scanCamera];
    
    [self hideControlMenu];
    
    NSLog(@"Check selectedChannel is %@ and ip of deviece is %@", self.selectedChannel, self.selectedChannel.profile.ip_address);
    
    [self setupPtt];
    
    self.stringTemperature = TEMP_NULL;
    //end add button to change
    [ib_switchDegree setHidden:YES];
    
    self.imageViewHandle.hidden = YES;
    self.imageViewKnob.center = self.imgViewDrectionPad.center;
    self.imageViewHandle.center = self.imgViewDrectionPad.center;
}

- (BOOL)isStopProcess
{
    //NSLog(@"%s userWantToCancel:%d, _h264StreamerIsStopped:%d, _returnFromPlayback:%d, _isFWUpgradingInProgress:%d", __FUNCTION__, userWantToCancel, _h264StreamerIsInStopped, _returnFromPlayback, _isFWUpgradingInProgress);
    
    return (userWantToCancel         ||
            _h264StreamerIsInStopped ||
            _returnFromPlayback      ||
            _isFWUpgradingInProgress);
}

#pragma mark - Shared Cam
-(void)queryToKnowSharedCamOnMacOSOrWin
{
    NSString *bodyKey = @"";
    
    if (self.selectedChannel.profile.isInLocal )
	{
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"get_running_os"];
        if (response != nil)
        {
            self.sharedCamConnectedTo = [[response componentsSeparatedByString:@": "] objectAtIndex:1];
        }
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
	{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        if (_jsonCommBlocked == nil)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlocked = comm;
            [comm release];
        }
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:[NSString stringWithFormat:@"action=command&command=get_running_os"]
                                                                                  andApiKey:apiKey];
        if (responseDict != nil)
        {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200)
            {
                bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
        if (![bodyKey isEqualToString:@""])
        {
            NSArray * tokens = [bodyKey componentsSeparatedByString:@": "];
            if ([tokens count] >=2 )
            {
                self.sharedCamConnectedTo = [tokens objectAtIndex:1];//return MacOS|Window
            }
        }
        else
        {
            //default is connected to window.
            _sharedCamConnectedTo = @"Unknown";
        }
        
	}
}

- (void)createMonvementControlTimer
{
    NSLog(@"%s model:%@", __FUNCTION__, _cameraModel);
    
     [self cleanUpDirectionTimers];
    
    //if([_cameraModel hasPrefix:CP_MODEL_008] || [_cameraModel isEqualToString:CP_MODEL_0073] )
    if(![_cameraModel isEqualToString:CP_MODEL_CONCURRENT] &&
       ![_cameraModel isEqualToString:CP_MODEL_SHARED_CAM])
    {
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
}

#pragma mark - Setup camera

- (void)setupCamera
{
    self.mediaProcessStatus = 0;
    
    [self createMonvementControlTimer];
    
    _isShowCustomIndicator = YES;
    [self displayCustomIndicator];
    self.selectedChannel.stream_url = nil;
    
    [self setupHttpPort];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"H264VC - setupCamera -device_ip: %@, -device_port: %d, -{remote_only: %d}", self.selectedChannel.profile.ip_address, self.selectedChannel.profile.port, [userDefaults boolForKey:@"remote_only"]);
    
    NSLog(@"%s LOCAL _askForFWUpgradeOnce:%d", __FUNCTION__, _askForFWUpgradeOnce);
    if (_askForFWUpgradeOnce)
    {
        [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
        self.askForFWUpgradeOnce = NO;
    }
    
    
    
    //Support remote UPNP video as well
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"H264VC - setupCamera -created a local streamer");
        self.selectedChannel.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
        NSLog(@"%s Start stage 2", __FUNCTION__);
        self.timeStartingStageTwo = [NSDate date];
        
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
#ifdef SHOW_DEBUG_INFO
        _viewVideoIn = @"L";
#endif
        self.ib_labelTouchToTalk.text = NSLocalizedStringWithDefaultValue(@"text_touch_to_talk", nil, [NSBundle mainBundle], @"Touch to Talk", nil);
        self.stringStatePTT = @"Touch to Talk";
        
        
        
       

        
    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        NSLog(@"H264VC - setupCamera - created a remote streamer - {enable_stun}: %@", [userDefaults objectForKey:@"enable_stun"]);
#if 1
        // Ignore enable_stun value key
        [self symmetric_check_result:TRUE];
#else
        // This value is setup on Account view
        if([userDefaults boolForKey:@"enable_stun"] == FALSE)
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
#endif
        
        self.ib_labelTouchToTalk.text = NSLocalizedStringWithDefaultValue(@"text_touch_to_talk", nil, [NSBundle mainBundle], @"Touch to Talk", nil);
        self.stringStatePTT = @"Touch to Talk";
    }
    else
    {
        NSLog(@"Unknown Exception!");
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
    
    if (userWantToCancel == TRUE)
    {
        NSLog(@"startStream: userWantToCancel >>>>");
        //force this to gobacktoCameralist
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    if (_returnFromPlayback ||
        _isFWUpgradingInProgress)
    {
        NSLog(@"%s returnFromPlayback:%d, isFWUpgradingInProgress:%d", __FUNCTION__, _returnFromPlayback, _isFWUpgradingInProgress);
        return;
    }
    
    self.mediaProcessStatus = MEDIAPLAYER_SET_LISTENER;
    NSLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    h264StreamerListener = new H264PlayerListener(self);
    MediaPlayer::Instance()->setListener(h264StreamerListener);
    MediaPlayer::Instance()->setPlaybackAndSharedCam(false, [_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]);
    
    MediaPlayer::Instance()->setDisableAudioStream([_cameraModel isEqualToString:CP_MODEL_0073]);
    
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    
    //Store current SSID - to check later
	self.current_ssid = [CameraPassword fetchSSIDInfo];
    
	if (_current_ssid == nil)
	{
		NSLog(@"Error: streamingSSID is nil before streaming");
	}
    
	NSLog(@"Current SSID is: %@", _current_ssid);
    
    
	//Store some of the info for used in menu  --
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    
	[userDefaults setBool:!(isOffline) forKey:_is_Loggedin];
    
	if (_current_ssid != nil)
	{
		[userDefaults setObject:_current_ssid forKey:_streamingSSID];
	}
    
    [userDefaults synchronize];
    
    //`NSLog(@"Play with TCP Option >>>>> ") ;
    //mp->setPlayOption(MEDIA_STREAM_RTSP_WITH_TCP);
    
    NSString * url = self.selectedChannel.stream_url;
    NSLog(@"%s url: %@", __FUNCTION__, url);
    
    if ([self isStopProcess] ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        NSLog(@"%s View is invisible or is in background mode. Ignoring.", __FUNCTION__);
    }
    else
    {
        self.mediaProcessStatus = MEDIAPLAYER_SET_DATASOURCE;
        NSLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
        
        do
        {
            if (url == nil || [url isEqualToString:@""])
            {
                break;
            }
            
            status = MediaPlayer::Instance()->setDataSource([url UTF8String]);
            
            if (status != NO_ERROR) // NOT OK
            {
                NSLog(@"setDataSource  failed");
                
                if (self.selectedChannel.profile.isInLocal)
                {
//                    [self showTimelineView];
                    self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
                }
                
                break;
            }
            //self.mediaProcessStatus = 3;
            
            MediaPlayer::Instance()->setVideoSurface(_imageViewStreamer);
            
            //self.mediaProcessStatus = 4;
            status = MediaPlayer::Instance()->prepare();
            
            if (status != NO_ERROR) // NOT OK
            {
                break;
            }
            
            // Play anyhow
            //self.mediaProcessStatus = 5;
            status = MediaPlayer::Instance()->start();
            
            
            if (status != NO_ERROR) // NOT OK
            {
                break;
            }
        }
        while (false);
        
        NSLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
        self.mediaProcessStatus = MEDIAPLAYER_STARTED;

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
}

/* Within 1 sec MUST exit the player - this is a MUST** */
- (void)prepareGoBackToCameraList:(id)sender
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Go back"
                                                     withLabel:@"Hubble back button item"
                                                     withValue:[NSNumber numberWithDouble:_currentMediaStatus]];
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    _isShowCustomIndicator = NO;
    
    self.view.userInteractionEnabled = NO;
    
    NSLog(@"%s - self.currentMediaStatus: %d", __FUNCTION__, self.currentMediaStatus);
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    if (_jsonComm)
    {
        [_jsonComm cancel];
        [_jsonComm release];
    }
    
    if (_audioOutStreamRemote)
    {
        [self performSelectorInBackground:@selector(closeRemoteTalkback) withObject:nil];
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
    
    [self stopPeriodicBeep];
    
    if (_timerRemoteStreamTimeOut && [_timerRemoteStreamTimeOut isValid])
    {
        [_timerRemoteStreamTimeOut invalidate];
        self.timerRemoteStreamTimeOut = nil;
    }
    if (_timerHideMenu != nil && [_timerHideMenu isValid])
    {
        [self.timerHideMenu invalidate];
        self.timerHideMenu = nil;
    }
    
    [self stopPeriodicBeep];
    
    if (_alertFWUpgrading)
    {
        [_alertFWUpgrading dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    NSLog(@"%s _mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    if (_earlierVC)
    {
        NSLog(@"%s _earlierVC:%d", __FUNCTION__, _earlierVC.retainCount);
        [_earlierVC removeSubviews];
        [_earlierVC release];
        _earlierVC = nil;
    }
    
    if (_timelineVC)
    {
        _timelineVC.timelineVCDelegate = nil;
        [_timelineVC cancelAllLoadingImageTask];
        NSLog(@"%s timelineVC:%d", __FUNCTION__, _timelineVC.retainCount);
        
        NSLog(@"%s release timelineVC",__FUNCTION__ );
        [_timelineVC release];
        _timelineVC = nil;
    }
    
    if (_jsonCommBlocked)
    {
        [_jsonCommBlocked release];
    }
    
    BOOL isGoBack = YES;
    
    if (!sender)
    {
        isGoBack = NO; // Calling from iosVC.
    }
    
    [self stopMediaProcessGoBack:isGoBack backgroundMode:NO];
}

- (void)goBackToCamerasRemoteStreamTimeOut
{
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    
    NSLog(@"self.currentMediaStatus: %d", self.currentMediaStatus);
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ||
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),   UIDeviceOrientationPortrait);
        }
    }
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.selectedChannel.profile.isSelected = FALSE;
    
#if 1
    [self.navigationController popViewControllerAnimated:YES];
#else
    [self.navigationController popToRootViewControllerAnimated:YES];
#endif
}

- (void)goBack
{
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    NSLog(@" %s self.currentMediaStatus: %d retaintCount:%d ",__FUNCTION__, self.currentMediaStatus, self.retainCount);
    
    self.walkieTalkieEnabled = NO;
    self.enablePTT = NO;
    if (self.selectedChannel.profile.isInLocal)
    {
        [self enableLocalPTT:_walkieTalkieEnabled];
    }
    else
    {
        [self enableRemotePTT:[NSNumber numberWithBool:self.walkieTalkieEnabled]];
    }
    
    // Release the instance here - since we are going to camera list
    MediaPlayer::release();
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ||
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),   UIDeviceOrientationPortrait);
        }
    }
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.selectedChannel.profile.isSelected = FALSE;
    
#if 1
    [self.navigationController popViewControllerAnimated:YES];
#else
    [self.navigationController popToRootViewControllerAnimated:YES];
#endif
}

-(void) cleanUpDirectionTimers
{
    //if([_cameraModel hasPrefix:CP_MODEL_008] || [_cameraModel isEqualToString:CP_MODEL_0073])
    if(![_cameraModel isEqualToString:CP_MODEL_CONCURRENT] &&
       ![_cameraModel isEqualToString:CP_MODEL_SHARED_CAM])
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
    
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSString * cmd_string = @"action=command&command=close_p2p_rtsp_stun";
    
    //NSDictionary *responseDict =
    [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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



- (void)stopStream
{
    NSLog(@"%s MainThread: %d", __FUNCTION__, [NSThread isMainThread]);
    
    _timerStopStreamAfter30s = nil;
    @synchronized(self)
    {
        if (_timerIncreaseBitRate)
        {
            [_timerIncreaseBitRate invalidate];
            self.timerIncreaseBitRate = nil;
        }
        
        if (_timerBufferingTimeout)
        {
            [_timerBufferingTimeout invalidate];
            self.timerBufferingTimeout = nil;
        }
        
        if (_timerRemoteStreamKeepAlive)
        {
            [_timerRemoteStreamKeepAlive invalidate];
            self.timerRemoteStreamKeepAlive = nil;
        }
        
        self.mediaProcessStatus = 0;
        MediaPlayer::Instance()->setListener(NULL);
        
        delete h264StreamerListener;
        h264StreamerListener = NULL;
        
        
        _isProcessRecording = FALSE;
        [self stopRecordingVideo];
        [self stopPeriodicBeep];
        
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        
        
        if (self.backgroundTask != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }
        
        [self cleanUpDirectionTimers];
        
        if (scanner != nil)
        {
            [scanner cancel];
        }
        
        if (_timerRemoteStreamTimeOut != nil)
        {
            [self.timerRemoteStreamTimeOut invalidate];
            self.timerRemoteStreamTimeOut = nil;
        }
        
        self.imageViewStreamer.userInteractionEnabled = NO;
        
        if (self.isHorizeShow)
        {
            [self hideControlMenu];
        }
        
        [self hidenAllBottomView];
        
        
        //TODO: enable this
        //[self  stopStunStream];
        
        
    }
}

- (void)stopMediaProcessGoBack:(BOOL )isGoBack backgroundMode:(BOOL )isBgMode
{
    NSLog(@"%s isGoBack:%d, isBgMode:%d", __FUNCTION__, isGoBack, isBgMode);
    
    if (_mediaProcessStatus == MEDIAPLAYER_NOT_INIT)
    {
    }
    else if(_mediaProcessStatus == MEDIAPLAYER_SET_LISTENER)
    {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
    }
    else if (_mediaProcessStatus == MEDIAPLAYER_SET_DATASOURCE)
    {
        NSLog(@"%s Waiting for response from Media lib.", __FUNCTION__);
        MediaPlayer::Instance()->sendInterrupt();
        
        if (isBgMode)
        {
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                NSLog(@"Background handler called. Not running background tasks anymore.");
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }];
            
            NSLog(@"%s Waiting for call back from MediaPlayer lib. backgroundTask:%d", __FUNCTION__, _backgroundTask);
        }
        
        if (isGoBack)
        {
             MediaPlayer::Instance()->setShouldWait(FALSE);
            isGoBack = FALSE;
        }
    }
    else //MEDIAPLAYER_STARTED
    {
        [self stopStream];
    }
    
    if (isGoBack)
    {
        MediaPlayer::Instance()->setShouldWait(FALSE);
        [self goBack];
    }
}

- (void)showDialogAndStopStream: (id)sender // Timer
{
    _timerRemoteStreamTimeOut = nil;
    //stop stream after 30s if user no click.
    _timerStopStreamAfter30s = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(stopStream) userInfo:nil repeats:NO];
    
    if (_alertViewTimoutRemote && _alertViewTimoutRemote.isVisible)
    {
        NSLog(@"%s already visible!", __FUNCTION__);
    }
    else
    {
        self.alertViewTimoutRemote = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_remote_stream", nil, [NSBundle mainBundle], @"Remote Stream", nil)
                                                                message:NSLocalizedStringWithDefaultValue(@"alert_mes_camera_has_been_viewed_for_about_5_minutes", nil, [NSBundle mainBundle], @"The Camera has been viewed for about 5 minutes. Do you want to continue?", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"view_other_camera", nil, [NSBundle mainBundle], @"View other camera", nil)
                                                      otherButtonTitles:NSLocalizedStringWithDefaultValue(@"yes", nil, [NSBundle mainBundle], @"YES", nil), nil];
        _alertViewTimoutRemote.tag = TAG_ALERT_VIEW_REMOTE_TIME_OUT;
        
        [_alertViewTimoutRemote show];
    }
}

#pragma mark - VQ

-(void) getVQ_bg
{
    NSString *bodyKey = @"";
    
    if (self.selectedChannel.profile.isInLocal )
	{
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"get_resolution"];
        
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
        
		if (_jsonCommBlocked == nil)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlocked = comm;
            [comm release];
        }
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
    //modelVideo example is "720p_926"
    _resolution = [NSString stringWithFormat:@"%@x%@", [modeVideo substringToIndex:3], [modeVideo substringFromIndex:5]];
}

- (void)getTriggerRecording_bg
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"get_recording_stat"];
        
        if (responseData != nil)
        {
            
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"getTriggerRecording_bg response string: %@", responseString);
        }
    }
    else
    {
        if (_jsonCommBlocked == nil)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlocked = comm;
            [comm release];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:[NSString stringWithFormat:@"set_recording_stat&mode=%@", modeRecording]];
        
        if (responseData != nil)
        {
            
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
            
            NSLog(@"setTriggerRecording_bg response string: %@", responseString);
        }
    }
    else
    {
        if (_jsonCommBlocked == nil)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlocked = comm;
            [comm release];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
}

#pragma mark - Temperature

- (void)getCameraTemperature_bg: (id)sender
{
    /*
     * If back, Need not to update UI
     */
    
    if (userWantToCancel    ||
        _returnFromPlayback ||
        _isFWUpgradingInProgress)
    {
        return;
    }
    
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
        responseString = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"value_temperature"];
    }
    else
    {
        if (_jsonCommBlocked == nil)
        {
            BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                  Selector:nil
                                              FailSelector:nil
                                                 ServerErr:nil];
            self.jsonCommBlocked = comm;
            [comm release];
        }
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:@"action=command&command=value_temperature"
                                                                                  andApiKey:_apiKey];
        
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
                
                /*
                 * If back, Need not to update UI
                 */
                
                if (userWantToCancel ||
                    _returnFromPlayback)
                {
                    return;
                }
                
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

-(float) temperatureToFfromC: (float) degreeC
{
    float degreeF = ((degreeC * 9.0)/5.0) + 32;

    return degreeF;
}

- (void)setTemperatureState_Fg: (NSString *)temperature
{
    // Update UI
    
    NSLog(@"%s isEarlierView:%d", __FUNCTION__, _earlierNavi.isEarlierView);
    
    _degreeCString = [NSString stringWithFormat:@"%d", (int)roundf([temperature floatValue])];
    //_degreeCString = stringTemperature;
    
    int degreeF = (int) [self temperatureToFfromC:[temperature floatValue]];
    
    _degreeFString = [NSString stringWithFormat:@"%d", degreeF];
    
    /*
     * Need not to update Temperature UI if the current view is Earlier view.
     */
    
    if (_earlierNavi.isEarlierView)
    {
        return;
    }
#if 1
    UILabel *lblTemperatureValue = (UILabel *)[_viewTemperature viewWithTag:TAG_TEMPERATURE_VALUE];
    lblTemperatureValue.text = _isDegreeFDisplay?_degreeFString:_degreeCString;
    
    UILabel *lblTemperatureType = (UILabel *)[_viewTemperature viewWithTag:TAG_TEMPERATURE_TYPE];
    lblTemperatureType.text = _isDegreeFDisplay?@"°F":@"°C";
    
    if (self.selectedItemMenu == INDEX_TEMP &&
        ![self.stringTemperature isEqualToString:TEMP_NULL])
    {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        self.viewTemperature.hidden = NO;
        [self.view bringSubviewToFront:_viewTemperature];
    }
    else
    {
        self.viewTemperature.hidden = YES;
    }
#else
    // start
    [self.ib_temperature.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    UILabel *degreeCelsius = [[UILabel alloc] init];
    degreeCelsius.backgroundColor=[UIColor clearColor];
    degreeCelsius.textColor=[UIColor temperatureTextColor];
    degreeCelsius.textAlignment = NSTextAlignmentLeft;
    
    NSString *degreeCel;
    
    if (_isDegreeFDisplay)
    {
        degreeCel = @"°F";
        stringTemperature = _degreeFString;
    }
    else
    {
        degreeCel = @"°C";
        stringTemperature = _degreeCString;
    }
    
    degreeCelsius.text= degreeCel;
    
    UIFont *degreeFont;
    UIFont *temperatureFont;
    float positionYOfBottomView = self.ib_temperature.frame.origin.y;//240.0f;
#if 0
    if (!isiOS7AndAbove)
    {
        positionYOfBottomView = positionYOfBottomView - 44;
    }
#endif
    
    if (_isLandScapeMode)
    {
        degreeCelsius.backgroundColor=[UIColor clearColor];
        degreeCelsius.textColor=[UIColor whiteColor];
        float xPosTemperature;
        float yPosTemperature;
        CGSize stringBoundingBox;;
        CGSize degreeCelBoundingBox;
        CGFloat deltaWidth = 20;
        
        if (isiPhone5 || isiPhone4)
        {
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:13];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:53];
        }
        else // Expect iPad
        {
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:30];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:100];
            positionYOfBottomView = self.ib_temperature.frame.origin.y;
            deltaWidth += 72;
        }
        
        [degreeCelsius setFont:degreeFont];
        [self.ib_temperature setFont:temperatureFont];
        [self.ib_temperature setTextColor:[UIColor whiteColor]];
        [self.ib_temperature setText:stringTemperature];
        
        stringBoundingBox = [stringTemperature sizeWithAttributes:@{NSFontAttributeName: temperatureFont}];
        degreeCelBoundingBox = [degreeCel sizeWithAttributes:@{NSFontAttributeName: degreeFont}];
        
        xPosTemperature = SCREEN_HEIGHT - self.ib_temperature.bounds.size.width - 40 + (self.ib_temperature.bounds.size.width - stringBoundingBox.width)/2;
        yPosTemperature = SCREEN_WIDTH - deltaWidth - stringBoundingBox.height;
        
        [self.ib_temperature setFrame:CGRectMake(xPosTemperature, yPosTemperature, self.ib_temperature.bounds.size.width, self.ib_temperature.bounds.size.height)];
        [ib_switchDegree setFrame:CGRectMake(xPosTemperature, yPosTemperature, self.ib_temperature.bounds.size.width, self.ib_temperature.bounds.size.height)];
        
        CGFloat widthString = stringBoundingBox.width;
        CGFloat alignX = (self.ib_temperature.bounds.size.width + widthString)/2;
        [degreeCelsius setFrame:CGRectMake(alignX, 5, degreeCelBoundingBox.width, degreeCelBoundingBox.height)];
        [self.ib_temperature addSubview:degreeCelsius];
    }
    else
    {
        if (isiPhone5)
        {
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:35];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:135];
            
        }
        else if (isiPhone4)
        {
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:30];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:125];
        }
        else
        {
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:50];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:200];
            positionYOfBottomView = 543.0f;
        }
        
        [degreeCelsius setFont:degreeFont];
        [self.ib_temperature setFrame:CGRectMake(0, positionYOfBottomView, SCREEN_WIDTH, SCREEN_HEIGHT - positionYOfBottomView)];
        [ib_switchDegree setFrame:CGRectMake(0, positionYOfBottomView, SCREEN_WIDTH, SCREEN_HEIGHT - positionYOfBottomView)];
        [self.ib_temperature setFont:temperatureFont];
        [self.ib_temperature setTextColor:[UIColor temperatureTextColor]];
        
        //need update text for C or F
        [self.ib_temperature setText:stringTemperature];
        
        //CGSize stringBoundingBox = [stringTemperature sizeWithFont:temperatureFont];
        CGSize stringBoundingBox = [stringTemperature sizeWithAttributes:@{NSFontAttributeName: temperatureFont}];
        //CGSize degreeCelBoundingBox = [degreeCel sizeWithFont:degreeFont];
        CGSize degreeCelBoundingBox = [degreeCel sizeWithAttributes:@{NSFontAttributeName: degreeFont}];
        
        
        CGFloat widthString = stringBoundingBox.width;
        CGFloat heightString = stringBoundingBox.height;
        CGFloat alignX = (SCREEN_WIDTH + widthString)/2 - degreeCelBoundingBox.width/2 + 15;
        CGFloat alignYCel = (SCREEN_HEIGHT - positionYOfBottomView)/2 - heightString/2 + 10;
        [degreeCelsius setFrame:CGRectMake(alignX, alignYCel, degreeCelBoundingBox.width, degreeCelBoundingBox.height)];
        [self.ib_temperature addSubview:degreeCelsius];
    }
    
    if (self.selectedItemMenu == INDEX_TEMP && ![self.stringTemperature isEqualToString:TEMP_NULL])
    {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [self.view bringSubviewToFront:self.ib_temperature];
        [self.ib_temperature setHidden:NO];
    }
    else
    {
        [self.ib_temperature setHidden:YES];
    }
    
    [degreeCelsius release];
#endif
}

- (void)changeDegreeTemperatureType:(id )sender
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Temperature type"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isDegreeFDisplay]];
    
    _isDegreeFDisplay = !_isDegreeFDisplay;
    
    [self setTemperatureState_Fg:_stringTemperature];
}

#pragma mark - Melody

- (void)getMelodyState:(NSTimer *)timer
{
    if (self.melodyViewController.view.isHidden)
    {
        NSLog(@"%s Melody view is hidden. Invalidate timer.", __FUNCTION__);
        [timer invalidate];
    }
    else
    {
        [_melodyViewController performSelectorInBackground:@selector(getMelodyValue_bg)
                                                withObject:nil];
    }
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

#if 1
- (void)symmetric_check_result:(BOOL )isBehindSymmetricNat
{
    NSInteger result = (isBehindSymmetricNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"enable_stun"] == TRUE)
    {
        [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
        [userDefaults synchronize];
    }
    
    NSString *stringUDID = self.selectedChannel.profile.registrationID;
    
    self.timeStartingStageOne = [NSDate date];
    
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:@selector(createSessionSuccessWithResponse:)
                                                      FailSelector:@selector(createSessionFailedWithResponse:)
                                                         ServerErr:@selector(createSessionFailedServerUnreachable)];
    
    if (isBehindSymmetricNat == TRUE) // USE RELAY
    {
#ifdef SHOW_DEBUG_INFO
        _viewVideoIn = @"R";
#endif
        [_jsonComm createSessionWithRegistrationId:stringUDID
                                     andClientType:@"BROWSER"
                                         andApiKey:_apiKey];
        // --> call back.
    }
    else
    {
        //TODO: Using STUN mode, will be handled later.
    }
}
#else

-(void)symmetric_check_result: (BOOL) isBehindSymmetricNat
{
    NSInteger result = (isBehindSymmetricNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"enable_stun"] == TRUE)
    {
        [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
        [userDefaults synchronize];
    }
    
    dispatch_queue_t qt = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(qt,
                   ^{
                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                       NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                       //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
                       NSString *stringUDID = self.selectedChannel.profile.registrationID;
                       
                       NSDate *dateStage1 = [NSDate date];
                       
                       if (_jsonCommBlocked == nil)
                       {
                           self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                        Selector:nil
                                                                                    FailSelector:nil
                                                                                       ServerErr:nil];
                       }
                       
                       NSDictionary *responseDict;
                       //NSLog(@"%@", responseDict);
                       
                       
                       if (isBehindSymmetricNat == TRUE) // USE RELAY
                       {
#ifdef SHOW_DEBUG_INFO
                           _viewVideoIn = @"R";
#endif
                           self.shouldRestartProcessing = FALSE;
                           //responseDict = [jsonComm createSessionBlockedWithRegistrationId:mac
                           responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:stringUDID
                                                                                     andClientType:@"BROWSER"
                                                                                         andApiKey:apiKey];
                           self.shouldRestartProcessing = TRUE;
                           NSLog(@"USE RELAY TO VIEW- userWantsToCancel:%d, returnFromPlayback:%d, responsed: %@", userWantToCancel, _returnFromPlayback, responseDict);
                           
                           NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateStage1];
                           NSString *gaiActionTime = GAI_ACTION(1, diff);
                           
                           [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                           withAction:gaiActionTime
                                                                            withLabel:nil
                                                                            withValue:nil];
                           
                           NSLog(@"%s stage 1 takes %f seconds \n Start stage 2 \n %@", __FUNCTION__, diff, gaiActionTime);
                           self.timeStartingStageTwo = [NSDate date];
                           
                           if (!userWantToCancel && !_returnFromPlayback && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
                           {
                               if (responseDict != nil)
                               {
                                   if ([[responseDict objectForKey:@"status"] intValue] == 200)
                                   {
                                       NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                                       
                                       if ([urlResponse hasPrefix:ME_WOWZA] &&
                                           [userDefaults boolForKey:VIEW_NXCOMM_WOWZA] == TRUE)
                                       {
                                           self.selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                                       }
                                       else
                                       {
                                           self.selectedChannel.stream_url = urlResponse;
                                       }
                                       
                                       self.selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                                       
                                       NSLog(@"%s Start stage 2", __FUNCTION__);
                                       
                                       [self performSelectorOnMainThread:@selector(startStream)
                                                              withObject:nil
                                                           waitUntilDone:NO];
                                       
                                       self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"low_data_bandwidth_detected", nil, [NSBundle mainBundle], @"Low data bandwidth detected. Trying to connect...", nil);
                                   }
                                   else
                                   {
                                       //handle Bad response
                                       NSLog(@"%s ERROR: %@", __FUNCTION__, [responseDict objectForKey:@"message"]);
#if 1
                                       self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
                                       _isShowTextCameraIsNotAccesible = YES;
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self messageNotAccesible:NO];
                                       });
                                       
                                       [self symmetric_check_result:TRUE];
#else
                                       NSArray * args = [NSArray arrayWithObjects:
                                                         [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];
                                       //force server died
                                       [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                              withObject:args
                                                           waitUntilDone:NO];
#endif
                                   }
                               }
                               else
                               {
                                   NSLog(@"SERVER unreachable (timeout) ");
                                   self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
                                   _isShowTextCameraIsNotAccesible = YES;
#if 1
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self messageNotAccesible:NO];
                                       [self performSelector:@selector(setupCamera) withObject:nil afterDelay:10];
                                   });
#else
                                   NSArray * args = [NSArray arrayWithObjects:
                                                     [NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED],nil];
                                   
                                   
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self performSelector:@selector(handleMessageOnMainThread:) withObject:args afterDelay:10];
                                   });
#endif
                               }
                           }
                           else
                           {
                               NSLog(@"%s View is invisible OR in background mode. Do nothing!", __FUNCTION__);
                           }
                       }
                       else // USE RTSP/STUN
                       {
                           
                           //Set port1, port2
                           NSLog(@"TRY TO USE RTSP/STUN TO VIEW***********************");
#ifdef SHOW_DEBUG_INFO
                           _viewVideoIn = @"S";
#endif
                           if ([self.client create_stun_forwarder:self.selectedChannel] != 0 )
                           {
                               //TODO: Handle error
                           }
                           NSString * cmd_string = [NSString stringWithFormat:@"action=command&command=get_session_key&mode=p2p_stun_rtsp&port1=%d&port2=%d&ip=%@",
                                                    self.selectedChannel.local_stun_audio_port,
                                                    self.selectedChannel.local_stun_video_port,
                                                    self.selectedChannel.public_ip];
                           
                           responseDict =  [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
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
                                           [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                                        andCommand:cmd_string
                                                                                         andApiKey:apiKey];
                                           
                                           if (userWantToCancel == FALSE)
                                           {
                                               self.numberOfSTUNError = 0;
                                               
                                               //[self handleMessage:H264_SWITCHING_TO_RELAY_SERVER ext1:0 ext2:0];
                                               NSArray * args = [NSArray arrayWithObjects:
                                                                 [NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER],nil];
#ifdef SHOW_DEBUG_INFO
                                               _viewVideoIn = @"R";
#endif
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
#ifdef SHOW_DEBUG_INFO
                                               _viewVideoIn = @"S";
#endif
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
                                       [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                                    andCommand:cmd_string
                                                                                     andApiKey:apiKey];
                                       
                                       if (userWantToCancel == FALSE)
                                       {
#ifdef SHOW_DEBUG_INFO
                                           _viewVideoIn = @"R";
#endif
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
    dispatch_release(qt);
    
    if (isBehindSymmetricNat != TRUE)
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           NSString *bodyKey = @"";
                           
                           if (self.selectedChannel.profile.isInLocal )
                           {
                               [HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
                               [HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
                               
                               NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"get_resolution"];
                               
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
                               
                               if (_jsonCommBlocked == nil)
                               {
                                   self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                                Selector:nil
                                                                                            FailSelector:nil
                                                                                               ServerErr:nil];
                               }
                               
                               NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:stringUDID
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

#endif
- (void)remoteConnectingViaSymmectric
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                   ^{
                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                       NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                       //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
                       NSString *stringUDID = self.selectedChannel.profile.registrationID;
                       
                       if (_jsonCommBlocked == nil)
                       {
                           BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                 Selector:nil
                                                             FailSelector:nil
                                                                ServerErr:nil];
                           self.jsonCommBlocked = comm;
                           [comm release];
                       }
                       
                       NSDictionary *responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:stringUDID
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
            //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView V directional change" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:@"V directional change"
                                                             withLabel:@"Direction pad"
                                                             withValue:nil];
            
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
            //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
            //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
            
            //Non block send-
            NSLog(@"device_ip: %@, device_port: %d", _selectedChannel.profile.ip_address, _selectedChannel.profile.port);
            
            [[HttpCom instance].comWithDevice sendCommand:dir_str];
		}
		else if(_selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            //NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            if (_jsonCommBlocked == nil)
            {
                BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                      Selector:nil
                                                  FailSelector:nil
                                                     ServerErr:nil];
                self.jsonCommBlocked = comm;
                [comm release];
            }
            
            NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                     andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                                      andApiKey:apiKey];
            NSLog(@"send_UD_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void)h_directional_change_callback:(NSTimer *) timer_exp
{
    //BOOL need_to_send = FALSE;
    
    @synchronized(_imgViewDrectionPad)
	{
		if ( lastDirLR != DIRECTION_H_NON)
        {
			//need_to_send = TRUE;
            //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView H directional change" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:@"H directional change"
                                                             withLabel:@"Direction pad"
                                                             withValue:nil];
            
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
            //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
            //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
            //Non block send-
            [[HttpCom instance].comWithDevice sendCommand:dir_str];
		}
		else if ( _selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            //NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            if (_jsonCommBlocked == nil)
            {
                BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                      Selector:nil
                                                  FailSelector:nil
                                                     ServerErr:nil];
                self.jsonCommBlocked = comm;
                [comm release];
            }
            
            NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else if (translation.y <0)
		{
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
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
            
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else if (translation.x < 0){
            
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
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

#pragma mark - HelpWindowPopupDelegate
- (void)willDismiss:(id)sender
{
    self.helpPopup = nil;
}

#pragma mark - Rotation screen
- (BOOL)shouldAutorotate
{
    
    if (userWantToCancel == TRUE ||
        _earlierNavi.isEarlierView)
    {
        return NO;
    }
    
	//return YES;//
    return !_disableAutorotateFlag;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (_earlierNavi.isEarlierView)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView - will rotate interface" withProperties:nil];
    if (self.helpPopup != nil)
    {
        [self.helpPopup dismiss];
    }
    
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"View will rotate interface"
                                                     withLabel:nil
                                                     withValue:nil];
    
    if (_earlierNavi.isEarlierView) //don't call adjustViews for Earlier
    {
        return;
    }
    else
    {
        [self adjustViewsForOrientation:toInterfaceOrientation];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self applyFont];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGRect rect = self.ib_lbCameraNotAccessible.frame;
        rect.origin.x = (self.scrollView.frame.size.width - rect.size.width) / 2;
        rect.origin.y = (self.scrollView.frame.size.height - rect.size.height) / 2 + 55;
        self.ib_lbCameraNotAccessible.frame = rect;
        self.ib_openHelpButton.frame = rect;
    }
}

-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_isProcessRecording)
    {
        _syncPortraitAndLandscape = YES;
    }
    else
    {
        _syncPortraitAndLandscape = NO;
    }
    
    [self resetZooming];
#if 0
    NSInteger deltaY = 0;
    
    if (isiOS7AndAbove)
    {
        deltaY = HIGH_STATUS_BAR;
    }
#endif
    
    // Remove all subviews before reloading the xib
#if 1
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
#endif
    
	if (UIInterfaceOrientationIsLandscape(orientation))
	{
        _isLandScapeMode = YES;
        //load new nib for landscape iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            MelodyViewController *melodyVC = [[MelodyViewController alloc] initWithNibName:@"MelodyViewController_land" bundle:nil andSelectedChannel:self.selectedChannel];
            if (self.melodyViewController)
            {
                [melodyVC setCurrentMelodyIndex:self.melodyViewController.melodyIndex andPlaying:self.melodyViewController.playing];
            }
            
            [self release];
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land_iPad"
                                          owner:self
                                        options:nil];
            self.melodyViewController = melodyVC;
            self.melodyViewController.melodyDelegate = self;
            [melodyVC release];
            
            [_earlierVC.view setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        }
        else
        {
            MelodyViewController *melodyVC = [[MelodyViewController alloc] initWithNibName:@"MelodyViewController_land" bundle:nil andSelectedChannel:self.selectedChannel];
            if (self.melodyViewController)
            {
                [melodyVC setCurrentMelodyIndex:self.melodyViewController.melodyIndex andPlaying:self.melodyViewController.playing];
            }
            
            [self release];
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
                                          owner:self
                                        options:nil];
            self.melodyViewController = melodyVC;
            self.melodyViewController.melodyDelegate = self;
            [melodyVC release];
#if 0
            if (isiOS7AndAbove)
            {
                self.melodyViewController.view.frame = CGRectMake(393, 78, 175, 165);
            }
            else
            {
                self.melodyViewController.view.frame = CGRectMake(320, 60, 159, 204);
            }
#endif
        }
        //landscape mode
        //hide navigation bar
        [self.navigationController setNavigationBarHidden:YES];
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        if (_isAlreadyHorizeMenu)
        {
            [self.horizMenu reloadData:YES];
        }
        
        
        CGFloat imageViewHeight = SCREEN_HEIGHT * 9 / 16;
        CGRect newRect = CGRectMake(0, (SCREEN_WIDTH - imageViewHeight) / 2, SCREEN_HEIGHT, imageViewHeight);
        self.imageViewVideo.frame = CGRectMake(0, 0, SCREEN_HEIGHT, imageViewHeight);
        self.scrollView.frame = newRect;
        
        if (_timelineVC != nil)
        {
            [self.timelineVC.view removeFromSuperview];
        }
        
        [self addGesturesPichInAndOut];
	}
	else
	{
        //load new nib
        //remove pinch in, out (zoom for portrait)
        [self removeGestureRecognizerAtPortraitMode];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            MelodyViewController *melodyVC = [[MelodyViewController alloc] initWithNibName:@"MelodyViewController_iPad" bundle:nil andSelectedChannel:self.selectedChannel];
            if (self.melodyViewController)
            {
                [melodyVC setCurrentMelodyIndex:self.melodyViewController.melodyIndex andPlaying:self.melodyViewController.playing];
            }
            
            [self release];
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_ipad"
                                          owner:self
                                        options:nil];
            self.melodyViewController = melodyVC;
            self.melodyViewController.melodyDelegate = self;
            [melodyVC release];
            
            [_earlierVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        }
        else
        {
            MelodyViewController *melodyVC = [[MelodyViewController alloc] initWithNibName:@"MelodyViewController" bundle:nil andSelectedChannel:self.selectedChannel];
            if (self.melodyViewController)
            {
                [melodyVC setCurrentMelodyIndex:self.melodyViewController.melodyIndex andPlaying:self.melodyViewController.playing];
            }
            
            //[self release];
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
                                          owner:self
                                        options:nil];
            self.melodyViewController = melodyVC;
            self.melodyViewController.melodyDelegate = self;
            [melodyVC release];
        }
        //portrait mode
        
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.view.backgroundColor = [UIColor whiteColor];
        
        if (_isAlreadyHorizeMenu)
        {
            [self.horizMenu reloadData:NO];
        }
        
#if 1
        CGFloat alignYTimeLine = self.ib_ViewTouchToTalk.frame.origin.y;
        
        self.melodyViewController.view.frame = CGRectMake(0, alignYTimeLine - 5, SCREEN_WIDTH, SCREEN_HEIGHT - alignYTimeLine);
        
        // Control display for TimelineVC
        
        if (_timelineVC != nil)
        {
            CGFloat actualScreenHigh = SCREEN_HEIGHT;
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && (actualScreenHigh == 320 || actualScreenHigh == 768)) {
                actualScreenHigh = SCREEN_WIDTH;
            }
            
            CGRect rect = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, actualScreenHigh - alignYTimeLine);
            
            if (isiPhone4) // This condition check size of screen. Not iPhone4 or other
            {
                rect = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, actualScreenHigh - alignYTimeLine + 64);
            }
            else
            {
                // Default
                //rect = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - alignYTimeLine);
            }
            
            self.timelineVC.view.frame = rect;
            
            _timelineVC.tableView.contentSize = CGSizeMake(SCREEN_WIDTH, _timelineVC.tableView.frame.size.height);
            //don't show timeline after switch from land to port
            self.timelineVC.view.hidden = NO;
            [self.view addSubview:_timelineVC.view];
            
            if (_isLandScapeMode)
            {
                if (isiPhone4 || isiPhone5)
                {
                    //iPhone
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 275, 0);
                }
                else
                {
                    //iPad
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
                }
                
            }
            else
            {
                self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
            }
        }
#else
        CGFloat imageViewHeight = SCREEN_WIDTH * 9 / 16;
        
        if (isiOS7AndAbove)
        {
            //CGRect destRect = CGRectMake(0, 44 + deltaY, SCREEN_WIDTH, imageViewHeight);
            //self.scrollView.frame = destRect;
            //self.imageViewVideo.frame = CGRectMake(0, 0, SCREEN_WIDTH, imageViewHeight);
            self.melodyViewController.view.frame = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
            
            // Control display for TimelineVC
            
            if (_timelineVC != nil)
            {
                CGFloat alignYTimeLine = self.ib_ViewTouchToTalk.frame.origin.y;
                
                if (isiPhone4) // This condition check size of screen. Not iPhone4 or other
                {
                    CGRect rect = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y + 64);
                    self.timelineVC.view.frame = rect;
                }
                else
                {
                    CGRect rect = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                    self.timelineVC.view.frame = rect;
                }
                
                _timelineVC.tableView.contentSize = CGSizeMake(SCREEN_WIDTH, _timelineVC.tableView.frame.size.height);
                //don't show timeline after switch from land to port
                self.timelineVC.view.hidden = NO;
                [self.view addSubview:_timelineVC.view];
                if (_isLandScapeMode)
                {
                    if (isiPhone4 || isiPhone5)
                    {
                        //iPhone
                        self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 275, 0);
                    }
                    else
                    {
                        //iPad
                        self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
                    }
                    
                }
                else
                {
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
                }
            }
        }
        else
        {
            CGRect destRect = CGRectMake(0, deltaY, SCREEN_WIDTH, imageViewHeight);
            self.scrollView.frame = destRect;
            self.imageViewVideo.frame = CGRectMake(0, -44, SCREEN_WIDTH, imageViewHeight);
            self.melodyViewController.view.frame = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 30 - 44, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
            
            
            // Control display for TimelineVC
            if (_timelineVC != nil)
            {
                CGFloat alignYTimeLine = self.ib_ViewTouchToTalk.frame.origin.y - 64;
                
                if (_isLandScapeMode)
                {
                    self.timelineVC.view.frame = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - alignYTimeLine);
                    self.timelineVC.view.hidden = NO;
                    [self.view addSubview:_timelineVC.view];
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 250, 0);
                }
                else
                {
                    self.timelineVC.view.frame = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - alignYTimeLine);
                    self.timelineVC.view.hidden = NO;
                    [self.view addSubview:_timelineVC.view];
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
        }
#endif
        //[self showControlMenu];
        //add hubble_logo_back
        //[self addHubbleLogo_Back];
        _isLandScapeMode = NO;
        
	}// end of portrait
    
#if 0
    [self.melodyViewController.melodyTableView setNeedsLayout];
    [self.melodyViewController.melodyTableView setNeedsDisplay];
#endif
    
    self.imageViewStreamer.frame = _imageViewVideo.frame;
    [self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
    [self setTemperatureState_Fg:_stringTemperature];
    
    self.customIndicator.animationImages =[NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"loader_a"],
                                           [UIImage imageNamed:@"loader_b"],
                                           [UIImage imageNamed:@"loader_c"],
                                           [UIImage imageNamed:@"loader_d"],
                                           [UIImage imageNamed:@"loader_e"],
                                           [UIImage imageNamed:@"loader_f"],
                                           nil];


    self.customIndicator.hidden = YES;
    [self displayCustomIndicator];
    
    //trigger re-cal of videosize
    if (MediaPlayer::Instance()->isPlaying())
    {
        _isShowCustomIndicator = NO;
    }
    
    if (_currentMediaStatus != 0)
    {
        MediaPlayer::Instance()->videoSizeChanged();
    }
    
    [self setupPtt];
    [self applyFont];
    [self hidenAllBottomView];
    
#if 0
    [self hideControlMenu];
    [self updateBottomView];
    
    //Earlier must at bottom of land, and port
    if (_isFirstLoad || _wantToShowTimeLine || _selectedItemMenu == -1)
    {
        [self showTimelineView];
    }
    else
    {
        [self hideTimelineView];
    }
#endif
    
    if(_selectedItemMenu != -1){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            /*
             * Maintain selected item in horize menu.
             */
            
            int selectedItem = _selectedItemMenu;
            
            if ([_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
            {
                selectedItem--;
            }
            else if ([_cameraModel isEqualToString:CP_MODEL_0073])
            {
                if (selectedItem == INDEX_RECORDING)
                {
                    selectedItem = 1;
                }
            }
            
            NSLog(@"%s selectedItem:%d", __FUNCTION__, _selectedItemMenu);
            
            [self.horizMenu setSelectedIndex:selectedItem animated:NO];
        });
        
        [self hideTimelineView];
    }
    else if (_isFirstLoad || _wantToShowTimeLine)
    {
        [self showTimelineView];
    }
    
    self.ib_buttonTouchToTalk.enabled = _enablePTT;
    self.ib_labelTouchToTalk.text = _stringStatePTT;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugOpt"] == YES)
    {
        self.btnSendingLog.enabled = YES;
        self.ib_btShowDebugInfo.enabled = YES;
    }
    
    [self.viewTemperature addGestureRecognizer:_tapGestureTemperature];
}


#pragma mark -
#pragma mark Scan cameras

- (void) scan_for_missing_camera
{
    self.scanAgain = TRUE;
    
    if (userWantToCancel == TRUE)
    {
        return;
    }
    
    NSLog(@"scanning for : %@", self.selectedChannel.profile.mac_address);
    
	scanner = [[ScanForCamera alloc] initWithNotifier:self];
	[scanner scan_for_device:self.selectedChannel.profile.mac_address];
    
}

- (void)scan_done:(NSArray *)_scan_results
{
    // Scan for Local camera if it is disconnected
    if (_scanAgain == TRUE)
    {
        BOOL found = FALSE;
        
        if (_scan_results.count > 0)
        {
            //confirm the mac address
            CamProfile * cp = self.selectedChannel.profile;
            
            for (int j = 0; j < [_scan_results count]; j++)
            {
                CamProfile * cp1 = (CamProfile *) [_scan_results objectAtIndex:j];
                
                if ( [cp.mac_address isEqualToString:cp1.mac_address])
                {
                    //FOUND - copy ip address.
                    cp.ip_address = cp1.ip_address;
                    cp.isInLocal  = TRUE;
                    cp.port       = cp1.port;
                    found = TRUE;
                    break;
                }
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
    else // This is scan for camera when -becomeActive
    {
        BOOL found = FALSE;
        
        self.selectedChannel.profile.isInLocal  = NO;
        
        if (_scan_results.count > 0)
        {
            //confirm the mac address
            CamProfile * cp = self.selectedChannel.profile;
            
            for (int j = 0; j < [_scan_results count]; j++)
            {
                CamProfile * cp1 = (CamProfile *) [_scan_results objectAtIndex:j];
                
                if ( [cp.mac_address isEqualToString:cp1.mac_address])
                {
                    //FOUND - copy ip address.
                    cp.ip_address = cp1.ip_address;
                    cp.isInLocal  = TRUE;
                    cp.port       = cp1.port;
                    found         = TRUE;
                    break;
                }
            }
        }
        
        NSLog(@"Scan done with ipserver");
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];

        while (_threadBonjour != nil &&
               [_threadBonjour isExecuting] )
        {
            if ([self isStopProcess] ||
                [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
            {
                [_threadBonjour cancel];
                
                return;
            }
            else
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
            }
        }
        
        NSLog(@"\nH264=================================\nSCAN DONE - IPSERVER SYNC BONJOUR\nCamProfile: %@\nbonjourList: %@\n=================================\n", self.selectedChannel.profile, _bonjourList);
        
        if(_bonjourList && _bonjourList.count > 0 &&
           found == FALSE) // If Cameara is NOT found on ip-sever
        {
            for (CamProfile * cam in _bonjourList)
            {
                if ([self.selectedChannel.profile.mac_address isEqualToString:cam.mac_address])
                {
                    NSLog(@"H264 Camera is on Bonjour -mac: %@, -port: %d", self.selectedChannel.profile.mac_address, cam.port);
                    
                    self.selectedChannel.profile.ip_address = cam.ip_address;
                    self.selectedChannel.profile.isInLocal  = YES;
                    self.selectedChannel.profile.port       = cam.port;
                    found                                   = TRUE;
                    
                    break;
                }
            }
        }
        
        [_bonjourList release];
        _bonjourList = nil;
        
        
        self.selectedChannel.profile.hasUpdateLocalStatus = YES;
        
        if (![self isStopProcess])
        {
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
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView dismiss alert: %d with btn index: %d", tag, buttonIndex] withProperties:nil];

    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Dismiss alert: %d", alertView.tag]
                                                     withLabel:[NSString stringWithFormat:@"Alert %@", alertView.title]
                                                     withValue:[NSNumber numberWithInteger:buttonIndex]];
    switch (alertView.tag)
    {
        case TAG_ALERT_VIEW_REMOTE_TIME_OUT:
        {
            switch (buttonIndex)
            {
                case 0: // View other camera
                    self.view.userInteractionEnabled = NO;
                    
                    //stop stream
                    if (_timerStopStreamAfter30s && [_timerStopStreamAfter30s isValid])
                    {
                        //stop time, avoid stopStream 2 times
                        [_timerStopStreamAfter30s invalidate];
                        _timerStopStreamAfter30s = nil;
                        [self stopStream];
                    }
                    
                    [self goBackToCamerasRemoteStreamTimeOut];
                    break;
                    
                case 1: // Continue view --> restart stream
                    
                    if (_timerStopStreamAfter30s == nil)
                    {
                        //already stop stream, call setup again.
                        [self setupCamera];
                    }
                    else
                    {
                        if (_timerStopStreamAfter30s && [_timerStopStreamAfter30s isValid])
                        {
                            //stop time, avoid stopStream 2 times
                            [_timerStopStreamAfter30s invalidate];
                            _timerStopStreamAfter30s = nil;
                        }
                        //do nothing, just dissmiss because still stream.
                        //create new timer to display info after 4m30s.
                        [self reCreateTimoutViewCamera];
                    }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case TAG_ALERT_SENDING_LOG:
        {
            switch (buttonIndex)
            {
                case 1: // Yes
                    if ([[alertView textFieldAtIndex:0].text isEqualToString:SENDING_CAMERA_LOG_PASSWORD])
                    {
                        [self performSelectorInBackground:@selector(sendRequestLogCmdToCamera) withObject:nil];
                    }
                    else// Like Cancel
                    {
                        NSLog(@"%s wrong password!", __FUNCTION__);
                    }
                    break;
                case 0:
                default:
                    // Do nothing
                    break;
            }
        }
            break;
            
        case TAG_ALERT_FW_OTA_UPGRADE_AVAILABLE:
        {
            switch (buttonIndex)
            {
                case 1: // Yes
                {
                    dispatch_queue_t qt = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(qt,^{
                        
                        NSString *response = nil;
                        BMS_JSON_Communication * jsoncomm = [[[BMS_JSON_Communication alloc]initWithObject:self
                                                                                                 Selector:nil
                                                                                             FailSelector:nil
                                                                                                ServerErr:nil]autorelease];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        
                        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                        
                        
                        if (self.selectedChannel.profile.isInLocal == TRUE)
                        {
                            response = [[HttpCom instance].comWithDevice sendCommandAndBlock: REQUEST_FW_UPGRADE];
                        }
                        else
                        {
                            NSDictionary * responseDict = [jsoncomm sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                              andCommand:[NSString stringWithFormat:@"action=command&command=%@",REQUEST_FW_UPGRADE]
                                                                                               andApiKey:apiKey];
                            
                            if (responseDict != nil)
                            {
                                NSInteger status = [[responseDict objectForKey:@"status"] intValue];
                                if (status == 200)
                                {
                                    response = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
                                }
                            }
                            
                        }
                        
                        
                        
                        NSLog(@"%s response:%@", __FUNCTION__, response);
                        
                        if ([response isEqualToString:@"request_fw_upgrade: 0"])
                        {
                            
                            dispatch_async(dispatch_get_main_queue(),^{
                                MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                                [hub setLabelText:@"Checking Fw upgrade..."];
                                self.isFWUpgradingInProgress = YES; // Entering bg control
                                self.fwUpgradedProgress = 0;
                                self.fwUpgradeStatus = FIRMWARE_UPGRADE_IN_PROGRESS;
                                [self createHubbleAlertView];
                                
                                NSLog(@"%s Start upgrading to %@", __FUNCTION__,_fwUpgrading );

                                [self stopMediaProcessGoBack:NO backgroundMode:NO];

                            }); //dispatch_async
                            
                        }
                        else
                        {
                            NSLog(@"%s Cannot upgrade Fw now.", __FUNCTION__);
                        }
                    }); // dispatch_async
                }
                    
                                   
                    
                    break;
                    
                case 0:
                default:
                    break;
            }
        }
            break;
            
        case TAG_ALERT_FW_OTA_UPGRADE_FAILED:
        {
            [self prepareGoBackToCameraList:self.navigationItem.leftBarButtonItem];
        }
            break;
        case TAG_ALERT_FW_OTA_UPGRADE_DONE:
        {
            
            [self performSelectorOnMainThread:@selector(scanCamera)
                                   withObject:nil
                                waitUntilDone:NO];
            break;
        }
        default:
            break;
    }
    
    alertView.delegate = nil;
    


}

- (void)sendRequestLogCmdToCamera_bg
{
    [self sendRequestLogCmdToCamera];
}

- (void)sendRequestLogCmdToCamera
{
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    BOOL sendFailed = TRUE;
    
    NSDictionary *dictResponse = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                             andCommand:@"action=command&command=request_log"
                                                                              andApiKey:self.apiKey];
    if (dictResponse)
    {
        if ([[dictResponse objectForKey:@"status"] integerValue] == 200)
        {
            if ([[[[dictResponse objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"device_response_code"] integerValue] == 200)
            {
                sendFailed = FALSE;
            }
        }
    }
    
    if (sendFailed)
    {
        NSLog(@"%s FAILED!", __FUNCTION__);
    }
    else
    {
        NSLog(@"%s SUCCEEDED!", __FUNCTION__);
    }
}

#pragma mark -
#pragma mark Beeping

-(void)periodicBeep:(NSTimer*) exp
{
    if (userWantToCancel == TRUE)
    {
        [self stopPeriodicBeep];
    }
    else
    {
        [self playSound];
    }
}

-(void) stopPeriodicBeep
{
	if (self.alertTimer != nil)
	{
		if ([self.alertTimer isValid])
		{
			[self.alertTimer invalidate];
            self.alertTimer = nil;
		}
	}
}


-(void) periodicPopup:(NSTimer *) exp
{
	[self playSound];
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
}
-(void) playSound
{
    NSLog(@"%s", __FUNCTION__);
    
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
    
    NSLog(@"H264VC - centerScrollViewContents -imageVideo: %@, imageStreamer: %@", NSStringFromCGRect(_imageViewVideo.frame), NSStringFromCGRect(_imageViewStreamer.frame));
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    NSLog(@"double tap scrollViewDoubleTapped");
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
    NSLog(@"Two finger tap scrollViewTwoFingerTapped");
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

#pragma mark - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    //return self.imageViewVideo;
    return self.imageViewStreamer;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}


#pragma mark -
#pragma mark HorizMenu Data Source

- (void)initHorizeMenu:(NSString *)camerModel
{
    self.isAlreadyHorizeMenu = TRUE;
    /*
     //create list image for display horizontal scroll view menu
     1.Pan, Tilt & Zoom (bb_setting_icon.png)
     2.Microphone (for two way audio) bb_setting_icon.png
     3.Take a photo/Record Video ( bb_rec_icon_d.png )
     4.Lullaby          bb_melody_off_icon.png
     5.Camera List          bb_camera_slider_icon
     6.Temperature display        temp_alert
     */
    
    if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM])
    {
        //query command to check shared cam is connected to mac or window
        [self queryToKnowSharedCamOnMacOSOrWin];
        if ([_sharedCamConnectedTo isEqualToString:@"MACOS"])
        {
            self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_photo", @"video_action_temp", nil];
            self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_photo_pressed", @"video_action_temp_pressed", nil];
        }
        else
        {
            self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan", @"video_action_photo", @"video_action_music", @"video_action_temp", nil];
            self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed", @"video_action_photo_pressed", @"video_action_music_pressed", @"video_action_temp_pressed", nil];
        }
    }
    else if ([_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
    {
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_mic", @"video_action_photo", @"video_action_music", @"video_action_temp", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_mic_pressed", @"video_action_photo_pressed", @"video_action_music_pressed", @"video_action_temp_pressed", nil];
    }
    else if ([_cameraModel isEqualToString:CP_MODEL_0073])
    {
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan", @"video_action_photo", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed", @"video_action_photo_pressed", nil];
    }
    else //if ([_cameraModel isEqualToString:CP_MODEL_BLE])
    {
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan", @"video_action_mic", @"video_action_photo", @"video_action_music", @"video_action_temp", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed", @"video_action_mic_pressed", @"video_action_photo_pressed", @"video_action_music_pressed", @"video_action_temp_pressed", nil];
    }
    

    dispatch_async(dispatch_get_main_queue(), ^{
        [self horizMenuReloadData];
    });

}

- (void)horizMenuReloadData
{
    [self.horizMenu reloadData:NO];
}

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
    
    //show when user selecte one item inner control panel
    [self showControlMenu];
    
    _wantToShowTimeLine = NO;
    _isFirstLoad = NO;
    
    if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM])
    {
        if ([_sharedCamConnectedTo isEqualToString:@"MACOS"])
        {
            if (index == 0)
            {
                self.selectedItemMenu = INDEX_RECORDING;
            }
            else if (index == 1)
            {
                self.selectedItemMenu = INDEX_TEMP;
            }
            else
            {
                //do nothing
            }
        }
        else
        {
            switch (index)
            {
                case INDEX_PAN_TILT:
                    self.selectedItemMenu = INDEX_PAN_TILT;
                    break;
                    
                case 1:
                    self.selectedItemMenu = INDEX_RECORDING;
                    break;
                    
                case 2:
                    self.selectedItemMenu = INDEX_MELODY;
                    [self melodyTouchAction:nil];
                    break;
                    
                case 3:
                    self.selectedItemMenu = INDEX_TEMP;
                    break;
                    
                default:
                    break;
            }
        }
    }
    else if ([_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
    {
        switch (index)
        {
            case 0:
                self.selectedItemMenu = INDEX_MICRO;
                break;
                
            case 1:
                self.selectedItemMenu = INDEX_RECORDING;
                break;
                
            case 2:
                self.selectedItemMenu = INDEX_MELODY;
                [self melodyTouchAction:nil];
                break;
                
            case 3:
                self.selectedItemMenu = INDEX_TEMP;
                break;
                
            default:
                break;
        }
    }
    else if ([_cameraModel isEqualToString:CP_MODEL_0073])
    {
        switch (index)
        {
            case INDEX_PAN_TILT:
                self.selectedItemMenu = INDEX_PAN_TILT;
                break;
                
            case 1:
                self.selectedItemMenu = INDEX_RECORDING;
                break;
                
            default:
                NSLog(@"Action out of bound");
                break;
        }
    }
    else// if ([_cameraModel isEqualToString:CP_MODEL_BLE])
    {
        switch (index)
        {
            case INDEX_PAN_TILT:
                self.selectedItemMenu = INDEX_PAN_TILT;
                break;
                
            case INDEX_MICRO:
                self.selectedItemMenu = INDEX_MICRO;
                [self recordingPressAction:nil];
                break;
                
            case INDEX_RECORDING:
                self.selectedItemMenu = INDEX_RECORDING;
                break;
                
            case INDEX_MELODY:
                self.selectedItemMenu = INDEX_MELODY;
                [self melodyTouchAction:nil];
                break;
                
            case INDEX_TEMP:
                self.selectedItemMenu = INDEX_TEMP;
                break;
                
            default:
                NSLog(@"Action out of bound");
                break;
        }
    }
    
    [self hideTimelineView];
    [self updateBottomView];
    [self applyFont];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView select item on horize menu - idx: %d", _selectedItemMenu] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Select item on horize menu"
                                                     withLabel:@"Item"
                                                     withValue:[NSNumber numberWithInt:_selectedItemMenu]];
}

- (void)updateBottomView
{
    [self hidenAllBottomView];
    
    if (_wantToShowTimeLine || self.horizMenu.isAllButtonDeselected)
    {
        [self showTimelineView];
    }
    else
    {
        if (_selectedItemMenu == INDEX_PAN_TILT)
        {
            [self.view bringSubviewToFront:_imgViewDrectionPad];
            [self.view bringSubviewToFront:_imageViewKnob];
            [self.view bringSubviewToFront:_imageViewHandle];
            [self.imgViewDrectionPad setHidden:NO];
            self.imageViewKnob.hidden = NO;
            self.imageViewKnob.center = _imgViewDrectionPad.center;
            self.imageViewHandle.center = _imgViewDrectionPad.center;
        }
        else if (_selectedItemMenu == INDEX_MICRO)
        {
            [self.view bringSubviewToFront:self.ib_ViewTouchToTalk];
            [self.ib_ViewTouchToTalk setHidden:NO];
        }
        else if (_selectedItemMenu == INDEX_RECORDING)
        {
            [self.view bringSubviewToFront:self.ib_viewRecordTTT];
            [self.ib_viewRecordTTT setHidden:NO];
#if 0 // Enable it later.
            //check if is share cam, up UI
            if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM] ||
                [_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
#endif
            {
                _isRecordInterface = YES;
                [self changeAction:nil];
                [self.ib_buttonChangeAction setHidden:YES];
            }
        }
        else if (_selectedItemMenu == INDEX_MELODY)
        {
            [self.melodyViewController.view setHidden:NO];
            
            CGRect rect;
            
            if (_isLandScapeMode)
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                        rect = CGRectMake(SCREEN_WIDTH - 236, SCREEN_HEIGHT - 400, 236, 175);
                    }
                    else
                    {
                        rect = CGRectMake(SCREEN_HEIGHT - 236, SCREEN_WIDTH - 400, 236, 175);
                    }
                }
                else
                {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                        rect = CGRectMake(SCREEN_WIDTH - 159, 65, 159, 204);
                    }
                    else
                    {
                        rect = CGRectMake(SCREEN_HEIGHT - 159, 65, 159, 204);
                    }
                }
            }
            else
            {
#if 1
                rect = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
#else
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    rect = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
                else
                {
                    rect = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 30 - 44, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
                
                //NSLog(@"%s rect:%@, SCREEN_HEIGHT:%f, SCREEN_WIDTH:%f", __FUNCTION__, NSStringFromCGRect(rect), SCREEN_HEIGHT, SCREEN_WIDTH);
#endif
            }
            
            self.melodyViewController.view.frame = rect;
            
            /*
             TODO:need get status of laluby and update on UI.
             when landscape or portrait display correctly
             */
            //[self performSelectorInBackground:@selector(getMelodyValue_bg) withObject:nil];
            
            if (_timerCheckMelodyState) {
                [_timerCheckMelodyState invalidate];
            }
            
            self.timerCheckMelodyState = [NSTimer scheduledTimerWithTimeInterval:5
                                                                          target:self
                                                                        selector:@selector(getMelodyState:)
                                                                        userInfo:nil
                                                                         repeats:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_melodyViewController performSelectorInBackground:@selector(getMelodyValue_bg)
                                                        withObject:nil];
            });
        }
        else if (_selectedItemMenu == INDEX_TEMP)
        {
            if ([self.stringTemperature isEqualToString:TEMP_NULL])
            {
                NSLog(@"%s Show progress.", __FUNCTION__);
                MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                [hub setLabelText:NSLocalizedStringWithDefaultValue(@"loading", nil, [NSBundle mainBundle], @"Loading...", nil)];
            }
#if 1
            self.viewTemperature.hidden = NO;
            [self.view bringSubviewToFront:_viewTemperature];
#else
            [ib_switchDegree setHidden:NO];
            [self.view bringSubviewToFront:ib_switchDegree];
#endif
            
            [self setTemperatureState_Fg:_stringTemperature];
            
            if (_existTimerTemperature == FALSE)
            {
                self.existTimerTemperature = TRUE;
                NSLog(@"Log - Create Timer to get Temperature");
                //should call it first and then update later
                [NSTimer scheduledTimerWithTimeInterval:10
                                                 target:self
                                               selector:@selector(getCameraTemperature_bg:)
                                               userInfo:nil
                                                repeats:YES];
            }
        }
        else
        {
            //first hide all bottom view
            //[self hidenAllBottomView];
            //and then display time line
            [self showTimelineView];
        }
    }
    
    [self stopTalkbackUnexpected];
}

- (void)hidenAllBottomView
{
    [self.imgViewDrectionPad setHidden:YES];
    self.imageViewKnob.hidden = YES;
    self.imageViewHandle.hidden = YES;
#if 1
    self.viewTemperature.hidden = YES;
#else
    [self.ib_temperature setHidden:YES];
    [self.ib_temperature setBackgroundColor:[UIColor clearColor]];
#endif
    
    [self.ib_ViewTouchToTalk setHidden:YES];
    [self.ib_ViewTouchToTalk setBackgroundColor:[UIColor clearColor]];
    
    [self.ib_viewRecordTTT setHidden:YES];
    [self.ib_viewRecordTTT setBackgroundColor:[UIColor clearColor]];
    [self.melodyViewController.view setHidden:YES];
}

#pragma mark - Memory Release

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if (MediaPlayer::Instance()->isPlaying() &&
        self.isViewLoaded                    &&
        self.view.window)
    {
        NSLog(@"%s Send interrupt.", __FUNCTION__);
        MediaPlayer::Instance()->sendInterrupt();
    }
    else
    {
        NSLog(@"%s View is invisible. Ignoring.", __FUNCTION__);
    }
}

- (void)dealloc {
    [_imageViewVideo release];
    [_imageViewStreamer release];
    [_imgViewDrectionPad release];
    [send_UD_dir_req_timer invalidate];
    [send_LR_dir_req_timer invalidate];
    [_activityIndicator release];
    [_activityStopStreamingProgress release];
    [_probeTimer release];
    
    [_scrollView release];
    [_ib_temperature release];
    [_ib_ViewTouchToTalk release];
    
    [_ib_labelTouchToTalk release];
    [_ib_viewRecordTTT release];
    [_ib_labelRecordVideo release];
    [_ib_buttonTouchToTalk release];
    [_ib_processRecordOrTakePicture release];
    [_ib_buttonChangeAction release];
    
    [_timelineVC release];
    [_earlierVC release];
    
    [_imageViewHandle release];
    [_imageViewKnob release];
    [_ib_changeToMainRecording release];
    [ib_switchDegree release];
    [_customIndicator release];
    [_ib_lbCameraNotAccessible release];
    [_ib_lbCameraName release];
    [_ib_btShowDebugInfo release];
    [_audioOutStreamRemote release];
    [_jsonCommBlocked release];
    [_viewDebugInfo release];
    [_alertViewTimoutRemote release];
    [_melodyViewController release];
    [_alertFWUpgrading release];
    [_audioOut release];
    [_userAccount release];
    [_timerCheckMelodyState release];
    
    NSLog(@"%s", __FUNCTION__);
    
    [_btnSendingLog release];
    [_viewTemperature release];
    [_tapGestureTemperature release];
    [super dealloc];
}


#pragma  mark -
#pragma mark PTT

- (void)cleanup
{
    [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                           withObject:@"0"];
    
    self.audioOut = nil;
    self.walkieTalkieEnabled = NO;
}

-(void) setupPtt
{
    [self.ib_buttonTouchToTalk addTarget:self action:@selector(ib_buttonTouchToTalkTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

- (void)ib_buttonTouchToTalkTouchUpInside
{
    self.walkieTalkieEnabled = !self.walkieTalkieEnabled;
    self.enablePTT = NO;
    _ib_buttonTouchToTalk.enabled = NO;
    self.stringStatePTT = @"Processing...";
    _ib_labelTouchToTalk.text = NSLocalizedStringWithDefaultValue(@"text_processing", nil, [NSBundle mainBundle], @"Processing...", nil);
    
    if (self.selectedChannel.profile.isInLocal)
    {
        [self enableLocalPTT:_walkieTalkieEnabled];
    }
    else
    {
        [self performSelectorInBackground:@selector(enableRemotePTT:)
                               withObject:[NSNumber numberWithBool:self.walkieTalkieEnabled]];
    }
}

- (void)stopTalkbackUnexpected
{
    if (_walkieTalkieEnabled)
    {
        // Stop talkback if it is enabled
        
        [self showToat:NSLocalizedStringWithDefaultValue(@"stop_talking_toat", nil, [NSBundle mainBundle], @"Talkback disabled", nil)];
        
        //self.walkieTalkieEnabled = !_walkieTalkieEnabled;
        [self ib_buttonTouchToTalkTouchUpInside];
    }
}

- (void)showToat:(NSString *)text {
    UILabel *labelCrazy = [[UILabel alloc] init];
    
    CGRect rect;
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    {
        rect = CGRectMake((SCREEN_WIDTH - 150) / 2, SCREEN_HEIGHT - 35, 150, 30);
    }
    else
    {
        rect = CGRectMake((SCREEN_HEIGHT - 150) / 2, SCREEN_WIDTH - 35, 150, 30);
    }
    
    labelCrazy.frame = rect;
    labelCrazy.backgroundColor = [UIColor grayColor];
    labelCrazy.textColor = [UIColor whiteColor];
    labelCrazy.font = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:13];
    labelCrazy.textAlignment = NSTextAlignmentCenter;
    labelCrazy.text = text;
    [self.view addSubview:labelCrazy];
    [self.view bringSubviewToFront:labelCrazy];
    
    [labelCrazy performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3];
    
    [labelCrazy release];
}

- (void)enableLocalPTT:(BOOL)walkieTalkieEnable
{
    NSLog(@"%s walkieTalkieEnable: %d", __FUNCTION__, walkieTalkieEnable);
    
    if (walkieTalkieEnable)
    {
        //1. Starting
        // UI need to verify
        UIImage *imageHoldedToTalk;
        
        if (isiPhone4)
        {
            imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed.png"];
        }
        else
        {
            imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed_5.png"];
        }
        
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchDown];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlStateNormal];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchUpInside];
        [self applyFont];
        
        
        self.disableAutorotateFlag = TRUE;
        [self.ib_labelTouchToTalk setText:NSLocalizedStringWithDefaultValue(@"text_please_speak", nil, [NSBundle mainBundle], @"Please Speak", nil)];
        self.stringStatePTT = @"Speaking";
        
        //Mute audio to MediaPlayer lib
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_MUTE);
        
        
        NSLog(@"Device ip: %@, Port push to talk: %d, actually is: %d", [HttpCom instance].comWithDevice.device_ip, self.selectedChannel.profile.ptt_port,IRABOT_AUDIO_RECORDING_PORT);
        
        // Init connectivity to Camera via socket & prevent loss of audio data
        _audioOut = [[AudioOutStreamer alloc] initWithDeviceIp:[HttpCom instance].comWithDevice.device_ip
                                                    andPTTport:self.selectedChannel.profile.ptt_port];  //IRABOT_AUDIO_RECORDING_PORT
        [_audioOut startRecordingSound];
        
        [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                               withObject:[NSString stringWithFormat:@"%d", walkieTalkieEnable]];
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
        //2. Stopping
        
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_NOT_MUTE);
        
        if (_audioOut != nil)
        {
            [_audioOut disconnectFromAudioSocket];
            self.audioOut = nil;
        }
        else
        {
            self.ib_buttonTouchToTalk.enabled = YES;
            self.enablePTT = YES;
        }
        
        // UI
        UIImage *imageNormal;
        
        if (isiPhone4)
        {
            imageNormal = [UIImage imageNamed:@"camera_action_mic.png"];
        }
        else
        {
            imageNormal = [UIImage imageNamed:@"camera_action_mic_5.png"];
        }
        
        [self.ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlEventTouchDown];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlEventTouchUpInside];
        //[self applyFont];
        self.disableAutorotateFlag = FALSE;
        [self.ib_labelTouchToTalk setText:NSLocalizedStringWithDefaultValue(@"text_touch_to_talk", nil, [NSBundle mainBundle], @"Touch to Talk", nil)];
        self.stringStatePTT = @"Touch to Talk";
    }
}

- (void) set_Walkie_Talkie_bg: (NSString *) status
{
    @autoreleasepool {
        NSString * command = [NSString stringWithFormat:@"%@%@", SET_PTT, status];
        
        NSLog(@"Command send to camera is %@", command);
        
        [[HttpCom instance].comWithDevice sendCommandAndBlock:command];
        
        self.enablePTT = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ib_buttonTouchToTalk.enabled = YES;
            if (self.melodyViewController) {
                if (self.melodyViewController.playing) {
                    self.melodyViewController.playing = NO;
                    [self.melodyViewController resetStatus];
                    [self showToat:NSLocalizedStringWithDefaultValue(@"stop_melody_toat", nil, [NSBundle mainBundle], @"Melody will be stopped", nil)];
                }
            }
        });
    }
}

- (void)touchUpInsideHoldToTalk {
    //update UI
    [_ib_buttonTouchToTalk setBackgroundColor:[UIColor clearColor]];
    [_ib_buttonTouchToTalk setBackgroundImage:[UIImage imageMic] forState:UIControlStateNormal];
    [_ib_buttonTouchToTalk setBackgroundImage:[UIImage imageMic] forState:UIControlEventTouchUpInside];
    
    self.disableAutorotateFlag = FALSE;
    
    if (self.selectedChannel.profile.isInLocal)
    {
        [self.ib_labelTouchToTalk setText:NSLocalizedStringWithDefaultValue(@"text_touch_to_talk", nil, [NSBundle mainBundle], @"Touch to Talk", nil)];
    }
    else
    {
        _ib_buttonTouchToTalk.enabled = YES;
        self.enablePTT = YES;
        [_ib_labelTouchToTalk setText:NSLocalizedStringWithDefaultValue(@"text_touch_to_talk", nil, [NSBundle mainBundle], @"Touch to Talk", nil)];
        self.stringStatePTT = @"Touch to Talk";
    }
    
    [self applyFont];
}

// Talk back remote

- (NSInteger )getTalkbackSessionKey
{
    // STEP 1
    //[BMS_JSON_Communication setServerInput:@"https://dev-api.hubble.in:443/v1"];
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSString *regID = self.selectedChannel.profile.registrationID;
    
    NSDictionary *responseDict = [_jsonCommBlocked createTalkbackSessionBlockedWithRegistrationId:regID
                                                                                           apiKey:_apiKey];
    NSLog(@"%@", responseDict);
    
    //[BMS_JSON_Communication setServerInput:@"https://api.hubble.in/v1"];
    
    if (responseDict != nil)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            self.sessionKey = [[responseDict objectForKey:@"data"] objectForKey:@"session_key"];
            self.streamID = [[responseDict objectForKey:@"data"] objectForKey:@"stream_id"];
            
            [userDefault setObject:_sessionKey forKey:SESSION_KEY];
            [userDefault setObject:_streamID forKey:STREAM_ID];
            [userDefault synchronize];
            
            return 200;
        }
        else
        {
            NSLog(@"Resquest session key failed: %@", [responseDict objectForKey:@"message"]);
            
            if ([[responseDict objectForKey:@"status"] integerValue] == 404)
            {
                self.ib_buttonTouchToTalk.enabled = NO;
                self.ib_labelTouchToTalk.text = NSLocalizedStringWithDefaultValue(@"text_not_support", nil, [NSBundle mainBundle], @"Not support!", nil);
                self.stringStatePTT = @"Not support!";
                
                return 404;
            }
            else if ([[responseDict objectForKey:@"status"] integerValue] == 422)
            {
                return 422;
            }
        }
    }
    
    return 500;
}

- (void)processingHoldToTalkRemote
{
    if (_audioOutStreamRemote == nil)
    {
        AudioOutStreamRemote *audio = [[AudioOutStreamRemote alloc] initWithRemoteMode];
        self.audioOutStreamRemote = audio;
        [audio release];
        
        [_audioOutStreamRemote retain];
        //Start buffering sound from user at the moment they press down the button
        //  This is to prevent loss of audio data
    }
    
    [_audioOutStreamRemote startRecordingSound];
    
}

- (void)enableRemotePTT: (NSNumber *)walkieTalkieEnabledFlag
{
    NSLog(@"H264VC - enableRemotePTT: %@", walkieTalkieEnabledFlag);
    
    if ([walkieTalkieEnabledFlag boolValue] == NO)
    {
        self.disableAutorotateFlag = FALSE;
        
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_NOT_MUTE);
        
        if (_audioOutStreamRemote != nil)
        {
            [_audioOutStreamRemote performSelectorOnMainThread:@selector(disconnectFromAudioSocketRemote) withObject:nil waitUntilDone:NO];
            
            if (!_audioOutStreamRemote.audioOutStreamRemoteDelegate)
            {
                [self performSelectorOnMainThread:@selector(touchUpInsideHoldToTalk) withObject:nil waitUntilDone:NO];
            }
        }
        else
        {
            [self performSelectorOnMainThread:@selector(touchUpInsideHoldToTalk) withObject:nil waitUntilDone:NO];
        }
    }
    else
    {
        self.disableAutorotateFlag = YES;
        
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_MUTE);
        
        [self processingHoldToTalkRemote];
        
        NSLog(@"H264VC - enableRemotePTT - isHandshakeSuccess: %d", _audioOutStreamRemote.isHandshakeSuccess);
        
        if (_audioOutStreamRemote.isHandshakeSuccess)
        {
            // STEP 3 -- Reconnect to Relay-server
            [_audioOutStreamRemote performSelectorOnMainThread:@selector(connectToAudioSocketRemote) withObject:nil waitUntilDone:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.melodyViewController) {
                    if (self.melodyViewController.playing) {
                        self.melodyViewController.playing = NO;
                        [self.melodyViewController resetStatus];
                        [self showToat:NSLocalizedStringWithDefaultValue(@"stop_melody_toat", nil, [NSBundle mainBundle], @"Melody will be stopped", nil)];
                    }
                }
            });
        }
        else
        {
            // STEP 1
            NSInteger statusCode = [self getTalkbackSessionKey];
            
            NSLog(@"H264VC - enableRemotePTT - [self getTalkbackSessionKey]: %d", statusCode);
            
            if (statusCode == 404)
            {
                self.walkieTalkieEnabled = NO;
                [self enableRemotePTT:[NSNumber numberWithBool:self.walkieTalkieEnabled]];
                return;
            }
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            self.sessionKey = [userDefault objectForKey:SESSION_KEY];
            self.streamID = [userDefault objectForKey:STREAM_ID];
            
            if (!_ib_ViewTouchToTalk.isHidden && _walkieTalkieEnabled)
            {
                if (_sessionKey == nil)
                {
                    [self retryTalkbackRemote];
                }
                else
                {
                    // STEP 2
                    
                    NSString *url = [NSString stringWithFormat: @"%@/devices/start_talk_back", _talkbackRemoteServer];
                    
                    NSDictionary *resDict = [self workWithServer:url sessionKey:_sessionKey streamID:_streamID];
                    
                    NSLog(@"%@", resDict);
                    
                    if (!_ib_ViewTouchToTalk.isHidden && _walkieTalkieEnabled)
                    {
                        if (resDict != Nil)
                        {
                            NSInteger status = [[resDict objectForKey:@"status"] integerValue];
                            
                            if (status == 200)
                            {
                                NSMutableData *data = [[NSMutableData alloc] init];
                                
                                Byte header[3];// = {1, 79, 1};
                                header[0] = 1;
                                header[1] = 79;
                                header[2] = 1;
                                
                                NSString *handshake = [_streamID stringByAppendingString:_sessionKey];
                                [data appendBytes:header length:3];
                                
                                const char *charHandshake = [handshake UTF8String];
                                [data appendBytes:charHandshake length:strlen(charHandshake)];
                                
                                _audioOutStreamRemote.dataRequest = data;
                                [data release];
                                
                                NSString *relayServerIP = (NSString *)[resDict objectForKey:@"relay_server_ip"];
                                id relayServerPort = [resDict objectForKey:@"relay_server_port"];
                                
                                if (relayServerIP != nil && relayServerPort != nil)
                                {
                                    _audioOutStreamRemote.relayServerIP = relayServerIP;
                                    _audioOutStreamRemote.relayServerPort = [relayServerPort integerValue];
                                    
                                    [_audioOutStreamRemote performSelectorOnMainThread:@selector(connectToAudioSocketRemote) withObject:nil waitUntilDone:NO];
                                    _audioOutStreamRemote.audioOutStreamRemoteDelegate = self;
                                }
                                else
                                {
                                    NSLog(@"H264VC - enableRemotePTT - relayServerIP = nil | relayServerPort = nil {0}");
                                }
                                
                                NSLog(@"H264VC -enableRemotePTT - data: %@, -length: %lu, -ip: %@, -port: %d", data, (unsigned long)data.length, _audioOutStreamRemote.relayServerIP, _audioOutStreamRemote.relayServerPort);
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (self.melodyViewController) {
                                        if (self.melodyViewController.playing) {
                                            self.melodyViewController.playing = NO;
                                            [self.melodyViewController resetStatus];
                                            [self showToat:NSLocalizedStringWithDefaultValue(@"stop_melody_toat", nil, [NSBundle mainBundle], @"Melody will be stopped", nil)];
                                        }
                                    }
                                });
                            }
                            else
                            {
                                if (status == 404)
                                {
                                    self.walkieTalkieEnabled = NO;
                                    [self enableRemotePTT:[NSNumber numberWithBool:self.walkieTalkieEnabled]];
                                    return;
                                }
                                
                                NSLog(@"Send cmd start_talk_back failed! Retry...");
                                [self retryTalkbackRemote];
                            }
                        }
                        else
                        {
                            NSLog(@"Response Dict from camera - resDict = nil! Retry...");
                            [self retryTalkbackRemote];
                        }
                    }
                    else
                    {
                        NSLog(@"%s PTT view is invisible. Do nothing!", __FUNCTION__);
                    }
                } // End sessionKey != nil
            }
            else
            {
                NSLog(@"%s PTT view is invisible. Do nothing!", __FUNCTION__);
            }
        } // End Handshake
    }// End walkieTalkieEnabledFlag
}

- (void)closeRemoteTalkback
{
    NSString *url = [NSString stringWithFormat: @"%@/devices/stop_talk_back", _talkbackRemoteServer];
    
    NSDictionary *resDict = [self workWithServer:url sessionKey:_sessionKey streamID:_streamID];
    
    NSLog(@"%@", resDict);
}

- (NSDictionary *)workWithServer: (NSString *)url sessionKey: (NSString *)sessionKey streamID: (NSString *)streamID
{
    NSString *requestString = [url stringByAppendingFormat:@"?session_key=%@&stream_id=%@", sessionKey, streamID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestString]];
    request.timeoutInterval = 30;
    
    //Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    // This is how we set header fields
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    
    NSData *dataReply = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:nil];
    
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    NSLog(@"H264 - workWithServer - url: %@, -status code: %d", requestString, statusCode);
    
    if (statusCode != 200)
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:statusCode], @"status", nil];
    }
    
    if (dataReply == nil)
    {
        return nil;
    }
    else
    {
        return [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:dataReply
                                                                                      options:kNilOptions
                                                                                        error:nil]];
    }
}

#pragma mark - Audio out stream remote delete

- (void)didDisconnecteSocket
{
    [self performSelectorOnMainThread:@selector(touchUpInsideHoldToTalk) withObject:nil waitUntilDone:NO];
    self.walkieTalkieEnabled = NO;
}

- (void)closeTalkbackSession
{
    [self performSelectorInBackground:@selector(closeRemoteTalkback) withObject:nil];
    [self touchUpInsideHoldToTalk];
    
    self.walkieTalkieEnabled = NO;
    [self enableRemotePTT:[NSNumber numberWithBool:NO]];
}

- (void)retryTalkbackRemote
{
    //self.ib_labelTouchToTalk.text = @"Retry...";
    self.ib_buttonTouchToTalk.enabled = YES;
    
    if (userWantToCancel || !self.walkieTalkieEnabled)
    {
        return;
    }
    
    // Re-enable Remote PTT
    [self enableRemotePTT:[NSNumber numberWithBool:YES]];
}

- (void)reportHandshakeFaild:(BOOL)isFailed
{
    // Enable for user cancel PTT
    self.ib_buttonTouchToTalk.enabled = YES;
    
    /*
     * 1: Handshake failed!
     * 2: Handshake successfully.
     */
    
    if (isFailed)
    {
        NSLog(@"Report handshake failed! Retry...");
        self.ib_labelTouchToTalk.text = NSLocalizedStringWithDefaultValue(@"text_retry", nil, [NSBundle mainBundle], @"Retry...", nil);
        [self retryTalkbackRemote];
    }
    else
    {
        self.ib_labelTouchToTalk.text = NSLocalizedStringWithDefaultValue(@"text_please_speak", nil, [NSBundle mainBundle], @"Please Speak", nil);
    }
}

#pragma mark - Bottom menu

- (IBAction)changeToMainRecording:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Take picture to Recording or " withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Take picture to Recording or vice versa"
                                                     withLabel:@"Recording"
                                                     withValue:nil];
    //change to main recording here
    [self changeAction:nil];
}

#if 1
#else
- (IBAction)switchDegreePressed:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Temperature type" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Temperature type"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isDegreeFDisplay]];
    
    _isDegreeFDisplay = !_isDegreeFDisplay;
    
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setBool:_isDegreeFDisplay forKey:IS_FAHRENHEIT];
    //[userDefaults synchronize];
    
    [self setTemperatureState_Fg:_stringTemperature];
}
#endif

- (IBAction)showInfoDebug:(id)sender
{
    self.viewDebugInfo.hidden = !_viewDebugInfo.isHidden;
}

- (IBAction)processingRecordingOrTakePicture:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView Touch up inside recording - mode: %d", _isRecordInterface] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Temperature type"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isDegreeFDisplay]];
    
    NSLog(@"_isRecordInterface is %d", _isRecordInterface);
    
    if (_isRecordInterface)
    {
        if (!_syncPortraitAndLandscape)
        {
            _isProcessRecording = !_isProcessRecording;
        }
        
        if (_isProcessRecording)
        {
            //now is interface recording
            [self.ib_labelRecordVideo setText:@"00:00:00"];
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStop] forState:UIControlStateNormal];
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStopPressed] forState:UIControlEventTouchDown];
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStop] forState:UIControlEventTouchUpInside];
            //display time to recording
            if (!_syncPortraitAndLandscape)
            {
                _timerRecording = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            }
            
            /*
             start recording :: TODO
             */
            
            
            
        }
        else
        {
            //here to stop
            [self stopRecordingVideo];
        }
    }
    else
    {
        //now is for take pictures
        [self.ib_labelRecordVideo setText:NSLocalizedStringWithDefaultValue(@"text_take_picture", nil, [NSBundle mainBundle], @"Take Picture", nil)];
        [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlStateNormal];
        [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlEventTouchUpInside];
        [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhotoPressed] forState:UIControlEventTouchDown];
        
        if (_isProcessRecording)
        {
            [self.ib_changeToMainRecording setHidden:NO];
            [self.view bringSubviewToFront:self.ib_changeToMainRecording];
        }
        else
        {
            _syncPortraitAndLandscape = NO;
#if 0 // Enable it later.
            if ([_cameraModel isEqualToString:CP_MODEL_008])
            {
                [self.ib_buttonChangeAction setHidden:NO];
                [self.view bringSubviewToFront:self.ib_buttonChangeAction];
            }
#endif
        }
        
        if (!_syncPortraitAndLandscape)
        {
            //processing for take picture
            [self processingForTakePicture];
        }
    }
    [self applyFont];
    
}

- (void)stopRecordingVideo
{
    [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlStateNormal];
    [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideoPressed] forState:UIControlEventTouchDown];
    [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlEventTouchUpInside];
    //stop timer display
    [self stopTimerRecoring];
    [self.ib_labelRecordVideo setText:NSLocalizedStringWithDefaultValue(@"text_record_video", nil, [NSBundle mainBundle], @"Record Video", nil)];
    _syncPortraitAndLandscape = NO;
    
    // DUMMY for now..
}

- (IBAction)changeAction:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Take picture to Recording or " withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Take picture to Recording or vice versa"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isRecordInterface]];
    if (!_syncPortraitAndLandscape)
    {
        _isRecordInterface = !_isRecordInterface;
    }
    
    //#endif
    
    if (_isRecordInterface)
    {
        //bring to front of view
        [self.ib_changeToMainRecording setHidden:YES];
        [self.ib_buttonChangeAction setHidden:NO];
        [self.view bringSubviewToFront:self.ib_buttonChangeAction];
        //set image display
        [self.ib_buttonChangeAction setBackgroundImage:[UIImage imagePhotoGrey] forState:UIControlStateNormal];
        [self.ib_buttonChangeAction setBackgroundImage:[UIImage imagePhotoGreyPressed] forState:UIControlStateSelected];
        //now is interface take picture
        if (_isProcessRecording)
        {
            //but,we are recording
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStop] forState:UIControlStateNormal];
            [self.ib_labelRecordVideo setText:@""];
        }
        else
        {
            //not recording
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlStateNormal];
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideoPressed] forState:UIControlEventTouchDown];
            [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlEventTouchUpInside];
            [self.ib_labelRecordVideo setText:NSLocalizedStringWithDefaultValue(@"text_record_video", nil, [NSBundle mainBundle], @"Record Video", nil)];
            _syncPortraitAndLandscape = NO;
        }
    }
    else
    {
        //now is interface take picture
        [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlStateNormal];
        [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhotoPressed] forState:UIControlEventTouchDown];
        [self.ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlEventTouchUpInside];
        
        if (_isProcessRecording)
        {
            //but,we are recording
            //now, replace image take picture with time animation
            [self.ib_buttonChangeAction setHidden:YES];
            [self.ib_changeToMainRecording setHidden:NO];
            [self.view bringSubviewToFront:self.ib_changeToMainRecording];
            [self.ib_labelRecordVideo setText:NSLocalizedStringWithDefaultValue(@"text_take_picture", nil, [NSBundle mainBundle], @"Take Picture", nil)];
        }
        else
        {
            //not recording
            [self.ib_changeToMainRecording setHidden:YES];
            [self.ib_buttonChangeAction setHidden:NO];
            [self.view bringSubviewToFront:self.ib_buttonChangeAction];
            [self.ib_buttonChangeAction setBackgroundImage:[UIImage imageVideoGrey] forState:UIControlStateNormal];
            [self.ib_buttonChangeAction setBackgroundImage:[UIImage imageVideoGreyPressed] forState:UIControlStateSelected];
            [self.ib_labelRecordVideo setText:NSLocalizedStringWithDefaultValue(@"text_take_picture", nil, [NSBundle mainBundle], @"Take Picture", nil)];
            _syncPortraitAndLandscape = NO;
        }
        
    }
    [self applyFont];
}

#pragma mark -
#pragma mark display timer recording

- (void)timerTick:(NSTimer *)timer
{
    _ticks += 1.0;
    double seconds = fmod(_ticks, 60.0);
    double minutes = fmod(trunc(_ticks / 60.0), 60.0);
    double hours = trunc(_ticks / 3600.0);
    NSString *timeToDisplay = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f",hours, minutes, seconds];
    
    if (_isRecordInterface && _isProcessRecording)
    {
        self.ib_labelRecordVideo.text = timeToDisplay;
        [self applyFont];
    }
    else
    {
        self.ib_labelRecordVideo.text = NSLocalizedStringWithDefaultValue(@"text_take_picture", nil, [NSBundle mainBundle], @"Take Picture", nil);
        //now is interface take picture
        if (_isProcessRecording)
        {
            //but,we are recording
            //only update time display
            [self.ib_changeToMainRecording setTitle:timeToDisplay forState:UIControlStateNormal];
        }
        else
        {
            //not recording
            //handle it at (IBAction)changeAction:(id)sender
            _syncPortraitAndLandscape = NO;
        }
    }
    if (_syncPortraitAndLandscape)
    {
        [self changeAction:nil];
        [self processingRecordingOrTakePicture:nil];
        _syncPortraitAndLandscape = NO;
    }
}
- (void)stopTimerRecoring
{
    _ticks = 0;
    if (_timerRecording && [_timerRecording isValid])
    {
        [_timerRecording invalidate];
        _timerRecording = nil;
    }
}

#pragma mark -
#pragma mark SnapShot

- (void)processingForTakePicture
{
    [self.ib_processRecordOrTakePicture setEnabled:NO];
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
    [self.ib_processRecordOrTakePicture setEnabled:YES];
	NSString *message;
	NSString *title;
	if (!error)
	{
		title = NSLocalizedStringWithDefaultValue(@"alert_title_snapshot", nil, [NSBundle mainBundle], @"Snapshot", nil);
		message = NSLocalizedStringWithDefaultValue(@"alert_mes_saved_to_photo_album", nil, [NSBundle mainBundle], @"Saved to Photo Album", nil);
        
	}
	else
	{
		title = NSLocalizedStringWithDefaultValue(@"error", nil, [NSBundle mainBundle], @"Error", nil);
		//message = [error description];
        message = NSLocalizedStringWithDefaultValue(@"alert_mes_permission_to_save_media_in_gallery", nil, [NSBundle mainBundle], @"Please allow permission to save media in gallery.  iPhone Settings > Privacy > Photos > Hubble Home :- Turn switch on.", nil);
		NSLog(@"Error when writing file to image library: %@", [error localizedDescription]);
		NSLog(@"Error code %d", [error code]);
        
	}
	UIAlertView *_alertInfo = [[UIAlertView alloc]
                               initWithTitle:title
                               message:message
                               delegate:self
                               cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil)
                               otherButtonTitles:nil];
	[_alertInfo show];
	[_alertInfo release];
    
}

//
#ifdef SHOW_DEBUG_INFO

- (void)updateDebugInfoFrameRate:(NSInteger )fps
{
    UITextField *tfFrameRate = (UITextField *)[_viewDebugInfo viewWithTag:TF_DEBUG_FRAME_RATE_TAG];
    tfFrameRate.text = [NSString stringWithFormat:@"%@ %d", _viewVideoIn, fps];
}

- (void)updateDebugInfoResolutionWidth: (NSInteger )width heigth: (NSInteger )height
{
    UITextField *tfResolution = (UITextField *)[_viewDebugInfo viewWithTag:TF_DEBUG_RESOLUTION_TAG];
    tfResolution.text = [NSString stringWithFormat:@"%dx%d", width, height];
}

- (void)updateDebugInfoBitRate:(NSInteger)bitRate
{
    
    UITextField *tfBitRate = (UITextField *)[_viewDebugInfo viewWithTag:TF_DEBUG_BIT_RATE_TAG];
    
    //bitrate value is updated every 2 sec
    tfBitRate.text = [NSString stringWithFormat:@"%d", (bitRate *8) / (2*  1000)];
}

#endif

- (BOOL)checkAvailableStateOfCamera: (NSString *)regID
{
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSDictionary *responseDict = [_jsonCommBlocked checkDeviceIsAvailableBlockedWithRegistrationId:regID andApiKey:apiKey];
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            if ([[[responseDict objectForKey:@"data"] objectForKey:@"is_available"] boolValue] == TRUE)
            {
                NSLog(@"Check Available - Camera is AVAILABLE");
                self.selectedChannel.profile.minuteSinceLastComm = 1;
                self.selectedChannel.profile.hasUpdateLocalStatus = TRUE;
                self.cameraIsNotAvailable = FALSE;
                return TRUE;
            }
            else
            {
                NSLog(@"Check Available - Camera is NOT available");
            }
        }
        else
        {
            NSLog(@"Result isn't expected");
        }
    }
    else
    {
        NSLog(@"Empty results of device list from server OR response error");
    }
    
    self.selectedChannel.profile.hasUpdateLocalStatus = TRUE;
    self.selectedChannel.profile.minuteSinceLastComm = 10;
    self.cameraIsNotAvailable = TRUE;
    return FALSE;
}

#pragma mark - New flow

- (void)scanCamera
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.current_ssid = [CameraPassword fetchSSIDInfo];
    
    if ( [self isCurrentConnection3G] ||
        [userDefaults boolForKey:@"remote_only"] ||
        (self.selectedChannel.profile.ip_address == nil)
        )
    {
        NSLog(@"Connection over 3G | remote_only: %d, ip_address: %p --> Skip scanning all together, bit rate 128", [userDefaults boolForKey:@"remote_only"], self.selectedChannel.profile.ip_address);
        
        //pulldown to 32 KB/s initially - pull up when we get 1st image
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"128"];
        
        self.selectedChannel.profile.isInLocal = FALSE;
        self.selectedChannel.profile.hasUpdateLocalStatus = TRUE;
        self.selectedChannel.profile.minuteSinceLastComm = 1;
        
        [self performSelector:@selector(setupCamera)
                   withObject:nil afterDelay:0.1];
    }
    else
    {
        if ([self.selectedChannel.profile.hostSSID isEqualToString:_current_ssid])
        {
            NSLog(@"The same ssid --> uses local stream");
            self.selectedChannel.profile.isInLocal = TRUE;
            self.selectedChannel.profile.hasUpdateLocalStatus = TRUE;
            self.selectedChannel.profile.minuteSinceLastComm = 1;
            
            if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM])
            {
                self.selectedChannel.profile.port = 8081; // HARD CODE for now
            }
            else
            {
                self.selectedChannel.profile.port = 80; // HARD CODE for now
            }
            
            [self performSelector:@selector(setupCamera)
                       withObject:nil afterDelay:0.1];
        }
        else
        {
            if ([self isInTheSameNetworkAsCamera:self.selectedChannel.profile])
            {
                [self startScanningWithBonjour];
                //[self startScanningWithIpServer];
                [self performSelectorInBackground:@selector(startScanningWithIpServer) withObject:nil];
            }
            else
            {
                [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"128"];
                
                self.selectedChannel.profile.isInLocal = FALSE;
                self.selectedChannel.profile.hasUpdateLocalStatus = TRUE;
                self.selectedChannel.profile.minuteSinceLastComm = 1;
                
                [self performSelector:@selector(setupCamera)
                           withObject:nil afterDelay:0.1];
            }
        }
    }
}

-(BOOL) isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    if ([reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        //        //3G
        //        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"200"];
        
        return TRUE;
    }
    
    return FALSE;
}

- (void)increaseBitRate:(NSTimer *)timer
{
    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"600"];
}

- (void)setVideoBitRateToCamera:(NSString *)bitrate_str
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    if (_jsonCommBlocked == nil)
    {
        BMS_JSON_Communication *comm = [[BMS_JSON_Communication alloc] initWithObject:self
                                              Selector:nil
                                          FailSelector:nil
                                             ServerErr:nil];
        self.jsonCommBlocked = comm;
        [comm release];
    }
    
    NSString * cmd_str = [NSString stringWithFormat:@"action=command&command=set_video_bitrate&value=%@",bitrate_str];
    
    NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                             andCommand:cmd_str
                                                                              andApiKey:apiKey];
    BOOL sendCmdFailed = TRUE;
    
    if (responseDict != nil)
    {
        NSInteger status = [[responseDict objectForKey:@"status"] intValue];
        
        if (status == 200)
        {
            NSString *bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            
            if (bodyKey != nil && ![bodyKey isEqual:[NSNull null]])
            {
                if ([bodyKey isEqualToString:@"set_video_bitrate: 0"])
                {
                    sendCmdFailed = FALSE;
                }
            }
        }
    }
    
    if (sendCmdFailed)
    {
        NSLog(@"H264VC - setVideoBitRateToCamera: %@", responseDict);
    }
    else
    {
        self.currentBitRate = bitrate_str;
        NSLog(@"H264VC - setVideoBitRateToCamera successfully: %@", bitrate_str);
    }
}

- (void)startScanningWithBonjour
{
    self.threadBonjour = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(scanWithBonjour)
                                                   object:nil];
    [_threadBonjour start];
}

-(void) scanWithBonjour
{
    @autoreleasepool
    {
        // When use autoreleseapool, no need to call autorelease.
        Bonjour *bonjour = [[Bonjour alloc] initSetupWith:[NSMutableArray arrayWithObject:self.selectedChannel.profile]];
        [bonjour setDelegate:self];
        
        [bonjour startScanLocalWiFi];
        
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        
        while (bonjour.isSearching)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        self.bonjourList = [NSMutableArray arrayWithArray:bonjour.cameraList];
    }
    
    [NSThread exit];
}

- (void)startScanningWithIpServer
{
    NSMutableArray * finalResult = [[NSMutableArray alloc] init];
    
    if (self.selectedChannel.profile != nil &&
        self.selectedChannel.profile.mac_address != nil)
    {
        
        BOOL skipScan = [self isCurrentIpAddressValid:self.selectedChannel.profile];
        
        if (skipScan)
        {
            self.selectedChannel.profile.port = 80;
            //Dont need to scan.. call scan_done directly
            [finalResult addObject:self.selectedChannel.profile];
            
            //                [self performSelector:@selector(scan_done:)
            //                           withObject:finalResult afterDelay:0.1];
            [self performSelectorOnMainThread:@selector(scan_done:)
                                   withObject:finalResult
                                waitUntilDone:NO];
            
        }
        else // NEED to do local scan
        {
            ScanForCamera *cameraScanner = [[ScanForCamera alloc] initWithNotifier:self];
            //[cameraScanner scan_for_device:self.selectedChannel.profile.mac_address];
            [cameraScanner performSelectorOnMainThread:@selector(scan_for_device:)
                                            withObject:self.selectedChannel.profile.mac_address
                                         waitUntilDone:NO];
            
            
        } /* skipScan = false*/
        
    }
    
    [finalResult release];
}

-(BOOL) isInTheSameNetworkAsCamera :(CamProfile *) cp
{
    long ip = 0, ownip =0 ;
    long netMask = 0 ;
	struct ifaddrs *ifa = NULL, *ifList;
    
    NSString * bc = @"";
	NSString * own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own ipasLong:&ownip];
    
    getifaddrs(&ifList); // should check for errors
    
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_netmask != NULL)
        {
            ip = (( struct sockaddr_in *)ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == ownip)
            {
                netMask = (( struct sockaddr_in *)ifa->ifa_netmask)->sin_addr.s_addr;
                
                break;
            }
        }
    }
    
    freeifaddrs(ifList); // clean up after yourself
    
    if (netMask ==0 || ip ==0)
    {
        return FALSE;
    }
    
    long camera_ip =0 ;
    if (cp != nil &&
        cp.ip_address != nil)
    {
        NSArray * tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if ([tokens count] != 4)
        {
            //sth is wrong
            return FALSE;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        if ( (camera_ip & netMask) == (ip & netMask))
        {
            NSLog(@"H264 - Camera is in same subnet");
            return TRUE;
        }
    }
    
    return FALSE;
}

-(BOOL) isCurrentIpAddressValid :(CamProfile *) cp
{
    if (cp != nil &&
        cp.ip_address != nil)
    {
        [HttpCom instance].comWithDevice.device_ip = cp.ip_address;
        [HttpCom instance].comWithDevice.device_port = 80; // HARD code one more time.
        
        
        NSString *mac = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:3.0f];
        
        if (mac != nil && mac.length == 12)
        {
            mac = [Util add_colon_to_mac:mac];
            
            if ([mac isEqual:cp.mac_address])
            {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

#pragma mark - Bonjour delegate

- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
}



#pragma mark - Custom Indicator
-(void)start_animation_with_orientation
{
    self.customIndicator.hidden = NO;

    self.customIndicator.animationDuration = 1.5;
    self.customIndicator.animationRepeatCount = 0;
    [self.customIndicator startAnimating];
    
}

- (void)displayCustomIndicator
{
    if (_isShowCustomIndicator && !_hideCustomIndicatorAndTextNotAccessble)
    {
        
        if (self.alertTimer != nil && [self.alertTimer isValid])
        {
            //some periodic is running dont care
            NSLog(@"some periodic is running dont care");
        }
        else
        {
            if (_disconnectAlert == YES && _shouldBeep)
            {
                self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                                   target:self
                                                                 selector:@selector(periodicBeep:)
                                                                 userInfo:nil
                                                                  repeats:YES];
            }
        }
        
        
        [self start_animation_with_orientation];
        
        
        NSString *message = [NSString stringWithFormat:@"%@ %@", _messageStreamingState, NSLocalizedStringWithDefaultValue(@"more_detail", nil, [NSBundle mainBundle], @"details", nil)];
        self.ib_lbCameraNotAccessible.text = message;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.ib_lbCameraNotAccessible.attributedText];
        [attributedString addAttribute:NSUnderlineStyleAttributeName
                                 value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                 range:NSMakeRange(attributedString.length - 7, 7)];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor colorWithRed:51/255.0f green:102/255.f blue:187/255.0f alpha:1.0f]
                                 range:NSMakeRange(attributedString.length - 7, 7)];
        [self.ib_lbCameraNotAccessible setAttributedText:attributedString];
        
        if (_isShowTextCameraIsNotAccesible)
        {
            [self.ib_lbCameraNotAccessible setHidden:NO];
            [self showTimelineView];
            [self messageNotAccesible:NO];
        }
        else
        {
            [self messageNotAccesible:YES];
        }
    }
    else
    {
        [self stopPeriodicBeep];
        _isShowTextCameraIsNotAccesible = NO;
        [self.customIndicator stopAnimating];
        [self.customIndicator setHidden:YES];
        [self messageNotAccesible:YES];
        [self.ib_lbCameraName setText:self.selectedChannel.profile.name];
    }
}

- (void)messageNotAccesible:(BOOL)hidden
{
    [self.ib_lbCameraNotAccessible setHidden:hidden];
    [self.ib_openHelpButton setHidden:hidden];
}

#pragma mark - Hubble alert view & delegate

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];
    
    // Modify the parameters
    //[alertView setButtonTitles:[NSArray arrayWithObjects:@"View other camera", nil]];
    [alertView setButtonTitles:NULL];
    
    
    [alertView setDelegate:self];
    
    //You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    if (_isFwUpgradedByAnotherDevice)
    {
        // And launch the dialog
        [alertView show];
    }
    else
    {
        NSLog(@"%s Alert will be shown after 6s.", __FUNCTION__);
    }
    
    self.customeAlertView = alertView;
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{

    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    alertView.delegate = nil;
    [alertView close];
}

- (void)closeCustomAlertView
{
    [self customIOS7dialogButtonTouchUpInside:_customeAlertView clickedButtonAtIndex:1];
}

- (UIView *)createDemoView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 175)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 15, 30, 30)];// autorelease];
    [imageView setImage:[UIImage imageNamed:@"loader_a"]];
    
    imageView.animationImages = @[[UIImage imageNamed:@"loader_a"],
                                  [UIImage imageNamed:@"loader_b"],
                                  [UIImage imageNamed:@"loader_c"],
                                  [UIImage imageNamed:@"loader_d"],
                                  [UIImage imageNamed:@"loader_e"],
                                  [UIImage imageNamed:@"loader_f"]];
    imageView.animationRepeatCount = 0;
    imageView.animationDuration = 1.5f;
    [demoView addSubview:imageView];
    [imageView startAnimating];
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"fw_upgrade_2",nil, [NSBundle mainBundle],
                                                       @"Upgrading firmware, do not power off the camera. This process may take up to 5 mins..." , nil);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, 200, 91)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 4;
    label.text = msg;
    [demoView addSubview:label];

    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 150, 160, 20)];
    [demoView addSubview:progressView];
    
    UILabel *lblProgress = [[UILabel alloc] initWithFrame:CGRectMake(170, 130, 50, 21)];
    lblProgress.text = @"--";
    [demoView addSubview:lblProgress];
   
    NSArray *arr = [NSArray arrayWithObjects:progressView, lblProgress, nil];
    [self performSelectorInBackground:@selector(upgradeFwProgress_bg:)
                           withObject:arr];
    [self performSelectorInBackground:@selector(checkFwUpgradeStatus_bg) withObject:nil];

    [imageView release];
    [label release];
    [progressView release];
    [lblProgress release];
    return [demoView autorelease];
}

- (void)upgradeFwProgress_bg:(NSArray *)obj
{
    //NSLog(@"%s userWantToCancel:%d, _fwUpgradeStatus:%d", __FUNCTION__, userWantToCancel, _fwUpgradeStatus);

    float sleepPeriod = TIME_FW_UPGRADE / 100.f; // 100 cycles
    
    while (_fwUpgradedProgress++ < 100 &&
           (_fwUpgradeStatus == FIRMWARE_UPGRADE_IN_PROGRESS || _fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT))
    {
        if (userWantToCancel)
        {
            self.isFWUpgradingInProgress = NO;
            self.isFwUpgradedByAnotherDevice = NO;
            [self performSelectorOnMainThread:@selector(closeCustomAlertView) withObject:nil waitUntilDone:NO];// PN
            NSLog(@"%s Backout.", __FUNCTION__);
            return;
        }
        
        [self performSelectorOnMainThread:@selector(upgradeFwProgress_ui:)
                               withObject:obj
                            waitUntilDone:YES];
        
        [NSThread sleepForTimeInterval:sleepPeriod];
    }
    
    NSLog(@"%s percentage:%d, fwStatus:%d", __FUNCTION__, _fwUpgradedProgress, _fwUpgradeStatus);
    [self performSelectorOnMainThread:@selector(popupAlertFwUpgradingStatus)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)popupAlertFwUpgradingStatus
{
    NSLog(@"%s status:%d", __FUNCTION__, _fwUpgradeStatus);
    
    [self closeCustomAlertView];
    
    NSString *msg = nil;
    NSString *title = @"Firmware Upgrade Succeeded";
    NSString *ok = NSLocalizedStringWithDefaultValue(@"ok",nil, [NSBundle mainBundle],
                                                     @"OK" , nil);
    NSInteger alertTag = TAG_ALERT_FW_OTA_UPGRADE_DONE;
    
    if (_fwUpgradeStatus == FIRMWARE_UPGRADE_SUCCEED)
    {
        self.isFWUpgradingInProgress = NO;
        self.isFwUpgradedByAnotherDevice = NO;
        _isShowCustomIndicator = YES;
        [self displayCustomIndicator];
    }
    else
    {
        alertTag = TAG_ALERT_FW_OTA_UPGRADE_FAILED;
        
        title = @"Firmware Upgrade Failed";
        
        NSString *msg1 = @"Firmware upgrade could not be completed.";
        
        if (_fwUpgradeStatus == FIRMWARE_UPGRADE_FAILED)
        {
            msg1 = @"Incorrect Firmware version.";
        }
        else if(_fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT)
        {
            msg1 = @"Camera offline after upgrading.";
        }
        
        msg = [NSString stringWithFormat:@"%@ Please manually off and on the camera.", msg1];
    }
    
    UIAlertView *alertViewUpgradeStatus = [[UIAlertView alloc] initWithTitle:title
                                                                     message:msg
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:ok, nil];
    alertViewUpgradeStatus.tag = alertTag;
    [alertViewUpgradeStatus show];
    [alertViewUpgradeStatus release];
}

-(void) upgradeFwProgress_ui:(NSArray *) obj
{
    //NSLog(@"%s progress:%d, fwStatus:%d", __FUNCTION__, _fwUpgradedProgress, _fwUpgradeStatus);
    
    if (_fwUpgradedProgress == 2) //6s
    {
        NSLog(@"%s Show custom dialog.", __FUNCTION__);
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [_customeAlertView show];
    }
    
    UIProgressView *percentageProgress = (UIProgressView *)obj[0];
    UILabel *percentageLabel = obj[1];

	float value = (float)_fwUpgradedProgress / 100.f;
    
    percentageLabel.text = [NSString stringWithFormat:@"%ld%%", lroundf(value * 100)];
    percentageProgress.progress = value;
}

/*
 
   INIT :  "firmware_status": 0 ------> 1 
   UPGRADING:"firmware_status": 1 .... 1
 
   DONE:  "firmware_status": 1 -----> 0
   FAILED: - TIMEOUT 
           - FW version no updated
 
 
 */

- (void )checkFwUpgradeStatus_bg
{
    NSLog(@"%s _fwUpgradePercentage:%d, _fwUpgradeStatus:%d", __FUNCTION__,_fwUpgradedProgress, _fwUpgradeStatus);
    
    while (_fwUpgradedProgress < 100 &&
           (_fwUpgradeStatus == FIRMWARE_UPGRADE_IN_PROGRESS || _fwUpgradeStatus == FIRMWARE_UPGRADE_REBOOT))
    {
        if (userWantToCancel)
        {
            NSLog(@"%s Back out.", __FUNCTION__);
            return;
        }
        
        if (_fwUpgradedProgress <= 10)// 30s
        {
            self.fwUpgradeStatus = FIRMWARE_UPGRADE_IN_PROGRESS;
        }
        else
        {
            self.fwUpgradeStatus = [self checkFwUpgradeStatusFromServer];
            
            NSLog(@"%s fwUpgradeStatus:%d", __FUNCTION__, _fwUpgradeStatus);
        }
        
        [NSThread sleepForTimeInterval:2];
    }
}

- (NSInteger )checkFwUpgradeStatusFromServer
{
    if (!_userAccount)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * userEmail  = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
        NSString * userPass   = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
        NSString * userApiKey = (NSString *) [userDefaults objectForKey:@"PortalApiKey"];
        
        _userAccount = [[UserAccount alloc] initWithUser:userEmail
                                                    password:userPass
                                                      apiKey:userApiKey
                                                    listener:nil];
    }
    
    return [_userAccount checkFwUpgrageStatusWithRegistrationId:self.selectedChannel.profile.registrationID
                                                               currentFwVersion:self.selectedChannel.profile.fw_version];
}

- (void)checkFwUpgradeByAnotherDevice
{
    //self.isFwUpgradedByAnotherDevice = NO;
    
    if ([self checkFwUpgradeStatusFromServer] == FIRMWARE_UPGRADE_IN_PROGRESS)
    {
        self.isFwUpgradedByAnotherDevice = YES;
    }
}

#pragma mark - Json communication call back

- (void)createSessionSuccessWithResponse:(NSDictionary *)responseDict
{
    [self logDebugInfo:nil];
    
    if (![self isStopProcess] &&
        [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
            self.selectedChannel.stream_url = urlResponse;
            self.selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
            
            NSLog(@"%s Start stage 2", __FUNCTION__);
            
            [self performSelectorOnMainThread:@selector(startStream)
                                   withObject:nil
                                waitUntilDone:NO];
            
            self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"low_data_bandwidth_detected", nil, [NSBundle mainBundle], @"Low data bandwidth detected. Trying to connect...", nil);
        }
        else
        {
            //handle Bad response
            NSLog(@"%s ERROR: %@", __FUNCTION__, [responseDict objectForKey:@"message"]);
            self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
            _isShowTextCameraIsNotAccesible = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self messageNotAccesible:NO];
            });
            
            [self symmetric_check_result:TRUE];
        }
    }
    else
    {
        NSLog(@"%s View is invisible OR in background mode. Do nothing!", __FUNCTION__);
    }
}

- (void)createSessionFailedWithResponse:(NSDictionary *)responseDict
{
    [self logDebugInfo:responseDict];
    
    if (![self isStopProcess] &&
        [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) // Testing this to decide using it or not
    {
        //handle Bad response
        NSLog(@"%s ERROR: %@", __FUNCTION__, [responseDict objectForKey:@"message"]);
        self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
        _isShowTextCameraIsNotAccesible = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self messageNotAccesible:NO];
        });
        
        [self symmetric_check_result:TRUE];
    }
    else
    {
        NSLog(@"%s View is invisible OR in background mode. Do nothing!", __FUNCTION__);
    }
}

- (void)createSessionFailedServerUnreachable
{
    [self logDebugInfo:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self isStopProcess] &&
            [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) // Testing this to decide using it or not
        {
            NSLog(@"SERVER unreachable (timeout) ");
//            [self showTimelineView];
            self.messageStreamingState = NSLocalizedStringWithDefaultValue(@"camera_is_not_accessible", nil, [NSBundle mainBundle], @"Camera is not accessible...", nil);
            _isShowTextCameraIsNotAccesible = YES;
            [self messageNotAccesible:NO];
            [self performSelector:@selector(setupCamera) withObject:nil afterDelay:10];
        }
        else
        {
            NSLog(@"%s View is invisible OR in background mode. Do nothing!", __FUNCTION__);
        }
    });
}

- (void)logDebugInfo:(NSDictionary *)responseDict
{
    NSLog(@"USE RELAY TO VIEW- userWantsToCancel:%d, returnFromPlayback:%d, isFWUpgradeInProgress:%d, responsed: %@", userWantToCancel, _returnFromPlayback, _isFWUpgradingInProgress, responseDict);
    
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartingStageOne];
    self.timeStartingStageOne = 0;
    NSString *gaiActionTime = GAI_ACTION(1, diff);

    [[GAI sharedInstance].defaultTracker sendTimingWithCategory:GAI_CATEGORY
                                                      withValue:diff
                                                       withName:@"Stage 1"
                                                      withLabel:nil];
    
    NSLog(@"%s stage 1 takes %f seconds \n Start stage 2 \n %@", __FUNCTION__, diff, gaiActionTime);
    self.timeStartingStageTwo = [NSDate date];
}

#pragma mark - MelodySetingDelegate
- (void)updateCompleted:(BOOL)success
{
    if (!success)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self showToat:NSLocalizedStringWithDefaultValue(@"update_melody_failed", nil, [NSBundle mainBundle], @"Update melody failed", nil)];
        });
    }
}
@end
