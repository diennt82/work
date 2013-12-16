//
//  H264PlayerViewController.h
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <H264MediaPlayer/H264MediaPlayer.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "PlaylistInfo.h"
#import "PlaybackViewController.h"
#import "PlaylistCell.h"
#import "MTStackViewController.h"
#import "PlayListViewController.h"
#import "H264PlayerListener.h"
#import "PlayerCallbackHandler.h"
#import "MBP_LoginOrRegistration.h"
#import "ZoneViewController.h"
#import "MelodyViewController.h"
#import "DeviceSettingsViewController.h"
//for scrollHorizontalMenu
#import "ScrollHorizontalMenu.h"


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
<UIPickerViewDelegate, UIPickerViewDataSource, PlaylistDelegate,PlayerCallbackHandler,ScanForCameraNotifier, StunClientDelegate, ZoneViewControlerDeleate, MelodyVCDelegate, UIScrollViewDelegate, ScrollHorizontalMenuDelegate>
{
    ScrollHorizontalMenu *_horizMenu;
    NSMutableArray *_itemImages;
    MediaPlayer* h264Streamer;
    
    H264PlayerListener * h264StreamerListener;
    
    UIAlertView * alert;
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
    BOOL _isCameraOffline;
}

@property (nonatomic, retain) IBOutlet ScrollHorizontalMenu *horizMenu;
@property (nonatomic, retain) NSMutableArray *itemImages;
@property (nonatomic, retain) NSTimer * alertTimer;
//Add scrollview to support zoom in and zoom out
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UIView *viewCtrlButtons;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerHQOptions;
@property (retain, nonatomic) IBOutlet UIButton *melodyButton;
@property (retain, nonatomic) IBOutlet UIButton *hqViewButton;
@property (retain, nonatomic) IBOutlet UIButton *triggerRecordingButton;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewDrectionPad;
@property (retain, nonatomic) IBOutlet PlayListViewController *playlistViewController;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIView *viewStopStreamingProgress;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityStopStreamingProgress;
@property (retain, nonatomic) IBOutlet UIButton *zoneButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBntItemReveal;

@property (nonatomic, retain) HttpCommunication* httpComm;
@property (nonatomic, retain) NSMutableArray *playlistArray;
@property (nonatomic) BOOL h264StreamerIsInStopped;
@property (nonatomic, retain) HttpCommunication *htppComm;
@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic) BOOL recordingFlag;
@property (nonatomic) BOOL disableAutorotateFlag;

@property (nonatomic) BOOL askForFWUpgradeOnce;
@property (nonatomic) int currentMediaStatus;
@property (nonatomic) BOOL iFrameOnlyFlag;
@property (nonatomic,retain) StunClient * client; 
@property (nonatomic, retain)  IBOutlet ZoneViewController *zoneViewController;
@property (nonatomic, retain) NSTimer * probeTimer;
@property (nonatomic, assign) id<H264PlayerVCDelegate> h264PlayerVCDelegate;
@property (nonatomic, retain) MelodyViewController *melodyViewController;


/* Direction */
//@property (nonatomic, retain) NSTimer * send_UD_dir_req_timer;
//@property (nonatomic, retain) NSTimer * send_LR_dir_req_timer;
///* Added to support direction update */
//@property (nonatomic) int currentDirUD, lastDirUD;
//@property (nonatomic) int delay_update_lastDir_count;
//@property (nonatomic) int currentDirLR,lastDirLR;
//@property (nonatomic) int delay_update_lastDirLR_count;

#if 1 //Needed or not ??

@property (retain, nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backBarBtnItem;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *cameraNameBarBtnItem;
@property (retain, nonatomic) IBOutlet UIView *progressView;

@property (retain, nonatomic) IBOutlet UISegmentedControl *segCtrl;
@property (retain, nonatomic) UISegmentedControl *segmentControl;

@property (nonatomic, retain) CamChannel *selectedChannel;



#endif


- (void)scan_done:(NSArray *) _scan_results;

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2;
- (void)stopStream;
- (void)goBackToCameraList;
@end
