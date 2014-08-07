//
//  H264PlayerViewController.h
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <CameraScanner/Util.h>
#import <H264MediaPlayer/H264MediaPlayer.h>
#import <MonitorCommunication/MonitorCommunication.h>
#import <AudioToolbox/AudioToolbox.h>

#import "PlaybackViewController.h"
#import "H264PlayerVCDelegate.h"
#import "PlaylistInfo.h"
#import "PlaylistCell.h"
#import "H264PlayerListener.h"
#import "PlayerCallbackHandler.h"
#import "MelodyViewController.h"
#import "ScrollHorizontalMenu.h"

//control panel menu
#import "AudioOutStreamer.h"

#import "UIFont+Hubble.h"
#import "UIColor+Hubble.h"
#import "UIImage+Hubble.h"
#import "StunClient.h"
#import "GAITrackedViewController.h"


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

@interface H264PlayerViewController: GAITrackedViewController <PlayerCallbackHandler, ScanForCameraNotifier, StunClientDelegate, MelodyVCDelegate, UIScrollViewDelegate, ScrollHorizontalMenuDelegate, AudioOutStreamerDelegate>

@property (nonatomic, retain) IBOutlet ScrollHorizontalMenu *horizMenu;
@property (nonatomic, retain) IBOutlet UIView *menuBackgroundView;

//ib for Touch to talk
@property (nonatomic, retain) IBOutlet UIView *ib_ViewTouchToTalk;
@property (nonatomic, retain) IBOutlet UIButton *ib_buttonTouchToTalk;
@property (nonatomic, retain) IBOutlet UILabel *ib_labelTouchToTalk;

//ib for recording
@property (nonatomic, retain) IBOutlet UIView *ib_viewRecordTTT;
@property (nonatomic, retain) IBOutlet UIButton *ib_processRecordOrTakePicture;
@property (nonatomic, retain) IBOutlet UIButton *ib_buttonChangeAction;

//button for replacing image take picture when recording
@property (nonatomic, retain) IBOutlet UIButton *ib_changeToMainRecording;
@property (nonatomic, retain) IBOutlet UILabel *ib_labelRecordVideo;
@property (nonatomic, retain) IBOutlet UILabel *ib_temperature;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewDrectionPad;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityStopStreamingProgress;
@property (nonatomic, retain) IBOutlet UIImageView *customIndicator;
@property (nonatomic, retain) IBOutlet UILabel *ib_lbCameraNotAccessible;
@property (nonatomic, retain) IBOutlet UILabel *ib_lbCameraName;

@property (nonatomic, retain) IBOutlet UIButton *ib_btShowDebugInfo;
@property (nonatomic, retain) IBOutlet UIButton *sendLogButton;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewVideo;

@property (nonatomic, retain) NSMutableArray *itemImages;
@property (nonatomic, retain) NSMutableArray *itemSelectedImages;
@property (nonatomic, retain) NSTimer *alertTimer;
@property (nonatomic, retain) NSTimer *probeTimer;
@property (nonatomic, retain) StunClient *client;
@property (nonatomic, retain) MelodyViewController *melodyViewController;
@property (nonatomic, assign) id<H264PlayerVCDelegate> h264PlayerVCDelegate;
@property (nonatomic, assign) CamChannel *selectedChannel;

@property (nonatomic) int selectedItemMenu;
@property (nonatomic) int currentMediaStatus;
@property (nonatomic) BOOL h264StreamerIsInStopped;
@property (nonatomic) BOOL recordingFlag;
@property (nonatomic) BOOL askForFWUpgradeOnce;
@property (nonatomic) BOOL iFrameOnlyFlag;

- (void)handleMessage:(int)msg ext1:(int)ext1 ext2:(int)ext2;
- (void)goBackToCameraList;

@end
