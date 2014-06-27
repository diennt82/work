//
//  H264PlayerViewController.h
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <CameraScanner/Util.h>
#import <H264MediaPlayer/H264MediaPlayer.h>
#import <MonitorCommunication/MonitorCommunication.h>
#import <AudioToolbox/AudioToolbox.h>

#import "MBP_iosAppDelegate.h"
#import "PlaylistInfo.h"
#import "PlaybackViewController.h"
#import "H264PlayerListener.h"
#import "PlayerCallbackHandler.h"
#import "MelodyViewController.h"
//for scrollHorizontalMenu
#import "ScrollHorizontalMenu.h"
//control panel menu
#import "AudioOutStreamer.h"
#import "MBP_iosViewController.h"


#import "UIFont+Hubble.h"
#import "UIColor+Hubble.h"
#import "UIImage+Hubble.h"
#import "StunClient.h"
#import "GAITrackedViewController.h"
#import "TimelineViewController.h"
#import "AudioOutStreamRemote.h"
#import "EarlierNavigationController.h"
//#import <GAI.h>
#import "KISSMetricsAPI.h"
#import "HttpCom.h"
#import "EarlierViewController.h"



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

//mediaProcessStatus values
#define MEDIAPLAYER_NOT_INIT        0
#define MEDIAPLAYER_SET_LISTENER    1
#define MEDIAPLAYER_SET_DATASOURCE  2
#define MEDIAPLAYER_STARTED         3




@protocol H264PlayerVCDelegate <NSObject>

- (void)stopStreamFinished: (CamChannel *)camChannel;

@end



@interface H264PlayerViewController: GAITrackedViewController
<PlayerCallbackHandler, ScanForCameraNotifier, StunClientDelegate, UIScrollViewDelegate, ScrollHorizontalMenuDelegate, AudioOutStreamerDelegate, TimelineVCDelegate, AudioOutStreamRemoteDelegate, BonjourDelegate>
{
    ScrollHorizontalMenu *_horizMenu;
    int _selectedItemMenu;
    NSMutableArray *_itemImages;
    NSMutableArray *_itemSelectedImages;
    MediaPlayer* h264Streamer;
    
    H264PlayerListener * h264StreamerListener;
    
	NSTimer * alertTimer;
    
    ScanForCamera *scanner;
    
    SystemSoundID soundFileObject;
    
    
    BOOL userWantToCancel;
    BOOL askForFWUpgradeOnce;
    
    
    int currentDirUD, lastDirUD;
	int delay_update_lastDir_count;
	int currentDirLR,lastDirLR;
	int delay_update_lastDirLR_count;
    /* Direction */
	NSTimer * send_UD_dir_req_timer;
	NSTimer * send_LR_dir_req_timer;
	/* Added to support direction update */
	BOOL v_direction_update_needed, h_direction_update_needed;

	//NSTimer * probeTimer;
     dispatch_queue_t player_func_queue;
    BOOL _isRecordInterface;
    BOOL _isProcessRecording;
    BOOL _isListening;
    
    //processing for hold to talk
    BOOL ptt_enabled;
    AudioOutStreamer * _audioOut;
    
    //processing for recording
    int iMaxRecordSize;
    NSString * iFileName;

    //display time when recording
    NSTimer *_timerRecording;
    //degreeC
    NSString *_degreeCString;
    NSString *_degreeFString;
    BOOL _isDegreeFDisplay;

    IBOutlet UIButton *ib_switchDegree;
    BOOL _isFirstLoad;

    //timer display text Camera is not accessible
    NSTimer *_timerNotAccessible;
    NSString *_resolution;
    NSTimer *_timerStopStreamAfter30s;
    
    
    BOOL _syncPortraitAndLandscape;
    UIBarButtonItem *nowButton, *earlierButton;
    BOOL _isLandScapeMode;//cheat to display correctly timeline bottom
    BOOL _hideCustomIndicatorAndTextNotAccessble;
    //check to show custom indicator
    BOOL _isShowCustomIndicator;
    //check to show custom indicator
    BOOL _isShowTextCameraIsNotAccesible;
    
}

@property (nonatomic, retain) IBOutlet ScrollHorizontalMenu *horizMenu;
@property (nonatomic, assign) int selectedItemMenu;

//ib for Touch to talk
@property (retain, nonatomic) IBOutlet UIView *ib_ViewTouchToTalk;
@property (retain, nonatomic) IBOutlet UIButton *ib_buttonTouchToTalk;

@property (retain, nonatomic) IBOutlet UILabel *ib_labelTouchToTalk;

//ib for recording
@property (retain, nonatomic) IBOutlet UIView *ib_viewRecordTTT;
@property (retain, nonatomic) IBOutlet UIButton *ib_processRecordOrTakePicture;
@property (retain, nonatomic) IBOutlet UIButton *ib_buttonChangeAction;
//button for replacing image take picture when recording
@property (retain, nonatomic) IBOutlet UIButton *ib_changeToMainRecording;
@property (retain, nonatomic) IBOutlet UILabel *ib_labelRecordVideo;
@property (retain, nonatomic) IBOutlet UILabel *ib_temperature;
@property (nonatomic, retain) NSMutableArray *itemImages;
@property (nonatomic, retain) NSMutableArray *itemSelectedImages;
@property (nonatomic, retain) NSTimer * alertTimer;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewDrectionPad;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityStopStreamingProgress;
@property (retain, nonatomic) IBOutlet UIImageView *customIndicator;
@property (retain, nonatomic) IBOutlet UILabel *ib_lbCameraNotAccessible;
@property (retain, nonatomic) IBOutlet UILabel *ib_lbCameraName;
@property (retain, nonatomic) IBOutlet UIButton *ib_btShowDebugInfo;
@property (nonatomic) BOOL h264StreamerIsInStopped;

@property (nonatomic) BOOL recordingFlag;

@property (nonatomic) BOOL askForFWUpgradeOnce;
@property (nonatomic) int currentMediaStatus;
@property (nonatomic) BOOL iFrameOnlyFlag;
@property (nonatomic,retain) StunClient * client; 
@property (nonatomic, retain) NSTimer * probeTimer;
@property (nonatomic, assign) id<H264PlayerVCDelegate> h264PlayerVCDelegate;
@property (nonatomic, retain) MelodyViewController *melodyViewController;


#if 1 //Needed or not ??

@property (retain, nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backBarBtnItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *cameraNameBarBtnItem;
@property (retain, nonatomic) IBOutlet UIView *progressView;

@property (nonatomic, assign) CamChannel *selectedChannel;


#endif



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
@property (nonatomic, retain) NSString *current_ssid;

#ifdef SHOW_DEBUG_INFO
//for debug
@property (nonatomic, retain) NSString *viewVideoIn;
#endif

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL shouldRestartProcessing;


- (void)scan_done:(NSArray *) _scan_results;

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2;
//- (void)goBackToCameraList;
- (void)prepareGoBackToCameraList:(id)sender;


- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;


@end




