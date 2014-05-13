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

#import "PlaylistInfo.h"
#import "PlaybackViewController.h"
#import "PlaylistCell.h"
#import "H264PlayerListener.h"
#import "PlayerCallbackHandler.h"
#import "MelodyViewController.h"
//for scrollHorizontalMenu
#import "ScrollHorizontalMenu.h"
//control panel menu
#import "AudioOutStreamer.h"

#import "UIFont+Hubble.h"
#import "UIColor+Hubble.h"
#import "UIImage+Hubble.h"
#import "StunClient.h"


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

@protocol H264PlayerVCDelegate <NSObject>

- (void)stopStreamFinished: (CamChannel *)camChannel;

@end

@interface H264PlayerViewController: UIViewController
<PlayerCallbackHandler, ScanForCameraNotifier, StunClientDelegate, MelodyVCDelegate, UIScrollViewDelegate, ScrollHorizontalMenuDelegate, AudioOutStreamerDelegate>
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


- (void)scan_done:(NSArray *) _scan_results;

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2;
- (void)goBackToCameraList;


@end
