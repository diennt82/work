//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import <CoreText/CTStringAttributes.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/message.h>

#include <ifaddrs.h>

#import "H264PlayerViewController.h"
#import "MBP_iosViewController.h"
#import "EarlierNavigationController.h"
#import "EarlierViewController.h"
#import "TimelineViewController.h"
#import "AudioOutStreamRemote.h"
#import "HttpCom.h"
#import "define.h"

@interface H264PlayerViewController () <TimelineVCDelegate, BonjourDelegate, AudioOutStreamRemoteDelegate>

@property (nonatomic, weak) IBOutlet ScrollHorizontalMenu *horizMenu;
@property (nonatomic, weak) IBOutlet UIView *menuBackgroundView;

// Touch to talk
@property (nonatomic, weak) IBOutlet UIView *ib_ViewTouchToTalk;
@property (nonatomic, weak) IBOutlet UIButton *ib_buttonTouchToTalk;
@property (nonatomic, weak) IBOutlet UILabel *ib_labelTouchToTalk;

// Recording
@property (nonatomic, weak) IBOutlet UIView *ib_viewRecordTTT;
@property (nonatomic, weak) IBOutlet UIButton *ib_processRecordOrTakePicture;
@property (nonatomic, weak) IBOutlet UIButton *ib_buttonChangeAction;

@property (nonatomic, weak) IBOutlet UIButton *ib_changeToMainRecording;
@property (nonatomic, weak) IBOutlet UILabel *ib_labelRecordVideo;
@property (nonatomic, weak) IBOutlet UILabel *ib_temperature;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *imgViewDrectionPad;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityStopStreamingProgress;
@property (nonatomic, weak) IBOutlet UIImageView *customIndicator;
@property (nonatomic, weak) IBOutlet UILabel *ib_lbCameraNotAccessible;
@property (nonatomic, weak) IBOutlet UILabel *ib_lbCameraName;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewVideo;

@property (nonatomic, weak) IBOutlet UIButton *ib_switchDegree;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewHandle;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewKnob;
@property (nonatomic, weak) IBOutlet UIView *viewDebugInfo;

@property (nonatomic, strong) NSThread *threadBonjour;
@property (nonatomic, strong) UIControl *backCover;
@property (nonatomic, strong) UIAlertView *alertViewTimoutRemote;
@property (nonatomic, strong) UIImageView *imageViewStreamer;
@property (nonatomic, strong) NSMutableArray *bonjourList;
@property (nonatomic, strong) EarlierViewController *earlierVC;
@property (nonatomic, strong) TimelineViewController *timelineVC;
@property (nonatomic, strong) AudioOutStreamRemote *audioOutStreamRemote;
@property (nonatomic, strong) BMS_JSON_Communication *jsonCommBlocked;
@property (nonatomic, strong) NSTimer *timerIncreaseBitRate;
@property (nonatomic, strong) NSTimer *timerBufferingTimeout;
@property (nonatomic, strong) NSTimer *timerRemoteStreamTimeOut;
@property (nonatomic, strong) NSTimer *timerRemoteStreamKeepAlive;
@property (nonatomic, strong) NSTimer *timerHideMenu;
@property (nonatomic, strong) NSDate *timeStartingStageTwo;
@property (nonatomic, strong) NSDate *timeStartPlayerView;

@property (nonatomic, strong) ScanForCamera *scanner;
@property (nonatomic, strong) NSTimer *timerRecording; // display time when recording
@property (nonatomic, strong) NSTimer *timerStopStreamAfter30s; // timer display text Camera is not accessible
@property (nonatomic, strong) NSTimer *send_UD_dir_req_timer;
@property (nonatomic, strong) NSTimer *send_LR_dir_req_timer;

@property (nonatomic, assign) H264PlayerListener *h264StreamerListener;
@property (nonatomic, weak) EarlierNavigationController *earlierNavi;

@property (nonatomic, copy) NSString *stringTemperature;
@property (nonatomic, copy) NSString *cameraModel;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *sessionKey;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, copy) NSString *talkbackRemoteServer;
@property (nonatomic, copy) NSString *sharedCamConnectedTo;
@property (nonatomic, copy) NSString *currentBitRate;
@property (nonatomic, copy) NSString *messageStreamingState;
@property (nonatomic, copy) NSString *stringStatePTT;
@property (nonatomic, copy) NSString *current_ssid;

@property (nonatomic) SystemSoundID soundFileObject;

@property (nonatomic) BOOL isHorizeShow;
@property (nonatomic) BOOL isEarlierView;
@property (nonatomic) BOOL existTimerTemperature;
@property (nonatomic) BOOL cameraIsNotAvailable;
@property (nonatomic) BOOL scanAgain;
@property (nonatomic) BOOL isFahrenheit;
@property (nonatomic) BOOL wantsCancelRemoteTalkback;
@property (nonatomic) BOOL remoteViewTimeout;
@property (nonatomic) BOOL disconnectAlert;
@property (nonatomic) BOOL returnFromPlayback;
@property (nonatomic) BOOL shouldUpdateHorizeMenu;
@property (nonatomic) BOOL isInLocal;
@property (nonatomic) BOOL isAlreadyHorizeMenu;
@property (nonatomic) BOOL wantToShowTimeLine;
@property (nonatomic) BOOL walkieTalkieEnabled;
@property (nonatomic) BOOL disableAutorotateFlag;
@property (nonatomic) BOOL enablePTT;
@property (nonatomic) BOOL isFirstLoad;

@property (nonatomic) BOOL syncPortraitAndLandscape;
@property (nonatomic) BOOL isLandScapeMode; // cheat to display correctly timeline bottom
@property (nonatomic) BOOL hideCustomIndicatorAndTextNotAccessble;
@property (nonatomic) BOOL isShowCustomIndicator; // check to show custom indicator
@property (nonatomic) BOOL isShowTextCameraIsNotAccesible; // check to show custom indicator

@property (nonatomic) BOOL isRecordInterface;
@property (nonatomic) BOOL isProcessRecording;

@property (nonatomic) NSInteger numberOfSTUNError;
@property (nonatomic) NSTimeInterval timeStageTwoTotal;
@property (nonatomic) NSInteger mediaProcessStatus;
@property (nonatomic) NSInteger numbersOfRemoteViewError;
@property (nonatomic) double ticks;

@property (nonatomic) BOOL userWantToCancel;
@property (nonatomic) int currentDirUD;
@property (nonatomic) int lastDirUD;
@property (nonatomic) int delay_update_lastDir_count;
@property (nonatomic) int currentDirLR;
@property (nonatomic) int lastDirLR;

// processing for hold to talk
@property (nonatomic) BOOL ptt_enabled;
@property (nonatomic, strong) AudioOutStreamer *audioOut;

// processing for recording
@property (nonatomic) int iMaxRecordSize;
@property (nonatomic, copy) NSString *iFileName;

// degreeC
@property (nonatomic, copy) NSString *degreeCString;
@property (nonatomic, copy) NSString *degreeFString;
@property (nonatomic) BOOL isDegreeFDisplay;

// visible in debug build only
@property (nonatomic, copy) NSString *viewVideoIn;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer;

@end

@implementation H264PlayerViewController

#define H264_STREAM_STARTED              1
#define H264_STREAM_STOPPED_UNEXPECTEDLY 2
#define H264_STREAM_RESTARTED            3
#define H264_STREAM_STOPPED              4
#define H264_REMOTE_STREAM_STOPPED_UNEXPECTEDLY 5
#define H264_CONNECTED_TO_CAMERA         6
#define H264_REMOTE_STREAM_CANT_CONNECT_FIRST_TIME 7
#define H264_REMOTE_STREAM_SSKEY_MISMATCH    8
#define H264_SWITCHING_TO_RELAY_SERVER       9
#define H264_REMOTE_STREAM_STOPPED          10
#define H264_SWITCHING_TO_RELAY2_SERVER     11

#define NXCOMM_WOWZA @"rtmp://nxcomm-office.no-ip.info:1935"
#define ME_WOWZA @"rtmp://wowza.api.simplimonitor.com:1935"
#define VIEW_NXCOMM_WOWZA @"nxcomm_wowza"

#define LOCAL_VIDEO_STOPPED_UNEXPECTEDLY 0x1001

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

#define MAXIMUM_ZOOMING_SCALE   6.0
#define MINIMUM_ZOOMING_SCALE   1.0f
#define ZOOM_SCALE              1.5f
#define CONTENT_SIZE_W_PORTRAIT 320
#define CONTENT_SIZE_H_PORTRAIT 180
#define CONTENT_SIZE_W_PORTRAIT_IPAD 768
#define CONTENT_SIZE_H_PORTRAIT_IPAD 432

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

#define _streamingSSID  @"string_Streaming_SSID"
#define _is_Loggedin @"bool_isLoggedIn"
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

#pragma mark - UIViewController methods

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    _hideCustomIndicatorAndTextNotAccessble = NO;
    
    // update navi
    self.earlierNavi = (EarlierNavigationController *)self.navigationController;
    _earlierNavi.isEarlierView = NO;
    _selectedItemMenu = INDEX_NO_SELECT;
    [_ib_buttonChangeAction setHidden:NO];
    [self.view bringSubviewToFront:_ib_buttonChangeAction];
    
    [_ib_labelRecordVideo setText:LocStr(@"Record video")];
    [_ib_labelTouchToTalk setText:LocStr(@"Touch to talk")];

    //setup Font
    [self applyFont];
    
    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_soundFileObject);
    
    CFRelease(soundFileURLRef);
    
    self.imageViewStreamer = [[UIImageView alloc] initWithFrame:_imageViewVideo.frame];
    [_imageViewStreamer setBackgroundColor:[UIColor blackColor]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapGestureCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_imageViewStreamer addGestureRecognizer:singleTap];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    _imageViewStreamer.userInteractionEnabled = NO;
    self.sharedCamConnectedTo = @"";
    self.cameraModel = [_selectedChannel.profile getModel];
    
    [self performSelectorInBackground:@selector(initHorizeMenu:) withObject:_cameraModel];
    
    [self.ib_lbCameraName setText:self.selectedChannel.profile.name];
    
    _isDegreeFDisplay = [userDefaults boolForKey:@"IS_FAHRENHEIT"];
    
    NSString *serverInput = [userDefaults stringForKey:@"name_server"];
    serverInput = [serverInput substringToIndex:serverInput.length - 3];
    self.talkbackRemoteServer = [serverInput stringByReplacingOccurrencesOfString:@"api" withString:@"talkback"];
    self.talkbackRemoteServer = [_talkbackRemoteServer stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
    
    self.remoteViewTimeout = [userDefaults boolForKey:@"remote_view_timeout"];
    self.disconnectAlert   = [userDefaults boolForKey:@"disconnect_alert"];
    
    self.enablePTT = YES;
    self.numbersOfRemoteViewError = 0;
    self.currentBitRate = @"128";
    self.messageStreamingState = LocStr(@"Camera is not accessible");
    self.timeStartingStageTwo = 0;

#ifndef DEBUG
    // Remove debug buttons for Release builds
    [_ib_btShowDebugInfo removeFromSuperview];
    [self setIb_btShowDebugInfo:nil];
    self.customIndicator.image = [UIImage imageNamed:@"loader_a"];
    
    DLog(@"camera model is :%@", self.cameraModel);

    [_sendLogButton removeFromSuperview];
    [self setSendLogButton:nil];
#endif
    
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView view will appear - return from Playback: %d", _returnFromPlayback] withProperties:nil];
    
    self.trackedViewName = GAI_CATEGORY;
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"viewWillAppear"
                                                     withLabel:nil
                                                     withValue:nil];
    [self startStreamPlayback];
    [self checkOrientation];
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
    
    DLog(@"%s", __FUNCTION__);
    [self setImageViewVideo:nil];
    [self setSelectedChannel:nil];
    [self setBackCover:nil];
}

#pragma mark - Public methods

- (void)setSelectedChannel:(CamChannel *)selectedChannel
{
    _selectedChannel = selectedChannel;
    
    CamProfile *cp = _selectedChannel.profile;
    self.title = cp.name;
}

- (void)goBackToCameraList
{
    [self stopPeriodicBeep];
    if ( _timerRemoteStreamTimeOut && [_timerRemoteStreamTimeOut isValid] ) {
        [_timerRemoteStreamTimeOut invalidate];
        _timerRemoteStreamTimeOut = nil;
    }
    
    [self stopStream];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _selectedChannel.profile.isSelected = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)applyFont
{
    if (_isLandScapeMode) {
        // update position text recording
        // update position button
        // Touch to Talk (size = 75, bottom align = 30
        CGSize holdTTButtonSize = _ib_buttonTouchToTalk.bounds.size;
        CGSize viewRecordSize   = _ib_viewRecordTTT.bounds.size;
        CGSize directionPadSize = _imgViewDrectionPad.bounds.size;
        
        float alignXButtonRecord        = SCREEN_HEIGHT - 15 - _ib_viewRecordTTT.bounds.size.width;
        float alignXButtonDirectionPad  = SCREEN_HEIGHT - directionPadSize.width - 10;
        float alignYButtonRecord        = SCREEN_WIDTH - viewRecordSize.height;
        float alignYButtonDirectionPad  = (SCREEN_WIDTH - 10 - directionPadSize.height);
        
        // margin TTT
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
        
        [_ib_ViewTouchToTalk setFrame:CGRectMake(alignXTTT, alignYTTT, holdTTButtonSize.width, holdTTButtonSize.height)];
        [_ib_viewRecordTTT setFrame:CGRectMake(alignXButtonRecord, alignYButtonRecord, viewRecordSize.width, viewRecordSize.height)];
        [_imgViewDrectionPad setFrame:CGRectMake(alignXButtonDirectionPad, alignYButtonDirectionPad, directionPadSize.width, directionPadSize.height)];
    }
    else {
        float marginBottomText, marginBottomButton, positionYOfBottomView;
        CGFloat fontSize = 19;
        
        if (isiPhone5) {
            // for holdtotalk
            fontSize = 19;
            marginBottomText = 42;
            marginBottomButton = 81;
            positionYOfBottomView = 255;
            
        }
        else if (isiPhone4) {
            fontSize = 17;
            marginBottomText = 25.0f;
            marginBottomButton = 48.0f;
            positionYOfBottomView = _ib_viewRecordTTT.frame.origin.y;
        }
        else {
            //iPad
            fontSize = 50;
            marginBottomText = 42.0f * 2;
            marginBottomButton = 81.0f * 2;
            positionYOfBottomView = 543.0f;
        }
        
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        
        [_ib_labelTouchToTalk setFont:font];
        _ib_labelTouchToTalk.textColor = [UIColor holdToTalkTextColor];

        [_ib_labelRecordVideo setFont:font];
        
        if (_isRecordInterface && _isProcessRecording) {
            _ib_labelRecordVideo.textColor = [UIColor recordingTextColor];
        }
        else {
            _ib_labelRecordVideo.textColor = [UIColor holdToTalkTextColor];
        }
        
        // update position text recording
        CGPoint localPoint = _ib_viewRecordTTT.frame.origin;
        NSString *recordingString = _ib_labelRecordVideo.text;
        
        CGSize recordingSize;
        if ( isiOS7AndAbove ) {
            recordingSize = [recordingString sizeWithAttributes:@{NSFontAttributeName: font}];
        }
        else {
            recordingSize = [recordingString sizeWithFont:font];
        }
        
        float alignY = (SCREEN_HEIGHT - localPoint.y) - marginBottomText + _ib_labelRecordVideo.bounds.size.height/2 - 3*recordingSize.height/2;
        
        // update position text Touch to Talk
        NSString *holdTTString = _ib_labelTouchToTalk.text;
        
        CGSize holdTTSize;
        if ( isiOS7AndAbove ) {
            holdTTSize = [holdTTString sizeWithAttributes:@{NSFontAttributeName:font}];
        }
        else {
            holdTTSize = [holdTTString sizeWithFont:font];
        }
        
        CGSize labelTouchToTalkSize = _ib_labelTouchToTalk.bounds.size;
        
        float alignY1 = (SCREEN_HEIGHT - localPoint.y) - marginBottomText + labelTouchToTalkSize.height/2 - 3*holdTTSize.height/2;
        
        if (isiOS7AndAbove) {
            [_ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY)];
            [_ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1)];
        }
        else {
            [_ib_labelRecordVideo setCenter:CGPointMake(SCREEN_WIDTH/2, alignY - 64)];
            [_ib_labelTouchToTalk setCenter:CGPointMake(SCREEN_WIDTH/2, alignY1 - 64)];
        }
        
        // update position button
        // Touch to Talk
        CGSize holdTTButtonSize = _ib_buttonTouchToTalk.bounds.size;
        CGSize directionPadSize = _imgViewDrectionPad.bounds.size;
        float alignXButton = SCREEN_WIDTH/2- holdTTButtonSize.width/2;
        float alignXButtonDirectionPad = SCREEN_WIDTH/2- directionPadSize.width/2;
        float alignYButton = SCREEN_HEIGHT - localPoint.y - marginBottomButton - holdTTButtonSize.height;
        float alignYButtonDirectionPad = (SCREEN_HEIGHT - localPoint.y - directionPadSize.height)/2;
        
        if (!isiOS7AndAbove) {
            alignYButton = alignYButton - 64;
            alignYButtonDirectionPad = alignYButtonDirectionPad - 44 - 64;
        }
        
        [_ib_buttonTouchToTalk setFrame:CGRectMake(alignXButton, alignYButton, holdTTButtonSize.width, holdTTButtonSize.height)];
        [_ib_processRecordOrTakePicture setFrame:CGRectMake(alignXButton, alignYButton, holdTTButtonSize.width, holdTTButtonSize.height)];
        [_imgViewDrectionPad setFrame:CGRectMake(alignXButtonDirectionPad, alignYButtonDirectionPad + localPoint.y, directionPadSize.width, directionPadSize.height)];
    }
}

- (void)setupHttpPort
{
    DLog(@"Self.selcetedChangel is %@", _selectedChannel);
    
    [HttpCom instance].comWithDevice.device_ip = _selectedChannel.profile.ip_address;
    [HttpCom instance].comWithDevice.device_port = _selectedChannel.profile.port;
    
    // init the ptt port to default
    _selectedChannel.profile.ptt_port = IRABOT_AUDIO_RECORDING_PORT;
}

- (void)addGesturesPichInAndOut
{
    [_scrollView insertSubview:_imageViewStreamer aboveSubview:_imageViewVideo];
    [_scrollView setUserInteractionEnabled:YES];

    // set background for scrollView
    [_scrollView setBackgroundColor:[UIColor clearColor]];

    // processing for pinch gestures
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = MAXIMUM_ZOOMING_SCALE;
    _scrollView.minimumZoomScale = MINIMUM_ZOOMING_SCALE;
    [self centerScrollViewContents];
    [self resetZooming];
    
    // Add action for touch
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [_imageViewStreamer addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [_imageViewStreamer addGestureRecognizer:twoFingerTapRecognizer];
}

// remove gestures touch when at portrait
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

- (void)nowButtonAction:(id)sender
{
    // Ensure CAM_IN_VEW is set so that view rotations happen as needed.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_selectedChannel.profile.mac_address forKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Touch up inside NOW btn item" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"nowButtonAciton"
                                                     withLabel:@"Now"
                                                     withValue:nil];
    
    _hideCustomIndicatorAndTextNotAccessble = NO;
    
    _earlierNavi.isEarlierView = NO;
    
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

    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Touch up inside EARLIER btn item" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"earlierButtonAction"
                                                     withLabel:@"Earlier"
                                                     withValue:nil];
    _hideCustomIndicatorAndTextNotAccessble = YES;
    
    _customIndicator.hidden = YES;
    _earlierNavi.isEarlierView = YES;
    
    if ( !_earlierVC ) {
        self.earlierVC = [[EarlierViewController alloc] initWithParentVC:self camChannel:self.selectedChannel];
        _earlierVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    
    [self.view addSubview:_earlierVC.view];
    [self.view bringSubviewToFront:_earlierVC.view];
    _earlierVC.view.hidden = NO;
    _earlierVC.camChannel = _selectedChannel;
    
    [self stopTalkbackUnexpected];
}

#pragma mark - Action

- (void)recordingPressAction
{
    self.recordingFlag = !_recordingFlag;
    NSString *modeRecording = @"";
    
    if (_recordingFlag) {
        modeRecording = @"on";
    }
    else {
        modeRecording = @"off";
    }
    
    [self performSelectorInBackground:@selector(setTriggerRecording_bg:) withObject:modeRecording];
}

- (void)melodyTouchAction
{
    if ( self.melodyViewController ) {
        [self.view addSubview:_melodyViewController.view];
        [self.view bringSubviewToFront:_melodyViewController.view];
    }
}

#pragma mark - Delegate Stream callback

- (void)forceRestartStream:(NSTimer *)timer
{
    DLog(@"%s", __FUNCTION__);
    [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:-99 ext2:-1];
    self.messageStreamingState = LocStr(@"Low data bandwidth detected. Trying to connect...");
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
    NSNumber *numberMsg = (NSNumber *)args[0];
    int msg = [numberMsg integerValue];
    
    int ext1 = -1, ext2 = -1;
    if ( args.count >= 3) {
        ext1 = [args[1] integerValue];
        ext2 = [args[2] integerValue];
    }
    
    switch (msg)
    {
        case MEDIA_INFO_GET_AUDIO_PACKET:
        {
            [_timerBufferingTimeout invalidate];
            self.timerBufferingTimeout = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_BUFFERING
                                                                          target:self
                                                                        selector:@selector(forceRestartStream:)
                                                                        userInfo:nil
                                                                         repeats:NO];
            break;
        }
        case MEDIA_INFO_START_BUFFERING:
        {
            DLog(@"%s MEDIA_INFO_START_BUFFERING", __FUNCTION__);
            [_timerBufferingTimeout invalidate];
            self.timerBufferingTimeout = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_BUFFERING
                                                                          target:self
                                                                        selector:@selector(forceRestartStream:)
                                                                        userInfo:nil
                                                                         repeats:NO];
            break;
        }
        case MEDIA_INFO_STOP_BUFFERING:
        {
            DLog(@"%s MEDIA_INFO_STOP_BUFFERING", __FUNCTION__);
            [_timerBufferingTimeout invalidate];
            break;
        }
#ifdef DEBUG
        case MEDIA_INFO_FRAMERATE_VIDEO:
        {
            [self updateDebugInfoFrameRate:ext1];
            break;
        }
#endif
        case MEDIA_INFO_VIDEO_SIZE:
        {
            DLog(@"video size: %d x %d", ext1, ext2);
            [self updateDebugInfoResolutionWidth:ext1 heigth:ext2];
            
            float top = 0 , left = 0;
            float destWidth;
            float destHeight;
            
            // Maintain Aspect Ratio
            if (ext1 == 0 || ext2 == 0) {
                break;
            }
            
            float ratio = (float) ext1/ (float)ext2;
            float fw = _imageViewVideo.frame.size.height * ratio;
            float fh = _imageViewVideo.frame.size.width  / ratio;
            
            DLog(@"video adjusted size:r= %f    fw=%f  fh=%f", ratio, fw, fh);
            
            if ( fw > _imageViewVideo.frame.size.width) {
                // Use the current width with new-height
                destWidth = _imageViewVideo.frame.size.width ;
                destHeight = fh;
                
                // so need to adjust the origin
                left = _imageViewVideo.frame.origin.x;
            }
            else {
                // Use the new-width with current height
                destWidth = fw;
                destHeight = _imageViewVideo.frame.size.height;
                
                // so need to adjust the origin
                if (_imageViewVideo.frame.size.width > fw) {
                    left = (_imageViewVideo.frame.size.width - fw)/2;
                }
                else {
                    left = _imageViewVideo.frame.origin.x;
                }
            }
            
            DLog(@"video adjusted size: %f x %f", destWidth, destHeight);
            
            _imageViewStreamer.frame = CGRectMake(left, top, destWidth, destHeight);
            break;
        }
        case MEDIA_INFO_BITRATE_BPS:
        {
            if ( _userWantToCancel ) {
                DLog(@"*[MEDIA_INFO_BITRATE_BPS] **SHOULD NOT HAPPEN FREQUENTLY* USER want to cancel **.. cancel after .1 sec...");
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(goBackToCameraList) withObject:nil afterDelay:0.1];
                break;
            }
            
            if ( _h264StreamerIsInStopped ) {
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(stopStream) withObject:nil afterDelay:0.1];
            }
            
#ifdef DEBUG
            [self updateDebugInfoBitRate:ext1];
#endif
            break;
        }
        case MEDIA_INFO_HAS_FIRST_IMAGE:
        {
            self.isShowCustomIndicator = NO;
            [self displayCustomIndicator];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TEST_MEDIA"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.timeStageTwoTotal = [[NSDate date] timeIntervalSinceDate:_timeStartingStageTwo];
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartPlayerView];
            
            DLog(@"%s total time: %f, stage 2 takes %f seconds", __FUNCTION__, diff, _timeStageTwoTotal);
            
            self.timeStartingStageTwo = 0;
            
            DLog(@"[MEDIA_PLAYER_HAS_FIRST_IMAGE]");
            if ( !_selectedChannel.profile.isInLocal ) {
                [_timerIncreaseBitRate invalidate];
                self.timerIncreaseBitRate = nil;
                
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
            
            if ( _selectedChannel.communication_mode == COMM_MODE_STUN ) {
                self.numberOfSTUNError = 0;
            }
            
            if ( _probeTimer.isValid ) {
                [self.probeTimer invalidate];
                self.probeTimer = nil;
            }
            
            [self stopPeriodicPopup];
            
            if ( _h264StreamerIsInStopped ) {
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(stopStream) withObject:nil afterDelay:0.1];
                break;
            }
            
            if ( _userWantToCancel  ) {
                DLog(@"*[MEDIA_PLAYER_HAS_FIRST_IMAGE] *** USER want to cancel **.. cancel after .1 sec...");
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(goBackToCameraList) withObject:nil afterDelay:0.1];
            }
            else {
                if ( _selectedChannel.profile.isInLocal && _askForFWUpgradeOnce ) {
                    [self performSelectorInBackground:@selector(checkIfUpgradeIsPossible) withObject:nil];
                    self.askForFWUpgradeOnce = NO;
                }

                if ( !_selectedChannel.profile.isInLocal ) {
                    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_timeStartingStageTwo];
                    
                    NSString *gaiActionTime = GAI_ACTION(2, diff);
                    DLog(@"%s gaiActionTime: %@", __FUNCTION__, gaiActionTime);
                    
                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                    withAction:gaiActionTime
                                                                     withLabel:nil
                                                                     withValue:nil];
                    self.timeStartingStageTwo = 0;
                    
                    if (_remoteViewTimeout == YES) {
                        [self reCreateTimoutViewCamera];
                    }
                }
                
                _imageViewStreamer.userInteractionEnabled = YES;
                _imgViewDrectionPad.userInteractionEnabled = YES;
                
                if (isiPhone4) {
                    _imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg"];
                }
                else {
                    _imgViewDrectionPad.image = [UIImage imageNamed:@"camera_action_pan_bg@5"];
                }
                
                [self performSelectorInBackground:@selector(getCameraTemperature:) withObject:nil];
                
                _horizMenu.userInteractionEnabled = YES;
            }
            
            break;
        }
        case MEDIA_PLAYER_STARTED:
        {
            self.currentMediaStatus = msg;
            
            if ( _userWantToCancel ) {
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(goBackToCameraList) withObject:nil afterDelay:0.1];
                break;
            }
            
            if ( _h264StreamerIsInStopped ) {
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(stopStream) withObject:nil afterDelay:0.1];
            }
            break;
        }
        case MEDIA_ERROR_SERVER_DIED:
    	case MEDIA_ERROR_TIMEOUT_WHILE_STREAMING:
        {
            self.currentMediaStatus = msg;
            
            // set custom indication is YES when server die
            _isShowCustomIndicator = YES;
            _isShowTextCameraIsNotAccesible = YES;
            
            [_timerBufferingTimeout invalidate];
            self.timerBufferingTimeout = nil;
            
            [_timerRemoteStreamKeepAlive invalidate];
            self.timerRemoteStreamKeepAlive = nil;
            
    		DLog(@"Timeout While streaming  OR server DIED - userWantToCancel: %d, returnFromPlayback: %d, forceStop: %d", _userWantToCancel, _returnFromPlayback, ext1);
            
            if ( _userWantToCancel ) {
                DLog(@"*[MEDIA_ERROR_TIMEOUT_WHILE_STREAMING] *** USER want to cancel **.. cancel after .1 sec...");
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(goBackToCameraList) withObject:nil afterDelay:0.1];
                return;
            }
            else {
                // Need not to do if went to Playback.
                if (!_returnFromPlayback) {
                    [self displayCustomIndicator];
                }
            }
            
            if ( _h264StreamerIsInStopped || _returnFromPlayback || [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                _selectedChannel.stopStreaming = YES;
                [self performSelector:@selector(stopStream) withObject:nil afterDelay:0.1];
                return;
            }
            
            if ( _selectedChannel.communication_mode == COMM_MODE_STUN ) {
                self.numberOfSTUNError++;
            }
            else if ( _selectedChannel.communication_mode == COMM_MODE_STUN_RELAY2 ) {
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
                    DLog(@"%s: numbers of remote streaming error: %d, curr Bit-rate; %@", __FUNCTION__, _numbersOfRemoteViewError, _currentBitRate);
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
            if ( _selectedChannel.profile.isInLocal ) {
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
                    DLog(@"%s gaiActionTime: %@", __FUNCTION__, gaiActionTime);
                    
                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                                    withAction:gaiActionTime
                                                                     withLabel:nil
                                                                     withValue:nil];
                    self.timeStartingStageTwo = 0;
                }
                
                DLog(@"Re-start Remote streaming for : %@", self.selectedChannel.profile.mac_address);
                
                [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(setupCamera)
                                               userInfo:nil
                                                repeats:NO];
            }
            
            break;
        }
        case H264_SWITCHING_TO_RELAY_SERVER:
        {
            DLog(@"switching to relay server");
            // Assume we are connecting via Symmetrict NAT
            [self remoteConnectingViaSymmectric];
            
            break;
        }
        case MEDIA_INFO_RECEIVED_VIDEO_FRAME:
        {
            _isShowCustomIndicator = NO;
            [self displayCustomIndicator];
            break;
        }
        case MEDIA_INFO_CORRUPT_FRAME_TIMEOUT:
        {
            _isShowCustomIndicator = YES;
            [self displayCustomIndicator];
            break;
        }
        default:
            break;
    }
}

- (void)reCreateTimoutViewCamera
{
    if ( _timerRemoteStreamTimeOut && [_timerRemoteStreamTimeOut isValid] ) {
        [_timerRemoteStreamTimeOut invalidate];
        self.timerRemoteStreamTimeOut = nil;
    }
    
    self.timerRemoteStreamTimeOut = [NSTimer scheduledTimerWithTimeInterval:270.0 //4m30s
                                                                     target:self
                                                                   selector:@selector(showDialogAndStopStream:)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (void)createTimerKeepRemoteStreamAlive
{
    [_timerRemoteStreamKeepAlive invalidate];
    self.timerRemoteStreamKeepAlive = nil;
    
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
    if (_userWantToCancel || _returnFromPlayback || !MediaPlayer::Instance()->isPlaying()) {
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
            DLog(@"%s SUCCEEDED", __FUNCTION__);
            [self createTimerKeepRemoteStreamAlive];
        }
        else {
            DLog(@"%s FAILED -responseDict: %@", __FUNCTION__, responseDict);
            [self performSelector:@selector(sendKeepAliveCmd:) withObject:nil afterDelay:1];
        }
    });
}

#pragma mark - TimelineVCDelegate protocol methods

- (void)stopStreamPlayback
{
    DLog(@"%s - currentMediaStatus: %d", __FUNCTION__, _currentMediaStatus);
    self.returnFromPlayback = YES;
    self.h264StreamerIsInStopped = YES;
    self.selectedChannel.stream_url = nil;
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (_audioOutStreamRemote) {
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }

    DLog(@"%s _mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startStreamPlayback
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(h264_HandleEnteredBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(h264_HandleEnteredBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(h264_HandleBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // alway show custom indicator, when view appears
    _isShowCustomIndicator = YES;
    self.currentMediaStatus = 0;
    self.shouldUpdateHorizeMenu = YES;
    self.wantToShowTimeLine = YES;
    self.viewVideoIn = @"R";
    
    if ( !_returnFromPlayback ) {
        self.isFirstLoad = YES;
        self.isRecordInterface  = YES;
        self.isProcessRecording = NO;
        self.ticks = 0.0;
        
        if ( _timelineVC ) {
            _timelineVC.camChannel = _selectedChannel;
        }
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.returnFromPlayback = NO;
        
        [self performSelectorOnMainThread:@selector(scanCamera)
                               withObject:nil
                            waitUntilDone:NO];
        
        self.h264StreamerIsInStopped = NO;
    }
    
    [self checkOrientation];
    
    if ( !_backCover ) {
        // Cover the back button so we can overide the default back action
        self.backCover = [[UIControl alloc] initWithFrame:CGRectMake( 0, 0, 100, 44)]; // Width setup for @"Cameras"
        [_backCover addTarget:self action:@selector(prepareGoBackToCameraList:) forControlEvents:UIControlEventTouchUpInside];
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
    DLog(@"Single tap singleTapGestureCaptured");
    
    if ( _isHorizeShow ) {
        [self hideControlMenu];
    }
    else {
        [self showControlMenu];
    }
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView single tap on video image view: %d", _isHorizeShow] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"single tap on video image view"
                                                     withLabel:@"Video image view"
                                                     withValue:[NSNumber numberWithDouble:_isHorizeShow]];
}

- (void)hideControlMenu
{
    [UIView animateWithDuration:0.3f animations:^{
        _menuBackgroundView.alpha = 0;
        self.isHorizeShow = NO;
        self.horizMenu.alpha = 0;
        self.ib_lbCameraName.alpha = 0;
    } completion:^(BOOL finished) {
        self.horizMenu.hidden = YES;
        self.ib_lbCameraName.hidden = YES;
    }];
}

- (void)showControlMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        _menuBackgroundView.alpha = 1;
        _menuBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.isHorizeShow = YES;
        self.horizMenu.hidden = NO;
        [self.view bringSubviewToFront:_horizMenu];
        self.horizMenu.alpha = 1.0;
        self.ib_lbCameraName.hidden = NO;
        self.ib_lbCameraName.alpha = 1.0;
    } completion:nil];
    
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
        _timelineVC.view.hidden = YES;
    }
    _timerHideMenu = nil;
    
}

- (void)showTimelineView
{
    // reset selected menu;
    _selectedItemMenu = -1;
    
    if ( _timelineVC ) {
        _timelineVC.view.hidden = NO;
        [self.view bringSubviewToFront:_timelineVC.view];
    }
}

- (void)h264_HandleBecomeActive
{
    DLog(@"%s wants to cancel: %d, rtn frm Playback: %d", __FUNCTION__, _userWantToCancel, _returnFromPlayback);
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Become active" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Become Active"
                                                     withLabel:nil
                                                     withValue:[NSNumber numberWithDouble:_userWantToCancel]];
    
    if ( _userWantToCancel || _returnFromPlayback) {
        return;
    }
    
    self.h264StreamerIsInStopped = NO;
    self.currentMediaStatus = 0;
    self.wantToShowTimeLine = YES;
    
    if (!_earlierNavi.isEarlierView) {
        [self showTimelineView];
    }
    
    if ( _selectedChannel.profile.isInLocal ) {
        DLog(@"Become ACTIVE _  .. Local");
    }
    else if ( _selectedChannel.profile.minuteSinceLastComm <= 5) {
        // Remote
        DLog(@"Become ACTIVE _  .. REMOTE");
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL cancelBecauseOfPn = [userDefaults boolForKey:HANDLE_PN];
    if ( cancelBecauseOfPn ) {
        DLog(@"set user = true");
        self.userWantToCancel = YES;
        return;
    }
    
    [self scanCamera];
}

- (void)h264_HandleEnteredBackground
{
    DLog(@"%s wants to cancel: %d, rtn frm Playback: %d, nav: %@", __FUNCTION__, _userWantToCancel, _returnFromPlayback, self.navigationController.visibleViewController.description);
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView Enter background" withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Enter background"
                                                     withLabel:@"Homekey"
                                                     withValue:[NSNumber numberWithDouble:_userWantToCancel]];
    
    if ( _userWantToCancel || _returnFromPlayback ) {
        return;
    }
    
    _selectedChannel.stopStreaming = YES;
    
    [self stopPeriodicBeep];
    [self stopPeriodicPopup];
    
    if (_alertViewTimoutRemote) {
        [_alertViewTimoutRemote dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    if (_audioOutStreamRemote) {
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
    
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
    
    self.h264StreamerIsInStopped = YES;
    _imageViewVideo.backgroundColor = [UIColor blackColor];
    _imageViewStreamer.backgroundColor = [UIColor blackColor];
    
    if ( _selectedChannel.profile.isInLocal ) {
        DLog(@"Enter Background.. Local ");
    }
    else if (_selectedChannel.profile.minuteSinceLastComm <= 5) {
        // Remote
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
        self.timelineVC = [[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
        [self.view addSubview:_timelineVC.view];
        _timelineVC.timelineVCDelegate = self;
        _timelineVC.camChannel = _selectedChannel;
        _timelineVC.parentVC = self;
        
        [_timelineVC loadEvents:_selectedChannel];
    }
    
    _selectedChannel.stopStreaming = NO;
    [self displayCustomIndicator];
    [self scanCamera];
    [self hideControlMenu];
    
    DLog(@"Check selectedChannel is %@ and ip of deviece is %@", _selectedChannel, _selectedChannel.profile.ip_address);
    
    [self setupPtt];
    
    self.stringTemperature = @"0";
    //end add button to change
    [_ib_switchDegree setHidden:YES];
    
    _imageViewHandle.hidden = YES;
    _imageViewKnob.center = _imgViewDrectionPad.center;
    _imageViewHandle.center = _imgViewDrectionPad.center;
    
    DLog(@"H264VC - becomeActive -timeline: %@", NSStringFromCGRect(_timelineVC.view.frame));
}

#pragma mark - Shared Cam

- (void)queryToKnowSharedCamOnMacOSOrWin
{
    NSString *bodyKey = @"";
    
    if ( _selectedChannel.profile.isInLocal ) {
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"get_running_os"];
        if ( response ) {
            self.sharedCamConnectedTo = [[response componentsSeparatedByString:@": "] objectAtIndex:1];
        }
	}
	else if ( _selectedChannel.profile.minuteSinceLastComm <= 5 ) {
        // Remote
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        if (_jsonCommBlocked == nil) {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:_selectedChannel.profile.registrationID
                                                                                 andCommand:[NSString stringWithFormat:@"action=command&command=get_running_os"]
                                                                                  andApiKey:apiKey];
        if ( responseDict ) {
            NSInteger status = [responseDict[@"status"] intValue];
            if (status == 200) {
                bodyKey = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
        if (![bodyKey isEqualToString:@""]) {
            NSArray *tokens = [bodyKey componentsSeparatedByString:@": "];
            if ( tokens.count >= 2 ) {
                self.sharedCamConnectedTo = tokens[1]; // returns MacOS|Window
            }
        }
        else {
            // default is connected to window.
            _sharedCamConnectedTo = @"Unknown";
        }
	}
}

- (void)createMonvementControlTimer
{
    [self cleanUpDirectionTimers];
    if ([_cameraModel isEqualToString:CP_MODEL_BLE]) {
        // MBP83
        DLog(@"H264VC - createMonvementControlTimer");
        
        // Direction stuff - Kick off the two timer for direction sensing
        self.currentDirUD = DIRECTION_V_NON;
        self.lastDirUD = DIRECTION_V_NON;
        self.delay_update_lastDir_count = 1;
        
        self.send_UD_dir_req_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(v_directional_change_callback:)
                                                               userInfo:nil
                                                                repeats:YES];
        
        self.currentDirLR = DIRECTION_H_NON;
        self.lastDirLR = DIRECTION_H_NON;
        
        self.send_LR_dir_req_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(h_directional_change_callback:)
                                                               userInfo:nil
                                                                repeats:YES];
    }
}

#pragma mark - Setup camera

- (void)setupCamera
{
    self.isInLocal = _selectedChannel.profile.isInLocal;
    self.mediaProcessStatus = 0;
    [self createMonvementControlTimer];
    
    _isShowCustomIndicator = YES;
    [self displayCustomIndicator];
    _selectedChannel.stream_url = nil;
    
    [self setupHttpPort];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    DLog(@"H264VC - setupCamera -device_ip: %@, -device_port: %d, -{remote_only: %d}", _selectedChannel.profile.ip_address, _selectedChannel.profile.port, [userDefaults boolForKey:@"remote_only"]);

    // Support remote UPNP video as well
    if ( _selectedChannel.profile.isInLocal ) {
        DLog(@"H264VC - setupCamera -created a local streamer");
        self.selectedChannel.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", _selectedChannel.profile.ip_address];
        DLog(@"%s Start stage 2", __FUNCTION__);
        self.timeStartingStageTwo = [NSDate date];
        
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
        self.viewVideoIn = @"L";
        
        _ib_labelTouchToTalk.text = LocStr(@"Touch to talk");
        self.stringStatePTT = LocStr(@"Touch to talk");
    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5) {
        DLog(@"H264VC - setupCamera - created a remote streamer - {enable_stun}: %@", [userDefaults objectForKey:@"enable_stun"]);

        // Ignore enable_stun value key
        [self symmetric_check_result:YES];
        
        _ib_labelTouchToTalk.text = LocStr(@"Touch to talk");
        self.stringStatePTT = LocStr(@"Touch to talk");
    }
    else {
        DLog(@"Unknown Exception!");
    }
}

- (void)startStunStream
{
    self.selectedChannel.communication_mode = COMM_MODE_STUN;
    NSDate *timeout;
    NSRunLoop *mainloop = [NSRunLoop currentRunLoop];
    
    do {
        //send probes
        [_client sendAudioProbesToIp:_selectedChannel.profile.camera_mapped_address
                                 andPort:_selectedChannel.profile.camera_stun_audio_port];
        [NSThread sleepForTimeInterval:0.3];
        
        [_client sendVideoProbesToIp:_selectedChannel.profile.camera_mapped_address
                                 andPort:_selectedChannel.profile.camera_stun_video_port];
        
        timeout = [NSDate dateWithTimeIntervalSinceNow:0.5];
        [mainloop runUntilDate:timeout];
        
        if ( _userWantToCancel ) {
            DLog(@"startStunStream: userWantToCancel >>>>");
            break;
        }
    }
    while ( !_selectedChannel.stream_url || _selectedChannel.stream_url.length == 0 );
    
    if ( !_userWantToCancel ) {
        self.probeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(periodicProbe:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    
    DLog(@"--URL: %@", _selectedChannel.stream_url);
    [self startStream];
}

- (void)startStream
{
    self.h264StreamerIsInStopped = NO;
    
    if ( _userWantToCancel ) {
        DLog(@"startStream: userWantToCancel >>>>");
        //force this to gobacktoCameralist
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:0 ext2:0];
        return;
    }
    
    if ( _returnFromPlayback ) {
        DLog(@"H264VC - startStream --> break to Playback");
        return;
    }
    
    self.mediaProcessStatus = 1;
    DLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    self.h264StreamerListener = new H264PlayerListener(self);
    MediaPlayer::Instance()->setListener(_h264StreamerListener);
    MediaPlayer::Instance()->setPlaybackAndSharedCam(false, [_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]);

    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    
    // Store current SSID - to check later
	self.current_ssid = [CameraPassword fetchSSIDInfo];
    
	if (_current_ssid == nil) {
		DLog(@"Error: streamingSSID is nil before streaming");
	}
    
	DLog(@"Current SSID is: %@", _current_ssid);
    
	// Store some of the info for used in menu  --
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL isOffline = [userDefaults boolForKey:OFFLINE_MODE_KEY];
    
	[userDefaults setBool:!(isOffline) forKey:_is_Loggedin];
    
	if ( _current_ssid ) {
		[userDefaults setObject:_current_ssid forKey:_streamingSSID];
	}
    
    [userDefaults synchronize];
    
    NSString *url = _selectedChannel.stream_url;
    DLog(@"%s url: %@", __FUNCTION__, url);
    
    self.mediaProcessStatus = 2;
    DLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    do {
        if ( !url || [url isEqualToString:@""]) {
            break;
        }
        
        status = MediaPlayer::Instance()->setDataSource([url UTF8String]);
        
        if (status != NO_ERROR) {
            // NOT OK
            DLog(@"setDataSource  failed");
            
            if (self.selectedChannel.profile.isInLocal) {
                self.messageStreamingState = @"Camera is not accessible";
            }

            break;
        }
        
        MediaPlayer::Instance()->setVideoSurface(_imageViewStreamer);
        status = MediaPlayer::Instance()->prepare();
        
        if (status != NO_ERROR) {
            // NOT OK
            break;
        }
        
        // Play anyhow
        status = MediaPlayer::Instance()->start();
        
        if (status != NO_ERROR) {
            // NOT OK
            break;
        }
    }
    while (false);
    
    DLog(@"%s mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    self.mediaProcessStatus = 3;
    
    if (status == NO_ERROR) {
        [self handleMessage:MEDIA_PLAYER_STARTED ext1:0 ext2:0];
    }
    else {
        // Consider it's down and perform necessary action.
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:0 ext2:0];
    }
}

- (void)prepareGoBackToCameraList:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView goes back" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Go back"
                                                     withLabel:@"Hubble back button item"
                                                     withValue:[NSNumber numberWithDouble:_currentMediaStatus]];
    
    self.activityStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:_activityStopStreamingProgress];
    
    _isShowCustomIndicator = NO;
    
    self.view.userInteractionEnabled = NO;
    
    DLog(@"H264VC- prepareGoBackToCameraList - self.currentMediaStatus: %d", self.currentMediaStatus);
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.userWantToCancel = YES;
    _selectedChannel.stopStreaming = YES;
    
    if (_audioOutStreamRemote) {
        [self performSelectorInBackground:@selector(closeRemoteTalkback) withObject:nil];
        [_audioOutStreamRemote disconnectFromAudioSocketRemote];
    }
    
    DLog(@"%s _mediaProcessStatus: %d", __FUNCTION__, _mediaProcessStatus);
    
    if (_timelineVC) {
        _timelineVC.timelineVCDelegate = nil;
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
}

- (void)goBackToCamerasRemoteStreamTimeOut
{
    _activityStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:_activityStopStreamingProgress];
    
    DLog(@"self.currentMediaStatus: %d", self.currentMediaStatus);
    
    self.userWantToCancel = YES;
    _selectedChannel.stopStreaming = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _selectedChannel.profile.isSelected = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBack
{
    // Release the instance here - since we are going to camera list
    MediaPlayer::release();
    
    _activityStopStreamingProgress.hidden = NO;
    [self.view bringSubviewToFront:_activityStopStreamingProgress];
    
    DLog(@"self.currentMediaStatus: %d", _currentMediaStatus);
    
    self.userWantToCancel = YES;
    _selectedChannel.stopStreaming = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _selectedChannel.profile.isSelected = NO;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)cleanUpDirectionTimers
{
    if ([_cameraModel isEqualToString:CP_MODEL_BLE]) {
        // MBP83 - Kick off the two timer for direction sensing
        self.currentDirUD = DIRECTION_V_NON;
        self.lastDirUD    = DIRECTION_V_NON;
        self.delay_update_lastDir_count = 1;
        
        if ( _send_UD_dir_req_timer ) {
            if ([_send_UD_dir_req_timer isValid] ) {
                [_send_UD_dir_req_timer invalidate];
                self.send_UD_dir_req_timer = nil;
            }
        }
        
        self.currentDirLR = DIRECTION_H_NON;
        self.lastDirLR  = DIRECTION_H_NON;
        
        if ( _send_LR_dir_req_timer ) {
            if ([_send_LR_dir_req_timer isValid]) {
                [_send_LR_dir_req_timer invalidate];
                self.send_LR_dir_req_timer = nil;
            }
        }
    }
}

- (void)stopStunStream
{
    if ( [_probeTimer isValid]) {
        [_probeTimer invalidate];
        self.probeTimer = nil;
    }
    
    if ( _selectedChannel.communication_mode == COMM_MODE_STUN ) {
        if ( _selectedChannel.profile.camera_mapped_address &&
            _selectedChannel.profile.camera_stun_audio_port != 0 &&
            _selectedChannel.profile.camera_stun_video_port != 0 )
        {
            // Make sure we are connecting via STUN
            if ( _h264PlayerVCDelegate ) {
                _selectedChannel.waitingForStreamerToClose = YES;
                DLog(@"waiting for close STUN stream from server");
            }
            
            H264PlayerViewController *vc = (H264PlayerViewController *)self;
            [self performSelectorInBackground:@selector(closeStunStream_bg:) withObject:vc];
        }
    }
    
    if ( _client ) {
        [_client shutdown];
        _client = nil;
    }
}

- (void)closeStunStream_bg: (id)vc
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    if ( !_jsonCommBlocked ) {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSString *cmd_string = @"action=command&command=close_p2p_rtsp_stun";
    
    [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                 andCommand:cmd_string
                                                  andApiKey:apiKey];
    H264PlayerViewController *thisVC = (H264PlayerViewController *)vc;
    if ( _userWantToCancel ) {
        [thisVC.h264PlayerVCDelegate stopStreamFinished:thisVC.selectedChannel];
        thisVC.h264PlayerVCDelegate = nil;
    }
    else {
        _selectedChannel.waitingForStreamerToClose = NO;
    }
    
}

- (void)stopStream
{
    DLog(@"Calling suspend() on thread: %@", [NSThread currentThread]);
    self.timerStopStreamAfter30s = nil;
    @synchronized(self)
    {
        if (_timerIncreaseBitRate) {
            [_timerIncreaseBitRate invalidate];
            self.timerIncreaseBitRate = nil;
        }
        
        if (_timerBufferingTimeout) {
            [_timerBufferingTimeout invalidate];
            self.timerBufferingTimeout = nil;
        }
        
        if (_timerRemoteStreamKeepAlive) {
            [_timerRemoteStreamKeepAlive invalidate];
            self.timerRemoteStreamKeepAlive = nil;
        }
        
        MediaPlayer::Instance()->setListener(NULL);
       
        delete _h264StreamerListener;
        _h264StreamerListener = NULL;
        
        _isProcessRecording = NO;
        [self stopRecordingVideo];
        
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        
        [self cleanUpDirectionTimers];
        
        if ( _scanner ) {
            [_scanner cancel];
        }
        
        if ( _timerRemoteStreamTimeOut ) {
            [_timerRemoteStreamTimeOut invalidate];
            self.timerRemoteStreamTimeOut = nil;
        }
        
        _imageViewStreamer.userInteractionEnabled = NO;
        
        if ( _isHorizeShow ) {
            [self hideControlMenu];
        }
        
        [self hideAllBottomView];
        
        //TODO: enable this???
        //[self stopStunStream];
    }
}

- (void)showDialogAndStopStream:(id)sender
{
    _timerRemoteStreamTimeOut = nil;
    // stop stream after 30s if user no click.
    self.timerStopStreamAfter30s = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(stopStream) userInfo:nil repeats:NO];
    
    if (_alertViewTimoutRemote && _alertViewTimoutRemote.isVisible) {
        DLog(@"%s already visible!", __FUNCTION__);
    }
    else {
        self.alertViewTimoutRemote = [[UIAlertView alloc] initWithTitle:LocStr(@"Remote stream")
                                                            message:LocStr(@"The camera has been viewed for about 5 minutes. Do you want to continue?")
                                                           delegate:self
                                                  cancelButtonTitle:LocStr(@"No")
                                                  otherButtonTitles:LocStr(@"Yes"), nil];
        
        _alertViewTimoutRemote.tag = TAG_ALERT_VIEW_REMOTE_TIME_OUT;
        [_alertViewTimoutRemote show];
    }
}

- (void)setTriggerRecording_bg:(NSString *)modeRecording
{
    NSString *responseString = @"";
    
    if ( _selectedChannel.profile.isInLocal ) {
        //[HttpCom instance].comWithDevice.device_ip   = self.selectedChannel.profile.ip_address;
        //[HttpCom instance].comWithDevice.device_port = self.selectedChannel.profile.port;
        
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:[NSString stringWithFormat:@"set_recording_stat&mode=%@", modeRecording]];
        if ( responseData ) {
            responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
            DLog(@"setTriggerRecording_bg response string: %@", responseString);
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
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:[NSString stringWithFormat:@"action=command&command=set_recording_stat&mode=%@", modeRecording]
                                                                                  andApiKey:apiKey];
        if ( responseDict ) {
            NSInteger status = [responseDict[@"status"] intValue];
            if (status == 200) {
                responseString = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    if ( !responseString || [responseString isEqualToString:@""]) {
        self.recordingFlag = !_recordingFlag;
    }
}

#pragma mark - Melody Control

- (void)getMelodyValue
{
    NSString *responseString = @"";
    
    if ( _selectedChannel.profile.isInLocal ) {
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"value_melody"];
        if ( responseData ) {
            responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
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
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        
        NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:self.selectedChannel.profile.registrationID
                                                                                 andCommand:@"action=command&command=value_melody"
                                                                                  andApiKey:apiKey];
        if ( responseDict ) {
            NSInteger status = [responseDict[@"status"] intValue];
            if (status == 200) {
                responseString = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            }
        }
    }
    
    DLog(@"getMelodyValue: %@", responseString);
    
    if (![responseString isEqualToString:@""]) {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        if (tmpRange.location != NSNotFound) {
            NSArray *tokens = [responseString componentsSeparatedByString:@": "];
            if ( tokens.count > 1 ) {
                NSString *melodyIndex = [tokens lastObject];
                if ( !_userWantToCancel ) {
                    [self performSelectorOnMainThread:@selector(setMelodyState:) withObject:melodyIndex waitUntilDone:NO];
                }
            }
        }
    }
}

- (void)setMelodyState:(NSString *)melodyIndex
{
    NSInteger index  = [melodyIndex intValue] - 1;
    [self.melodyViewController updateUIMelody:index];
}

#pragma mark - Temperature

- (void)getCameraTemperature:(id)sender
{
    // If back, Need not to update UI
    if ( _userWantToCancel ) {
        return;
    }
    
    NSString *responseString = @"";
    
    if ( _selectedChannel.profile.isInLocal ) {
        NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"value_temperature"];
        if ( responseData ) {
            responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
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
    
    DLog(@"Reponse - getCameraTemperature: %@", responseString);
    
    if (![responseString isEqualToString:@""]   && // Get temperature failed!
        ![responseString isEqualToString:@"NA"] && // Received temperature wrong format
        ![responseString hasSuffix:@"null"])       // Received temperature {status code} null
    {
        NSRange tmpRange = [responseString rangeOfString:@": "];
        
        if (tmpRange.location != NSNotFound) {
            NSArray *arrayBody = [responseString componentsSeparatedByString:@": "];
            if (arrayBody.count == 2) {
                self.stringTemperature = [arrayBody objectAtIndex:1];
                
                // If back, Need not to update UI
                if ( _userWantToCancel ) {
                    return;
                }
                
                [self performSelectorOnMainThread:@selector(setTemperatureState:)
                                       withObject:_stringTemperature
                                    waitUntilDone:NO];
            }
        }
    }
    
    // Make sure Update temperature once after that check condition
    if ( [sender isKindOfClass:[NSTimer class]] ) {
        if ( _ib_temperature.hidden || _userWantToCancel || _h264StreamerIsInStopped ) {
            [((NSTimer *)sender) invalidate];
            sender = nil;
            self.existTimerTemperature = NO;
            
            DLog(@"Log - Invalidate Timer get temperature");
            return;
        }
    }
}

- (void)setTemperatureState:(NSString *)temperature
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
    
    NSString *degreeStr;
    if (_isDegreeFDisplay) {
        degreeStr = LocStr(@"°F");
        stringTemperature = _degreeFString;
    }
    else {
        degreeStr = LocStr(@"°C");
        stringTemperature = _degreeCString;
    }
    
    degreeCelsius.text= degreeStr;
    
    UIFont *degreeFont;
    UIFont *temperatureFont;
    float positionYOfBottomView = _ib_temperature.frame.origin.y;
    
    if (!isiOS7AndAbove) {
        positionYOfBottomView = positionYOfBottomView - 44;
    }
    
    if (_isLandScapeMode) {
        degreeCelsius.backgroundColor = [UIColor clearColor];
        degreeCelsius.textColor = [UIColor whiteColor];
        float xPosTemperature;
        float yPosTemperature;
        CGSize stringBoundingBox;;
        CGSize degreeCelBoundingBox;
        CGFloat deltaWidth = 20;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            degreeFont = [UIFont systemFontOfSize:13];
            temperatureFont = [UIFont systemFontOfSize:53];
        }
        else {
            // iPad
            degreeFont = [UIFont systemFontOfSize:30];
            temperatureFont = [UIFont systemFontOfSize:100];
            positionYOfBottomView = _ib_temperature.frame.origin.y;
            deltaWidth += 72;
        }
        
        [degreeCelsius setFont:degreeFont];
        [_ib_temperature setFont:temperatureFont];
        [_ib_temperature setTextColor:[UIColor whiteColor]];
        [_ib_temperature setShadowColor:[UIColor blackColor]];
        [_ib_temperature setShadowOffset:CGSizeMake(2, 2)];
        [_ib_temperature setText:stringTemperature];
        
        if ( isiOS7AndAbove ) {
            stringBoundingBox = [stringTemperature sizeWithAttributes:@{NSFontAttributeName:temperatureFont}];
            degreeCelBoundingBox = [degreeStr sizeWithAttributes:@{NSFontAttributeName:degreeFont}];
        }
        else {
            stringBoundingBox = [stringTemperature sizeWithFont:temperatureFont];
            degreeCelBoundingBox = [degreeStr sizeWithFont:degreeFont];
        }
        
        xPosTemperature = SCREEN_HEIGHT - _ib_temperature.bounds.size.width - 40 + (_ib_temperature.bounds.size.width - stringBoundingBox.width)/2;
        yPosTemperature = SCREEN_WIDTH - deltaWidth - stringBoundingBox.height;
        
        [_ib_temperature setFrame:CGRectMake(xPosTemperature, yPosTemperature + 10, _ib_temperature.bounds.size.width, _ib_temperature.bounds.size.height)];
        [_ib_switchDegree setFrame:CGRectMake(xPosTemperature, yPosTemperature, _ib_temperature.bounds.size.width, _ib_temperature.bounds.size.height)];
        
        CGFloat widthString = stringBoundingBox.width;
        CGFloat alignX = (_ib_temperature.bounds.size.width + widthString)/2;
        [degreeCelsius setFrame:CGRectMake(alignX, 5, degreeCelBoundingBox.width, degreeCelBoundingBox.height)];
        [_ib_temperature addSubview:degreeCelsius];
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (isiPhone4) {
                degreeFont = [UIFont systemFontOfSize:30];
                temperatureFont = [UIFont systemFontOfSize:125];
            }
            else {
                // iPhone 5+ (tall screen)
                degreeFont = [UIFont systemFontOfSize:35];
                temperatureFont = [UIFont systemFontOfSize:135];
            }
        }
        else {
            // iPad
            degreeFont = [UIFont systemFontOfSize:50];
            temperatureFont = [UIFont systemFontOfSize:200];
            positionYOfBottomView = 543.0f;
        }
        
        [degreeCelsius setFont:degreeFont];
        [_ib_temperature setFrame:CGRectMake(0, positionYOfBottomView, SCREEN_WIDTH, SCREEN_HEIGHT - positionYOfBottomView)];
        [_ib_switchDegree setFrame:CGRectMake(0, positionYOfBottomView, SCREEN_WIDTH, SCREEN_HEIGHT - positionYOfBottomView)];
        [_ib_temperature setFont:temperatureFont];
        [_ib_temperature setTextColor:[UIColor temperatureTextColor]];
        
        // need update text for C or F
        [_ib_temperature setText:stringTemperature];

        CGSize stringBoundingBox;
        CGSize degreeCelBoundingBox;
        if ( isiOS7AndAbove ) {
            stringBoundingBox = [stringTemperature sizeWithAttributes:@{NSFontAttributeName:temperatureFont}];
            degreeCelBoundingBox = [degreeStr sizeWithAttributes:@{NSFontAttributeName:degreeFont}];
        }
        else {
            stringBoundingBox = [stringTemperature sizeWithFont:temperatureFont];
            degreeCelBoundingBox = [degreeStr sizeWithFont:degreeFont];
        }
        
        CGFloat widthString = stringBoundingBox.width;
        CGFloat heightString = stringBoundingBox.height;
        CGFloat alignX = (SCREEN_WIDTH + widthString)/2 - degreeCelBoundingBox.width/2 + 8;
        CGFloat alignYCel = (SCREEN_HEIGHT - positionYOfBottomView)/2 - heightString/2 + 10;
        [degreeCelsius setFrame:CGRectMake(alignX, alignYCel, degreeCelBoundingBox.width, degreeCelBoundingBox.height)];
        [_ib_temperature addSubview:degreeCelsius];
    }
}

#pragma mark - Stun probe timer

-(void)periodicProbe:(NSTimer *)exp
{
    if ( _userWantToCancel || _selectedChannel.stopStreaming ) {
        DLog(@"Stop probing ... ");
    }
    else if ( _client ) {
        NSRunLoop *mainloop = [NSRunLoop currentRunLoop];
        DLog(@"send probes ... ");

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
    NSInteger result = (isBehindSymmetricNat ? TYPE_SYMMETRIC_NAT : TYPE_NON_SYMMETRIC_NAT);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ( [userDefaults boolForKey:@"enable_stun"] ) {
        [userDefaults setInteger:result forKey:APP_IS_ON_SYMMETRIC_NAT];
        [userDefaults synchronize];
    }
    
    dispatch_queue_t qt = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(qt, ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *stringUDID = self.selectedChannel.profile.registrationID;
        
        NSDate *dateStage1 = [NSDate date];
        
        if ( !_jsonCommBlocked ) {
            self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                         Selector:nil
                                                                     FailSelector:nil
                                                                        ServerErr:nil];
        }
        
        NSDictionary *responseDict;
        
        if ( isBehindSymmetricNat ) {
            // USE RELAY
            self.viewVideoIn = @"R";

            responseDict = [_jsonCommBlocked createSessionBlockedWithRegistrationId:stringUDID
                                                                      andClientType:@"BROWSER"
                                                                          andApiKey:apiKey];
            DLog(@"USE RELAY TO VIEW- userWantsToCancel:%d, returnFromPlayback:%d, responsed: %@", _userWantToCancel, _returnFromPlayback, responseDict);
            
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateStage1];
            NSString *gaiActionTime = GAI_ACTION(1, diff);
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:gaiActionTime
                                                             withLabel:nil
                                                             withValue:nil];
            
            DLog(@"%s stage 1 takes %f seconds \n Start stage 2 \n %@", __FUNCTION__, diff, gaiActionTime);
            self.timeStartingStageTwo = [NSDate date];
            
            if (!_userWantToCancel && !_returnFromPlayback && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                if ( responseDict) {
                    if ([responseDict[@"status"] intValue] == 200) {
                        NSString *urlResponse = [responseDict[@"data"] objectForKey:@"url"];
                        
                        if ( [urlResponse hasPrefix:ME_WOWZA] && [userDefaults boolForKey:VIEW_NXCOMM_WOWZA] ) {
                            _selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                        }
                        else {
                            _selectedChannel.stream_url = urlResponse;
                        }
                        
                        _selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                        DLog(@"%s Start stage 2", __FUNCTION__);
                        [self performSelectorOnMainThread:@selector(startStream) withObject:nil waitUntilDone:NO];
                        self.messageStreamingState = LocStr(@"Low data bandwidth detected. Trying to connect...");
                    }
                    else {
                        //handle Bad response
                        DLog(@"%s ERROR: %@", __FUNCTION__, responseDict[@"message"]);

                        self.messageStreamingState = LocStr(@"Camera is not accessible");
                        _isShowTextCameraIsNotAccesible = YES;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _ib_lbCameraNotAccessible.hidden = NO;
                        });
                        
                        [self symmetric_check_result:YES];
                    }
                }
                else {
                    DLog(@"SERVER unreachable (timeout) ");
                    self.messageStreamingState = LocStr(@"Camera is not accessible");
                    _isShowTextCameraIsNotAccesible = YES;

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_ib_lbCameraNotAccessible setHidden:NO];
                        [self performSelector:@selector(setupCamera) withObject:nil afterDelay:10];
                    });
                }
            }
            else {
                DLog(@"%s View is invisible OR in background mode. Do nothing!", __FUNCTION__);
            }
        }
        else {
            // USE RTSP/STUN - Set port1, port2
            DLog(@"TRY TO USE RTSP/STUN TO VIEW***********************");
            self.viewVideoIn = @"S";
            
            if ([_client create_stun_forwarder:_selectedChannel] != 0 ) {
                //TODO: Handle error??
            }
            
            NSString *cmd_string = [NSString stringWithFormat:@"action=command&command=get_session_key&mode=p2p_stun_rtsp&port1=%d&port2=%d&ip=%@",
                                    _selectedChannel.local_stun_audio_port,
                                    _selectedChannel.local_stun_video_port,
                                    _selectedChannel.public_ip];
            
            responseDict =  [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                         andCommand:cmd_string
                                                                          andApiKey:apiKey];
            if ( responseDict ) {
                DLog(@"symmetric_check_result, responseDict: %@", responseDict);
                
                NSString *body = [[[responseDict objectForKey: @"data"] objectForKey: @"device_response"] objectForKey: @"body"];
                
                DLog(@"Respone - camera response : %@, Number of STUN error: %d", body, _numberOfSTUNError);
                if ( body ) {
                    NSArray *tokens = [body componentsSeparatedByString:@","];
                    if ( [[tokens objectAtIndex:0] hasSuffix:@"error=200"]) {
                        // roughly check for "error=200"
                        if (_numberOfSTUNError >= 3) {
                            // Switch to RELAY because STUN try probe & failed many times
                            DLog(@"Switch to RELAY - Number of STUN error: %d", _numberOfSTUNError);
                            
                            // close current session  before continue
                            cmd_string = @"action=command&command=close_p2p_rtsp_stun";
                            
                            [_jsonCommBlocked sendCommandBlockedWithRegistrationId:stringUDID
                                                                        andCommand:cmd_string
                                                                         andApiKey:apiKey];
                            if ( !_userWantToCancel ) {
                                self.numberOfSTUNError = 0;
                                NSArray *args = @[[NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER]];
                                self.viewVideoIn = @"R";
                                
                                // relay
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
                            
                            if ( !_userWantToCancel ) {
                                self.viewVideoIn = @"S";
                                [self performSelectorOnMainThread:@selector(startStunStream)
                                                       withObject:nil
                                                    waitUntilDone:NO];
                            }
                        }
                    }
                    else {
                        DLog(@"Respone error - camera response error: %@", body);
                        
                        // close current session  before continue
                        cmd_string = @"action=command&command=close_p2p_rtsp_stun";
                        
                        //responseDict =
                        [_jsonCommBlocked  sendCommandBlockedWithRegistrationId:stringUDID
                                                                     andCommand:cmd_string
                                                                      andApiKey:apiKey];
                        
                        if ( !_userWantToCancel ) {
                            self.viewVideoIn = @"R";
                            NSArray *args = @[[NSNumber numberWithInt:H264_SWITCHING_TO_RELAY_SERVER]];
                            
                            // relay
                            [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                                   withObject:args
                                                waitUntilDone:NO];
                        }
                    }
                }
                else {
                    DLog(@"Respone error - can't parse \"body\"field from: %@", responseDict);
                    
                    NSArray *args = @[[NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED]];
                    
                    // force server died
                    [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                           withObject:args
                                        waitUntilDone:NO];
                    
                }
            }
            else {
                DLog(@"SERVER unreachable (timeout) - responseDict == nil --> Need test this more");
                
                NSArray *args = @[[NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED]];
                
                [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                       withObject:args
                                    waitUntilDone:NO];
            }
        }
    });
    
    
    if ( isBehindSymmetricNat ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *bodyKey = @"";
            
            if (self.selectedChannel.profile.isInLocal ) {
                [HttpCom instance].comWithDevice.device_ip   = _selectedChannel.profile.ip_address;
                [HttpCom instance].comWithDevice.device_port = _selectedChannel.profile.port;
                
                NSData *responseData = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:@"get_resolution"];
                if ( responseData ) {
                    bodyKey = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
                    DLog(@"symmetric_check_result response string: %@", bodyKey);
                }
            }
            else if (_selectedChannel.profile.minuteSinceLastComm <= 5) {
                // Remote
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *stringUDID = _selectedChannel.profile.registrationID;
                NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
                DLog(@"Log - registrationID: %@, apikey: %@", stringUDID, apiKey);
                
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
                
                DLog(@"symmetric_check_result responseDict = %@", responseDict);
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
    }
}

- (void)remoteConnectingViaSymmectric
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
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
        DLog(@"remoteConnectingViaSymmectric: %@", responseDict);
        if ( responseDict) {
            if ([responseDict[@"status"] intValue] == 200) {
                NSString *urlResponse = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
                
                if ( [urlResponse hasPrefix:ME_WOWZA] && [userDefalts boolForKey:VIEW_NXCOMM_WOWZA] ) {
                    _selectedChannel.stream_url = [urlResponse stringByReplacingOccurrencesOfString:ME_WOWZA withString:NXCOMM_WOWZA];
                }
                else {
                    _selectedChannel.stream_url = urlResponse;
                }
                
                if ( !_userWantToCancel ) {
                    _selectedChannel.communication_mode = COMM_MODE_STUN_RELAY2;
                    [self performSelectorOnMainThread:@selector(startStream) withObject:nil waitUntilDone:NO];
                }
            }
            else {
                // handle Bad response
                NSArray *args = @[[NSNumber numberWithInt:MEDIA_ERROR_SERVER_DIED]];
                
                // force server died
                [self performSelectorOnMainThread:@selector(handleMessageOnMainThread:)
                                       withObject:args
                                    waitUntilDone:NO];
            }
        }
        else {
            DLog(@"SERVER unreachable (timeout) ");
            //TODO : handle SERVER unreachable (timeout)??
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
        {
            transformX = 0;
            transformY = 0;
            break;
        }
        case DIRECTION_H_LF:
        {
            transformX =  - _imageViewKnob.frame.size.width;
            transformY = 0;
            break;
        }
        case DIRECTION_H_RT:
        {
            transformX = _imageViewKnob.frame.size.width;
            transformY = 0;
            break;
        }
        case DIRECTION_V_DN:
        {
            transformX = 0;
            transformY = _imageViewKnob.frame.size.width;
            break;
        }
        case DIRECTION_V_UP:
        {
            transformX = 0;
            transformY = - _imageViewKnob.frame.size.width;
            break;
        }
        default:
            break;
    }
    
    _imageViewKnob.transform = CGAffineTransformMakeTranslation(transformX, transformY);
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
        {
            _imageViewHandle.hidden = YES;
            transformX = 0;
            transformY = 0;
            angleRotation = 0;
            break;
        }
        case DIRECTION_H_LF:
        {
            _imageViewHandle.hidden = NO;
            transformX =  - _imageViewHandle.frame.size.height / 2;
            transformY = 0;
            angleRotation = -M_PI_2;
            break;
        }
        case DIRECTION_H_RT:
        {
            _imageViewHandle.hidden = NO;
            transformX = _imageViewHandle.frame.size.height / 2;
            transformY = 0;
            angleRotation = M_PI_2;
            break;
        }
        case DIRECTION_V_DN:
        {
            _imageViewHandle.hidden = NO;
            transformX = 0;
            transformY = _imageViewHandle.frame.size.height / 2;
            angleRotation = 0;
            break;
        }
        case DIRECTION_V_UP:
        {
            _imageViewHandle.hidden = NO;
            transformX = 0;
            transformY = - _imageViewHandle.frame.size.height / 2;
            angleRotation = 0;
            break;
        }
        default:
            break;
    }
    
    _imageViewHandle.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(transformX, transformY), angleRotation);
}

// Periodically called every 200ms
- (void)v_directional_change_callback:(NSTimer *)timer_exp
{
	/* currentDirUD holds the LATEST direction,
     lastDirUD holds the LAST direction that we have seen
     - this is called every 100ms
	 */
	@synchronized(_imgViewDrectionPad)
	{
		if (_lastDirUD != DIRECTION_V_NON) {
            //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView V directional change" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:@"V directional change"
                                                             withLabel:@"Direction pad"
                                                             withValue:nil];
            
			[self send_UD_dir_to_rabot:_currentDirUD];
		}
        
		// Update directions
		self.lastDirUD = _currentDirUD;
	}
}

- (void)send_UD_dir_to_rabot:(int)direction
{
	NSString *dir_str = nil;
	float duty_cycle = 0;
    
	switch (direction) {
		case DIRECTION_V_NON:
        {
			dir_str= FB_STOP;
			break;
        }
		case DIRECTION_V_DN	:
        {
			duty_cycle = IRABOT_DUTYCYCLE_MAX;// +0.1;
			dir_str= MOVE_DOWN;
			dir_str = [NSString stringWithFormat:@"%@%.1f", dir_str, duty_cycle];
			break;
        }
		case DIRECTION_V_UP	:
        {
			duty_cycle = IRABOT_DUTYCYCLE_MAX ;
			dir_str= MOVE_UP;
			dir_str = [NSString stringWithFormat:@"%@%.1f", dir_str, duty_cycle];
			break;
        }
		default:
			break;
	}
    
	if (dir_str) {
        if (_selectedChannel.profile.isInLocal) {
            // Non block send-
            DLog(@"device_ip: %@, device_port: %d", _selectedChannel.profile.ip_address, _selectedChannel.profile.port);
            
            [[HttpCom instance].comWithDevice sendCommand:dir_str];
		}
		else if (_selectedChannel.profile.minuteSinceLastComm <= 5) {
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
            DLog(@"send_UD_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void)h_directional_change_callback:(NSTimer *)timerExp
{
    //BOOL need_to_send = NO;
    @synchronized(_imgViewDrectionPad)
	{
		if ( _lastDirLR != DIRECTION_H_NON ) {
			//need_to_send = TRUE;
            //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView H directional change" withProperties:nil];
            
            [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                            withAction:@"H directional change"
                                                             withLabel:@"Direction pad"
                                                             withValue:nil];
            
            [self send_LR_dir_to_rabot:_currentDirLR];
		}
        
		// Update directions
		self.lastDirLR = _currentDirLR;
	}
}

- (void)send_LR_dir_to_rabot:(int)direction
{
	NSString * dir_str = nil;
    
	switch (direction)
    {
		case DIRECTION_H_NON:
        {
			dir_str= LR_STOP;
			break;
        }
		case DIRECTION_H_LF	:
        {
			dir_str= MOVE_LEFT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str,(float) IRABOT_DUTYCYCLE_LR_MAX];
			break;
        }
		case DIRECTION_H_RT	:
        {
			dir_str= MOVE_RIGHT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str,(float) IRABOT_DUTYCYCLE_LR_MAX];
			break;
        }
		default:
			break;
	}
    
    DLog(@"dir_str: %@", dir_str);
    
	if ( dir_str ) {
        if ( _selectedChannel.profile.isInLocal ) {
            // Non block send-
            [[HttpCom instance].comWithDevice sendCommand:dir_str];
		}
		else if ( _selectedChannel.profile.minuteSinceLastComm <= 5 ) {
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
            DLog(@"send_LR_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void)updateVerticalDirection_begin:(int)dir inStep:(uint)step
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
		self.currentDirUD = newDirection;
        [self updateKnobUI:_currentDirUD]; // Update ui for Knob & Handle
        [self updateHandleUI:_currentDirUD];
	}
    
	// Adjust the fire date to now
	NSDate *now = [NSDate date];
	[_send_UD_dir_req_timer setFireDate:now];
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
		self.currentDirUD = newDirection;
        [self updateKnobUI:_currentDirUD];
        [self updateHandleUI:_currentDirUD];
	}
}

- (void)updateVerticalDirection_end:(int)dir inStep:(uint)step
{
	@synchronized(_imgViewDrectionPad)
	{
		self.currentDirUD = DIRECTION_V_NON;
        [self updateKnobUI:DIRECTION_V_NON];
        [self updateHandleUI:DIRECTION_V_NON];
	}
}

- (void)updateHorizontalDirection_end:(int)dir inStep:(uint)step
{
	@synchronized(_imgViewDrectionPad)
	{
		self.currentDirLR = DIRECTION_H_NON;
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
    
	@synchronized(_imgViewDrectionPad) {
		self.currentDirLR = newDirection;
        [self updateKnobUI:_currentDirLR];
        [self updateHandleUI:_currentDirLR];
	}
    
	// Adjust the fire date to now
	NSDate *now = [NSDate date];
	[_send_LR_dir_req_timer setFireDate:now ];
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
    
	@synchronized(_imgViewDrectionPad) {
		self.currentDirLR = newDirection;
        [self updateKnobUI:_currentDirLR];
        [self updateHandleUI:_currentDirLR];
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
                [_timerHideMenu invalidate];
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
                [_timerHideMenu invalidate];
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
        if ( touch.view.tag == 999 ) {
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void)touchEventAt:(CGPoint) location phase:(UITouchPhase) phase
{
    if ([_cameraModel isEqualToString:CP_MODEL_BLE]) {
        // MBP83
        switch (phase)
        {
            case UITouchPhaseBegan:
            {
                [self touchesbegan:location];
                break;
            }
            case UITouchPhaseMoved:
            case UITouchPhaseStationary:
            {
                [self touchesmoved:location];
                break;
            }
            case UITouchPhaseEnded:
            {
                [self touchesended:location];
                break;
            }
            default:
                break;
        }
    }
}

- (void)touchesbegan:(CGPoint)location
{
	[self validatePoint:location newMovement:YES ];
}

- (void)touchesmoved:(CGPoint)location
{
	/*
     when moved, the new point may change from vertical to Horizontal plane ,
     thus reset it here,
     later the point will be re-evaluated  and set to the corrent command
     */
    
    [self updateVerticalDirection_end:0 inStep:0];
	[self updateHorizontalDirection_end:0 inStep:0];
    [self validatePoint:location newMovement:NO ];
}

- (void)touchesended:(CGPoint)location
{
	CGPoint beginLocation = CGPointMake(_imgViewDrectionPad.center.x - _imgViewDrectionPad.frame.origin.x,
                                        _imgViewDrectionPad.center.y - _imgViewDrectionPad.frame.origin.y);
    
	[self validatePoint:beginLocation newMovement:NO ];
	[self updateVerticalDirection_end:0 inStep:0];
	[self updateHorizontalDirection_end:0 inStep:0];
}

- (void)validatePoint:(CGPoint)location newMovement:(BOOL)isBegan
{
	CGPoint translation;
	BOOL is_vertical;
    
	CGPoint beginLocation = CGPointMake(_imgViewDrectionPad.center.x - _imgViewDrectionPad.frame.origin.x,
                                        _imgViewDrectionPad.center.y - _imgViewDrectionPad.frame.origin.y);
    
	translation.x =  location.x - beginLocation.x;
	translation.y =  location.y - beginLocation.y;

	is_vertical = YES;
	
    if ( abs(translation.x) >  abs(translation.y)) {
		is_vertical = NO;
	}
    
	if ( is_vertical ) {
		/// TODO: update image
		if (translation.y > 0) {
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else if (translation.y <0) {
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else {
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
        
		if (isBegan) {
			[self updateVerticalDirection_begin:translation.y inStep:0];
		}
		else {
			[self updateVerticalDirection:translation.y inStep:0 withAnimation:NO];
		}
	}
	else {
		// TODO: update image
		if (translation.x > 0) {
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else if (translation.x < 0) {
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
		else {
			[_imgViewDrectionPad setImage:[UIImage imageCameraActionPan]];
		}
        
		if (isBegan) {
			[self updateHorizontalDirection_begin:translation.x inStep:0];
		}
		else {
			[self updateHorizontalDirection:translation.x inStep:0 withAnimation:NO];
		}
	}
}

#pragma mark - Rotation screen

- (BOOL)shouldAutorotate
{
    if ( _userWantToCancel || _earlierNavi.isEarlierView ) {
        return NO;
    }
    return !_disableAutorotateFlag;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (_earlierNavi.isEarlierView) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView - will rotate interface" withProperties:nil];
    
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
    DLog(@"H264VC - adjustViewsForOrientation:");
    
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

        // Load new nib for landscape iPad
        [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land" owner:self options:nil];
        self.melodyViewController = [[MelodyViewController alloc] initWithNibName:@"MelodyViewController_land" bundle:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_earlierVC.view setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        }
        else {
            if (isiOS7AndAbove) {
                _melodyViewController.view.frame = CGRectMake(393, 78, 175, 165);
            }
            else {
                _melodyViewController.view.frame = CGRectMake(320, 60, 159, 204);
            }
        }
        
        if ( !_isHorizeShow ) {
            _menuBackgroundView.alpha = 0;
        }
        
        _melodyViewController.selectedChannel = _selectedChannel;
        _melodyViewController.melodyVcDelegate = self;
        
        // Landscape mode - hide navigation bar
        self.navigationController.navigationBarHidden = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
        
        if (_isAlreadyHorizeMenu) {
            [self.horizMenu reloadData:YES];
        }
        
        // I don't know why remove it.
        [self.melodyViewController.view removeFromSuperview];
        
        CGFloat imageViewHeight = SCREEN_HEIGHT * 9 / 16;
        CGRect newRect = CGRectMake(0, (SCREEN_WIDTH - imageViewHeight) / 2, SCREEN_HEIGHT, imageViewHeight);
        _imageViewVideo.frame = CGRectMake(0, 0, SCREEN_HEIGHT, imageViewHeight);
        self.scrollView.frame = newRect;
        
        if ( _timelineVC ) {
            [self.timelineVC.view removeFromSuperview];
        }
        
        [self addGesturesPichInAndOut];
	}
	else if ( UIInterfaceOrientationIsPortrait(orientation) ) {
        // remove pinch in, out (zoom for portrait)
        [self removeGestureRecognizerAtPortraitMode];

        // load new nib
        [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController" owner:self options:nil];
        self.melodyViewController = [[MelodyViewController alloc] initWithNibName:@"MelodyViewController" bundle:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_earlierVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        }
        
        if ( !_isHorizeShow ) {
            _menuBackgroundView.alpha = 0;
        }
        
        _melodyViewController.selectedChannel = _selectedChannel;
        _melodyViewController.melodyVcDelegate = self;
        
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        if (_isAlreadyHorizeMenu) {
            [self.horizMenu reloadData:NO];
        }
        
        CGFloat imageViewHeight = SCREEN_WIDTH * 9 / 16;
        
        if (isiOS7AndAbove) {
            self.melodyViewController.view.frame = CGRectMake(0, self.ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - _ib_ViewTouchToTalk.frame.origin.y);
        }
        else {
            CGRect destRect = CGRectMake(0, deltaY, SCREEN_WIDTH, imageViewHeight);
            _scrollView.frame = destRect;
            _imageViewVideo.frame = CGRectMake(0, -44, SCREEN_WIDTH, imageViewHeight);
            _melodyViewController.view.frame = CGRectMake(0, _ib_ViewTouchToTalk.frame.origin.y - 30 - 44, SCREEN_WIDTH, SCREEN_HEIGHT - _ib_ViewTouchToTalk.frame.origin.y);
        }
        
        [self showControlMenu];
        _isLandScapeMode = NO;
	}
    
    // Ensure that TimelineVC view frame is setup correctly
    if ( _timelineVC ) {
        CGRect rect = self.view.bounds;
        
        if (isiOS7AndAbove) {
            // Place with the same y as the video container's scroll view.
            rect.origin.y = _scrollView.frame.origin.y + _scrollView.frame.size.height;
        }
        else {
            // Place with the a y that is just under the toolbar view.
            rect.origin.y = _menuBackgroundView.frame.origin.y + _menuBackgroundView.frame.size.height;
        }
        
        rect.origin.y += 10;
        rect.size.height -= rect.origin.y;
        _timelineVC.view.frame = rect;
        _timelineVC.view.hidden = NO;
        
        [self.view insertSubview:_timelineVC.view belowSubview:_scrollView];
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
    [self setTemperatureState:_stringTemperature];
    
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
    if (MediaPlayer::Instance()->isPlaying()) {
        _isShowCustomIndicator = NO;
    }
    
    if (_currentMediaStatus != 0) {
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
    
    // Earlier must at bottom of land, and port
    if (_isFirstLoad || _wantToShowTimeLine || _selectedItemMenu == -1) {
        [self showTimelineView];
    }
    else {
        [self hideTimelineView];
    }
    
    _ib_buttonTouchToTalk.enabled = _enablePTT;
    _ib_labelTouchToTalk.text = _stringStatePTT;
}

#pragma mark - Scan cameras

- (void)scan_for_missing_camera
{
    self.scanAgain = YES;
    if ( _userWantToCancel ) {
        return;
    }
    
    DLog(@"scanning for : %@", _selectedChannel.profile.mac_address);
	self.scanner = [[ScanForCamera alloc] initWithNotifier:self];
	[_scanner scan_for_device:_selectedChannel.profile.mac_address];
}

#pragma mark - ScanForCameraNotifier protocol methods

- (void)scan_done:(NSArray *)scanResults
{
    // Scan for Local camera if it is disconnected
    if ( _scanAgain ) {
        BOOL found = NO;

        if (scanResults.count > 0) {
            //confirm the mac address
            CamProfile *cp = self.selectedChannel.profile;
            
            for (int j = 0; j < scanResults.count; j++) {
                CamProfile *cp1 = (CamProfile *)scanResults[j];
                
                if ( [cp.mac_address isEqualToString:cp1.mac_address]) {
                    //FOUND - copy ip address.
                    cp.ip_address = cp1.ip_address;
                    cp.isInLocal = YES;
                    cp.port = cp1.port;
                    found = YES;
                    break;
                }
            }
        }
        
        if (!found) {
            // Rescan...
            DLog(@"Re- scan for : %@", self.selectedChannel.profile.mac_address);
            [self scan_for_missing_camera];
        }
        else {
            // Restart streaming..
            DLog(@"Re-start streaming for : %@", self.selectedChannel.profile.mac_address);
            
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(setupCamera)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    else {
        // This is scan for camera when -becomeActive
        BOOL found = NO;
        
        _selectedChannel.profile.isInLocal = NO;
        
        if ( scanResults.count > 0 ) {
            //confirm the mac address
            CamProfile *cp = _selectedChannel.profile;
            
            for (int j = 0; j < scanResults.count; j++) {
                CamProfile *cp1 = (CamProfile *)scanResults[j];
                
                if ( [cp.mac_address isEqualToString:cp1.mac_address] ) {
                    //FOUND - copy ip address.
                    cp.ip_address = cp1.ip_address;
                    cp.isInLocal = YES;
                    cp.port = cp1.port;
                    found = YES;
                    break;
                }
            }
        }
        
        DLog(@"Scan done with ipserver");
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        
        while ( _threadBonjour.isExecuting ) {
            if ( _userWantToCancel ) {
                [_threadBonjour cancel];
            }
            else {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
            }
        }
        
        DLog(@"\nH264=================================\nSCAN DONE - IPSERVER SYNC BONJOUR\nCamProfile: %@\nbonjourList: %@\n=================================\n", self.selectedChannel.profile, _bonjourList);
        
        if ( _bonjourList.count > 0 && !found ) {
            // If Camera is NOT found on ip-sever
            for (CamProfile *cam in _bonjourList) {
                if ([_selectedChannel.profile.mac_address isEqualToString:cam.mac_address]) {
                    DLog(@"H264 Camera is on Bonjour -mac: %@, -port: %d", _selectedChannel.profile.mac_address, cam.port);
                    _selectedChannel.profile.ip_address = cam.ip_address;
                    _selectedChannel.profile.isInLocal = YES;
                    _selectedChannel.profile.port = cam.port;
                    found = YES;
                    break;
                }
            }
        }
        
        _bonjourList = nil;
        _selectedChannel.profile.hasUpdateLocalStatus = YES;
        
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
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView dismiss alert: %d with btn index: %d", tag, buttonIndex] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Dismiss alert: %d", tag]
                                                     withLabel:[NSString stringWithFormat:@"Alert %@", alertView.title]
                                                     withValue:[NSNumber numberWithInteger:buttonIndex]];
    
    if (tag == TAG_ALERT_VIEW_REMOTE_TIME_OUT) {
        switch (buttonIndex)
        {
            case 0: // No - Go back to camera list
            {
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
                
                // stop stream
                if ( [_timerStopStreamAfter30s isValid] ) {
                    // stop time, avoid stopStream 2 times
                    [_timerStopStreamAfter30s invalidate];
                    self.timerStopStreamAfter30s = nil;
                    [self stopStream];
                }
                
                [self goBackToCamerasRemoteStreamTimeOut];
                break;
            }
            case 1: // Yes - restart stream
            {
                if ( !_timerStopStreamAfter30s ) {
                    // already stop stream, call setup again.
                    [self setupCamera];
                }
                else {
                    if ( [_timerStopStreamAfter30s isValid] ) {
                        // stop time, avoid stopStream 2 times
                        [_timerStopStreamAfter30s invalidate];
                        self.timerStopStreamAfter30s = nil;
                    }
                    // do nothing, just dissmiss because still stream.
                    // create new timer to display info after 4m30s.
                    [self reCreateTimoutViewCamera];
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Beeping

- (void)periodicBeep:(NSTimer *)exp
{
    if ( _userWantToCancel ) {
        [self stopPeriodicBeep];
    }
    else {
        [self playSound];
    }
}

- (void)stopPeriodicBeep
{
	if ( _alertTimer ) {
		if ([_alertTimer isValid]) {
			[_alertTimer invalidate];
            self.alertTimer = nil;
		}
	}
}

- (void)periodicPopup:(NSTimer *)exp
{
	[self playSound];
}

- (void)stopPeriodicPopup
{
	if ( _alertTimer ) {
		if ([_alertTimer isValid]) {
			[_alertTimer invalidate];
		}
	}
}

- (void)playSound
{
	// Play beep
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        AudioServicesPlaySystemSound(_soundFileObject);
    }
    else {
        AudioServicesPlayAlertSound(_soundFileObject);
    }
}

#pragma mark - Zoom in&out

- (void)centerScrollViewContents
{
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
    
    DLog(@"H264VC - centerScrollViewContents -imageVideo: %@, imageStreamer: %@", NSStringFromCGRect(_imageViewVideo.frame), NSStringFromCGRect(_imageViewStreamer.frame));
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    DLog(@"double tap scrollViewDoubleTapped");
    // Get the location within the image view where we tapped
    //CGPoint pointInView = [recognizer locationInView:self.imageViewVideo];
    CGPoint pointInView = [recognizer locationInView:_imageViewStreamer];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = _scrollView.zoomScale * ZOOM_SCALE;
    newZoomScale = MIN(newZoomScale, _scrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
    DLog(@"Two finger tap scrollViewTwoFingerTapped");
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / ZOOM_SCALE;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [_scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)resetZooming
{
    CGFloat newZoomScale = MINIMUM_ZOOMING_SCALE;
    [_scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return _imageViewStreamer;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - HorizMenu Data Source

- (void)initHorizeMenu:(NSString *)camerModel
{
    self.isAlreadyHorizeMenu = YES;

    /*
     //create list image for display horizontal scroll view menu
     1.Pan, Tilt & Zoom (bb_setting_icon.png)
     2.Microphone (for two way audio) bb_setting_icon.png
     3.Take a photo/Record Video ( bb_rec_icon_d.png )
     4.Lullaby          bb_melody_off_icon.png
     5.Camera List          bb_camera_slider_icon
     6.Temperature display        temp_alert
     */
    
    if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]) {
        //query command to check shared cam is connected to mac or window
        [self queryToKnowSharedCamOnMacOSOrWin];
        if ([_sharedCamConnectedTo isEqualToString:@"MACOS"]) {
            self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_photo.png", @"video_action_temp.png", nil];
            self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_photo_pressed.png", @"video_action_temp_pressed.png", nil];
        }
        else {
            self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan.png", @"video_action_video.png", @"video_action_music.png", @"video_action_temp.png", nil];
            self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed.png", @"video_action_video_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
        }
    }
    else if ([_cameraModel isEqualToString:CP_MODEL_CONCURRENT]) {
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_mic.png", @"video_action_photo.png", @"video_action_music.png", @"video_action_temp.png", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_mic_pressed.png", @"video_action_photo_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
    }
    else {
        //if ([_cameraModel isEqualToString:CP_MODEL_BLE])
        self.itemImages = [NSMutableArray arrayWithObjects:@"video_action_pan.png", @"video_action_mic.png", @"video_action_video.png", @"video_action_music.png", @"video_action_temp.png", nil];
        self.itemSelectedImages = [NSMutableArray arrayWithObjects:@"video_action_pan_pressed.png", @"video_action_mic_pressed.png", @"video_action_video_pressed.png", @"video_action_music_pressed.png", @"video_action_temp_pressed.png", nil];
    }
    
    //[self.horizMenu reloadData:NO];
    [self performSelectorOnMainThread:@selector(horizMenuReloadData) withObject:nil waitUntilDone:NO];
}

- (void)horizMenuReloadData
{
    [_horizMenu reloadData:NO];
}

- (UIImage *)selectedItemImageForMenu:(ScrollHorizontalMenu *)menu withIndexItem:(NSInteger)index
{
    NSString *imageSelected = _itemSelectedImages[index];
    return [UIImage imageNamed:imageSelected];
}

- (UIColor *)backgroundColorForMenu:(ScrollHorizontalMenu *)menu
{
    return [UIColor clearColor];
}

- (int)numberOfItemsForMenu:(ScrollHorizontalMenu *)menu
{
    return _itemImages.count;
}

- (NSString *)horizMenu:(ScrollHorizontalMenu *)menu nameImageForItemAtIndex:(NSUInteger)index
{
    return _itemImages[index];
}

- (NSString *)horizMenu:(ScrollHorizontalMenu *)menu nameImageSelectedForItemAtIndex:(NSUInteger)index
{
    return _itemSelectedImages[index];
}

#pragma mark - HorizMenu Delegate

- (void)horizMenu:(ScrollHorizontalMenu *)menu itemSelectedAtIndex:(NSUInteger)index
{
    /*
     //new
     0. pan/tilt,
     1. mic,
     2. rec,
     3. melody,
     4. temp
     */
    
    // show when user selects one item inner control panel
    [self showControlMenu];
    
    self.wantToShowTimeLine = NO;
    self.isFirstLoad = NO;
    
    if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]) {
        if ([_sharedCamConnectedTo isEqualToString:@"MACOS"]) {
            if (index == 0) {
                self.selectedItemMenu = INDEX_RECORDING;
            }
            else if (index == 1) {
                self.selectedItemMenu = INDEX_TEMP;
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
                    [self melodyTouchAction];
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
                [self melodyTouchAction];
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
                [self recordingPressAction];
                break;
                
            case INDEX_RECORDING:
                self.selectedItemMenu = INDEX_RECORDING;
                break;
                
            case INDEX_MELODY:
                self.selectedItemMenu = INDEX_MELODY;
                [self melodyTouchAction];
                break;
                
            case INDEX_TEMP:
                self.selectedItemMenu = INDEX_TEMP;
                break;
                
            default:
                DLog(@"Action out of bounds");
                break;
        }
    }
    
    [self hideTimelineView];
    [self updateBottomView];
    [self applyFont];
    
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"PlayerView select item on horize menu - idx: %d", _selectedItemMenu] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Select item on horiz menu"
                                                     withLabel:@"Item"
                                                     withValue:[NSNumber numberWithInt:_selectedItemMenu]];
}

- (void)updateBottomView
{
    [self hideAllBottomView];

    if (_wantToShowTimeLine || _horizMenu.isAllButtonDeselected) {
        [self showTimelineView];
    }
    else {
        if (_selectedItemMenu == INDEX_PAN_TILT) {
            [self.view bringSubviewToFront:_imgViewDrectionPad];
            [self.view bringSubviewToFront:_imageViewKnob];
            [self.view bringSubviewToFront:_imageViewHandle];
            _imgViewDrectionPad.hidden = NO;
            _imageViewKnob.hidden = NO;
            _imageViewKnob.center = _imgViewDrectionPad.center;
            _imageViewHandle.center = _imgViewDrectionPad.center;
        }
        else if (_selectedItemMenu == INDEX_MICRO) {
            [self.view bringSubviewToFront:self.ib_ViewTouchToTalk];
            _ib_ViewTouchToTalk.hidden = NO;
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
                _ib_buttonChangeAction.hidden = YES;
            }
        }
        else if (_selectedItemMenu == INDEX_MELODY) {
            _melodyViewController.view.hidden = NO;
            
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
                    rect = CGRectMake(0, _ib_ViewTouchToTalk.frame.origin.y - 5, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
                else {
                    rect = CGRectMake(0, _ib_ViewTouchToTalk.frame.origin.y - 30 - 44, SCREEN_WIDTH, SCREEN_HEIGHT - self.ib_ViewTouchToTalk.frame.origin.y);
                }
            }
            
            _melodyViewController.view.frame = rect;
            
            /*
             TODO:need get status of laluby and update on UI.
             when landscape or portrait display correctly
             */
            [self performSelectorInBackground:@selector(getMelodyValue) withObject:nil];
            [_melodyViewController.melodyTableView setNeedsLayout];
            [_melodyViewController.melodyTableView setNeedsDisplay];
            
        }
        else if (_selectedItemMenu == INDEX_TEMP) {
            _ib_temperature.hidden = NO;
            _ib_switchDegree.hidden = NO;
            [self.view bringSubviewToFront:_ib_switchDegree];
            
            if ( !_existTimerTemperature ) {
                self.existTimerTemperature = YES;
                DLog(@"Log - Create Timer to get Temperature");
                //should call it first and then update later
                [self setTemperatureState:_stringTemperature];
                [NSTimer scheduledTimerWithTimeInterval:10
                                                 target:self
                                               selector:@selector(getCameraTemperature:)
                                               userInfo:nil
                                                repeats:YES];
            }
        }
        else {
            [self showTimelineView];
        }
    }
    
    [self stopTalkbackUnexpected];
}

- (void)hideAllBottomView
{
    _imgViewDrectionPad.hidden = YES;
    _imageViewKnob.hidden = YES;
    _imageViewHandle.hidden = YES;
    
    _ib_temperature.hidden = YES;
    _ib_temperature.backgroundColor = [UIColor clearColor];
    
    [_ib_ViewTouchToTalk setHidden:YES];
    [_ib_ViewTouchToTalk setBackgroundColor:[UIColor clearColor]];
    
    [_ib_viewRecordTTT setHidden:YES];
    [_ib_viewRecordTTT setBackgroundColor:[UIColor clearColor]];
    [_melodyViewController.view setHidden:YES];
}

- (void)showAllBottomView
{
    [_imgViewDrectionPad setHidden:NO];
    [_ib_temperature setHidden:NO];
    [_ib_ViewTouchToTalk setHidden:NO];
    [_ib_viewRecordTTT setHidden:NO];
    [_melodyViewController.view setHidden:NO];
    [_scrollView setHidden:NO];
}

#pragma mark - Memory Release

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    DLog(@"H264Player - didReceiveMemoryWarning - force restart stream if running");
    
    if (MediaPlayer::Instance()->isPlaying()) {
        DLog(@"H264Player - send interrupt ");
        MediaPlayer::Instance()->sendInterrupt();
    }
}

- (void)dealloc
{
    [_send_UD_dir_req_timer invalidate];
    [_send_LR_dir_req_timer invalidate];
    DLog(@"%s", __FUNCTION__);
}

#pragma mark -  PTT

- (void)cleanup
{
    [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:) withObject:@"0"];
    _audioOut = nil;
}

-(void) setupPtt
{
    [_ib_buttonTouchToTalk addTarget:self action:@selector(ib_buttonTouchToTalkTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

- (void)ib_buttonTouchToTalkTouchUpInside
{
    self.walkieTalkieEnabled = !_walkieTalkieEnabled;
    self.enablePTT = NO;
    _ib_buttonTouchToTalk.enabled = NO;
    self.stringStatePTT = LocStr(@"Processing...");
    _ib_labelTouchToTalk.text = LocStr(@"Processing...");
    
    if (_selectedChannel.profile.isInLocal) {
        [self enableLocalPTT:_walkieTalkieEnabled];
    }
    else {
        [self performSelectorInBackground:@selector(enableRemotePTT:) withObject:[NSNumber numberWithBool:_walkieTalkieEnabled]];
    }
}

- (void)stopTalkbackUnexpected
{
    if (_walkieTalkieEnabled) {
        // Stop talkback if it is enabled
        UILabel *labelCrazy = [[UILabel alloc] init];
        CGRect rect;
        
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
            rect = CGRectMake(SCREEN_WIDTH/2 - 115/2, SCREEN_HEIGHT - 35, 115, 30);
        }
        else {
            rect = CGRectMake(SCREEN_HEIGHT/2 - 115/2, SCREEN_WIDTH - 35, 115, 30);
        }
        
        labelCrazy.frame = rect;
        labelCrazy.backgroundColor = [UIColor grayColor];
        labelCrazy.textColor = [UIColor whiteColor];
        labelCrazy.font = [UIFont boldSystemFontOfSize:13];
        labelCrazy.textAlignment = NSTextAlignmentCenter;
        labelCrazy.text = LocStr(@"Talkback disabled");
        [self.view addSubview:labelCrazy];
        [self.view bringSubviewToFront:labelCrazy];
        
        [labelCrazy performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3];
        [self ib_buttonTouchToTalkTouchUpInside];
    }
}

- (void)enableLocalPTT:(BOOL)walkieTalkieEnable
{
    DLog(@"%s walkieTalkieEnable: %d", __FUNCTION__, walkieTalkieEnable);
    
    if (walkieTalkieEnable) {
        // 1. Starting
        // UI need to verify
        UIImage *imageHoldedToTalk;
        
        if (isiPhone4) {
            imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed"];
        }
        else {
            imageHoldedToTalk = [UIImage imageNamed:@"camera_action_mic_pressed@5"];
        }
        
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchDown];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlStateNormal];
        [self.ib_buttonTouchToTalk setBackgroundImage:imageHoldedToTalk forState:UIControlEventTouchUpInside];
        [self applyFont];
        
        self.disableAutorotateFlag = YES;
        [self.ib_labelTouchToTalk setText:LocStr(@"Please speak")];
        self.stringStatePTT = LocStr(@"Speaking");
        
        // Mute audio to MediaPlayer lib
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_MUTE);
        
        DLog(@"Device ip: %@, Port push to talk: %d, actually is: %d", [HttpCom instance].comWithDevice.device_ip, self.selectedChannel.profile.ptt_port,IRABOT_AUDIO_RECORDING_PORT);
        
        // Init connectivity to Camera via socket & prevent loss of audio data
        _audioOut = [[AudioOutStreamer alloc] initWithDeviceIp:[HttpCom instance].comWithDevice.device_ip
                                                    andPTTport:self.selectedChannel.profile.ptt_port];  //IRABOT_AUDIO_RECORDING_PORT
        [_audioOut startRecordingSound];
        
        [self performSelectorInBackground:@selector(set_Walkie_Talkie_bg:)
                               withObject:[NSString stringWithFormat:@"%d", walkieTalkieEnable]];
        if ( _audioOut ) {
            DLog(@"Connect to Audio Soccket in setEnablePtt function");
            [_audioOut connectToAudioSocket];
            _audioOut.audioOutStreamerDelegate = self;
        }
        else {
            DLog(@"NEED to enable audioOut now BUT audioOut = nil!!!");
        }
    }
    else {
        // 2. Stopping
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_NOT_MUTE);
        
        if ( _audioOut ) {
            [_audioOut disconnectFromAudioSocket];
            _audioOut = nil;
        }
        else {
            _ib_buttonTouchToTalk.enabled = YES;
            self.enablePTT = YES;
        }
        
        // UI
        UIImage *imageNormal;
        if (isiPhone4) {
            imageNormal = [UIImage imageNamed:@"camera_action_mic"];
        }
        else {
            imageNormal = [UIImage imageNamed:@"camera_action_mic@5"];
        }
        
        [_ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlEventTouchDown];
        [_ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [_ib_buttonTouchToTalk setBackgroundImage:imageNormal forState:UIControlEventTouchUpInside];

        self.disableAutorotateFlag = NO;
        [_ib_labelTouchToTalk setText:LocStr(@"Touch to talk")];
        self.stringStatePTT = LocStr(@"Touch to talk");
    }
}

- (void)set_Walkie_Talkie_bg:(NSString *)status
{
    @autoreleasepool {
        NSString *command = [NSString stringWithFormat:@"%@%@", SET_PTT, status];
        DLog(@"Command send to camera is %@", command);
        
        [[HttpCom instance].comWithDevice sendCommandAndBlock:command];
        _ib_buttonTouchToTalk.enabled = YES;
        self.enablePTT = YES;
    }
}

- (void)touchUpInsideHoldToTalk
{
    [_ib_buttonTouchToTalk setBackgroundColor:[UIColor clearColor]];
    [_ib_buttonTouchToTalk setBackgroundImage:[UIImage imageMic] forState:UIControlStateNormal];
    [_ib_buttonTouchToTalk setBackgroundImage:[UIImage imageMic] forState:UIControlEventTouchUpInside];
    
    if ( _selectedChannel.profile.isInLocal ) {
        [_ib_labelTouchToTalk setText:LocStr(@"Touch to talk")];
    }
    else {
        _ib_buttonTouchToTalk.enabled = YES;
        self.enablePTT = YES;
        [_ib_labelTouchToTalk setText:LocStr(@"Touch to talk")];
        self.stringStatePTT = LocStr(@"Touch to talk");
    }
    
    [self applyFont];
}

// Talk back remote
- (NSInteger)getTalkbackSessionKey
{
    // STEP 1
    //[BMS_JSON_Communication setServerInput:@"https://dev-api.hubble.in:443/v1"];
    if ( !_jsonCommBlocked ) {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSString *regID = self.selectedChannel.profile.registrationID;
    NSDictionary *responseDict = [_jsonCommBlocked createTalkbackSessionBlockedWithRegistrationId:regID
                                                                                           apiKey:_apiKey];
    DLog(@"%@", responseDict);
    
    //[BMS_JSON_Communication setServerInput:@"https://api.hubble.in/v1"];
    
    if ( responseDict ) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if ([responseDict[@"status"] integerValue] == 200)
        {
            self.sessionKey = [responseDict[@"data"] objectForKey:@"session_key"];
            self.streamID = [responseDict[@"data"] objectForKey:@"stream_id"];
            
            [userDefault setObject:_sessionKey forKey:SESSION_KEY];
            [userDefault setObject:_streamID forKey:STREAM_ID];
            [userDefault synchronize];
            
            return 200;
        }
        else {
            DLog(@"Resquest session key failed: %@", responseDict[@"message"]);
            
            if ([[responseDict objectForKey:@"status"] integerValue] == 404) {
                _ib_buttonTouchToTalk.enabled = NO;
                _ib_labelTouchToTalk.text = @"Not support!";
                self.stringStatePTT = @"Not support!";
                
                return 404;
            }
            else if ([responseDict[@"status"] integerValue] == 422) {
                return 422;
            }
        }
    }
    
    return 500;
}

- (void)processingHoldToTalkRemote
{
    if ( !_audioOutStreamRemote ) {
        self.audioOutStreamRemote = [[AudioOutStreamRemote alloc] initWithRemoteMode];
    }
    
    [_audioOutStreamRemote startRecordingSound];
}

- (void)enableRemotePTT:(NSNumber *)walkieTalkieEnabledFlag
{
    DLog(@"H264VC - enableRemotePTT: %@", walkieTalkieEnabledFlag);
    
    if ( !walkieTalkieEnabledFlag.boolValue ) {
        self.disableAutorotateFlag = NO;
        
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_NOT_MUTE);
        
        if ( _audioOutStreamRemote ) {
            [_audioOutStreamRemote performSelectorOnMainThread:@selector(disconnectFromAudioSocketRemote) withObject:nil waitUntilDone:NO];
            
            if (!_audioOutStreamRemote.audioOutStreamRemoteDelegate) {
                [self performSelectorOnMainThread:@selector(touchUpInsideHoldToTalk) withObject:nil waitUntilDone:NO];
            }
        }
        else {
            [self performSelectorOnMainThread:@selector(touchUpInsideHoldToTalk) withObject:nil waitUntilDone:NO];
        }
    }
    else {
        self.disableAutorotateFlag = YES;
        
        MediaPlayer::Instance()->setPlayOption(MEDIA_STREAM_AUDIO_MUTE);
        
        [self processingHoldToTalkRemote];
        
        DLog(@"H264VC - enableRemotePTT - isHandshakeSuccess: %d", _audioOutStreamRemote.isHandshakeSuccess);
        
        if (_audioOutStreamRemote.isHandshakeSuccess) {
            // STEP 3 -- Reconnect to Relay-server
            [_audioOutStreamRemote performSelectorOnMainThread:@selector(connectToAudioSocketRemote) withObject:nil waitUntilDone:NO];
        }
        else {
            // STEP 1
            NSInteger statusCode = [self getTalkbackSessionKey];
            
            DLog(@"H264VC - enableRemotePTT - [self getTalkbackSessionKey]: %d", statusCode);
            
            if (statusCode == 404) {
                self.walkieTalkieEnabled = NO;
                [self enableRemotePTT:[NSNumber numberWithBool:self.walkieTalkieEnabled]];
                return;
            }
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            self.sessionKey = [userDefault objectForKey:SESSION_KEY];
            self.streamID = [userDefault objectForKey:STREAM_ID];
            
            if (!_ib_ViewTouchToTalk.isHidden && _walkieTalkieEnabled) {
                if ( !_sessionKey ) {
                    [self retryTalkbackRemote];
                }
                else {
                    // STEP 2
                    NSString *url = [NSString stringWithFormat: @"%@/devices/start_talk_back", _talkbackRemoteServer];
                    NSDictionary *resDict = [self workWithServer:url sessionKey:_sessionKey streamID:_streamID];
                    DLog(@"%@", resDict);
                    
                    if (!_ib_ViewTouchToTalk.isHidden && _walkieTalkieEnabled) {
                        if ( resDict ) {
                            NSInteger status = [resDict[@"status"] integerValue];
                            
                            if (status == 200) {
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
                                
                                NSString *relayServerIP = (NSString *)[resDict objectForKey:@"relay_server_ip"];
                                id relayServerPort = [resDict objectForKey:@"relay_server_port"];
                                
                                if (relayServerIP && relayServerPort ) {
                                    _audioOutStreamRemote.relayServerIP = relayServerIP;
                                    _audioOutStreamRemote.relayServerPort = [relayServerPort integerValue];
                                    
                                    [_audioOutStreamRemote performSelectorOnMainThread:@selector(connectToAudioSocketRemote) withObject:nil waitUntilDone:NO];
                                    _audioOutStreamRemote.audioOutStreamRemoteDelegate = self;
                                }
                                else {
                                    DLog(@"H264VC - enableRemotePTT - relayServerIP = nil | relayServerPort = nil {0}");
                                }
                                
                                DLog(@"H264VC -enableRemotePTT - data: %@, -length: %lu, -ip: %@, -port: %d", data, (unsigned long)data.length, _audioOutStreamRemote.relayServerIP, _audioOutStreamRemote.relayServerPort);
                            }
                            else {
                                if (status == 404) {
                                    self.walkieTalkieEnabled = NO;
                                    [self enableRemotePTT:[NSNumber numberWithBool:_walkieTalkieEnabled]];
                                    return;
                                }
                                
                                DLog(@"Send cmd start_talk_back failed! Retry...");
                                [self retryTalkbackRemote];
                            }
                        }
                        else {
                            DLog(@"Response Dict from camera - resDict = nil! Retry...");
                            [self retryTalkbackRemote];
                        }
                    }
                    else {
                        DLog(@"%s PTT view is invisible. Do nothing!", __FUNCTION__);
                    }
                }
            }
            else {
                DLog(@"%s PTT view is invisible. Do nothing!", __FUNCTION__);
            }
        }
    }
}

- (void)closeRemoteTalkback
{
    NSString *url = [NSString stringWithFormat:@"%@/devices/stop_talk_back", _talkbackRemoteServer];
    NSDictionary *resDict = [self workWithServer:url sessionKey:_sessionKey streamID:_streamID];
    DLog(@"%@", resDict);
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
    DLog(@"H264 - workWithServer - url: %@, -status code: %d", requestString, statusCode);
    
    if (statusCode != 200) {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:statusCode], @"status", nil];
    }
    
    if ( !dataReply ) {
        return nil;
    }
    else {
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
    _ib_buttonTouchToTalk.enabled = YES;
    
    if ( _userWantToCancel || !_walkieTalkieEnabled ) {
        return;
    }
    
    // Re-enable Remote PTT
    [self enableRemotePTT:[NSNumber numberWithBool:YES]];
}

- (void)reportHandshakeFaild:(BOOL)isFailed
{
    // Enable for user cancel PTT
    _ib_buttonTouchToTalk.enabled = YES;
    
    /*
     * 1: Handshake failed!
     * 2: Handshake successfully.
     */
    
    if (isFailed) {
        DLog(@"Report handshake failed! Retry...");
        _ib_labelTouchToTalk.text = LocStr(@"Retry...");
        [self retryTalkbackRemote];
    }
    else {
        _ib_labelTouchToTalk.text = LocStr(@"Please speak");
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

- (IBAction)switchDegreePressed:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Temperature type" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Changes Temperature type"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isDegreeFDisplay]];
    
    _isDegreeFDisplay = !_isDegreeFDisplay;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_isDegreeFDisplay forKey:@"IS_FAHRENHEIT"];
    [userDefaults synchronize];
    
    [self setTemperatureState:_stringTemperature];
}

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
    
    DLog(@"_isRecordInterface is %d", _isRecordInterface);
    
    if (_isRecordInterface) {
        if (!_syncPortraitAndLandscape) {
            _isProcessRecording = !_isProcessRecording;
        }
        
        if (_isProcessRecording) {
            // now is interface recording
            [_ib_labelRecordVideo setText:@"00:00:00"];
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStop] forState:UIControlStateNormal];
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStopPressed] forState:UIControlEventTouchDown];
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStop] forState:UIControlEventTouchUpInside];

            // display time to recording
            if (!_syncPortraitAndLandscape) {
                _timerRecording = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            }
            
            /*
             start recording :: TODO
             */
        }
        else {
            // here to stop
            [self stopRecordingVideo];
        }
    }
    else {
        // now is for take pictures
        [_ib_labelRecordVideo setText:LocStr(@"Take photo")];
        [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlStateNormal];
        [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlEventTouchUpInside];
        [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhotoPressed] forState:UIControlEventTouchDown];
        
        if (_isProcessRecording) {
            [_ib_changeToMainRecording setHidden:NO];
            [self.view bringSubviewToFront:_ib_changeToMainRecording];
        }
        else {
            _syncPortraitAndLandscape = NO;
            
            if (![_cameraModel isEqualToString:CP_MODEL_SHARED_CAM] &&
                ![_cameraModel isEqualToString:CP_MODEL_CONCURRENT])
            {
                [_ib_buttonChangeAction setHidden:NO];
                [self.view bringSubviewToFront:_ib_buttonChangeAction];
            }
        }
        
        if (!_syncPortraitAndLandscape) {
            // processing for take picture
            [self processingForTakePicture];
        }
    }
    [self applyFont];
    
}

- (void)stopRecordingVideo
{
    [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlStateNormal];
    [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideoPressed] forState:UIControlEventTouchDown];
    [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlEventTouchUpInside];

    // stop timer display
    [self stopTimerRecoring];
    [_ib_labelRecordVideo setText:LocStr(@"Record video")];
    _syncPortraitAndLandscape = NO;
}

- (IBAction)changeAction:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"PlayerView changes Take picture to Recording or " withProperties:nil];
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Take picture to Recording or vice versa"
                                                     withLabel:@"Temperature"
                                                     withValue:[NSNumber numberWithBool:_isRecordInterface]];
    if (!_syncPortraitAndLandscape) {
        _isRecordInterface = !_isRecordInterface;
    }
    
    if (_isRecordInterface) {
        // bring to front of view
        [_ib_changeToMainRecording setHidden:YES];
        [_ib_buttonChangeAction setHidden:NO];
        [self.view bringSubviewToFront:_ib_buttonChangeAction];

        // set image display
        [_ib_buttonChangeAction setBackgroundImage:[UIImage imagePhotoGrey] forState:UIControlStateNormal];
        [_ib_buttonChangeAction setBackgroundImage:[UIImage imagePhotoGreyPressed] forState:UIControlStateSelected];
        
        // now is interface take picture
        if (_isProcessRecording) {
            //but,we are recording
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageVideoStop] forState:UIControlStateNormal];
            [_ib_labelRecordVideo setText:@""];
        }
        else {
            // not recording
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlStateNormal];
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideoPressed] forState:UIControlEventTouchDown];
            [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageRecordVideo] forState:UIControlEventTouchUpInside];
            [_ib_labelRecordVideo setText:LocStr(@"Record video")];
            _syncPortraitAndLandscape = NO;
        }
    }
    else {
        // now is interface take picture
        [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlStateNormal];
        [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhotoPressed] forState:UIControlEventTouchDown];
        [_ib_processRecordOrTakePicture setBackgroundImage:[UIImage imageTakePhoto] forState:UIControlEventTouchUpInside];
        
        if (_isProcessRecording) {
            // but,we are recording
            // now, replace image take picture with time animation
            [_ib_buttonChangeAction setHidden:YES];
            [_ib_changeToMainRecording setHidden:NO];
            [self.view bringSubviewToFront:_ib_changeToMainRecording];
            [_ib_labelRecordVideo setText:LocStr(@"Take photo")];
        }
        else {
            // not recording
            [_ib_changeToMainRecording setHidden:YES];
            [_ib_buttonChangeAction setHidden:NO];
            [self.view bringSubviewToFront:_ib_buttonChangeAction];
            [_ib_buttonChangeAction setBackgroundImage:[UIImage imageVideoGrey] forState:UIControlStateNormal];
            [_ib_buttonChangeAction setBackgroundImage:[UIImage imageVideoGreyPressed] forState:UIControlStateSelected];
            [_ib_labelRecordVideo setText:LocStr(@"Take photo")];
            _syncPortraitAndLandscape = NO;
        }
    }
    
    [self applyFont];
}

#pragma mark - display timer recording

- (void)timerTick:(NSTimer *)timer
{
    _ticks += 1.0;
    double seconds = fmod(_ticks, 60.0);
    double minutes = fmod(trunc(_ticks / 60.0), 60.0);
    double hours = trunc(_ticks / 3600.0);
    NSString *timeToDisplay = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f",hours, minutes, seconds];
    
    if (_isRecordInterface && _isProcessRecording) {
        _ib_labelRecordVideo.text = timeToDisplay;
        [self applyFont];
    }
    else {
        _ib_labelRecordVideo.text = LocStr(@"Take photo");
        
        // now is interface take picture
        if (_isProcessRecording) {
            //but,we are recording
            //only update time display
            [_ib_changeToMainRecording setTitle:timeToDisplay forState:UIControlStateNormal];
        }
        else {
            // not recording
            // handle it at (IBAction)changeAction:(id)sender
            _syncPortraitAndLandscape = NO;
        }
    }
    
    if (_syncPortraitAndLandscape) {
        [self changeAction:nil];
        [self processingRecordingOrTakePicture:nil];
        _syncPortraitAndLandscape = NO;
    }
}

- (void)stopTimerRecoring
{
    _ticks = 0;
    if ( [_timerRecording isValid] ) {
        [_timerRecording invalidate];
        _timerRecording = nil;
    }
}

#pragma mark - SnapShot

- (void)processingForTakePicture
{
    [_ib_processRecordOrTakePicture setEnabled:NO];
    [self saveSnapShot:_imageViewStreamer.image];
}

- (void)saveSnapShot:(UIImage *)image
{
	// save to photo album
	UIImageWriteToSavedPhotosAlbum(image, self,
                                   @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_ib_processRecordOrTakePicture setEnabled:YES];
	NSString *message;
	NSString *title;
	if (!error) {
		title = LocStr(@"Snapshot");
		message = LocStr(@"Saved to Photo Album");
	}
	else {
		title = LocStr(@"Error");
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = info[@"CFBundleDisplayName"];

        message = [NSString stringWithFormat:LocStr(@"Allow permission to save media in gallery. Settings > Privacy > Photos > %@ :- turn switch on."), appName];
		DLog(@"Error when writing file to image library: %@", [error localizedDescription]);
		DLog(@"Error code %d", [error code]);
	}
    
	UIAlertView *alertInfo = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
	[alertInfo show];
}

- (void)updateDebugInfoFrameRate:(NSInteger)fps
{
    UITextField *tfFrameRate = (UITextField *)[_viewDebugInfo viewWithTag:TF_DEBUG_FRAME_RATE_TAG];
    tfFrameRate.text = [NSString stringWithFormat:@"%@ %d", _viewVideoIn, fps];
}

- (void)updateDebugInfoResolutionWidth:(NSInteger)width heigth:(NSInteger)height
{
    UITextField *tfResolution = (UITextField *)[_viewDebugInfo viewWithTag:TF_DEBUG_RESOLUTION_TAG];
    tfResolution.text = [NSString stringWithFormat:@"%dx%d", width, height];
}

- (void)updateDebugInfoBitRate:(NSInteger)bitRate
{
    UITextField *tfBitRate = (UITextField *)[_viewDebugInfo viewWithTag:TF_DEBUG_BIT_RATE_TAG];
    // bitrate value is updated every 2 sec
    tfBitRate.text = [NSString stringWithFormat:@"%d", (bitRate * 8) / (2 * 1000)];
}

- (BOOL)checkAvailableStateOfCamera:(NSString *)regID
{
    if ( !_jsonCommBlocked ) {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSDictionary *responseDict = [_jsonCommBlocked checkDeviceIsAvailableBlockedWithRegistrationId:regID andApiKey:apiKey];
    
    if ( responseDict ) {
        if ([responseDict[@"status"] integerValue] == 200) {
            if ([[responseDict[@"data"] objectForKey:@"is_available"] boolValue]) {
                DLog(@"Check Available - Camera is AVAILABLE");
                _selectedChannel.profile.minuteSinceLastComm = 1;
                _selectedChannel.profile.hasUpdateLocalStatus = YES;
                self.cameraIsNotAvailable = NO;
                return YES;
            }
            else {
                DLog(@"Check Available - Camera is NOT available");
            }
        }
        else {
            DLog(@"Result isn't expected");
        }
    }
    else {
        DLog(@"Empty results of device list from server OR response error");
    }
    
    _selectedChannel.profile.hasUpdateLocalStatus = YES;
    _selectedChannel.profile.minuteSinceLastComm = 10;
    self.cameraIsNotAvailable = YES;
    
    return NO;
}

#pragma mark - New flow

- (void)scanCamera
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.current_ssid = [CameraPassword fetchSSIDInfo];
    
    if ( [self isCurrentConnection3G] || [userDefaults boolForKey:@"remote_only"] || !_selectedChannel.profile.ip_address ) {
        DLog(@"Connection over 3G | remote_only: %d, ip_address: %p --> Skip scanning all together, bit rate 128", [userDefaults boolForKey:@"remote_only"], self.selectedChannel.profile.ip_address);
        
        // pulldown to 32 KB/s initially - pull up when we get 1st image
        [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"128"];
        
        _selectedChannel.profile.isInLocal = NO;
        _selectedChannel.profile.hasUpdateLocalStatus = YES;
        _selectedChannel.profile.minuteSinceLastComm = 1;
        
        [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.1];
    }
    else {
        if ([self.selectedChannel.profile.hostSSID isEqualToString:_current_ssid]) {
            DLog(@"The same ssid --> uses local stream");
            _selectedChannel.profile.isInLocal = YES;
            _selectedChannel.profile.hasUpdateLocalStatus = YES;
            _selectedChannel.profile.minuteSinceLastComm = 1;
            
            if ([_cameraModel isEqualToString:CP_MODEL_SHARED_CAM]) {
                _selectedChannel.profile.port = 8081; // HARD CODE for now
            }
            else {
                _selectedChannel.profile.port = 80; // HARD CODE for now
            }

            [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.1];
        }
        else {
            if ([self isInTheSameNetworkAsCamera:_selectedChannel.profile]) {
                [self startScanningWithBonjour];
                [self performSelectorInBackground:@selector(startScanningWithIpServer) withObject:nil];
            }
            else {
                [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"128"];
                
                _selectedChannel.profile.isInLocal = NO;
                _selectedChannel.profile.hasUpdateLocalStatus = YES;
                _selectedChannel.profile.minuteSinceLastComm = 1;
                
                [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.1];
            }
        }
    }
}

- (BOOL)isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    if ([reachability currentReachabilityStatus] == ReachableViaWWAN) {
        return YES;
    }
    
    return NO;
}

- (void)increaseBitRate:(NSTimer *)timer
{
    [self performSelectorInBackground:@selector(setVideoBitRateToCamera:) withObject:@"600"];
}

- (void)setVideoBitRateToCamera:(NSString *)bitrate_str
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    if ( !_jsonCommBlocked ) {
        self.jsonCommBlocked = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                     Selector:nil
                                                                 FailSelector:nil
                                                                    ServerErr:nil];
    }
    
    NSString *cmd = [NSString stringWithFormat:@"action=command&command=set_video_bitrate&value=%@",bitrate_str];
    
    NSDictionary *responseDict = [_jsonCommBlocked sendCommandBlockedWithRegistrationId:_selectedChannel.profile.registrationID
                                                                             andCommand:cmd
                                                                              andApiKey:apiKey];
    BOOL sendCmdFailed = YES;
    
    if ( responseDict ) {
        NSInteger status = [responseDict[@"status"] intValue];
        
        if (status == 200) {
            NSString *bodyKey = [[responseDict[@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
            
            if (bodyKey && ![bodyKey isEqual:[NSNull null]]) {
                if ([bodyKey isEqualToString:@"set_video_bitrate: 0"]) {
                    sendCmdFailed = NO;
                }
            }
        }
    }
    
    if (sendCmdFailed) {
        DLog(@"H264VC - setVideoBitRateToCamera: %@", responseDict);
    }
    else {
        self.currentBitRate = bitrate_str;
        DLog(@"H264VC - setVideoBitRateToCamera successfully: %@", bitrate_str);
    }
}

- (void)startScanningWithBonjour
{
    self.threadBonjour = [[NSThread alloc] initWithTarget:self selector:@selector(scanWithBonjour) object:nil];
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
        
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        
        while (bonjour.isSearching) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        self.bonjourList = [NSMutableArray arrayWithArray:bonjour.cameraList];
    }
    
    [NSThread exit];
}

- (void)startScanningWithIpServer
{
    NSMutableArray *finalResult = [[NSMutableArray alloc] init];
    
    if ( _selectedChannel.profile.mac_address ) {
        BOOL skipScan = [self isCurrentIpAddressValid:_selectedChannel.profile];
        if (skipScan) {
            _selectedChannel.profile.port = 80;
            
            // Don't need to scan.. call scan_done directly
            [finalResult addObject:_selectedChannel.profile];
            [self performSelectorOnMainThread:@selector(scan_done:) withObject:finalResult waitUntilDone:NO];
        }
        else {
            // NEED to do local scan
            ScanForCamera *cameraScanner = [[ScanForCamera alloc] initWithNotifier:self];
            [cameraScanner performSelectorOnMainThread:@selector(scan_for_device:)
                                            withObject:self.selectedChannel.profile.mac_address
                                         waitUntilDone:NO];
        }
    }
    
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
            DLog(@"H264 - Camera is in same subnet");
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
            DLog(@"some periodic is running dont care");
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
