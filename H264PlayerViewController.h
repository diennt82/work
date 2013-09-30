//
//  H264PlayerViewController.h
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamChannel.h"

#import "HttpCommunication.h"
#import "PlaylistInfo.h"
#import "PlaybackViewController.h"
#import "PlaylistCell.h"
#import "MTStackViewController.h"
#import "HttpCommunication.h"
#import "PlayListViewController.h"
#import "H264PlayerListener.h"
#import "PlayerCallbackHandler.h"
#import "ScanForCamera.h"
#import "MBP_LoginOrRegistration.h"

#import <MonitorCommunication/MonitorCommunication.h>
#import <H264MediaPlayer/H264MediaPlayer.h>



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

@interface H264PlayerViewController: UIViewController
<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PlaylistDelegate,PlayerCallbackHandler,ScanForCameraNotifier>
{
    MediaPlayer* h264Streamer;
    
    H264PlayerListener * h264StreamerListener;
    
    UIAlertView * alert;
	NSTimer * alertTimer;
    
    CamChannel *selectedChannel;
    
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

	
}


@property (nonatomic, retain) NSTimer * alertTimer; 

@property (retain, nonatomic) IBOutlet UITableView *tableViewPlaylist;
@property (retain, nonatomic) IBOutlet UIView *viewCtrlButtons;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerHQOptions;
@property (retain, nonatomic) IBOutlet UIButton *hqViewButton;
@property (retain, nonatomic) IBOutlet UIButton *triggerRecordingButton;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewDrectionPad;
@property (retain, nonatomic) IBOutlet PlayListViewController *playlistViewController;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIView *viewStopStreamingProgress;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityStopStreamingProgress;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBntItemReveal;

@property (nonatomic, retain) HttpCommunication* httpComm;
@property (nonatomic, retain) NSMutableArray *playlistArray;
@property (nonatomic) BOOL h264StreamerIsInStopped;
@property (nonatomic, retain) HttpCommunication *htppComm;
@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic) BOOL recordingFlag;
@property (nonatomic) BOOL disableAutorotateFlag;

@property (nonatomic) BOOL askForFWUpgradeOnce;


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
@property (nonatomic, retain) NSString* stream_url;
@property (nonatomic, retain) CamChannel *selectedChannel;



#endif


- (void)scan_done:(NSArray *) _scan_results;

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2;
- (void)stopStream;
- (void)goBackToCameraList;
@end