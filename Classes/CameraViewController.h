//
//  CameraViewController.h
//  MBP_ios
//
//  Created by NxComm on 7/31/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "CamChannel.h"
#import "CamProfile.h"
#import "MBP_Streamer.h"
#import "HttpCommunication.h"
#import "StunCommunication.h"
#import "MBP_MenuViewController.h"
#import "RemoteConnection.h"
#import "AudioOutStreamer.h"
#import "MBP_LoginOrRegistration.h"
#import "ScanForCameraProtocol.h"





#define DIRECTION_V_NON  0x01
#define DIRECTION_V_UP   0x02
#define DIRECTION_V_DN   0x04
#define DIRECTION_V_MASK 0xF0

#define DIRECTION_H_NON 0x10
#define DIRECTION_H_LF  0x20
#define DIRECTION_H_RT  0x40
#define DIRECTION_H_MASK 0x0F


#define _streamingSSID @"string_Streaming_SSID"
#define REMOTE_VIDEO_TIMEOUT 0x1000
#define LOCAL_VIDEO_STOPPED_UNEXPECTEDLY 0x1001
#define REMOTE_VIDEO_STOPPED_UNEXPECTEDLY 0x1002


#define ZOOM_STEP 0.25


#define HIGH_TEMPERATURE_THRESHOLD_C 29
#define LOW_TEMPERATURE_THRESHOLD_C 14

//Alert tag
#define REMOTE_VIDEO_TIMEOUT              0x1000
#define LOCAL_VIDEO_STOPPED_UNEXPECTEDLY  0x1001
#define REMOTE_VIDEO_STOPPED_UNEXPECTEDLY 0x1002
#define FW_OTA_UPGRADE_AVAILABLE          0x1003
#define REMOTE_VIDEO_CANT_START           0x1004





#define SPK_CONTROL_BTN  702


#define PTT_CONTROL_BTN  701
#define PTT_ENGAGE_BTN 711

#define MEL_CONTROL_BTN  700
#define MEL_CANCEL_BTN  1
#define MEL_DONE_BTN    2
#define MEL_ONOFF_SW    3

#define VIEW_DIRECTIONPAD_TAG 500
#define VIEW_DIRECTIONIND_TAG 501


#define CMD_SENDING_INTERVAL 0.2 /*sec*/


@class ScanForCamera;

@interface CameraViewController : UIViewController<StreamerEventHandler,ConnectionMethodDelegate , StreamerFrameRateUpdater, StreamerTemperatureUpdater, ScanForCameraNotifier>
{
    IBOutlet UILabel * temperature_label; 
    IBOutlet UIImageView * temperature_bg;
    IBOutlet UILabel * lowRes_label; 
    IBOutlet UIImageView * lowRes_bg;
    
    IBOutlet UIToolbar * topToolBar;
    IBOutlet UIBarButtonItem * barBtnCamera; 
    IBOutlet UIBarButtonItem * barBtnName; 
    IBOutlet UIBarButtonItem * barBtnSetttings; 
    IBOutlet UIImageView * videoView; 
   
    IBOutlet UIImageView * directionPad;
    IBOutlet UIView * controlButtons; 
    
    IBOutlet UIView *progressView; 
    
    IBOutlet UIView * lullabyView; 
    IBOutlet UISwitch * lullabyOnOff; 
    
    
    IBOutlet UITableViewCell * musicOnOffCell;
    IBOutlet UITableViewCell * songtitleCell; 
    
    IBOutlet UIButton * pttButton; 
    IBOutlet UIButton * lullabyButton; 
    
    IBOutlet UIView * videoAndSnapshotView; 
    IBOutlet UISlider *videoAndSnapshotSlider;
    IBOutlet UIButton * videoAndSnapshotButton; 
    IBOutlet UILabel * videoAndSnapshotTime; 
    
    IBOutlet UISlider * zoombar; 
    IBOutlet UIView * zoombarView;
    
    
    IBOutlet UIView * upgradeFwView; 
    IBOutlet UILabel * percentageLabel;
    IBOutlet UIProgressView * percentageProgress;
   
    
    HttpCommunication * comm; 
    StunCommunication * scomm; 
    
	MBP_Streamer * streamer; 
	CamChannel * selected_channel; 
	NSTimer * fullScreenTimer; 
    UIAlertView * alert;
	NSTimer * alertTimer;
    
    
    
    /* Direction */
	NSTimer * send_UD_dir_req_timer; 
	NSTimer * send_LR_dir_req_timer;
	/* Added to support direction update */
	BOOL v_direction_update_needed, h_direction_update_needed;
    int currentDirUD, lastDirUD;
	int delay_update_lastDir_count;	
	int currentDirLR,lastDirLR;
	int delay_update_lastDirLR_count;
	
	
	int melody_index;
    NSArray *melodies;
    
    AudioOutStreamer * audioOut; 
    
    CGFloat currentZoomLvl; 
    
    BOOL enableControls; 
    BOOL ptt_enabled, askForFWUpgradeOnce;
    
    SystemSoundID soundFileObject;
    
    ScanForCamera *scanner; 
    BOOL firstTimeConnect; 
    
    
    
}

@property (nonatomic, retain) IBOutlet UILabel * temperature_label, *videoAndSnapshotTime; 
@property (nonatomic, retain) StunCommunication * scomm;
@property (nonatomic, retain) MBP_Streamer * streamer; 
@property (nonatomic,retain) HttpCommunication *comm;
@property (nonatomic, retain) CamChannel * selected_channel;
@property (nonatomic, retain) IBOutlet UIImageView * videoView;
@property (nonatomic, retain) NSTimer * alertTimer; 
@property (nonatomic, assign) UISlider * zoombar; 
@property (nonatomic) float currentZoomLvl; 
@property (nonatomic) BOOL ptt_enabled,askForFWUpgradeOnce,enableControls, firstTimeConnect;


-(IBAction)buttonMelodyPressed:(id) sender;
-(IBAction)buttonPttPressed:(id)sender;
-(IBAction)buttonSpkPressed:(id)sender;

-(IBAction)buttonCamPressed:(id)sender;

-(void) goBackToCameraList;
-(IBAction)silderMoved:(id)sender;

//Video & Snapshot control
-(IBAction)buttonSnapPress:(id)sender;
- (IBAction)sliderChanged:(id)sender;


// TOUCHes
- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase;
- (void) _touchesbegan: (CGPoint) location;
- (void) _touchesmoved: (CGPoint) location;
- (void) _touchesended: (CGPoint) location;
- (void) validatePoint: (CGPoint)location andTranslateV:(UIView*) view began: (BOOL)isBegan;


//Temp & Frame rate update 
-(void) updateTemperature:(int) temp;
-(void) updateFrameRate:(int) frameRate;

-(void) startCameraConnection:(NSTimer *) exp;

-(void) remoteViewTimeout:(NSTimer *) expired;

@end
