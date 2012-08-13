//
//  MBP_iosViewController.h
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBP_CamView.h"
#import "MBP_MainMenuView.h"
#import "AiBallVideoListViewController.h"

#import "MBP_MainSetupViewController.h"
#import "MBP_InitialSetupViewController.h"
#import "AsyncSocket.h"
#import "AviRecord.h"

#import "CamProfile.h"
#import "CamChannel.h"
#import "PCMPlayer.h"
#import "PublicDefine.h"

#import "HttpCommunication.h"
#import "ConnectionMethodDelegate.h"
#import "MBP_LoginOrRegistration.h"
#import "MBP_CamListView.h"
#import "MBP_Streamer.h"
#import "MBP_AddCamController.h"
#import "AudioOutStreamer.h"
#import "MBP_MenuViewController.h"
#import "RemoteConnection.h"
#import "StunCommunication.h"
#import "ScanForCameraProtocol.h"
#import "DashBoard_ViewController.h"


#define DIRECTION_V_NON  0x01
#define DIRECTION_V_UP   0x02
#define DIRECTION_V_DN   0x04
#define DIRECTION_V_MASK 0xF0

#define DIRECTION_H_NON 0x10
#define DIRECTION_H_LF  0x20
#define DIRECTION_H_RT  0x40
#define DIRECTION_H_MASK 0x0F

#define CURRENT_VIEW_MODE_MULTI 0x11
#define CURRENT_VIEW_MODE_SINGLE 0x12

@class AiBallVideoListViewController;
@class MBP_CamView;
//@class MBP_MainMenuView;
@class CamProfile;

#define DIRECT_MODE_NEXT_BTN 311


#define _streamingSSID @"string_Streaming_SSID"


@interface MBP_iosViewController : UIViewController <SetupHttpDelegate, ConnectionMethodDelegate,UIActionSheetDelegate, StreamerEventHandler, ScanForCameraNotifier	> {

	
	
    //NOT USED - TO BE REMOVED
    IBOutlet MBP_CamView * camView;
    	IBOutlet MBP_CamListView * camListView; 
    IBOutlet UIView * direcModeWaitView; 
	IBOutlet UIButton * direcModeWaitConnect;
	IBOutlet UIActivityIndicatorView * direcModeWaitProgress;

    AsyncSocket * listenSocket;
	
	int initialFlag;
	NSMutableData *responseData;
    
#if 0 // defined(IRABOT_AUDIO_RECORDING_SUPPORT)
	AsyncSocket * sendingSocket;
	NSMutableData * pcm_data;
	
	
	NSTimer * voice_data_timer;
#endif
    PCMPlayer * pcmPlayer;
    //NSMutableArray * scan_results ;
	//int next_profile_index;
	//BOOL deviceScanInProgress;
    
	BOOL walkie_talkie_enabled;
	AudioOutStreamer * audioOut; 
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

	int current_view_mode; 
	
	HttpCommunication * comm; 
	//MBP_Streamer * streamer; 
	CamChannel * selected_channel; 
	NSTimer * fullScreenTimer; 

	
	UIAlertView * alert;
	NSTimer * alertTimer; 
	
	
	StunCommunication * scomm; 
    
    ///IN USED
    IBOutlet MBP_MainMenuView * mainMenuView;
	IBOutlet UIView * progressView; 
	
	AviRecord* iRecorder;
    
	BOOL toTakeSnapShot ;
	BOOL recordInProgress;
	
	int iMaxRecordSize;
	NSString * iFileName;
	
	NSString * bc_addr;
	NSString * own_addr;

    
    BOOL shouldReloadWhenEnterBG;
    NSArray * channel_array; 
	NSMutableArray * restored_profiles ; 

    
    IBOutlet UIView * backgroundView; 
    IBOutlet UIView * statusDialogView;
    IBOutlet UILabel * statusDialogLabel;
    IBOutlet UITextView * statusDialogText;
    

	
}
@property (nonatomic, retain) IBOutlet UIButton *direcModeWaitConnect; 
@property (nonatomic, retain) IBOutlet UIView * progressView, * direcModeWaitView; 
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * direcModeWaitProgress;
@property (nonatomic,retain) 	IBOutlet MBP_CamListView * camListView; 
@property (nonatomic,retain) IBOutlet MBP_CamView * camView; 
@property (nonatomic,retain) IBOutlet MBP_MainMenuView * mainMenuView;

@property (nonatomic,retain) HttpCommunication *comm;

//@property (nonatomic,retain) NSMutableArray * scan_results ;
//@property (nonatomic) int next_profile_index;

@property (nonatomic) BOOL toTakeSnapShot, recordInProgress, shouldReloadWhenEnterBG;
@property (nonatomic, retain) NSString * bc_addr, *own_addr;

@property (nonatomic, retain) NSArray * channel_array; 
@property (nonatomic, retain) NSMutableArray * restored_profiles ;
//@property (nonatomic, retain) MBP_Streamer * streamer; 

@property (nonatomic, retain) NSTimer * fullScreenTimer, *alertTimer; 
@property (nonatomic, retain) StunCommunication * scomm; 


- (void) initialize ;

- (IBAction) sideMenuButtonClicked:(id) sender;
- (IBAction) mainMenuButtonClicked:(id) sender;

-(void) startConnect;
- (void) scan_for_devices;
-(void) scan_for_devices_done:(NSMutableArray *) scan_results ;

//-(void) switchToSingleCameraMode:(int) channel_number;

- (void) setupDirectModeCamera; 
- (void) disconnectRabot;

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;

+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip;



- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout;
- (void ) requestURLSync_bg:(NSString*)url;

- (void) PlayPCM:(NSData*)pcm;

- (void) onMelody: (UIButton*) sender;
- (void) set_Melody_bg: (NSString *) status;

- (void)wakeup_display_main_cam:(NSTimer*) timer_exp;




- (void) takeSnapShot:(UIImage *) image;
- (void) startRecording;
- (void) stopRecording;
- (void) handleLongPress: (UIGestureRecognizer *) sender;


- (BOOL) toggle_walkie_talkie;
- (void) set_Walkie_Talkie_bg: (NSString *) status;

- (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToRect:(CGRect)newRect;



- (void) updateVerticalDirection:(int)dir inStep: (uint) step withAnimation:(BOOL) animate;
- (void) updateVerticalDirection_begin:(int)dir inStep: (uint) step;
- (void) updateVerticalDirection_end:(int)dir inStep: (uint) step;

- (void) updateHorizontalDirection:(int)dir inStep: (uint) step withAnimation:(BOOL) animate;
- (void) updateHorizontalDirection_begin:(int)dir inStep: (uint) step;
- (void) updateHorizontalDirection_end:(int)dir inStep: (uint) step;

- (void) send_UD_dir_to_rabot:(int) direction;
- (void) send_LR_dir_to_rabot:(int) direction;
/* added to accommodate more delay for the first time detecting
 direction change */
- (void) v_directional_change_callback:(NSTimer *) timer_exp;
- (void) h_directional_change_callback:(NSTimer *) timer_exp;


- (BOOL) restoreConfigData;
- (void) get_current_melody:  (UIButton*)sender updateIcons: (NSArray*) img_array;
- (void) set_current_melody_status:  (UIImageView*)sender updateIcons: (NSArray*) img_array;
- (void) update_battery_and_wifi:(Byte) wifi_and_battery;



-(void) startShowingCameraList;


- (void) channelSelect: (UIGestureRecognizer *) sender;
-(void) setupInfraCamera:(CamChannel *) ch;

- (IBAction) cameraListButtonClicked:(id) sender;
-(void) tryToShowFullScreen;
- (void) showFullScreenNow: (NSTimer*) exp;
- (void) showSideMenusAndStatus;
- (void) showJoysticksOnly;
- (IBAction) sideMenuButtonPressed:(id) sender;
- (void) updateBatteryIcon;
//delegate
- (void)sendConfiguration:(DeviceConfiguration *) conf;
- (void)sendStatus:(int) status;

-(void) waitForDirectCamera:(NSTimer *) exp;

-(void) remoteConnectionFailed:(CamChannel *) camChannel;
-(void) remoteConnectionSucceeded:(CamChannel *) camChannel;
-(void) prepareToViewRemotely:(CamChannel *) ch;
-(void) periodicPopup:(NSTimer *) exp;

-(void) stopPeriodicPopup;
@end

