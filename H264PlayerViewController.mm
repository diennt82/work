//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import "H264PlayerViewController.h"
#import "EarlierViewController.h"
#import "TimelineViewController.h"
#import <CoreText/CTStringAttributes.h>
#import "define.h"
#import <CFNetwork/CFNetwork.h>
#include <ifaddrs.h>

//#import <GAI.h>
#import "KISSMetricsAPI.h"

#import "AudioOutStreamRemote.h"
#import "EarlierNavigationController.h"
#import "HttpCom.h"

//#import "Reachability.h"
#import "MBP_iosViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/message.h>

#define MODEL_SHARED_CAM @"0036"
#define MODEL_CONCURRENT @"0066"
#define MODEL_BLE        @"0083" //0836 {UAP | BLE}

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

#define HIGH_STATUS_BAR 20;

//define for Control Panel button
#define INDEX_NO_SELECT     -1
#define INDEX_PAN_TILT      0
#define INDEX_MICRO         1
#define INDEX_RECORDING     2
#define INDEX_MELODY        3
#define INDEX_TEMP          4

#define PTT_ENGAGE_BTN 711

#define TAG_ALERT_VIEW_REMOTE_TIME_OUT 559
#define TAG_ALERT_SENDING_LOG          569

#define _streamingSSID  @"string_Streaming_SSID"
#define _is_Loggedin @"bool_isLoggedIn"
#define TEST_REMOTE_TALKBACK 0 // TODO: DELETE
#define SESSION_KEY @"SESSION_KEY"
#define STREAM_ID   @"STREAM_ID"

#define TF_DEBUG_FRAME_RATE_TAG 5001
#define TF_DEBUG_RESOLUTION_TAG 5002
#define TF_DEBUG_BIT_RATE_TAG   5003

#define TIMEOUT_BUFFERING           15// 15 seconds
#define TIMEOUT_REMOTE_STREAMING    5*60 // 5 minutes

#define GAI_CATEGORY                @"Player view"

#define GAI_MIN(stage)      (stage==1?1:4)
#define GAI_MIDIUM(stage)   (stage==1?2:6)
#define GAI_MAX(stage)      (stage==1?3:8)
#define GAI_ACTION(stage, time) [NSString stringWithFormat:@"Stage %d time %@ than %d second(s)", stage, time<GAI_MAX(stage)?@"less":@"greater", time<GAI_MIN(stage)?GAI_MIN(stage):(time<GAI_MIDIUM(stage)?GAI_MIDIUM(stage):GAI_MAX(stage))]

@interface H264PlayerViewController () <TimelineVCDelegate, BonjourDelegate, AudioOutStreamRemoteDelegate>
{
    BOOL _syncPortraitAndLandscape;
    UIBarButtonItem *nowButton, *earlierButton;
    BOOL _isLandScapeMode;//cheat to display correctly timeline bottom
    BOOL _hideCustomIndicatorAndTextNotAccessble;
    //check to show custom indicator
    BOOL _isShowCustomIndicator;
    //check to show custom indicator
    BOOL _isShowTextCameraIsNotAccesible;
}

@property (retain, nonatomic) IBOutlet UIImageView *imageViewHandle;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewKnob;
@property (retain, nonatomic) IBOutlet UIView *viewDebugInfo;

@property (retain, nonatomic) EarlierViewController *earlierVC;
@property (retain, nonatomic) TimelineViewController *timelineVC;
@property (retain, nonatomic) UIImageView *imageViewStreamer;
@property (nonatomic) BOOL isHorizeShow;
@property (nonatomic, retain) NSTimer *timerHideMenu;
@property (nonatomic) BOOL isEarlierView;
@property (nonatomic) NSInteger numberOfSTUNError;
@property (nonatomic, retain) NSString *stringTemperature;
@property (nonatomic) BOOL existTimerTemperature;
@property (nonatomic) BOOL cameraIsNotAvailable;
@property (nonatomic, retain) NSThread *threadBonjour;
@property (nonatomic, retain) NSMutableArray *bonjourList;
@property (nonatomic) BOOL scanAgain;
@property (nonatomic) BOOL isFahrenheit;
@property (nonatomic, retain) NSString *cameraModel;
@property (nonatomic, retain) NSTimer *timerRemoteStreamTimeOut;
@property (nonatomic, retain) NSTimer *timerRemoteStreamKeepAlive;
@property (nonatomic, retain) NSString *apiKey;

@property (nonatomic, retain) NSString *sessionKey;
@property (nonatomic, retain) NSString *streamID;
@property (nonatomic) BOOL wantsCancelRemoteTalkback;
@property (nonatomic, retain) AudioOutStreamRemote *audioOutStreamRemote;
@property (nonatomic, retain) NSString *talkbackRemoteServer;
//check if shared cam is connected to macOS
@property (nonatomic, retain) NSString *sharedCamConnectedTo;
@property (nonatomic) BOOL remoteViewTimeout;
@property (nonatomic) BOOL disconnectAlert;
@property (nonatomic) BOOL returnFromPlayback;
@property (nonatomic) BOOL shouldUpdateHorizeMenu;
@property (nonatomic) BOOL isInLocal;
@property (nonatomic) BOOL isAlreadyHorizeMenu;
@property (nonatomic, retain) BMS_JSON_Communication *jsonCommBlocked;
@property (nonatomic, assign) EarlierNavigationController *earlierNavi;
@property (nonatomic) BOOL wantToShowTimeLine;
@property (nonatomic, retain) NSTimer *timerIncreaseBitRate;
@property (nonatomic, retain) NSString *currentBitRate;
@property (nonatomic, retain) NSString *messageStreamingState;
@property (nonatomic, retain) NSTimer *timerBufferingTimeout;
@property (nonatomic, retain) UIAlertView *alertViewTimoutRemote;
@property (nonatomic, retain) NSDate *timeStartingStageTwo;
@property (nonatomic) NSTimeInterval timeStageTwoTotal;
@property (nonatomic, retain) NSDate *timeStartPlayerView;
@property (nonatomic) NSInteger mediaProcessStatus;

//property for Touch to Talk
@property (nonatomic) BOOL walkieTalkieEnabled;
@property (nonatomic) BOOL disableAutorotateFlag;
@property (nonatomic) BOOL enablePTT;
@property (nonatomic, retain) NSString *stringStatePTT;
@property (nonatomic) NSInteger numbersOfRemoteViewError;
@property (nonatomic, retain) NSString *current_ssid;

#ifdef SHOW_DEBUG_INFO
//for debug
@property (nonatomic, retain) NSString *viewVideoIn;
#endif

@property (nonatomic, retain) UIControl *backCover;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer;

@end

@implementation H264PlayerViewController

@synthesize  alertTimer;
@synthesize  askForFWUpgradeOnce;
@synthesize   client = _client;
@synthesize horizMenu = _horizMenu;
@synthesize itemImages = _itemImages;
@synthesize itemSelectedImages = _itemSelectedImages;
@synthesize selectedItemMenu = _selectedItemMenu;

double _ticks = 0;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Following is not needed as nib layouts already setup with iOS 6/7 Deltas.
    /*
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    */
    
    _hideCustomIndicatorAndTextNotAccessble = NO;
    
    // update navi
    self.earlierNavi = (EarlierNavigationController *)self.navigationController;
    self.earlierNavi.isEarlierView = NO;
    _selectedItemMenu = INDEX_NO_SELECT;
    [self.ib_buttonChangeAction setHidden:NO];
    [self.view bringSubviewToFront:self.ib_buttonChangeAction];
    [self.ib_labelRecordVideo setText:@"Record Video"];
    [self.ib_labelTouchToTalk setText:@"Touch to Talk"];

    //setup Font
    [self applyFont];
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    CFRelease(soundFileURLRef);
    
    [self updateNavigationBarAndToolBar];
    //[self addHubbleLogo_Back];
    
    self.imageViewStreamer = [[UIImageView alloc] initWithFrame:_imageViewVideo.frame];
    //[self.imageViewStreamer setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageViewStreamer setBackgroundColor:[UIColor blackColor]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapGestureCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageViewStreamer addGestureRecognizer:singleTap];
    [singleTap release];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    self.imageViewStreamer.userInteractionEnabled = NO;
    self.sharedCamConnectedTo = @"";
    self.cameraModel = [self.selectedChannel.profile getModel];
    
    // Move dow SetupCamera temporarily. Need to update here!
    
    //[self initHorizeMenu: _cameraModel];
    [self performSelectorInBackground:@selector(initHorizeMenu:) withObject:_cameraModel];
    
    //set text name for camera name
    [self.ib_lbCameraName setText:self.selectedChannel.profile.name];
    
    _isDegreeFDisplay = [userDefaults boolForKey:@"IS_FAHRENHEIT"];
    _resolution = @"";
    
    NSString *serverInput = [userDefaults stringForKey:@"name_server"];
    serverInput = [serverInput substringToIndex:serverInput.length - 3];
    self.talkbackRemoteServer = [serverInput stringByReplacingOccurrencesOfString:@"api" withString:@"talkback"];
    self.talkbackRemoteServer = [_talkbackRemoteServer stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
    
    self.remoteViewTimeout = [userDefaults boolForKey:@"remote_view_timeout"];
    self.disconnectAlert   = [userDefaults boolForKey:@"disconnect_alert"];
    
    self.enablePTT = YES;
    self.numbersOfRemoteViewError = 0;
    self.currentBitRate = @"128";
    self.messageStreamingState = @"Camera is not accessible";
    self.timeStartingStageTwo = 0;

#ifndef DEBUG
    // Remove debug buttons for Release builds
    [_ib_btShowDebugInfo removeFromSuperview];
    [self setIb_btShowDebugInfo:nil];
    

    
    self.customIndicator.image = [UIImage imageNamed:@"loader_a"];
    
    NSLog(@"camera model is :%@", self.cameraModel);

    [_sendLogButton removeFromSuperview];
    [self setSendLogButton:nil];
#endif
    
    [self checkOrientation];
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView view will appear - return from Playback: %d", _returnFromPlayback] withProperties:nil];
    NSLog(@"%s -_wantToShowTimeLine: %d, userWantToCancel: %d, returnFromPlayback: %d", __FUNCTION__, _wantToShowTimeLine, userWantToCancel, _returnFromPlayback);
    
    self.trackedViewName = GAI_CATEGORY;
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewWillAppear"
                                                     withLabel:nil
                                                     withValue:nil];

    [self startStreamPlayback];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimerRecoring];
    [_backCover removeFromSuperview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    NSLog(@"%s", __FUNCTION__);
    [self setImageViewVideo:nil];
    //    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    [self setCameraNameBarBtnItem:nil];
    [self setSelectedChannel:nil];
    [self setBackCover:nil];
}

- (void)applyFont
{
    if (_isLandScapeMode) {
        //update position text recording
        // update position button
        //Touch to Talk (size = 75, bottom align = 30
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
        
        
        if (isiPhone4 || isiPhone5) {
            //alignYTTT = alignYTTT;
            //alignYButtonRecord = alignYButtonRecord;
            //alignYButtonDirectionPad = alignYButtonDirectionPad;
        }
        else {
            alignYTTT -= 94;
            alignYButtonRecord -= 94;
            alignYButtonDirectionPad -= 94;
        }
        
        [self.ib_ViewTouchToTalk setFrame:CGRectMake(alignXTTT, alignYTTT, holdTTButtonSize.width, holdTTButtonSize.height)];
        
        [self.ib_viewRecordTTT setFrame:CGRectMake(alignXButtonRecord, alignYButtonRecord, viewRecordSize.width, viewRecordSize.height)];
        [_imgViewDrectionPad setFrame:CGRectMake(alignXButtonDirectionPad, alignYButtonDirectionPad, directionPadSize.width, directionPadSize.height)];
    }
    else {
        //UIFont *font;
        //UIColor *color;
        float marginBottomText, marginBottomButton, positionYOfBottomView;
        CGFloat fontSize = 19;
        
        if (isiPhone5) {
            //for holdtotalk
            //font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:19];
            fontSize = 19;
            //color = [UIColor holdToTalkTextColor];
            marginBottomText = 42;
            marginBottomButton = 81;
            positionYOfBottomView = 255;
            
        }
        else if (isiPhone4) {
            //for holdtotalk
            //font = [UIFont applyHubbleFontName:PN_REGULAR_FONT withSize:17];
            fontSize = 17;
            //color = [UIColor holdToTalkTextColor];
            marginBottomText = 25.0f;
            marginBottomButton = 48.0f;
            positionYOfBottomView = self.ib_viewRecordTTT.frame.origin.y;
        }
        else {
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
        
        if (_isRecordInterface && _isProcessRecording) {
            self.ib_labelRecordVideo.textColor = [UIColor recordingTextColor];
        }
        else {
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
        
        if (isiOS7AndAbove) {
            [self.ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY)];
            [self.ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1)];
        }
        else {
            [self.ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY - 64)];
            [self.ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1 - 64)];
        }
        
        // update position button
        //Touch to Talk
        CGSize holdTTButtonSize = self.ib_buttonTouchToTalk.bounds.size;
        CGSize directionPadSize = self.imgViewDrectionPad.bounds.size;
        float alignXButton = SCREEN_WIDTH/2- holdTTButtonSize.width/2;
        float alignXButtonDirectionPad = SCREEN_WIDTH/2- directionPadSize.width/2;
        float alignYButton = SCREEN_HEIGHT - localPoint.y - marginBottomButton - holdTTButtonSize.height;
        float alignYButtonDirectionPad = (SCREEN_HEIGHT - localPoint.y - directionPadSize.height)/2;
        
        if (!isiOS7AndAbove) {
            alignYButton = alignYButton - 64;
            alignYButtonDirectionPad = alignYButtonDirectionPad - 44 - 64;
        }
        
        [self.ib_buttonTouchToTalk setFrame:CGRectMake(alignXButton, alignYButton, holdTTButtonSize.width, holdTTButtonSize.height)];
        [self.ib_processRecordOrTakePicture setFrame:CGRectMake(alignXButton, alignYButton, holdTTButtonSize.width, holdTTButtonSize.height)];
        [_imgViewDrectionPad setFrame:CGRectMake(alignXButtonDirectionPad, alignYButtonDirectionPad + localPoint.y, directionPadSize.width, directionPadSize.height)];
    }
}

- (void)setupHttpPort
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
    [self resetZooming];
    
    //Add action for touch
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [_imageViewStreamer addGestureRecognizer:doubleTapRecognizer];
    [doubleTapRecognizer release];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [_imageViewStreamer addGestureRecognizer:twoFingerTapRecognizer];
    [twoFingerTapRecognizer release];
}

/**
 remove gestures touch when at portrait
 */
- (void)removeGestureRecognizerAtPortraitMode
{
    for (UITapGestureRecognizer *gesture in [_imageViewStreamer gestureRecognizers]) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (gesture.numberOfTapsRequired == 2 || gesture.numberOfTouchesRequired == 2) {
                [_imageViewStreamer removeGestureRecognizer:gesture];
            }
        }
    }
}

/**
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

- (void)updateNavigationBarAndToolBar
{
    if ( ![self.selectedChannel.profile isSharedCam] ) {
        // SharedCam
        nowButton = [[UIBarButtonItem alloc] initWithTitle:@"Now"
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(nowButtonAciton:)];
        [nowButton setTitleTextAttributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:PN_SEMIBOLD_FONT size:17.0],
                                            NSForegroundColorAttributeName:[UIColor barItemSelectedColor]
                                            } forState:UIControlStateNormal];
        
        earlierButton = [[UIBarButtonItem alloc] initWithTitle:@"Earlier"
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CamProfile *cp = self.selectedChannel.profile;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self setTitle:cp.name];
            [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        }
        else {
            [self.navigationItem setTitle:cp.name];
            [self.topToolbar setHidden:YES];
        }
    }
}

- (void)nowButtonAciton:(id)sender
{
    // Ensure CAM_IN_VEW is set so that view rotations happen as needed.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_selectedChannel.profile.mac_address forKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Touch up inside NOW btn item" withProperties:nil];
    
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
    
    self.earlierNavi.isEarlierView = NO;
    
    if (_wantToShowTimeLine) {
        [self showTimelineView];
        _wantToShowTimeLine = NO;
    }
    
    _earlierVC.view.hidden = YES;
    _earlierVC.camChannel = nil;
    
    [self displayCustomIndicator];
}

- (void)earlierButtonAction:(id)sender
{
    // Remove the CAM_IN_VEW so that view rotations happen as needed.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];

    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Touch up inside EARLIER btn item" withProperties:nil];
    
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
    
    //_wantToShowTimeLine = YES;
    
    if ( !_earlierVC ) {
        self.earlierVC = [[EarlierViewController alloc] initWithParentVC:self camChannel:self.selectedChannel];
        _earlierVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    
    [self.view addSubview:_earlierVC.view];
    [self.view bringSubviewToFront:_earlierVC.view];
    _earlierVC.view.hidden = NO;
    _earlierVC.camChannel = self.selectedChannel;
    
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
    
    if (self.recordingFlag == TRUE) {
        modeRecording = @"on";
    }
    else {
        modeRecording = @"off";
    }
    
    [self performSelectorInBackground:@selector(setTriggerRecording_bg:)
                           withObject:modeRecording];
}

- (IBAction)melodyTouchAction:(id)sender
{
    if ( self.melodyViewController ) {
        [self.view addSubview:self.melodyViewController.view];
        [self.view bringSubviewToFront:self.melodyViewController.view];
    }
}

- (IBAction)btnSendingLogTouchUpInside:(id)sender
{
    UIAlertView *alertViewSendingLog = [[UIAlertView alloc] initWithTitle:@"Request Camera log?"
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"NO"
                                                        otherButtonTitles:@"YES", nil];
    alertViewSendingLog.tag = TAG_ALERT_SENDING_LOG;
    alertViewSendingLog.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertViewSendingLog textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alertViewSendingLog textFieldAtIndex:0].placeholder = @"Password";
    [alertViewSendingLog show];
    [alertViewSendingLog release];
}

#pragma mark - Delegate Stream callback

- (void)forceRestartStream:(NSTimer *)timer
{
    NSLog(@"%s h264Streamer: %p", __FUNCTION__, h264Streamer);
    [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:-99 ext2:-1];
    self.messageStreamingState = @"Low data bandwidth detected. Trying to connect...";
}

- (void)handleMessage:(int)msg ext1:(int)ext1 ext2:(int)ext2
{
    NSArray *args = @[[NSNumber numberWithInt:msg],
                      [NSNumber numberWithInt:ext1],
                      [NSNumber numberWithInt:ext2]];
    
    [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:) withObject:args waitUntilDone:NO];
}

- (void)handleMessageOnMainThread:(NSArray *)args
{
    NSNumber *numberMsg = (NSNumber *)[args objectAtIndex:0];
    int msg = [numberMsg integerValue];
    
    int ext1 = -1, ext2=-1;
    if ([args count] >= 3) {
        ext1 = [[args objectAtIndex:1] integerValue];
        ext2 = [[args objectAtIndex:2] integerValue];
    }
    
    //NSLog(@"currentMediaStatus: %d", msg);
    
    switch (msg)
    {
        case MEDIA_INFO_GET_AUDIO_PACKET:
            //NSLog(@"%s Got audio packet", __FUNCTION__);
            
            if (_timerBufferingTimeout) {
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

            NSLog(@"%s MEDIA_INFO_START_BUFFERING", __FUNCTION__);
            
            if (_timerBufferingTimeout) {
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
            
            if (_timerBufferingTimeout) {
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
            // Maintain Aspect Ratio
            if (ext1 == 0 || ext2 == 0) {
                break;
            }
            
            float ratio = (float) ext1/ (float)ext2;
            float fw = self.imageViewVideo.frame.size.height * ratio;
            float fh = self.imageViewVideo.frame.size.width  / ratio;
            
            NSLog(@"video adjusted size:r= %f    fw=%f  fh=%f", ratio, fw, fh);
            
            if ( fw > self.imageViewVideo.frame.size.width) {
                // Use the current width with new-height
                destWidth = self.imageViewVideo.frame.size.width ;
                destHeight = fh;
                
                // so need to adjust the origin
                left = self.imageViewVideo.frame.origin.x;
            }
            else {
                // Use the new-width with current height
                destWidth =  fw;
                destHeight = self.imageViewVideo.frame.size.height;
                
                // so need to adjust the origin
                if (self.imageViewVideo.frame.size.width > fw) {
                    left = (self.imageViewVideo.frame.size.width - fw)/2;
                }
                else {
                    left = self.imageViewVideo.frame.origin.x;
                }
            }
            
            NSLog(@"video adjusted size: %f x %f", destWidth, destHeight);
            
            self.imageViewStreamer.frame = CGRectMake(left,
                                                      top,
                                                      destWidth, destHeight);
            break;
        }
        case MEDIA_INFO_BITRATE_BPS:
        {
            if (userWantToCancel == TRUE) {
                NSLog(@"*[MEDIA_INFO_BITRATE_BPS] **SHOULD NOT HAPPEN FREQUENTLY* USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
                break;
            }
            
            if (self.h264StreamerIsInStopped == TRUE) {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
            }
            
#ifdef SHOW_DEBUG_INFO
            [self updateDebugInfoBitRate:ext1];
#endif
        }
            break;
            
        case MEDIA_INFO_HAS_FIRST_IMAGE:
        {
            _isShowCustomIndicator = NO;
            [self displayCustomIndicator];
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"TEST_MEDIA"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.timeStageTwoTotal = [[NSDate date] timeIntervalSinceDate:_timeStartingStageTwo];
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartPlayerView];
            
            NSLog(@"%s total time: %f, stage 2 takes %f seconds", __FUNCTION__, diff, _timeStageTwoTotal);
            
            self.timeStartingStageTwo = 0;
            
            NSLog(@"[MEDIA_PLAYER_HAS_FIRST_IMAGE]");
            if(self.selectedChannel.profile.isInLocal == NO)
            {
                if (_timerIncreaseBitRate)
                {
                    [_timerIncreaseBitRate invalidate];
                    self.timerIncreaseBitRate = nil;
                }
                
                if ([_currentBitRate isEqualToString:@"128"]) {
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"600"];
                }
                else if (![_currentBitRate isEqualToString:@"600"]) {
                    self.timerIncreaseBitRate = [NSTimer scheduledTimerWithTimeInterval:60
                                                                                 target:self
                                                                               selector:@selector(increaseBitRate:)
                                                                               userInfo:nil
                                                                                repeats:NO];
                }
                
                [self createTimerKeepRemoteStreamAlive];
                
                self.numbersOfRemoteViewError = 1;
            }
            
            self.currentMediaStatus = msg;
            
            if (self.selectedChannel.communication_mode == COMM_MODE_STUN) {
                self.numberOfSTUNError = 0;
            }
            
            if (self.probeTimer != nil && [self.probeTimer isValid]) {
                [self.probeTimer invalidate];
                self.probeTimer = nil;
            }
            
            [self stopPeriodicPopup];
            
            if (self.h264StreamerIsInStopped == TRUE) {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
                break;
            }
            
            if (userWantToCancel == TRUE) {
                NSLog(@"*[MEDIA_PLAYER_HAS_FIRST_IMAGE] *** USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
            }
            else {
                if ( self.selectedChannel.profile.isInLocal && (self.askForFWUpgradeOnce == YES)) {
                    [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
                    self.askForFWUpgradeOnce = NO;
                }

                if (!self.selectedChannel.profile.isInLocal)
                {
                    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartingStageTwo];
                    
                    NSString *gaiActionTime = GAI_ACTION(2, diff);
                    NSLog(@"%s gaiActionTime: %@", __FUNCTION__, gaiActionTime);
                    
                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                    withAction:gaiActionTime
                                                                     withLabel:nil
                                                                     withValue:nil];
                    self.timeStartingStageTwo = 0;
                    
                    if (_remoteViewTimeout == YES) {
                        [self reCreateTimoutViewCamera];
                    }
                }
                
                self.imageViewStreamer.userInteractionEnabled = YES;
                self.imgViewDrectionPad.userInteractionEnabled = YES;
                
                if (isiPhone4) {
                    self.imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg"];
                }
                else {
                    self.imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg@5.png"];
                }
                
                [self performSelectorInBackground:@selector(getCameraTemperature_bg:) withObject:nil];
                
                self.horizMenu.userInteractionEnabled = YES;
            }
        }
            break;
            
        case MEDIA_PLAYER_STARTED:
        {
            self.currentMediaStatus = msg;
            
            if (userWantToCancel == TRUE) {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
                break;
            }
            
            if (self.h264StreamerIsInStopped == TRUE) {
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
            
            //set custom indication is TRUE when server die
            _isShowCustomIndicator = YES;
            _isShowTextCameraIsNotAccesible = YES;
            
            if (_timerBufferingTimeout) {
                [_timerBufferingTimeout invalidate];
                self.timerBufferingTimeout = nil;
            }
            
            if (_timerRemoteStreamKeepAlive) {
                [_timerRemoteStreamKeepAlive invalidate];
                self.timerRemoteStreamKeepAlive = nil;
            }
            
    		NSLog(@"Timeout While streaming  OR server DIED - userWantToCancel: %d, returnFromPlayback: %d, forceStop: %d", userWantToCancel, _returnFromPlayback, ext1);
            
    		//mHandler.dispatchMessage(Message.obtain(mHandler, Streamer.MSG_VIDEO_STREAM_HAS_STOPPED_UNEXPECTEDLY));
            
            if (userWantToCancel == TRUE) {
                NSLog(@"*[MEDIA_ERROR_TIMEOUT_WHILE_STREAMING] *** USER want to cancel **.. cancel after .1 sec...");
                self.selectedChannel.stopStreaming = TRUE;

                [self performSelector:@selector(goBackToCameraList)
                           withObject:nil
                           afterDelay:0.1];
                return;
            }
            else {
                // Need not to do if went to Playback.
                if (!_returnFromPlayback) {
                    [self displayCustomIndicator];
                }
            }
            
            if (self.h264StreamerIsInStopped == TRUE || _returnFromPlayback || [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            {
                self.selectedChannel.stopStreaming = TRUE;
                [self performSelector:@selector(stopStream)
                           withObject:nil
                           afterDelay:0.1];
                return;
            }
            
            if (self.selectedChannel.communication_mode == COMM_MODE_STUN) {
                self.numberOfSTUNError++;
            }
            else if (self.selectedChannel.communication_mode == COMM_MODE_STUN_RELAY2) {
                if (_timerIncreaseBitRate) {
                    [_timerIncreaseBitRate invalidate];
                    self.timerIncreaseBitRate = nil;
                }
                
                self.numbersOfRemoteViewError++;
                
                if ([_currentBitRate isEqualToString:@"600"]) {
                    self.currentBitRate = @"550";// Dont care it set succeeded or failed!
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
                }
                else if ([_currentBitRate isEqualToString:@"550"]) {
                    self.currentBitRate = @"500";// Dont care it set succeeded or failed!
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
                }
                else if ([_currentBitRate isEqualToString:@"500"]) {
                    self.currentBitRate = @"450";// Dont care it set succeeded or failed!
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
                }
                else if ([_currentBitRate isEqualToString:@"450"]) {
                    self.currentBitRate = @"400";// Dont care it set succeeded or failed!
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
                }
                else if ([_currentBitRate isEqualToString:@"400"]) {
                    self.currentBitRate = @"350";// Dont care it set succeeded or failed!
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:_currentBitRate];
                }
                else if ([_currentBitRate isEqualToString:@"350"]) {
                    // Update current bit rate only set succeeded!
                    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"300"];
                }
                else {
                    NSLog(@"%s: numbers of remote streaming error: %d, curr Bit-rate; %@", __FUNCTION__, _numbersOfRemoteViewError, _currentBitRate);
                }
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
            
            // Stop Streamming
            [self stopStream];
            
            // Start streaming
            if (self.selectedChannel.profile.isInLocal == TRUE)
            {
                /* re-scan for the camera */
                //[self scan_for_missing_camera];
                //[self setupCamera];
                [self scanCamera];
            }
            else {
                //Remote connection -> go back and retry
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
    
    //NSLog(@"H264VC - handleMsg -imageVideo: %@, imageStreamer: %@", NSStringFromCGRect(_imageViewVideo.frame), NSStringFromCGRect(_imageViewStreamer.frame));
    
    
}

- (void)reCreateTimoutViewCamera
{
    if ( _timerRemoteStreamTimeOut && [_timerRemoteStreamTimeOut isValid] ) {
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
    if (_timerRemoteStreamKeepAlive) {
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
    if (userWantToCancel || _returnFromPlayback || !MediaPlayer::Instance()->isPlaying()) {
        return;
    }
    
    if ( !_jsonCommBlocked ) {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSDictionary *responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                            andClientType:@"BROWSER"
                                                                                andApiKey:_apiKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (responseDict && [[responseDict objectForKey:@"status"] intValue] == 200) {
            NSLog(@"%s SUCCEEDED", __FUNCTION__);
            [self createTimerKeepRemoteStreamAlive];
        }
        else {
            NSLog(@"%s FAILED -responseDict: %@", __FUNCTION__, responseDict);
            [self performSelector:@selector(sendKeepAliveCmd:) withObject:nil afterDelay:1];
        }
    });
}

#pragma mark - TimelineVCDelegate protocol methods

- (void)stopStreamPlayback
{
    NSLog(@"%s - currentMediaStatus: %d, h264Streamer: %p", __FUNCTION__, _currentMediaStatus, h264Streamer);
    self.returnFromPlayback = TRUE;
    self.h264StreamerIsInStopped = TRUE;
    self.selectedChannel.stream_url = nil;
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (_audioOutStreamRemote) {
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
#if 1
    NSLog(@"%s _mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    if (_mediaProcessStatus == 0) {
        
    }
    else if(_mediaProcessStatus == 1) {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
    }
    else if (_mediaProcessStatus == 2) {
        MediaPlayer::Instance()->sendInterrupt();
    }
    else {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
    }
#else
    if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
        self.currentMediaStatus == MEDIA_PLAYER_STARTED ||
        (self.currentMediaStatus == 0)) // Media player haven't start yet.
    {
        [self stopStream];
    }
    else if (MediaPlayer::Instance() != NULL) {
        MediaPlayer::Instance()->sendInterrupt(); // Assuming h264Streamer stop itself.
    }
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startStreamPlayback
{
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleEnteredBackground)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(h264_HandleBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    //alway show custom indicator, when view appear
    _isShowCustomIndicator = YES;
    self.currentMediaStatus = 0;
    self.shouldUpdateHorizeMenu = YES;
    self.wantToShowTimeLine = YES;
    _viewVideoIn = @"R";
    
    if ( !_returnFromPlayback ) {
        _isFirstLoad = YES;
        _isRecordInterface  = YES;
        _isProcessRecording = NO;
        _isListening = NO;
        _ticks = 0.0;
        
        if ( _timelineVC ) {
            self.timelineVC.camChannel = self.selectedChannel;
        }
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.returnFromPlayback = FALSE;
        
        [self performSelectorOnMainThread:@selector(scanCamera)
                               withObject:nil
                            waitUntilDone:NO];
        
        self.h264StreamerIsInStopped = FALSE;
    }
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:_selectedChannel.profile.mac_address forKey:CAM_IN_VEW];
//    [userDefaults synchronize];
    
    [self checkOrientation];
    
    if ( !_backCover ) {
        // Cover the back button so we can overide the default back action
        self.backCover = [[UIControl alloc] initWithFrame:CGRectMake( 0, 0, 100, 44)]; // Width setup for @"Cameras"
        [_backCover addTarget:self action:@selector(prepareGoBackToCameraList:) forControlEvents:UIControlEventTouchUpInside];
        
        // Show the cover for testing
        //_backCover.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.15];
    }
    
    // Ensure view is reset of else we can lose it!
    [_backCover removeFromSuperview];
    [self.navigationController.navigationBar addSubview:_backCover];
}

#pragma mark - Delegate Melody

- (void)setMelodyWithIndex:(NSInteger)molodyIndex
{
}

#pragma mark - Method

- (void)singleTapGestureCaptured:(id)sender
{
    NSLog(@"Single tap singleTapGestureCaptured");
    
    if (_isHorizeShow == TRUE) {
        [self hideControlMenu];
    }
    else {
        [self showControlMenu];
    }
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView single tap on video image view: %d", _isHorizeShow] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"single tap on video image view"
                                                     withLabel:@"Vide image view"
                                                     withValue:[NSNumber numberWithDouble:_isHorizeShow]];
}

- (void)hideControlMenu
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         _menuBackgroundView.alpha = 0;
                         self.isHorizeShow = FALSE;
                         self.horizMenu.alpha = 0;
                         self.ib_lbCameraName.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.horizMenu.hidden = YES;
                         self.ib_lbCameraName.hidden = YES;
                     }
     ];
}

- (void)showControlMenu
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _menuBackgroundView.alpha = 1;
                         _menuBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

                         self.isHorizeShow = TRUE;
                         self.horizMenu.hidden = NO;
                         [self.view bringSubviewToFront:_horizMenu];
                         self.horizMenu.alpha = 1.0;
                         self.ib_lbCameraName.hidden = NO;
                         self.ib_lbCameraName.alpha = 1.0;
                     }
                     completion:nil
     ];
    
    if ( _timerHideMenu ) {
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
    if ( _timelineVC ) {
        self.timelineVC.view.hidden = YES;
    }
    [_timerHideMenu release];
    _timerHideMenu = nil;
    
}

- (void)showTimelineView
{
    //reset selected menu;
    _selectedItemMenu = -1;
    
    if ( _timelineVC ) {
        self.timelineVC.view.hidden = NO;
        [self.view bringSubviewToFront:self.timelineVC.view];
    }
}

- (void)h264_HandleBecomeActive
{
    NSLog(@"%s wants to cancel: %d, rtn frm Playback: %d", __FUNCTION__, userWantToCancel, _returnFromPlayback);
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Become active" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Become Active"
                                                     withLabel:nil
                                                     withValue:[NSNumber numberWithDouble:userWantToCancel]];
    
    if ( userWantToCancel || _returnFromPlayback) {
        return;
    }
    
    self.h264StreamerIsInStopped = FALSE;
    self.currentMediaStatus = 0;
    self.wantToShowTimeLine = YES;
    
    if (!_earlierNavi.isEarlierView) {
        [self showTimelineView];
    }
    
    if (_selectedChannel.profile.isInLocal == TRUE) {
        NSLog(@"Become ACTIVE _  .. Local");
    }
    else if ( _selectedChannel.profile.minuteSinceLastComm <= 5) {
        // Remote
        NSLog(@"Become ACTIVE _  .. REMOTE");
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL cancelBecauseOfPn = [userDefaults boolForKey:HANDLE_PN];
    if (cancelBecauseOfPn == TRUE) {
        NSLog(@"set user = true");
        userWantToCancel = TRUE;
        return;
    }
    
    [self scanCamera];
}

- (void)h264_HandleEnteredBackground
{
    NSLog(@"%s wants to cancel: %d, rtn frm Playback: %d, nav: %@", __FUNCTION__, userWantToCancel, _returnFromPlayback, self.navigationController.visibleViewController.description);
    
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Enter background" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Enter background"
                                                     withLabel:@"Homekey"
                                                     withValue:[NSNumber numberWithDouble:userWantToCancel]];
    
    if (userWantToCancel || _returnFromPlayback) {
        return;
    }
    
    _selectedChannel.stopStreaming = TRUE;
    
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (_alertViewTimoutRemote) {
        [_alertViewTimoutRemote dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    if (_audioOutStreamRemote) {
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
    
#if 1
    if (_mediaProcessStatus == 0) {
        
    }
    else if(_mediaProcessStatus == 1) {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
    }
    else if (_mediaProcessStatus == 2) {
        MediaPlayer::Instance()->sendInterrupt();
    }
    else {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
    }
#else
    if (self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
        self.currentMediaStatus == MEDIA_PLAYER_STARTED ||
        (self.currentMediaStatus == 0 && h264Streamer == NULL)) // Media player haven't start yet.
    {
        NSLog(@"H264VC - handleEnteredBackground - IF()");
        [self stopStream];
    }
    else if( h264Streamer )
    {
        NSLog(@"H264VC - handleEnteredBackground - else if(h264Streamer != nil)");
        h264Streamer->sendInterrupt();
    }
#endif
    
    self.h264StreamerIsInStopped = TRUE;
    self.imageViewVideo.backgroundColor = [UIColor blackColor];
    self.imageViewStreamer.backgroundColor = [UIColor blackColor];
    
    if (_selectedChannel.profile.isInLocal == TRUE) {
        NSLog(@"Enter Background.. Local ");
    }
    else if (_selectedChannel.profile.minuteSinceLastComm <= 5) {
        // Remote
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
    if (![_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]) {
        // CameraHD
        self.timelineVC = [[TimelineViewController alloc] init];
        [self.view addSubview:_timelineVC.view];
        _timelineVC.timelineVCDelegate = self;
        _timelineVC.camChannel = self.selectedChannel;
        _timelineVC.parentVC = self;
        
        [_timelineVC loadEvents:_selectedChannel];
    }
    
    self.selectedChannel.stopStreaming = NO;
    [self displayCustomIndicator];
    [self scanCamera];
    [self hideControlMenu];
    
    NSLog(@"Check selectedChannel is %@ and ip of deviece is %@", self.selectedChannel, self.selectedChannel.profile.ip_address);
    
    [self setupPtt];
    
    self.stringTemperature = @"0";
    //end add button to change
    [ib_switchDegree setHidden:YES];
    
    self.imageViewHandle.hidden = YES;
    self.imageViewKnob.center = self.imgViewDrectionPad.center;
    self.imageViewHandle.center = self.imgViewDrectionPad.center;
    
    NSLog(@"H264VC - becomeActive -timeline: %@", NSStringFromCGRect(self.timelineVC.view.frame));
}

#pragma mark - Shared Cam

- (void)queryToKnowSharedCamOnMacOSOrWin
{
    NSString *bodyKey = @"";
    
    if ( self.selectedChannel.profile.isInLocal ) {
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"get_running_os"];
        if ( response ) {
            self.sharedCamConnectedTo = [[response componentsSeparatedByString:@": "] objectAtIndex:1];
        }
	}
	else if (self.selectedChannel.profile.minuteSinceLastComm <= 5) {
        // Remote
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        if (_jsonCommBlocked == nil) {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:[NSString stringWithFormat:@"action=command&command=get_running_os"]
                                                                                  andApiKey:apiKey];
        if ( responseDict ) {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200) {
                bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
        if (![bodyKey isEqualToString:@""]) {
            NSArray * tokens = [bodyKey componentsSeparatedByString:@": "];
            if ([tokens count] >=2 ) {
                self.sharedCamConnectedTo = [tokens objectAtIndex:1];//return MacOS|Window
            }
        }
        else {
            //default is connected to window.
            _sharedCamConnectedTo = @"Unknown";
        }
	}
}

- (void)createMonvementControlTimer
{
    [self cleanUpDirectionTimers];
    if ([_cameraModel isEqualToString:CP_MODEL_BLE]) //MBP83
    {
        
        
        NSLog(@"H264VC - createMonvementControlTimer");
        
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
    self.isInLocal = self.selectedChannel.profile.isInLocal;
    self.mediaProcessStatus = 0;
    [self createMonvementControlTimer];
    
    _isShowCustomIndicator = YES;
    [self displayCustomIndicator];
    self.selectedChannel.stream_url = nil;
    
    [self setupHttpPort];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"H264VC - setupCamera -device_ip: %@, -device_port: %d, -{remote_only: %d}", self.selectedChannel.profile.ip_address, self.selectedChannel.profile.port, [userDefaults boolForKey:@"remote_only"]);
    //Support remote UPNP video as well
    if (self.selectedChannel.profile.isInLocal == TRUE) {
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
        self.ib_labelTouchToTalk.text = @"Touch to Talk";
        self.stringStatePTT = @"Touch to Talk";
    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5) {
        NSLog(@"H264VC - setupCamera - created a remote streamer - {enable_stun}: %@", [userDefaults objectForKey:@"enable_stun"]);
#if 1
        // Ignore enable_stun value key
        [self symmetric_check_result:TRUE];
#else
        // This value is setup on Account view
        if([userDefaults boolForKey:@"enable_stun"] == FALSE) {
            // Force APP_IS_ON_SYMMETRIC_NAT to use RELAY mode
            [self symmetric_check_result:TRUE];
        }
        else {
            if ( !_client ) {
                _client = [[StunClient alloc] init];
            }
            
            int symmetric_nat_status = [userDefaults integerForKey:APP_IS_ON_SYMMETRIC_NAT];
            
            //For any reason it fails to check earlier, we try checking now.
            if (symmetric_nat_status == TYPE_UNKNOWN) {
                //Non Blocking call
                [self.client test_start_async:self];
            }
            else {
                //call direct the callback
                [self symmetric_check_result: (symmetric_nat_status == TYPE_SYMMETRIC_NAT)];
            }
        }
#endif
        
        self.ib_labelTouchToTalk.text = @"Touch to Talk";
        self.stringStatePTT = @"Touch to Talk";
    }
    else {
        NSLog(@"Unknown Exception!");
    }
}

- (void)startStunStream
{
    self.selectedChannel.communication_mode = COMM_MODE_STUN;
    NSDate * timeout;
    NSRunLoop * mainloop = [NSRunLoop currentRunLoop];
    
    do {
        //send probes
        [_client sendAudioProbesToIp:_selectedChannel.profile.camera_mapped_address
                                 andPort:_selectedChannel.profile.camera_stun_audio_port];
        [NSThread sleepForTimeInterval:0.3];
        
        [_client sendVideoProbesToIp:_selectedChannel.profile.camera_mapped_address
                                 andPort:_selectedChannel.profile.camera_stun_video_port];
        //[NSThread sleepForTimeInterval:0.3];
        
        timeout = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [mainloop runUntilDate:timeout];
        
        if (userWantToCancel== TRUE) {
            NSLog(@"startStunStream: userWantToCancel >>>>");
            break;
        }
    }

    while ( !_selectedChannel.stream_url || _selectedChannel.stream_url.length == 0 );
    
    if ( !userWantToCancel ) {
        self.probeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(periodicProbe:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    
    NSLog(@"--URL: %@", _selectedChannel.stream_url);
    [self startStream];
}

- (void)startStream
{
    self.h264StreamerIsInStopped = NO;
    
    if ( userWantToCancel ) {
        NSLog(@"startStream: userWantToCancel >>>>");
        //force this to gobacktoCameralist
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:0 ext2:0];
        return;
    }
    
    if ( _returnFromPlayback ) {
        NSLog(@"H264VC - startStream --> break to Playback");
        return;
    }
    
    self.mediaProcessStatus = 1;
    NSLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
#if 1
    h264StreamerListener = new H264PlayerListener(self);
    MediaPlayer::Instance()->setListener(h264StreamerListener);
    MediaPlayer::Instance()->setPlaybackAndSharedCam(false, [_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]);
    //self.mediaProcessStatus = 2;
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
#else
    while (h264Streamer != NULL) {
        //NSLog(@"%s userWantToCancel: %d, _currentMediaStatus: %d", __FUNCTION__, userWantToCancel, _currentMediaStatus);
        
        if ( userWantToCancel || _currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ) {
            // 904
            return;
        }
        
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
    }
    
    h264Streamer = new MediaPlayer(false, [_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]);
    h264StreamerListener = new H264PlayerListener(self);
    h264Streamer->setListener(h264StreamerListener);
    
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
#endif
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    
    //Store current SSID - to check later
	self.current_ssid = [CameraPassword fetchSSIDInfo];
    
	if (_current_ssid == nil) {
		NSLog(@"Error: streamingSSID is nil before streaming");
	}
    
	NSLog(@"Current SSID is: %@", _current_ssid);
    
	//Store some of the info for used in menu  --
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL isOffline = [userDefaults boolForKey:_OfflineMode];
    
	[userDefaults setBool:!(isOffline) forKey:_is_Loggedin];
    
	if ( _current_ssid ) {
		[userDefaults setObject:_current_ssid forKey:_streamingSSID];
	}
    
    [userDefaults synchronize];
    
    //`NSLog(@"Play with TCP Option >>>>> ") ;
    //mp->setPlayOption(MEDIA_STREAM_RTSP_WITH_TCP);
    
    NSString *url = _selectedChannel.stream_url;
    NSLog(@"%s url: %@, h264Streamer: %p", __FUNCTION__, url, h264Streamer);
    
    self.mediaProcessStatus = 2;
     NSLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
#if 1
    do {
        if ( !url || [url isEqualToString:@""]) {
            break;
        }
        
        status = MediaPlayer::Instance()->setDataSource([url UTF8String]);
        
        if (status != NO_ERROR) {
            // NOT OK
            NSLog(@"setDataSource  failed");
            
            if (self.selectedChannel.profile.isInLocal) {
                self.messageStreamingState = @"Camera is not accessible";
            }

            break;
        }
        //self.mediaProcessStatus = 3;
        
        MediaPlayer::Instance()->setVideoSurface(_imageViewStreamer);
        
        //self.mediaProcessStatus = 4;
        status = MediaPlayer::Instance()->prepare();
        
        if (status != NO_ERROR) {
            // NOT OK
            break;
        }
        
        // Play anyhow
        //self.mediaProcessStatus = 5;
        status = MediaPlayer::Instance()->start();
        
        if (status != NO_ERROR) {
            // NOT OK
            break;
        }
    }
    
    while (false);
    
    NSLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    self.mediaProcessStatus = 3;
    
#else
    do {
        if ( !url || !h264Streamer ) {
            break;
        }
        
        status = h264Streamer->setDataSource([url UTF8String]);
        
        if (status != NO_ERROR) {
            // NOT OK
            NSLog(@"setDataSource  failed");
            
            if (self.selectedChannel.profile.isInLocal) {
                self.messageStreamingState = @"Camera is not accessible";
            }
            
            break;
        }
        
        //h264Streamer->setVideoSurface(self.imageViewVideo);
        //[self.scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
        h264Streamer->setVideoSurface(_imageViewStreamer);
        
        status=  h264Streamer->prepare();
        
        if (status != NO_ERROR) {
            // NOT OK
            break;
        }
        
        // Play anyhow
        status=  h264Streamer->start();
        
        if (status != NO_ERROR) {
            // NOT OK
            break;
        }
    }
    while (false);
#endif
    
    if (status == NO_ERROR) {
        [self handleMessage:MEDIA_PLAYER_STARTED ext1:0 ext2:0];
    }
    else {
        //Consider it's down and perform necessary action ..
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:0 ext2:0];
    }
}

- (void)prepareGoBackToCameraList:(id)sender
{
     [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView goes back" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Go back"
                                                     withLabel:@"Hubble back button item"
                                                     withValue:[NSNumber numberWithDouble:_currentMediaStatus]];
    
    self.activityStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:_activityStopStreamingProgress];
    
    _isShowCustomIndicator = NO;
    
    self.view.userInteractionEnabled = NO;
    
    NSLog(@"H264VC- prepareGoBackToCameraList - self.currentMediaStatus: %d", self.currentMediaStatus);
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    if (_audioOutStreamRemote) {
        [self performSelectorInBackground:@selector(closeRemoteTalkback) withObject:nil];
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
#if 1
    
    NSLog(@"%s _mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    if (_earlierVC){
        [_earlierVC release];
    }
    
    if (_timelineVC) {
        _timelineVC.timelineVCDelegate = nil;
    }
    
    if (_jsonCommBlocked) {
        [_jsonCommBlocked release];
    }
    
    if (_mediaProcessStatus == 0) {
        [self goBack];
    }
    else if (_mediaProcessStatus == 1) {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
        [self goBack];
    }
    else if (_mediaProcessStatus == 2) {
        MediaPlayer::Instance()->sendInterrupt();
    }
    else {
        MediaPlayer::Instance()->sendInterrupt();
        [self stopStream];
        [self goBack];
    }
    
#else
    if (self.currentMediaStatus == 0 && MediaPlayer::Instance() == NULL) {
        // Media player haven't start yet.
        [self performSelector:@selector(goBackToCameraList)
                   withObject:nil
                   afterDelay:0.001];
    }
    else if ( self.currentMediaStatus == MEDIA_INFO_HAS_FIRST_IMAGE ||
            self.currentMediaStatus == MEDIA_PLAYER_STARTED       ||
            ( MediaPlayer::Instance() != NULL))
    {
        NSLog(@"H264VC- prepareGoBackToCameraList - just sendInterrupt");
        
        MediaPlayer::Instance()->sendInterrupt();
        [self goBackToCameraList];
    }
    else {
        [self goBackToCameraList];
    }
#endif
}

- (void)goBackToCameraList
{
    [self stopPeriodicBeep];
    if ( _timerRemoteStreamTimeOut && [_timerRemoteStreamTimeOut isValid] ) {
        [_timerRemoteStreamTimeOut invalidate];
        _timerRemoteStreamTimeOut = nil;
    }
    
    //_isShowCustomIndicator = NO;
    //no need call stopStream in offline mode
    [self stopStream];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.selectedChannel.profile.isSelected = FALSE;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBackToCamerasRemoteStreamTimeOut
{
    self.activityStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:_activityStopStreamingProgress];
    
    
    NSLog(@"self.currentMediaStatus: %d", self.currentMediaStatus);
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.selectedChannel.profile.isSelected = FALSE;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBack
{
    // Release the instance here - since we are going to camera list
    MediaPlayer::release();
    
    self.activityStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:_activityStopStreamingProgress];
    
    NSLog(@"self.currentMediaStatus: %d", self.currentMediaStatus);
    
    userWantToCancel = TRUE;
    self.selectedChannel.stopStreaming = TRUE;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.selectedChannel.profile.isSelected = FALSE;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) cleanUpDirectionTimers
{
    if ([_cameraModel isEqualToString:CP_MODEL_BLE]) //MBP83
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
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
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
    NSLog(@"Calling suspend() on thread: %@", [NSThread currentThread]);
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
        
        
        MediaPlayer::Instance()->setListener(NULL);
       
        delete h264StreamerListener;
        h264StreamerListener = NULL;
        
        
        _isProcessRecording = FALSE;
        [self stopRecordingVideo];
        
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        
        
        
        
        
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
        
        if (_isHorizeShow == TRUE)
        {
            [self hideControlMenu];
        }
        
        [self hideAllBottomView];
        
        
        //TODO: enable this
        //[self  stopStunStream];
        

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
        self.alertViewTimoutRemote = [[UIAlertView alloc] initWithTitle:@"Remote Stream"
                                                            message:@"The Camera has been viewed for about 5 minutes. Do you want to continue?"
                                                           delegate:self
                                                  cancelButtonTitle:@"View other camera"
                                                  otherButtonTitles:@"Yes", nil];
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
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
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
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
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
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
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

#pragma mark - Melody Control

- (void)getMelodyValue_bg
{
    NSString *responseString = @"";
    
    if (self.selectedChannel.profile .isInLocal == TRUE)
    {
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"value_melody"];
        
        if (responseData != nil)
        {
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
        }
    }
    else
    {
        if (_jsonCommBlocked == nil)
        {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
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
                
                if (userWantToCancel == FALSE)
                {
                    [self performSelectorOnMainThread:@selector(setMelodyState_Fg:)
                                           withObject:melodyIndex
                                        waitUntilDone:NO];
                }
            }
        }
    }
    else
    {
    }
}

- (void)setMelodyState_Fg: (NSString *)melodyIndex
{
    NSInteger melody_index  = [melodyIndex intValue] - 1;
    
    [self.melodyViewController updateUIMelody:melody_index];
}

#pragma mark - Temperature

- (void)getCameraTemperature_bg:(id)sender
{
    // If back, Need not to update UI
    if ( userWantToCancel) {
        return;
    }
    
    NSString *responseString = @"";
    
    if ( _selectedChannel.profile.isInLocal ) {
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        //[HttpCom instance].comWithDevice.device_port = 80;// Hack code for Focus66.
        
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"value_temperature"];
        if ( responseData ) {
            responseString = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
        }
    }
    else {
        if ( !_jsonCommBlocked ) {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:@"action=command&command=value_temperature"
                                                                                  andApiKey:apiKey];
        if ( responseDict ) {
            NSInteger status = [[responseDict objectForKey:@"status"] intValue];
            if (status == 200) {
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
        
        if (tmpRange.location != NSNotFound) {
            NSArray *arrayBody = [responseString componentsSeparatedByString:@": "];
            if (arrayBody.count == 2) {
                self.stringTemperature = [arrayBody objectAtIndex:1];
                
                //If back, Need not to update UI
                if ( userWantToCancel ) {
                    return;
                }
                
                [self performSelectorOnMainThread:@selector(setTemperatureState_Fg:)
                                       withObject:_stringTemperature
                                    waitUntilDone:NO];
            }
            else {
                //NSLog(@"Error - Command is not found or wrong format: %@", responseString);
            }
        }
        else {
            //NSLog(@"Error - Command is not found or wrong format: %@", responseString);
        }
    }
    else {
        // Do nothings | reset UI
        //NSLog(@"Error - Command is not found or wrong format: %@", responseString);
    }
    
    // Make sure Update temperature once after that check condition
    if ( [sender isKindOfClass:[NSTimer class]] ) {
        if ( _ib_temperature.hidden || userWantToCancel || _h264StreamerIsInStopped ) {
            [((NSTimer *)sender) invalidate];
            sender = nil;
            self.existTimerTemperature = FALSE;
            
            NSLog(@"Log - Invalidate Timer get temperature");
            return;
        }
    }
}

- (void)setTemperatureState_Fg:(NSString *)temperature
{
    // Update UI
    [_ib_temperature.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    NSString *stringTemperature = [NSString stringWithFormat:@"%d", (int)roundf([temperature floatValue])];
    _degreeCString = stringTemperature;
    
    float celsius = [_degreeCString floatValue];
    float changeToFloat = (celsius * 9.0)/5.0;
    NSInteger degreeF = (round(changeToFloat)) + 32;
    _degreeFString = [NSString stringWithFormat:@"%d", degreeF];
    
    UILabel *degreeCelsius = [[UILabel alloc] init];
    degreeCelsius.backgroundColor=[UIColor clearColor];
    degreeCelsius.textColor=[UIColor temperatureTextColor];
    degreeCelsius.textAlignment = NSTextAlignmentLeft;
    
    NSString *degreeCel;
    if (_isDegreeFDisplay) {
        degreeCel = @"°F";
        stringTemperature = _degreeFString;
    }
    else {
        degreeCel = @"°C";
        stringTemperature = _degreeCString;
    }
    
    degreeCelsius.text= degreeCel;
    
    UIFont *degreeFont;
    UIFont *temperatureFont;
    float positionYOfBottomView = _ib_temperature.frame.origin.y;
    
    if (!isiOS7AndAbove) {
        positionYOfBottomView = positionYOfBottomView - 44;
    }
    
    if (_isLandScapeMode) {
        degreeCelsius.backgroundColor=[UIColor clearColor];
        degreeCelsius.textColor=[UIColor whiteColor];
        float xPosTemperature;
        float yPosTemperature;
        CGSize stringBoundingBox;;
        CGSize degreeCelBoundingBox;
        CGFloat deltaWidth = 20;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:13];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:53];
        }
        else {
            // iPad
            degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:30];
            temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:100];
            positionYOfBottomView = _ib_temperature.frame.origin.y;
            deltaWidth += 72;
        }
        
        [degreeCelsius setFont:degreeFont];
        [self.ib_temperature setFont:temperatureFont];
        [self.ib_temperature setTextColor:[UIColor whiteColor]];
        [self.ib_temperature setShadowColor:[UIColor blackColor]];
        [self.ib_temperature setShadowOffset:CGSizeMake(2, 2)];
        [self.ib_temperature setText:stringTemperature];
        
        stringBoundingBox = [stringTemperature sizeWithAttributes:@{NSFontAttributeName: temperatureFont}];
        degreeCelBoundingBox = [degreeCel sizeWithAttributes:@{NSFontAttributeName: degreeFont}];
        
        xPosTemperature = SCREEN_HEIGHT - self.ib_temperature.bounds.size.width - 40 + (_ib_temperature.bounds.size.width - stringBoundingBox.width)/2;
        yPosTemperature = SCREEN_WIDTH - deltaWidth - stringBoundingBox.height;
        
        [self.ib_temperature setFrame:CGRectMake(xPosTemperature, yPosTemperature+10, _ib_temperature.bounds.size.width, self.ib_temperature.bounds.size.height)];
        [ib_switchDegree setFrame:CGRectMake(xPosTemperature, yPosTemperature, _ib_temperature.bounds.size.width, _ib_temperature.bounds.size.height)];
        
        CGFloat widthString = stringBoundingBox.width;
        CGFloat alignX = (_ib_temperature.bounds.size.width + widthString)/2;
        [degreeCelsius setFrame:CGRectMake(alignX, 5, degreeCelBoundingBox.width, degreeCelBoundingBox.height)];
        [self.ib_temperature addSubview:degreeCelsius];
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (isiPhone4) {
                degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:30];
                temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:125];
            }
            else {
                // iPhone 5+ (tall screen)
                degreeFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:35];
                temperatureFont = [UIFont applyHubbleFontName:PN_LIGHT_FONT withSize:135];
            }
        }
        else {
            // iPad
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
        CGFloat alignX = (SCREEN_WIDTH + widthString)/2 - degreeCelBoundingBox.width/2 + 8;
        CGFloat alignYCel = (SCREEN_HEIGHT - positionYOfBottomView)/2 - heightString/2 + 10;
        [degreeCelsius setFrame:CGRectMake(alignX, alignYCel, degreeCelBoundingBox.width, degreeCelBoundingBox.height)];
        [self.ib_temperature addSubview:degreeCelsius];
    }
    
    [degreeCelsius release];
}

#pragma mark - Stun probe timer

-(void)periodicProbe:(NSTimer *)exp
{
    if ( userWantToCancel || _selectedChannel.stopStreaming ) {
        NSLog(@"Stop probing ... ");
    }
    else if ( self.client ) {
        NSRunLoop *mainloop = [NSRunLoop currentRunLoop];
        NSLog(@"send probes ... ");

        NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:0.5];

        [_client sendVideoProbesToIp:_selectedChannel.profile.camera_mapped_address
                             andPort:_selectedChannel.profile.camera_stun_video_port];
        [mainloop runUntilDate:timeout];
        
        [_client sendAudioProbesToIp:_selectedChannel.profile.camera_mapped_address
                             andPort:_selectedChannel.profile.camera_stun_audio_port];
        [mainloop runUntilDate:timeout];
    }
}

#pragma mark - Stun client delegate

-(void)symmetric_check_result:(BOOL)isBehindSymmetricNat
{
    NSInteger result = (isBehindSymmetricNat == TRUE)?TYPE_SYMMETRIC_NAT:TYPE_NON_SYMMETRIC_NAT;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ( [userDefaults boolForKey:@"enable_stun"] ) {
        [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
        [userDefaults synchronize];
    }
    
    dispatch_queue_t qt = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(qt, ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *stringUDID = self.selectedChannel.profile.registrationID;
        
        NSDate *dateStage1 = [NSDate date];
        
        if ( !_jsonCommBlocked ) {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSDictionary *responseDict;
        
        if (isBehindSymmetricNat == TRUE) // USE RELAY
        {
#ifdef SHOW_DEBUG_INFO
            _viewVideoIn = @"R";
#endif
            //responseDict = [jsonComm createSessionBlockedWithRegistrationId:mac
            responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:stringUDID
                                                                      andClientType:@"BROWSER"
                                                                          andApiKey:apiKey];
            NSLog(@"USE RELAY TO VIEW- userWantsToCancel:%d, returnFromPlayback:%d, responsed: %@", userWantToCancel, _returnFromPlayback, responseDict);
            
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateStage1];
            NSString *gaiActionTime = GAI_ACTION(1, diff);
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:gaiActionTime
                                                             withLabel:nil
                                                             withValue:nil];
            
            NSLog(@"%s stage 1 takes %f seconds \n Start stage 2 \n %@", __FUNCTION__, diff, gaiActionTime);
            self.timeStartingStageTwo = [NSDate date];
            
            if (!userWantToCancel && !_returnFromPlayback && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                if ( responseDict) {
                    if ([[responseDict objectForKey:@"status"] intValue] == 200) {
                        NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                        
                        if ([urlResponse hasPrefix:ME_WOWZA] &&
                            [userDefaults boolForKey:VIEW_NXCOMM_WOWZA] == TRUE)
                        {
                            self.selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                        }
                        else {
                            self.selectedChannel.stream_url = urlResponse;
                        }
                        
                        self.selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                        
                        NSLog(@"%s Start stage 2", __FUNCTION__);
                        
                        [self performSelectorOnMainThread:@selector(startStream)
                                               withObject:nil
                                            waitUntilDone:NO];
                        
                        self.messageStreamingState = @"Low data bandwidth detected. Trying to connect...";
                    }
                    else {
                        //handle Bad response
                        NSLog(@"%s ERROR: %@", __FUNCTION__, [responseDict objectForKey:@"message"]);
#if 1
                        self.messageStreamingState = @"Camera is not accessible";
                        _isShowTextCameraIsNotAccesible = YES;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.ib_lbCameraNotAccessible setHidden:NO];
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
                else {
                    NSLog(@"SERVER unreachable (timeout) ");
                    self.messageStreamingState = @"Camera is not accessible";
                    _isShowTextCameraIsNotAccesible = YES;
#if 1
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.ib_lbCameraNotAccessible setHidden:NO];
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
            else {
                NSLog(@"%s View is invisible OR in background mode. Do nothing!", __FUNCTION__);
            }
        }
        else {
            // USE RTSP/STUN
            // Set port1, port2
            NSLog(@"TRY TO USE RTSP/STUN TO VIEW***********************");
#ifdef SHOW_DEBUG_INFO
            _viewVideoIn = @"S";
#endif
            if ([_client create_stun_forwarder:_selectedChannel] != 0 ) {
                //TODO: Handle error
            }
            
            NSString * cmd_string = [NSString stringWithFormat:@"action=command&command=get_session_key&mode=p2p_stun_rtsp&port1=%d&port2=%d&ip=%@",
                                     _selectedChannel.local_stun_audio_port,
                                     _selectedChannel.local_stun_video_port,
                                     _selectedChannel.public_ip];
            
            responseDict =  [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                         andCommand:cmd_string
                                                                          andApiKey:apiKey];
            if ( responseDict ) {
                NSLog(@"symmetric_check_result, responseDict: %@", responseDict);
                
                NSString *body = [[[responseDict objectForKey: @"data"] objectForKey: @"device_response"] objectForKey: @"body"];
                //"get_session_key: error=200,port1=37171&port2=47608&ip=115.77.250.193,mode=p2p_stun_rtsp"
                
                NSLog(@"Respone - camera response : %@, Number of STUN error: %d", body, _numberOfSTUNError);
                if ( body ) {
                    NSArray *tokens = [body componentsSeparatedByString:@","];
                    if ( [[tokens objectAtIndex:0] hasSuffix:@"error=200"]) {
                        //roughly check for "error=200"
                        if (_numberOfSTUNError >= 3) {
                            // Switch to RELAY because STUN try probe & failed many times
                            NSLog(@"Switch to RELAY - Number of STUN error: %d", _numberOfSTUNError);
                            
                            /* close current session  before continue*/
                            cmd_string = @"action=command&command=close_p2p_rtsp_stun";
                            
                            //responseDict =
                            [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                         andCommand:cmd_string
                                                                          andApiKey:apiKey];
                            if ( !userWantToCancel ) {
                                self.numberOfSTUNError = 0;
                                
                                //[self handleMessage:H264_SWITCHING_TO_RELAY_SERVER ext1:0 ext2:0];
                                NSArray *args = @[[NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER]];
#ifdef SHOW_DEBUG_INFO
                                _viewVideoIn = @"R";
#endif
                                //relay
                                [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                       withObject:args
                                                    waitUntilDone:NO];
                            }
                        }
                        else {
                            NSString *ports_ip = tokens[1];
                            
                            NSArray *token1s = [ports_ip componentsSeparatedByString:@"&"];
                            NSString *port1_str = token1s[0];
                            NSString *port2_str = token1s[1];
                            NSString *cam_ip = token1s[2];
                            
                            _selectedChannel.profile.camera_mapped_address = [[cam_ip componentsSeparatedByString:@"="] objectAtIndex:1];
                            _selectedChannel.profile.camera_stun_audio_port = [(NSString *)[[port1_str componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
                            _selectedChannel.profile.camera_stun_video_port =[(NSString *)[[port2_str componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
                            
                            if ( !userWantToCancel ) {
#ifdef SHOW_DEBUG_INFO
                                _viewVideoIn = @"S";
#endif
                                [self performSelectorOnMainThread:@selector(startStunStream)
                                                       withObject:nil
                                                    waitUntilDone:NO];
                            }
                        }
                    }
                    else {
                        NSLog(@"Respone error - camera response error: %@", body);
                        
                        /* close current session  before continue*/
                        cmd_string = @"action=command&command=close_p2p_rtsp_stun";
                        
                        //responseDict =
                        [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                     andCommand:cmd_string
                                                                      andApiKey:apiKey];
                        
                        if ( !userWantToCancel ) {
#ifdef SHOW_DEBUG_INFO
                            _viewVideoIn = @"R";
#endif
                            NSArray *args = @[[NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER]];
                            
                            //relay
                            [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                   withObject:args
                                                waitUntilDone:NO];
                        }
                    }
                }
                else {
                    NSLog(@"Respone error - can't parse \"body\"field from: %@", responseDict);
                    
                    NSArray *args = @[[NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED]];
                    
                    //force server died
                    [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                           withObject:args
                                        waitUntilDone:NO];
                    
                }
            }
            else {
                NSLog(@"SERVER unreachable (timeout) - responseDict == nil --> Need test this more");
                
                NSArray *args = @[[NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED]];
                
                [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                       withObject:args
                                    waitUntilDone:NO];
            }
        }
    });
    
    dispatch_release(qt);
    
    if ( isBehindSymmetricNat ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *bodyKey = @"";
            
            if (self.selectedChannel.profile.isInLocal ) {
                [HttpCom instance].comWithDevice.device_ip   = _selectedChannel.profile.ip_address;
                [HttpCom instance].comWithDevice.device_port = _selectedChannel.profile.port;
                
                NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"get_resolution"];
                if ( responseData ) {
                    bodyKey = [[[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding] autorelease];
                    NSLog(@"symmetric_check_result response string: %@", bodyKey);
                }
            }
            else if (_selectedChannel.profile.minuteSinceLastComm <= 5) {
                // Remote
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                
                //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
                NSString *stringUDID = _selectedChannel.profile.registrationID;
                NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                NSLog(@"Log - registrationID: %@, apikey: %@", stringUDID, apiKey);
                
                if ( !_jsonCommBlocked ) {
                    self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:nil
                                                                             FailSelector:nil
                                                                                ServerErr:nil];
                }
                
                NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:stringUDID
                                                                                         andCommand:[NSString stringWithFormat:@"action=command&command=get_resolution"]
                                                                                          andApiKey:apiKey];
                if ( responseDict ) {
                    NSInteger status = [responseDict[@"status"] intValue];
                    if (status == 200) {
                        bodyKey = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
                    }
                }
                
                NSLog(@"symmetric_check_result responseDict = %@", responseDict);
            }
            
            if (![bodyKey isEqualToString:@""]) {
                NSArray *tokens = [bodyKey componentsSeparatedByString:@": "];
                
                if ([tokens count] >=2 ) {
                    NSString *modeVideo = tokens[1];
                    
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
                else {
                    self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"stream720p_10_926" ofType:@"sdp"];
                }
            }
            else {
                self.selectedChannel.stream_url = [[NSBundle mainBundle] pathForResource:@"stream720p" ofType:@"sdp"];
            }
            
        });
    } //if (isBehindSymmetricNat != TRUE)
}

- (void)remoteConnectingViaSymmectric
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        //NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        NSString *stringUDID = self.selectedChannel.profile.registrationID;
        
        if ( !_jsonCommBlocked ) {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSDictionary *responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:stringUDID
                                                                                andClientType:@"BROWSER"
                                                                                    andApiKey:apiKey];
        NSLog(@"remoteConnectingViaSymmectric: %@", responseDict);
        if ( responseDict) {
            if ([responseDict[@"status"] intValue] == 200) {
                NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
                
                if ([urlResponse hasPrefix:ME_WOWZA] &&
                    [userDefalts boolForKey:VIEW_NXCOMM_WOWZA] == TRUE)
                {
                    _selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                }
                else {
                    _selectedChannel.stream_url = urlResponse;
                }
                
                if ( !userWantToCancel ) {
                    _selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                    [self performSelectorOnMainThread:@selector(startStream)
                                           withObject:nil
                                        waitUntilDone:NO];
                }
            }
            else {
                //handle Bad response
                NSArray *args = @[[NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED]];
                
                //force server died
                [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                       withObject:args
                                    waitUntilDone:NO];
            }
        }
        else {
            NSLog(@"SERVER unreachable (timeout) ");
            //TODO : handle SERVER unreachable (timeout)
        }
    });
}

#pragma mark - DirectionPad

- (void)updateKnobUI:(NSInteger)direction
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

- (void)updateHandleUI:(NSInteger)direction
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
- (void)v_directional_change_callback:(NSTimer *)timer_exp
{
	/* currentDirUD holds the LATEST direction,
     lastDirUD holds the LAST direction that we have seen
     - this is called every 100ms
	 */
	@synchronized(_imgViewDrectionPad)
	{
		if (lastDirUD != DIRECTION_V_NON) {
            [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView V directional change" withProperties:nil];
            
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

- (void)send_UD_dir_to_rabot:(int)direction
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
    
	if (dir_str) {
        if (_selectedChannel.profile.isInLocal) {
            //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
            //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
            
            //Non block send-
            NSLog(@"device_ip: %@, device_port: %d", _selectedChannel.profile.ip_address, _selectedChannel.profile.port);
            
            [[HttpCom instance].comWithDevice sendCommand:dir_str];
		}
		else if (_selectedChannel.profile.minuteSinceLastComm <= 5) {
            //NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            if (_jsonCommBlocked == nil) {
                self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
            }
            
            NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                     andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                                      andApiKey:apiKey];
            NSLog(@"send_UD_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void)h_directional_change_callback:(NSTimer *)timer_exp
{
    //BOOL need_to_send = FALSE;
    @synchronized(_imgViewDrectionPad)
	{
		if ( lastDirLR != DIRECTION_H_NON ) {
			//need_to_send = TRUE;
            [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView H directional change" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:@"H directional change"
                                                             withLabel:@"Direction pad"
                                                             withValue:nil];
            
            [self send_LR_dir_to_rabot: currentDirLR];
		}
        
//        if (need_to_send)
//        {
//            [self send_LR_dir_to_rabot: currentDirLR];
//        }
        
		//Update directions
		lastDirLR = currentDirLR;
	}
}

- (void)send_LR_dir_to_rabot:(int)direction
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
    
	if ( dir_str ) {
        if ( _selectedChannel.profile.isInLocal ) {
            //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
            //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
            //Non block send-
            [[HttpCom instance].comWithDevice sendCommand:dir_str];
		}
		else if ( _selectedChannel.profile.minuteSinceLastComm <= 5 ) {
            //NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            if ( !_jsonCommBlocked ) {
                self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
            }
            
            NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                     andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                                      andApiKey:apiKey];
            NSLog(@"send_LR_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void)updateVerticalDirection_begin:(int)dir inStep:(uint)step
{
	unsigned int newDirection = 0;
    
	if (dir == 0) {
		newDirection = DIRECTION_V_NON;
	}
	else //Dir is either V_UP or V_DN
	{
		if (dir >0) {
			newDirection = DIRECTION_V_DN;
		}
		else {
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

- (void)updateVerticalDirection:(int)dir inStep:(uint)step withAnimation:(BOOL)animate
{
	unsigned int newDirection = 0;
    
	if (dir == 0) {
		newDirection = DIRECTION_V_NON;
	}
	else {
        // Dir is either V_UP or V_DN
		if (dir >0) {
			newDirection = DIRECTION_V_DN;
		}
		else {
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

- (void)updateVerticalDirection_end:(int)dir inStep:(uint)step
{
	@synchronized(_imgViewDrectionPad)
	{
		currentDirUD = DIRECTION_V_NON;
        [self updateKnobUI:DIRECTION_V_NON];
        [self updateHandleUI:DIRECTION_V_NON];
	}
}

- (void)updateHorizontalDirection_end:(int)dir inStep:(uint)step
{
	@synchronized(_imgViewDrectionPad)
	{
		currentDirLR = DIRECTION_H_NON;
        [self updateKnobUI:DIRECTION_H_NON];
        [self updateHandleUI:DIRECTION_H_NON];
	}
}

- (void)updateHorizontalDirection_begin:(int)dir inStep:(uint)step
{
    if ( _timerHideMenu ) {
        [self.timerHideMenu invalidate];
        self.timerHideMenu = nil;
    }
    
	unsigned int newDirection = 0;
    
	if (dir == 0) {
		newDirection = DIRECTION_H_NON;
	}
	else {
		if (dir >0) {
			newDirection = DIRECTION_H_RT;
		}
		else {
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

- (void)updateHorizontalDirection:(int)dir inStep:(uint)step withAnimation:(BOOL)animate
{
	unsigned int newDirection = 0;
    
	if (dir == 0) {
		newDirection = DIRECTION_H_NON;
	}
	else {
		if (dir >0) {
			newDirection = DIRECTION_H_RT;
		}
		else {
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

#pragma  mark - Touches

//----- handle all touches here then propagate into directionview

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        if(touch.view.tag == 999) {
            if ( _timerHideMenu ) {
                [self.timerHideMenu invalidate];
                self.timerHideMenu = nil;
            }
            
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        if(touch.view.tag == 999) {
            if ( _timerHideMenu ) {
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        if(touch.view.tag == 999) {
            //NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase
{
    if ([_cameraModel isEqualToString:CP_MODEL_BLE]) //MBP83
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

#pragma mark - Rotation screen

- (BOOL)shouldAutorotate
{
    if ( userWantToCancel || _earlierNavi.isEarlierView ) {
        return NO;
    }
    return !_disableAutorotateFlag;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (_earlierNavi.isEarlierView) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView - will rotate interface" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"View will rotate interface"
                                                     withLabel:nil
                                                     withValue:nil];
    
    if (_earlierNavi.isEarlierView) {
        //don't call adjustViews for Earlier
        return;
    }
    else {
        [self adjustViewsForOrientation:toInterfaceOrientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self applyFont];
}

- (void)checkOrientation
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	[self adjustViewsForOrientation:orientation];
}

- (void)adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"H264VC - adjustViewsForOrientation:");
    
    if (_isProcessRecording) {
        _syncPortraitAndLandscape = YES;
    }
    else {
        _syncPortraitAndLandscape = NO;
    }
    
    [self resetZooming];
    
    NSInteger deltaY = 0;
    
    if (isiOS7AndAbove) {
        deltaY = HIGH_STATUS_BAR;
    }
    
	if (UIInterfaceOrientationIsLandscape(orientation)) {
        _isLandScapeMode = YES;
        //load new nib for landscape iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land_iPad" owner:self options:nil];
            self.melodyViewController = [[[MelodyViewController alloc] initWithNibName:@"MelodyViewController_land" bundle:nil] autorelease];
            [_earlierVC.view setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        }
        else {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land" owner:self options:nil];
            self.melodyViewController = [[[MelodyViewController alloc] initWithNibName:@"MelodyViewController_land" bundle:nil] autorelease];
            
            if (isiOS7AndAbove) {
                self.melodyViewController.view.frame = CGRectMake(393, 78, 175, 165);
            }
            else {
                self.melodyViewController.view.frame = CGRectMake(320, 60, 159, 204);
            }
        }
        
        if ( !_isHorizeShow ) {
            _menuBackgroundView.alpha = 0;
        }
        
        self.melodyViewController.selectedChannel = self.selectedChannel;
        self.melodyViewController.melodyVcDelegate = self;
        
        //landscape mode
        //hide navigation bar
        [self.navigationController setNavigationBarHidden:YES];
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        if (_isAlreadyHorizeMenu) {
            [self.horizMenu reloadData:YES];
        }
        
        // I don't know why remove it.
        [self.melodyViewController.view removeFromSuperview];
        
        CGFloat imageViewHeight = SCREEN_HEIGHT * 9 / 16;
        CGRect newRect = CGRectMake(0, (SCREEN_WIDTH - imageViewHeight) / 2, SCREEN_HEIGHT, imageViewHeight);
        self.imageViewVideo.frame = CGRectMake(0, 0, SCREEN_HEIGHT, imageViewHeight);
        self.scrollView.frame = newRect;
        
        if ( _timelineVC ) {
            [self.timelineVC.view removeFromSuperview];
        }
        
        [self addGesturesPichInAndOut];
	}
	else if ( UIInterfaceOrientationIsPortrait(orientation) ) {
        //load new nib
        //remove pinch in, out (zoom for portrait)
        [self removeGestureRecognizerAtPortraitMode];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_ipad" owner:self options:nil];
            self.melodyViewController = [[[MelodyViewController alloc] initWithNibName:@"MelodyViewController_iPad" bundle:nil] autorelease];
            [_earlierVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController" owner:self options:nil];
            self.melodyViewController = [[[MelodyViewController alloc] initWithNibName:@"MelodyViewController" bundle:nil] autorelease];
        }
        
        if ( !_isHorizeShow ) {
            _menuBackgroundView.alpha = 0;
        }
        
        self.melodyViewController.selectedChannel = self.selectedChannel;
        self.melodyViewController.melodyVcDelegate = self;
        
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.view.backgroundColor = [UIColor whiteColor];
        
        if (_isAlreadyHorizeMenu) {
            [self.horizMenu reloadData:NO];
        }
        
        CGFloat imageViewHeight = SCREEN_WIDTH * 9 / 16;
        
        if (isiOS7AndAbove) {
            //CGRect destRect = CGRectMake(0, 44 + deltaY, SCREEN_WIDTH, imageViewHeight);
            //self.scrollView.frame = destRect;
            //self.imageViewVideo.frame = CGRectMake(0, 0, SCREEN_WIDTH, imageViewHeight);
            self.melodyViewController.view.frame = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
            
            // Control display for TimelineVC
            
            if ( _timelineVC ) {
                CGFloat alignYTimeLine = self.ib_ViewTouchToTalk.frame.origin.y;
                
                if (isiPhone4) {
                    // This condition check size of screen. Not iPhone4 or other
                    self.timelineVC.view.frame = CGRectMake(0, alignYTimeLine, SCREEN_HEIGHT, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y + 64);
                }
                else {
                    self.timelineVC.view.frame = CGRectMake(0, alignYTimeLine, SCREEN_HEIGHT, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
                
                _timelineVC.tableView.contentSize = CGSizeMake(SCREEN_WIDTH, _timelineVC.tableView.frame.size.height);
                //don't show timeline after switch from land to port
                self.timelineVC.view.hidden = NO;
                [self.view addSubview:_timelineVC.view];
                
                if (_isLandScapeMode) {
                    if (isiPhone4 || isiPhone5) {
                        //iPhone
                        self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 275, 0);
                    }
                    else {
                        //iPad
                        self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
                    }
                }
                else {
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
                }
            }
        }
        else {
            CGRect destRect = CGRectMake(0, deltaY, SCREEN_WIDTH, imageViewHeight);
            self.scrollView.frame = destRect;
            self.imageViewVideo.frame = CGRectMake(0, -44, SCREEN_WIDTH, imageViewHeight);
            self.melodyViewController.view.frame = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 30 - 44, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
            
            
            // Control display for TimelineVC
            if ( _timelineVC ) {
                CGFloat alignYTimeLine = self.ib_ViewTouchToTalk.frame.origin.y - 64;
                
                if (_isLandScapeMode) {
                    self.timelineVC.view.frame = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - alignYTimeLine);
                    self.timelineVC.view.hidden = NO;
                    [self.view addSubview:_timelineVC.view];
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 250, 0);
                }
                else {
                    self.timelineVC.view.frame = CGRectMake(0, alignYTimeLine, SCREEN_WIDTH, SCREEN_HEIGHT - alignYTimeLine);
                    self.timelineVC.view.hidden = NO;
                    [self.view addSubview:_timelineVC.view];
                    self.timelineVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
        }
        
        [self showControlMenu];
        _isLandScapeMode = NO;
	}
    
#ifndef DEBUG
    // Remove debug buttons for Release builds
    [_ib_btShowDebugInfo removeFromSuperview];
    [self setIb_btShowDebugInfo:nil];
    
    [_sendLogButton removeFromSuperview];
    [self setSendLogButton:nil];
#endif
    
    [self.melodyViewController.melodyTableView setNeedsLayout];
    [self.melodyViewController.melodyTableView setNeedsDisplay];
    
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
    [self hideControlMenu];
    [self hideAllBottomView];
    [self updateBottomView];
    
    if (_selectedItemMenu != -1) {
        [self.horizMenu setSelectedIndex:_selectedItemMenu-1 animated:NO];
    }
    
    //Earlier must at bottom of land, and port
    if (_isFirstLoad || _wantToShowTimeLine || _selectedItemMenu == -1) {
        [self showTimelineView];
    }
    else {
        [self hideTimelineView];
    }
    
    self.ib_buttonTouchToTalk.enabled = _enablePTT;
    self.ib_labelTouchToTalk.text = _stringStatePTT;
}

#pragma mark - Scan cameras

- (void) scan_for_missing_camera
{
    self.scanAgain = TRUE;
    if (userWantToCancel == TRUE) {
        return;
    }
    
    NSLog(@"scanning for : %@", self.selectedChannel.profile.mac_address);
	scanner = [[ScanForCamera alloc] initWithNotifier:self];
	[scanner scan_for_device:self.selectedChannel.profile.mac_address];
    
}

- (void)scan_done:(NSArray *)_scan_results
{
    // Scan for Local camera if it is disconnected
    if (_scanAgain == TRUE) {
        BOOL found = FALSE;

        if (_scan_results.count > 0) {
            //confirm the mac address
            CamProfile * cp = self.selectedChannel.profile;
            
            for (int j = 0; j < [_scan_results count]; j++) {
                CamProfile * cp1 = (CamProfile *) [_scan_results objectAtIndex:j];
                
                if ( [cp.mac_address isEqualToString:cp1.mac_address]) {
                    //FOUND - copy ip address.
                    cp.ip_address = cp1.ip_address;
                    cp.isInLocal  = TRUE;
                    cp.port       = cp1.port;
                    found = TRUE;
                    break;
                }
            }
        }
        
        if (!found) {
            //Rescann...
            NSLog(@"Re- scan for : %@", self.selectedChannel.profile.mac_address);
            [self scan_for_missing_camera];
        }
        else {
            //Restart streaming..
            NSLog(@"Re-start streaming for : %@", self.selectedChannel.profile.mac_address);
            
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(setupCamera)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    else {
        // This is scan for camera when -becomeActive
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
            if (userWantToCancel)
            {
                [_threadBonjour cancel];
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
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(setupCamera)
                                       userInfo:nil
                                        repeats:NO];
    }
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView dismiss alert: %d with btn index: %d", tag, buttonIndex] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Dismiss alert: %d", tag]
                                                     withLabel:[NSString stringWithFormat:@"Alert %@", alertView.title]
                                                     withValue:[NSNumber numberWithInteger:buttonIndex]];
    
    if (tag == TAG_ALERT_VIEW_REMOTE_TIME_OUT)
    {
        switch (buttonIndex)
        {
            case 0: // View other camera
                self.view.userInteractionEnabled = NO;
                
                if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
                    [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight ||
                    [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
                    [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
                {
                    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
                        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),   UIDeviceOrientationPortrait);
                    }
                }
                
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
    else if (tag == TAG_ALERT_SENDING_LOG)
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
}

- (void)sendRequestLogCmdToCamera_bg
{
    [self sendRequestLogCmdToCamera];
}

- (void)sendRequestLogCmdToCamera
{
    if (_jsonCommBlocked == nil)
    {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
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
            self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_photo.png", @"video_action_temp.png", nil];
            self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_photo_pressed.png", @"video_action_temp_pressed.png", nil];
        }
        else
        {
            self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan.png", @"video_action_video.png", @"video_action_music.png", @"video_action_temp.png", nil];
            self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed.png", @"video_action_video_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
        }
    }
    else if ([_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
    {
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_mic.png", @"video_action_photo.png", @"video_action_music.png", @"video_action_temp.png", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_mic_pressed.png", @"video_action_photo_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
    }
    else //if ([_cameraModel isEqualToString:CP_MODEL_BLE])
    {
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan.png", @"video_action_mic.png", @"video_action_video.png", @"video_action_music.png", @"video_action_temp.png", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed.png", @"video_action_mic_pressed.png", @"video_action_video_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
    }
    
    //[self.horizMenu reloadData:NO];
    [self performSelectorOnMainThread:@selector(horizMenuReloadData) withObject:nil waitUntilDone:NO];
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

- (void)horizMenu:(ScrollHorizontalMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
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
    
    if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]) {
        if ([_sharedCamConnectedTo isEqualToString:@"MACOS"]) {
            if (index == 0) {
                self.selectedItemMenu = INDEX_RECORDING;
            }
            else if (index == 1) {
                self.selectedItemMenu = INDEX_TEMP;
            }
            else {
                //do nothing
            }
        }
        else {
            switch (index) {
                case 0:
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
    else if ([_cameraModel isEqualToString:CP_MODEL_CONCURRENT]) {
        switch (index) {
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
                ;
        }
    }
    else {
        // [_cameraModel isEqualToString:CP_MODEL_BLE]
        switch (index) {
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
    
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView select item on horize menu - idx: %d", _selectedItemMenu] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Select item on horize menu"
                                                     withLabel:@"Item"
                                                     withValue:[NSNumber numberWithInt:_selectedItemMenu]];
}

- (void)updateBottomView
{
    if (_wantToShowTimeLine || _horizMenu.isAllButtonDeselected) {
        [self hideAllBottomView];
        [self showTimelineView];
    }
    else {
        [self hideAllBottomView];
        
        if (_selectedItemMenu == INDEX_PAN_TILT) {
            [self.view bringSubviewToFront:_imgViewDrectionPad];
            [self.view bringSubviewToFront:_imageViewKnob];
            [self.view bringSubviewToFront:_imageViewHandle];
            [self.imgViewDrectionPad setHidden:NO];
            self.imageViewKnob.hidden = NO;
            self.imageViewKnob.center = _imgViewDrectionPad.center;
            self.imageViewHandle.center = _imgViewDrectionPad.center;
        }
        else if (_selectedItemMenu == INDEX_MICRO) {
            [self.view bringSubviewToFront:self.ib_ViewTouchToTalk];
            [self.ib_ViewTouchToTalk setHidden:NO];
        }
        else if (_selectedItemMenu == INDEX_RECORDING) {
            [self.view bringSubviewToFront:self.ib_viewRecordTTT];
            [self.ib_viewRecordTTT setHidden:NO];
            
            //check if is share cam, up UI
            if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM] ||
                [_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
            {
                _isRecordInterface = YES;
                [self changeAction:nil];
                [self.ib_buttonChangeAction setHidden:YES];
            }
        }
        else if (_selectedItemMenu == INDEX_MELODY) {
            [self.melodyViewController.view setHidden:NO];
            
            if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
                self.wantToShowTimeLine = YES;
            }
            
            CGRect rect;
            
            if (_isLandScapeMode) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    rect = CGRectMake(SCREEN_HEIGHT - 236, SCREEN_WIDTH - 400, 236, 165);
                }
                else {
                    if (isiPhone4) {
                        rect = CGRectMake(SCREEN_HEIGHT - 159, 65, 159, 204);
                    }
                    else {
                        rect = CGRectMake(393, 78, 175, 165);
                    }
                }
            }
            else {
                if (isiOS7AndAbove) {
                    rect = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
                else {
                    rect = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 30 - 44, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
            }
            
            self.melodyViewController.view.frame = rect;
            
            /*
             TODO:need get status of laluby and update on UI.
             when landscape or portrait display correctly
             */
            [self performSelectorInBackground:@selector(getMelodyValue_bg) withObject:nil];
            [self.melodyViewController.melodyTableView setNeedsLayout];
            [self.melodyViewController.melodyTableView setNeedsDisplay];
            
        }
        else if (_selectedItemMenu == INDEX_TEMP) {
            [self.ib_temperature setHidden:NO];
            [ib_switchDegree setHidden:NO];
            [self.view bringSubviewToFront:ib_switchDegree];
            
            if ( !_existTimerTemperature ) {
                self.existTimerTemperature = TRUE;
                NSLog(@"Log - Create Timer to get Temperature");
                //should call it first and then update later
                [self setTemperatureState_Fg:_stringTemperature];
                [NSTimer scheduledTimerWithTimeInterval:10
                                                 target:self
                                               selector:@selector(getCameraTemperature_bg:)
                                               userInfo:nil
                                                repeats:YES];
            }
        }
        else {
            //first hide all bottom view
            //[self hideAllBottomView];
            //and then display time line
            [self showTimelineView];
        }
    }
    
    [self stopTalkbackUnexpected];
}

- (void)hideAllBottomView
{
    [self.imgViewDrectionPad setHidden:YES];
    self.imageViewKnob.hidden = YES;
    self.imageViewHandle.hidden = YES;
    
    [self.ib_temperature setHidden:YES];
    [self.ib_temperature setBackgroundColor:[UIColor clearColor]];
    
#if TEST_REMOTE_TALKBACK
#else
    [self.ib_ViewTouchToTalk setHidden:YES];
    [self.ib_ViewTouchToTalk setBackgroundColor:[UIColor clearColor]];
#endif
    
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
    
    NSLog(@"H264Player - didReceiveMemoryWarning - force restart stream if running");
    
    if (MediaPlayer::Instance()->isPlaying()) {
        NSLog(@"H264Player - send interrupt ");
        MediaPlayer::Instance()->sendInterrupt();
    }
}

- (void)dealloc
{
    [_imageViewVideo release];
    [_imageViewStreamer release];
    [_progressView release];
    [_selectedChannel release];
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
    
    NSLog(@"%s", __FUNCTION__);
    
    [super dealloc];
}


#pragma  mark -
#pragma mark PTT

- (void)cleanup
{
    [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                           withObject:@"0"];
    
    [_audioOut release];
    _audioOut = nil;
    
    //self.walkieTalkieEnabled = NO;
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
    _ib_labelTouchToTalk.text = @"Processing...";
    
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
        
        UILabel *labelCrazy = [[UILabel alloc] init];
        
        CGRect rect;
        
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
        {
            rect = CGRectMake(SCREEN_WIDTH/2 - 115/2, SCREEN_HEIGHT - 35, 115, 30);
        }
        else
        {
            rect = CGRectMake(SCREEN_HEIGHT/2 - 115/2, SCREEN_WIDTH - 35, 115, 30);
        }
        
        labelCrazy.frame = rect;
        labelCrazy.backgroundColor = [UIColor grayColor];
        labelCrazy.textColor = [UIColor whiteColor];
        labelCrazy.font = [UIFont applyHubbleFontName:PN_SEMIBOLD_FONT withSize:13];
        labelCrazy.textAlignment = NSTextAlignmentCenter;
        labelCrazy.text = @"Talkback disabled";
        [self.view addSubview:labelCrazy];
        [self.view bringSubviewToFront:labelCrazy];
        
        [labelCrazy performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3];
        
        [labelCrazy release];
        
        //self.walkieTalkieEnabled = !_walkieTalkieEnabled;
        [self ib_buttonTouchToTalkTouchUpInside];
    }
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
            imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed@5.png"];
        }
        
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchDown];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlStateNormal];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchUpInside];
        [self applyFont];
        
        
        self.disableAutorotateFlag = TRUE;
        [self.ib_labelTouchToTalk setText:@"Please Speak"];
        self.stringStatePTT = @"Speaking";
        
        //Mute audio to MediaPlayer lib
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_MUTE);
        
        
        NSLog(@"Device ip: %@, Port push to talk: %d, actually is: %d", [HttpCom instance].comWithDevice.device_ip, self.selectedChannel.profile.ptt_port,IRABOT_AUDIO_RECORDING_PORT);
        
        // Init connectivity to Camera via socket & prevent loss of audio data
        _audioOut = [[AudioOutStreamer alloc] initWithDeviceIp:[HttpCom instance].comWithDevice.device_ip
                                                    andPTTport:self.selectedChannel.profile.ptt_port];  //IRABOT_AUDIO_RECORDING_PORT
        [_audioOut retain];
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
            [_audioOut release];
            _audioOut = nil;
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
            imageNormal = [UIImage imageNamed:@"camera_action_mic@5.png"];
        }
        
        [self.ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlEventTouchDown];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlEventTouchUpInside];
        //[self applyFont];
        self.disableAutorotateFlag = FALSE;
        [self.ib_labelTouchToTalk setText:@"Touch to Talk"];
        self.stringStatePTT = @"Touch to Talk";
    }
}

- (void) set_Walkie_Talkie_bg: (NSString *) status
{
    @autoreleasepool {
        NSString * command = [NSString stringWithFormat:@"%@%@", SET_PTT, status];
        
        NSLog(@"Command send to camera is %@", command);
        
        [[HttpCom instance].comWithDevice sendCommandAndBlock:command];
        
        self.ib_buttonTouchToTalk.enabled = YES;
        self.enablePTT = YES;
    }
}

- (void)touchUpInsideHoldToTalk {
    //update UI
    [_ib_buttonTouchToTalk setBackgroundColor:[UIColor clearColor]];
    [_ib_buttonTouchToTalk setBackgroundImage:[UIImage imageMic] forState:UIControlStateNormal];
    [_ib_buttonTouchToTalk setBackgroundImage:[UIImage imageMic] forState:UIControlEventTouchUpInside];
    
    if (self.selectedChannel.profile.isInLocal)
    {
        [self.ib_labelTouchToTalk setText:@"Touch to Talk"];
    }
    else
    {
        _ib_buttonTouchToTalk.enabled = YES;
        self.enablePTT = YES;
        [_ib_labelTouchToTalk setText:@"Touch to Talk"];
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
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
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
                self.ib_labelTouchToTalk.text = @"Not support!";
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
        self.audioOutStreamRemote = [[AudioOutStreamRemote alloc] initWithRemoteMode];
        
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
        self.ib_labelTouchToTalk.text = @"Retry...";
        [self retryTalkbackRemote];
    }
    else
    {
        self.ib_labelTouchToTalk.text = @"Please Speak";
    }
}

#pragma mark - Bottom menu

- (IBAction)changeToMainRecording:(id)sender
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Take picture to Recording or " withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Take picture to Recording or vice versa"
                                                     withLabel:@"Recording"
                                                     withValue:nil];
    //change to main recording here
    [self changeAction:nil];
}

- (IBAction)switchDegreePressed:(id)sender
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Temperature type" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Temperature type"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isDegreeFDisplay]];
    
    _isDegreeFDisplay = !_isDegreeFDisplay;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_isDegreeFDisplay forKey:@"IS_FAHRENHEIT"];
    [userDefaults synchronize];
    
    [self setTemperatureState_Fg:_stringTemperature];
}

- (IBAction)showInfoDebug:(id)sender
{
    self.viewDebugInfo.hidden = !_viewDebugInfo.isHidden;
}

- (IBAction)processingRecordingOrTakePicture:(id)sender
{
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView Touch up inside recording - mode: %d", _isRecordInterface] withProperties:nil];
    
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
        [self.ib_labelRecordVideo setText:@"Take Picture"];
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
            
            if (![_cameraModel isEqualToString:CP_MODEL_SHARED_CAM] &&
                ![_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
            {
                [self.ib_buttonChangeAction setHidden:NO];
                [self.view bringSubviewToFront:self.ib_buttonChangeAction];
            }
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
    [self.ib_labelRecordVideo setText:@"Record Video"];
    _syncPortraitAndLandscape = NO;
    
    // DUMMY for now..
}

- (IBAction)changeAction:(id)sender
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Take picture to Recording or " withProperties:nil];
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
            [self.ib_labelRecordVideo setText:@"Record Video"];
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
            [self.ib_labelRecordVideo setText:@"Take Picture"];
        }
        else
        {
            //not recording
            [self.ib_changeToMainRecording setHidden:YES];
            [self.ib_buttonChangeAction setHidden:NO];
            [self.view bringSubviewToFront:self.ib_buttonChangeAction];
            [self.ib_buttonChangeAction setBackgroundImage:[UIImage imageVideoGrey] forState:UIControlStateNormal];
            [self.ib_buttonChangeAction setBackgroundImage:[UIImage imageVideoGreyPressed] forState:UIControlStateSelected];
            [self.ib_labelRecordVideo setText:@"Take Picture"];
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
        self.ib_labelRecordVideo.text = @"Take Picture";
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
		title = @"Snapshot";
		message = @"Saved to Photo Album";
        
	}
	else
	{
		title = @"Error";
		//message = [error description];
        message = @"Please allow permission to save media in gallery.  iPhone Settings > Privacy > Photos > Hubble Home :- Turn switch on.";
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
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
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

- (BOOL)isCurrentConnection3G
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
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
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

- (BOOL)isInTheSameNetworkAsCamera:(CamProfile *)cp
{
    long ip = 0, ownip =0 ;
    long netMask = 0 ;
	struct ifaddrs *ifa = NULL, *ifList;
    
    NSString *bc = @"";
	NSString *own = @"";
    
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own ipasLong:&ownip];
    
    getifaddrs(&ifList); // should check for errors
    
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_netmask != NULL) {
            ip = (( struct sockaddr_in *)ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == ownip) {
                netMask = (( struct sockaddr_in *)ifa->ifa_netmask)->sin_addr.s_addr;
                break;
            }
        }
    }
    
    freeifaddrs(ifList); // clean up after yourself
    
    if (netMask ==0 || ip ==0) {
        return NO;
    }
    
    long camera_ip =0 ;
    if ( cp.ip_address ) {
        NSArray * tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if (tokens.count != 4) {
            //sth is wrong
            return NO;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        if ( (camera_ip & netMask) == (ip & netMask)) {
            NSLog(@"H264 - Camera is in same subnet");
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isCurrentIpAddressValid:(CamProfile *)cp
{
    if ( cp.ip_address ) {
        [HttpCom instance].comWithDevice.device_ip = cp.ip_address;
        [HttpCom instance].comWithDevice.device_port = 80; // HARD code one more time.
        
        NSString *mac = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:3.0f];
        
        if ( mac.length == 12 ) {
            mac = [Util add_colon_to_mac:mac];
            if ([mac isEqual:cp.mac_address]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Bonjour delegate

- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
}

#pragma mark - Custom Indicator

- (void)start_animation_with_orientation
{
    _customIndicator.hidden = NO;
    [self.view addSubview:_customIndicator];
    [self.view  bringSubviewToFront:_customIndicator];
    
    _customIndicator.animationDuration = 1.5;
    _customIndicator.animationRepeatCount = 0;
    [_customIndicator startAnimating];
}

- (void)displayCustomIndicator
{
    if (_isShowCustomIndicator && !_hideCustomIndicatorAndTextNotAccessble) {
        if ( [self.alertTimer isValid] ) {
            //some periodic is running dont care
            NSLog(@"some periodic is running dont care");
        }
        else if ( _disconnectAlert ) {
            self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                               target:self
                                                             selector:@selector(periodicBeep:)
                                                             userInfo:nil
                                                              repeats:YES];
        }
        
        [self start_animation_with_orientation];
        
        _ib_lbCameraNotAccessible.text = _messageStreamingState;
        
        if (_isShowTextCameraIsNotAccesible) {
            [_ib_lbCameraNotAccessible setHidden:NO];
        }
        else {
            [_ib_lbCameraNotAccessible setHidden:YES];
        }
    }
    else {
        [self stopPeriodicBeep];
        _isShowTextCameraIsNotAccesible = NO;
        [_customIndicator stopAnimating];
        [_customIndicator setHidden:YES];
        [_ib_lbCameraNotAccessible setHidden:YES];
        [_ib_lbCameraName setText:_selectedChannel.profile.name];
    }
}

@end
